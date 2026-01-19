import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../utils/date_converter.dart';
import '../../../../utils/klog.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../routes/app_pages.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../appointment/controllers/appointment_controller.dart';
import '../../appointment/models/appointment_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../item/controllers/item_controller.dart';
import '../../item/models/item_list_model.dart';
import '../../signature/controllers/signature_controller.dart';
import '../models/qbo_class_dropdown_model.dart';
import '../models/qbo_location_dropdown_model.dart';
import '../models/tax_model.dart';

class InvoiceController extends GetxController with ExceptionHandler {
  // Dropdown values  @override
  void onInit() {
    super.onInit();
    getQBOClasses();
    getQBOLocations();
    // Load immediately when controller is created
  }

  final selectedLocation = Rx<QboLocationModel?>(null);
  final selectedClass = Rx<QboClassModel?>(null);

  final isLocAndClassShow = RxBool(true);
  // Checkbox
  var isNoneSelected = false.obs;

  // Dropdown options (example)
  // final List<String> locations = ["location 1", "location 2", "location 3"];
  // final List<String> classes = ["class 1", "class 2", "class 3"];

  late final WebViewController webController;
  bool isWebControllerInitialized = false;
  RxBool isSendXPayLink = false.obs;
  final ScrollController scrollController = ScrollController();
  final xpayLinkLoading = RxBool(false);
  Future<void> paymentViaXpayLink() async {
    try {
      xpayLinkLoading(true);
      var companyID = await MySharedPref.getCompanyID();
      var userName = await MySharedPref.getUserName();
      final body = {
        'companyId': companyID,
        'customerId': customerID,
        'invoiceId': invoiceNumber,
        'customerName': customerName,
        'email': userName,
        'amount': total.value, // or '10' if the API expects string
      };
      var response = await DioClient()
          .get(url: ApiUrl.xpayLink, params: body)
          .catchError(handleError);

      if (response == null) return;
      log("Xpay Link Response: $response");
      log("Xpay Link body: $body");
      if (response['XPayLink'] != '') {
        log(
          "XPayLink: ${response['XPayLink']} and condition = ${response['XPayLink'] != ''} ",
        );
        await initializeWebXpayLinkController(response['XPayLink']);
        Get.toNamed(Routes.X_PAY_LINK_WEB);
      } else {
        MySnackBar.showErrorToast(message: "Failed to fetch payment.");
      }
    } catch (e, s) {
      log("Error fetching tax: $e");
      log("Error stack trace: $s");
      MySnackBar.showErrorToast(message: "Failed to fetch payment.");
    } finally {
      xpayLinkLoading(false);
    }
  }

  Future<void> initializeWebController(String amount) async {
    if (isWebControllerInitialized) {
      return;
    }
    var companyID = await MySharedPref.getCompanyID();
    var userID = await MySharedPref.getUserName();

    var platform = Platform.isIOS ? "iOS" : "Android";
    final url =
        "https://paymentportal.xceleran.com/webterminal/Clearent/AppCCPayment_CL.aspx?appname=cec&device=$platform&cid=$companyID&uid=$userID&inv=$invoiceNumber&amount=$amount";

    Logger().i('WebView URL: $url');
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            isLoading.value = true;
            Logger().i('Page started: $url');
          },
          onPageFinished: (url) {
            isLoading.value = false;
            webController.runJavaScript("""
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = 'width=device-width, initial-scale=.8, maximum-scale=1.0 user-scalable=no';
      document.getElementsByTagName('head')[0].appendChild(meta);
      document.body.style.zoom = "1"; 
    """);
            Logger().i('Page finished: $url');
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    isWebControllerInitialized = true;
  }

  Future<void> initializeWebXpayLinkController(String url) async {
    if (isWebControllerInitialized) {
      return;
    }

    log('WebView URL: $url');
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // Logger().i('Page started: $url');
          },
          onPageFinished: (url) {
            // Logger().i('Page finished: $url');
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    isWebControllerInitialized = true;
  }

  List<Map<String, String>> createTypes = [
    {"name": "Invoice", "value": "1"},
    {"name": "Estimate", "value": "2"},
  ];
  RxString selectedCreateType = "Invoice".obs;

  final authController = Get.put(AuthController());
  final signatureController = Get.put(SignatureGetxController());
  final itemController = Get.put(ItemController());
  final TextEditingController itemSearchController = TextEditingController();
  final TextEditingController noteTextController = TextEditingController();
  final TextEditingController editNoteTextController = TextEditingController();
  final TextEditingController toTextController = TextEditingController();
  final TextEditingController bccTextController = TextEditingController();
  final TextEditingController subjectTextController = TextEditingController();
  final TextEditingController emailBodyTextController = TextEditingController();
  final TextEditingController cashAmtTextController = TextEditingController();
  final TextEditingController checkAmtTextController = TextEditingController();
  final TextEditingController checkNameTextController = TextEditingController();
  final TextEditingController checkNumberTextController =
      TextEditingController();
  // List<TextEditingController> quantityControllers = [];
  // List<TextEditingController> amountControllers = [];
  // List<TextEditingController> descriptionControllers = [];
  // List<TextEditingController> editQuantityControllers = [];
  // List<TextEditingController> editAmountControllers = [];
  // List<TextEditingController> editDescriptionControllers = [];
  final TextEditingController createDiscountTextController =
      TextEditingController();
  final TextEditingController editDiscountTextController =
      TextEditingController();
  RxString showingDate = "".obs;
  RxString finalCollectionAmount = "".obs;
  String createCustomerName = "";
  String createCustomerAddress = "";
  String createCustomerPhone = "";
  String createCustomerEmail = "";
  RxString customerID = "".obs;
  String invoiceNumber = "";
  RxString invoiceID = "".obs;
  String customerName = "";
  String address = "";
  RxString type = "".obs;
  String date = "";
  RxBool isConverted = false.obs;
  String subtotal = "";
  String discount = "";
  RxString tax = "0.00".obs;
  RxString total = "".obs;
  RxString newTotal = "".obs;
  String appointmentID = "";
  String paid = "";
  String status = "";
  String due = "";
  RxBool isApplyingSurcharge = false.obs;
  String notes = "";
  RxInt selectedInvoiceIndex = 0.obs;
  RxBool isInvoiceEmpty = false.obs;
  RxString selectedTaxName = "".obs;
  RxString selectedDiscountOption = "2".obs;
  List discountOptions = [
    {"name": "Fixed", "value": "2"},
    {"name": "Percentage", "value": "1"},
  ];
  RxString initialTaxID = "".obs;
  void toggleBlockStatus(bool isBlocked) {
    isApplyingSurcharge.value = isBlocked;
  }

  RxDouble invoiceDiscountDetails = 0.00.obs;

  RxString invoiceTotal = "0.00".obs;
  RxDouble invoiceSubtotal = 0.00.obs;

  RxDouble invoiceTax = 0.00.obs;
  RxString selectedTaxID = "".obs;
  RxDouble invoiceDiscount = 0.00.obs;

  RxDouble discountedTaxableTotalInEdit = 0.00.obs;
  RxDouble discountedTaxableTotalInCreate = 0.00.obs;
  RxDouble amountAfterDiscount = 0.00.obs;
  final isDirty = false.obs;

  // Call this whenever a change is made
  void markAsDirty() {
    isDirty.value = true;
  }

  RxDouble get subTotal {
    RxDouble amount = 0.0.obs;
    for (var element in selectedItemList) {
      amount.value += element.totalPrice;
    }
    return amount;
  }

  RxDouble get discountAmounts {
    RxDouble amount = 0.0.obs;
    if (createDiscountTextController.text.isEmpty) {
      return 0.0.obs;
    }
    if (selectedDiscountOption.value == "1") {
      amount(
        (subTotal * double.parse(createDiscountTextController.text) / 100),
      );
    } else {
      amount(double.parse(createDiscountTextController.text));
    }
    return amount;
  }

  RxDouble get amountAfterDiscounts {
    RxDouble amount = 0.0.obs;
    amount(subTotal.value - discountAmounts.value);

    return amount;
  }

  RxDouble get totalAmountWithSurcharge {
    RxDouble amount = 0.0.obs;
    if (!isApplyingSurcharge.value) {
      return amountAfterDiscounts;
    } else {
      amount(amountAfterDiscounts.value + (amountAfterDiscounts * 3 / 100));
      return amount;
    }
  }

  //final amount
  RxDouble get amountAfterAddingTax {
    RxDouble amount = 0.0.obs;
    amount(totalAmountWithSurcharge.value + taxAmount.value);

    return amount;
  }

  RxDouble get nonTaxableTotalInDetails {
    RxDouble total = 0.0.obs;
    if (!selectedItemList.any((item) => item.selectedItem!.isTaxable == true)) {
      // If no taxable items, return the subtotal minus discount
      total.value = invoiceSubtotal.value - invoiceDiscount.value;
      return total;
    } else {
      for (int i = 0; i < selectedItemList.length; i++) {
        final item = selectedItemList[i];
        if (item.selectedItem!.isTaxable == false) {
          final qty = item.quantity;
          final price = item.totalPrice;
          total.value += price * (qty ?? 1);
        }
      }
      return total;
    }
  }

  RxDouble get nonTaxableItemTotalInCreate {
    RxDouble total = 0.0.obs;
    if (!selectedItemList.any((item) => item.selectedItem!.isTaxable == true)) {
      // If no taxable items, return the subtotal minus discount
      total.value = invoiceSubtotal.value - invoiceDiscount.value;
      return total;
    } else {
      for (int i = 0; i < selectedItemList.length; i++) {
        final item = selectedItemList[i];
        if (item.selectedItem!.isTaxable == false) {
          final price = item.totalPrice;
          final qty = item.quantity ?? 1;
          total.value += price * qty;
        }
      }
      return total;
    }
  }

  RxDouble get taxableTotal {
    RxDouble amount = 0.0.obs;
    if (selectedItemList.isEmpty) {
      return 0.0.obs;
    }
    for (var element in selectedItemList) {
      if (element.selectedItem!.isTaxable ?? false) {
        amount.value += element.totalPrice;
      }
    }

    return amount;
  }

  RxDouble get discountedTaxableTotal {
    RxDouble amount = 0.0.obs;
    if (selectedItemList.isEmpty) {
      return 0.0.obs;
    }
    for (var element in selectedItemList) {
      if (element.selectedItem!.isTaxable ?? false) {
        amount.value += element.totalPrice;
      }
    }

    if (amount > 0.0) {
      if (selectedDiscountOption.value == '2') {
        double discount = double.parse(
          createDiscountTextController.text.isEmpty
              ? "0.00"
              : createDiscountTextController.text,
        );
        amount.value -= discount;
      } else {
        double discount = double.parse(
          createDiscountTextController.text.isEmpty
              ? "0.00"
              : createDiscountTextController.text,
        );
        amount.value -= (amount.value * discount / 100);
      }
    }
    return amount;
  }

  RxDouble get taxAmount {
    RxDouble amount = 0.0.obs;
    amount(discountedTaxableTotal.value * (double.parse(tax.value) / 100));
    return amount;
  }

  // RxDouble totalChargedToCC = 0.0.obs;
  // void createTotal() {
  //   double subTotal = 0.00;
  //   for (int i = 0; i < selectedItemList.length; i++) {
  //     subTotal += selectedItemList[i].totalPrice;
  //   }
  //   invoiceSubtotal.value = subTotal;

  //   // Discount
  //   double discount = double.parse(createDiscountTextController.text.isEmpty
  //       ? "0.00"
  //       : createDiscountTextController.text);
  //   double discountAmount = selectedDiscountOption.value == "1"
  //       ? (subTotal * discount / 100)
  //       : discount;
  //   invoiceDiscount.value = discountAmount;
  //   amountAfterDiscount.value = subTotal - discountAmount;

  //   // Non-taxable handling
  //   double nonTaxable = nonTaxableItemTotalInCreate.value;
  //   double taxableSubTotal = subTotal - nonTaxable;

  //   // Discount on taxable portion
  //   double discountRatio = (subTotal != 0) ? discountAmount / subTotal : 0;
  //   double taxableDiscountAmount = taxableSubTotal * discountRatio;
  //   double discountedTaxableTotal = taxableSubTotal - taxableDiscountAmount;

  //   discountedTaxableTotalInCreate.value = discountedTaxableTotal;

  //   // Tax calculation
  //   double taxPercentage = double.parse(tax.value);
  //   double taxOnTaxableTotal = discountedTaxableTotal * (taxPercentage / 100);
  //   invoiceTax.value = double.parse((taxOnTaxableTotal).toStringAsFixed(2));

  //   // Final invoice total (before surcharge)
  //   double invoiceTotalBeforeSurcharge =
  //       amountAfterDiscount.value + taxOnTaxableTotal;
  //   invoiceTotal.value = invoiceTotalBeforeSurcharge.toStringAsFixed(2);

  //   // >>> SURCHARGE CALCULATION (After final invoice total) <<<
  //   double surchargeAmount = 0.0;
  //   if (isApplyingSurcharge.value) {
  //     surchargeAmount =
  //         invoiceTotalBeforeSurcharge * 0.03; // 3% of final invoice total
  //   }
  //   surcharges.value = surchargeAmount;

  //   // Total charged to credit card (invoice total + surcharge)
  //   totalChargedToCC.value = invoiceTotalBeforeSurcharge + surchargeAmount;
  // }

  void createTotalForEdit() {
    double subTotal = 0.00;
    for (int i = 0; i < selectedItemList.length; i++) {
      double price = selectedItemList[i].totalPrice;
      double quantity = selectedItemList[i].quantity ?? 1.00;
      subTotal += quantity * price;
    }
    invoiceSubtotal.value = subTotal;

    double discount = double.parse(
      editDiscountTextController.text.isEmpty
          ? "0.00"
          : editDiscountTextController.text,
    );
    double discountAmount = selectedDiscountOption.value == "1"
        ? (subTotal * discount / 100)
        : discount;
    invoiceDiscount.value = discountAmount;
    amountAfterDiscount.value = subTotal - discountAmount;

    double nonTaxable = nonTaxableTotalInDetails.value;
    double taxableSubTotal = subTotal - nonTaxable;

    double discountRatio = (subTotal != 0) ? discount / subTotal : 0;
    double discountedTaxableTotal = selectedDiscountOption.value == "1"
        ? taxableSubTotal * (discount / 100)
        : taxableSubTotal * discountRatio;

    discountedTaxableTotalInEdit.value =
        taxableSubTotal - discountedTaxableTotal;

    double taxPercentage = double.parse(tax.value);
    double taxOnTaxableTotal =
        discountedTaxableTotalInEdit.value * (taxPercentage / 100);
    invoiceTax.value = double.parse((taxOnTaxableTotal).toStringAsFixed(2));

    // >>> SURCHARGE <<<
    double surchargeAmount = 0.0;
    if (isApplyingSurcharge.value) {
      surchargeAmount = amountAfterDiscount.value * 0.03;
    }
    // surcharges.value = surchargeAmount;

    double total =
        amountAfterDiscount.value + taxOnTaxableTotal + surchargeAmount;
    invoiceTotal.value = total.toStringAsFixed(2);
  }

  void removeItem(int index) {
    selectedItemList.removeAt(index);

    // amountControllers[index].dispose();
    // descriptionControllers[index].dispose();
    // quantityControllers[index].dispose();

    // amountControllers.removeAt(index);
    // descriptionControllers.removeAt(index);
    // quantityControllers.removeAt(index);

    // createTotal();
  }

  final removedList = RxList<String>([]);
  void removeItemFromEdit(int index) {
    removedList.add(selectedItemList[index].selectedItem!.id!);
    selectedItemList.removeAt(index);

    // editAmountControllers[index].dispose();
    // editDescriptionControllers[index].dispose();
    // editQuantityControllers[index].dispose();

    // editAmountControllers.removeAt(index);
    // editDescriptionControllers.removeAt(index);
    // editQuantityControllers.removeAt(index);

    createTotalForEdit();
    updateRequestedDepositAmount();
  }

  void clearAllItems() {
    // for (var controller in descriptionControllers) {
    //   controller.dispose();
    // }
    // for (var controller in amountControllers) {
    //   controller.dispose();
    // }
    // for (var controller in quantityControllers) {
    //   controller.dispose();
    // }

    selectedItemList.clear();
    // descriptionControllers.clear();
    // amountControllers.clear();
    // quantityControllers.clear();

    invoiceSubtotal.value = 0.00;
    invoiceTax.value = 0.00;
    invoiceDiscount.value = 0.00;
    invoiceTotal.value = "0.00";

    noteTextController.clear();
    createDiscountTextController.clear();
    selectedDiscountOption.value = "1";
    selectedTaxName.value = "";
    tax.value = "0.00";
    isApplyingSurcharge.value = false;

    // createTotal();
  }

  /// API ///
  final invoiceItemList = RxList<Items>();
  final depositList = RxList<Payment>();

  final taxes = RxList<TaxModel>();
  Future<void> getTax() async {
    var companyID = await MySharedPref.getCompanyID();
    var response = await DioClient().get(
        url: ApiUrl.getTax,
        params: {"CompanyId": companyID}).catchError(handleError);

    if (response == null) return;

    taxes.assignAll(
      (response as List).map((e) => TaxModel.fromJson(e)).toList(),
    );

    await MyHive.saveTax(taxes);
    var savedTax = MyHive.getAllTax();
    taxes.assignAll(savedTax);
  }

  final qboClassList = RxList<QboClassModel>([]);
  final selectedQboClass = Rx<QboClassModel?>(null);
  final isLoadingQboClass = RxBool(false);
  final qboLocationList = RxList<QboLocationModel>([]);
  final selectedQboLocation = Rx<QboLocationModel?>(null);
  Future<void> getQBOLocations() async {
    try {
      var companyID = await MySharedPref.getCompanyID();

      var response = await DioClient().get(
          url: ApiUrl.getQBOLocationsUrl,
          params: {"companyId": companyID}).catchError(handleError);
      log("all in data $response");
      if (response == null) return;

      // Ensure the response is a list
      if (response is List && response.isNotEmpty) {
        qboLocationList.value =
            response.map((e) => QboLocationModel.fromJson(e)).toList();
      } else {
        qboLocationList.value = [];
        // Get.showSnackbar(GetSnackBar(
        //   title: "No QBO Classes found",
        //   message: '',
        // ));
      }
    } catch (e) {
      log("err $e");

      // Get.showSnackbar(GetSnackBar(
      //   title: "No QBO Classes found",
      //   message: '',
      // ));
    }
  }

  Future<void> getQBOClasses() async {
    try {
      var companyID = await MySharedPref.getCompanyID();

      var response = await DioClient().get(
          url: ApiUrl.getQBOClassesUrl,
          params: {"companyId": companyID}).catchError(handleError);
      log("all in data $response");
      if (response == null) return;

      // Ensure the response is a list
      if (response is List && response.isNotEmpty) {
        qboClassList.value =
            response.map((e) => QboClassModel.fromJson(e)).toList();
      } else {
        qboClassList.value = [];
        // Get.showSnackbar(GetSnackBar(
        //   title: "No QBO Classes found",
        //   message: '',
        // ));
      }
    } catch (e) {
      log("err $e");

      // Get.showSnackbar(GetSnackBar(
      //   title: "No QBO Classes found",
      //   message: '',
      // ));
    }
  }

  RxString invoiceName = "".obs;
  Future<void> getInvoiceName() async {
    var companyID = await MySharedPref.getCompanyID();
    var response = await DioClient().get(
      url: ApiUrl.getInvoiceName,
      params: {
        "CompanyId": companyID,
        "IsInvoice": selectedCreateType.value == "Invoice" ? true : false,
      },
    ).catchError(handleError);
    kLog("invoice name response $response");
    if (response == null) return;

    invoiceName.value = response["InvoiceNo"];
  }

  void showEmptyWidget() {
    isInvoiceEmpty.value = true;
  }

  final RxBool isLoading = true.obs;
  final selectedItemList = RxList<SelectedItemListModel>([]);

  RxBool isInvoiceSaved = false.obs;
  Future<bool> createInvoice() async {
    showLoading();
    var companyID = await MySharedPref.getCompanyID();
    var userID = await MySharedPref.getUserName();
    isInvoiceSaved.value = false;
    var response = await DioClient().post(
      url: ApiUrl.createInvoice,
      body: {
        "invoice": {
          "Number": invoiceName.value,
          "CompanyID": "",
          "CompnyID": companyID,
          "DisplayNumber": null,
          "CustomerId": customerID.value,
          "UserId": userID,
          "Subtotal": subTotal.value,
          "Discount": invoiceDiscount.value,
          "QboClassId": selectedQboClass.value?.qboClassId ?? 0,
          "QboLocationId": selectedQboLocation.value?.qboLocationId ?? 0,

          "Tax": taxAmount.toStringAsFixed(2),

          "Total": amountAfterAddingTax.toStringAsFixed(2),
          "Status": 1,
          "InvoiceType": null,
          "ModifiedDate": null,
          "ModifiedBy": null,
          "Note": noteTextController.text,
          "CreatedDate": dateTimeConverter(
            inputTime: DateTime.now().toString(),
            outputFormat: "yyyy/MM/dd",
          ),
          "CreatedBy": userID,
          "InvoiceDate": dateTimeConverter(
            inputTime: DateTime.now().toString(),
            outputFormat: "yyyy/MM/dd",
          ),
          "AmountCollect": 0.00,
          "TaxType": selectedTaxID.value,
          "AppointmentId": appointmentID,
          "Type": selectedCreateType.value,
          "QboId": 0,

          "DiscountRate": createDiscountTextController.text,
          "DiscountOption": selectedDiscountOption.value,
          "QboEstimateId": 0,
          "ExpirationDate": null,
          "SyncToken": "0",
          "QboPaymentID": "0",
          "DepositAmount": 0.00,
          "LoanStatus": null,
          "IsConverted": false,
          "ConvertedInvocieID": "",
          "ConvertedInvocieNumber": null,
          "items": selectedItemList.map((item) {
            return {
              ...item.selectedItem!.toJson(),
              "IsTaxable": item.selectedItem!.isTaxable == true ? "TAX" : "NON",
              "Quantity": item.quantity,
              "UnitPrice":
                  item.selectedItem!.price?.toStringAsFixed(2) ?? "0.00",
              "TotalPrice": item.totalPrice,
              // "ItemTyId": item.itemTypeId ?? "",
              "ItemId": item.selectedItem!.id ?? "",
            };
          }).toList(),

          /// There will be item
        },
      },
    ).catchError(handleError);

    if (response == null) return false;

    invoiceID.value = response["Id"].toString();

    isInvoiceSaved.value = true;
    await getInvoiceName();
    clearAllItems(); //
    isNoneSelected(false);
    await Get.find<AppointmentController>().getAppointments(showLoader: false);
    // hideLoading();
    MySnackBar.showToast(
      message: "${selectedCreateType.value} created successfully!",
    );

    return true;
  }

  RxList<File> selectedFiles = <File>[].obs;

  RxList<File> docFileList = <File>[].obs;

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();

      selectedFiles.addAll(
        files.where((file) => !selectedFiles.any((f) => f.path == file.path)),
      );

      docFileList = RxList.from(selectedFiles); // Update docFileList for upload
    }
  }

  RxBool depositRequestPay = false.obs;
  final TextEditingController requestedDepositAmountEditTextController =
      TextEditingController();
  final TextEditingController requestDepositRateEditTextController =
      TextEditingController();
  RxBool convertToInvoice = false.obs;
  void updateRequestedDepositAmount() {
    final rate =
        double.tryParse(requestDepositRateEditTextController.text) ?? 0.0;
    final total = ((invoiceSubtotal.value - invoiceDiscount.value) -
                nonTaxableTotalInDetails.value) *
            (double.tryParse(tax.value) ?? 0) /
            100 +
        ((invoiceSubtotal.value) - (invoiceDiscount.value));
    final depositAmount =
        ((total - double.parse(this.depositAmount.value)) * rate / 100)
            .toStringAsFixed(2);
    requestedDepositAmountEditTextController.text = depositAmount;
  }

  RxString selectedDepositRequestOption = "0".obs; // percentage
  RxString selectedDepositRequestOptionName = "No Deposit Request".obs;
  List depositRequestOptions = [
    {"name": "No Request", "value": "0"},
    {"name": "Requested Deposit Amount:(%)", "value": "1"},
    {"name": "Requested Deposit Amount:(\$)", "value": "2"},
  ];

  Future<void> editInvoice() async {
    showLoading();
    var companyID = await MySharedPref.getCompanyID();
    var userID = await MySharedPref.getUserName();
    var response = await DioClient().post(
      url: ApiUrl.editInvoice,
      body: {
        "invoice": {
          "InvoiceID": invoiceID.value,
          "Number": invoiceNumber,
          "ConvertedInvocieID": "",
          "CompanyID": "",
          "CompnyID": companyID,
          "DisplayNumber": null,
          "CustomerId": customerID.value,
          "UserId": userID,
          "Subtotal": invoiceSubtotal.value,
          "Discount": invoiceDiscount.value,
          "Tax": double.parse(invoiceTax.value.toStringAsFixed(2)),
          "Total": double.parse(invoiceTotal.value).toStringAsFixed(2),
          "Status": 1,
          "InvoiceType": null,
          "ModifiedBy": null,
          "QboClassId": selectedQboClass.value?.qboClassId,
          "QboLocationId": selectedQboLocation.value?.qboLocationId,
          "Note": editNoteTextController.text,
          "CreatedBy": userID,
          "InvoiceDate": dateTimeConverter(
            inputTime: date,
            inputFormat: "MM/dd/yyyy",
            outputFormat: "yyyy/MM/dd",
          ),
          "ModifiedDate": dateTimeConverter(
            inputTime: DateTime.now().toString(),
            outputFormat: "yyyy/MM/dd",
          ),
          "RequestedDepositAmount":
              requestedDepositAmountEditTextController.text,
          "RequestedDepositPercentage":
              selectedDepositRequestOption.value == "2"
                  ? "0.00"
                  : requestDepositRateEditTextController.text,
          "RequestedAmtType": int.parse(selectedDepositRequestOption.value),
          "TaxType": initialTaxID.value,
          "AppointmentId": appointmentID,
          "Type": type.value,
          "QboId": 0,
          "DiscountRate": editDiscountTextController.text,
          "DiscountOption": selectedDiscountOption.value,
          "QboEstimateId": 0,
          "ExpirationDate": null,
          "SyncToken": "",
          "QboPaymentID": "",
          "AmountCollect": double.parse(
            depositAmount.value,
          ).toStringAsFixed(2),
          "DepositAmount": double.parse(
            depositAmount.value,
          ).toStringAsFixed(2),
          "LoanStatus": null,
          "IsConverted": false,
          "items": selectedItemList.map((item) {
            return {
              ...item.selectedItem!.toJson(),
              "IsTaxable": item.selectedItem!.isTaxable == true ? "TAX" : "NON",
              "Quantity": item.quantity,
              "UnitPrice":
                  item.selectedItem!.price?.toStringAsFixed(2) ?? "0.00",
              "TotalPrice": item.totalPrice,
              // "ItemTyId": item.itemTypeId ?? "",
              "ItemId": item.selectedItem!.id ?? "",
            };
          }).toList(),
        },
      },
    ).catchError(handleError);

    if (response == null) return;
    if (convertToInvoice.value) {
      await convertEstimate();
      convertToInvoice.value = false;
      isConverted.value = true;
    }
    isDirty.value = false;
    hideLoading();
    await Get.find<AppointmentController>().getAppointments();
  }

  Future<void> convertEstimate() async {
    var companyID = MySharedPref.getCompanyID();
    var userID = MySharedPref.getUserName();
    var response = await DioClient().post(
      url: ApiUrl.convertEST,
      body: {
        "invoiceId": invoiceID.value,
        "modifiedBy": userID,
        "companyId": companyID,
      },
    ).catchError(handleError);
    if (response == null) return;
  }

  RxString customerFirstName = "".obs;

  Future<void> getEmailAutofill({required String emailType}) async {
    showLoading();
    var companyID = await MySharedPref.getCompanyID();
    var companyName = await MySharedPref.getCompanyName();
    var response = await DioClient().get(
      url: ApiUrl.emailAutofill,
      params: {"companyId": companyID, "type": emailType},
    ).catchError(handleError);
    if (response == null) return;
    bccTextController.text = response["EmailBCC"] ?? "";
    subjectTextController.text = emailType == "Invoice"
        ? response['InvoiceMailSubject']
        : response['ProposalMailSubject'];
    emailBodyTextController.text = emailType == "Invoice"
        ? (response['InvoiceMailBody'] as String)
            .replaceAll('[First Name]', customerFirstName.value)
            .replaceAll('[Company Name]', companyName)
        : (response['ProposalMailBody'] as String)
            .replaceAll('[First Name]', customerFirstName.value)
            .replaceAll('[Company Name]', companyName);

    hideLoading();
  }

  Future<void> sendEmail({
    required String pdfType,
    required String emailType,
  }) async {
    showLoading();
    var companyID = await MySharedPref.getCompanyID();
    var userID = await MySharedPref.getUserName();

    List<Map<String, dynamic>> emailContents = [];

    for (var file in selectedFiles) {
      List<int> fileBytes = await file.readAsBytes(); // Not base64
      String fileName = file.path.split('/').last;
      String? mimeType =
          lookupMimeType(file.path) ?? "application/octet-stream";

      emailContents.add({
        "FileContent": fileBytes,
        "FileName": fileName,
        "FileType": mimeType,
        "FileUrl": "",
      });
    }

    var response = await DioClient().post(
      url: ApiUrl.sendEmail,
      body: {
        "companyID": companyID,
        "customerID": customerID.value,
        "emailType": "$emailType Email",
        "subject": subjectTextController.text,
        "body": emailBodyTextController.text,
        "recepientToEmail": toTextController.text,
        "recepientCCEmail": "",
        "recepientBCCEmail": bccTextController.text,
        "emailContents": selectedFiles.isEmpty ? [] : emailContents,
        "userId": userID,
        "currentPdfType": pdfType,
        "invoiceNo": invoiceID.value,
        "isSendPaymentLink": isSendXPayLink.value,
      },
    ).catchError(handleError);

    if (response == null) return;

    hideLoading();

    selectedFiles.clear();
    Get.back();
    MySnackBar.showToast(message: response["Message"]);
  }

  RxString depositAmount = "0.00".obs;
  Future<void> makePayment(String type) async {
    var companyID = await MySharedPref.getCompanyID();

    var response = await DioClient().post(
      url: ApiUrl.makePayment,
      body: {
        "payment": {
          "CompanyID": companyID,
          "InvocieId": invoiceID.value,
          "Amount": finalCollectionAmount.value,
          "Type": type,
          "Source": "Xinator BMS",
          "CheckName": checkNameTextController.text,
          "CheckNumber": checkNumberTextController.text,
        },
      },
    ).catchError(handleError);

    if (response == null) return;

    checkNumberTextController.clear();
    checkNameTextController.clear();
    await Get.find<AppointmentController>().getAppointments();

    Get.back();
    Get.back();
    Get.back();
  }

  Future<void> makeDepositPay(String amount, String type) async {
    var companyID = await MySharedPref.getCompanyID();

    var response = await DioClient().post(
      url: ApiUrl.makePayment,
      body: {
        "payment": {
          "CompanyID": companyID,
          "InvocieId": invoiceID.value,
          "Amount": amount.isEmpty ? "0.00" : amount,
          "Type": type,
          "Source": "Xinator BMS",
          "CheckName": checkNameTextController.text,
          "CheckNumber": checkNumberTextController.text,
        },
      },
    ).catchError(handleError);

    if (response == null) return;
    await Get.find<AppointmentController>().getAppointments();
    Get.back();
    Get.back();
    Get.back();
  }

  Future<void> paymentStatus() async {
    showLoading();
    var companyID = await MySharedPref.getCompanyID();
    var uri =
        "https://dev-services.myserviceforce.com/xceleranccportal/webterminal/Clearent/cecCCPaymentStatus.aspx";

    var response = await DioClient().post(url: uri, params: {
      "cid": companyID,
      "invNo": invoiceNumber
    }).catchError(handleError);

    if (response["Status"] != "Success Approved") {
      hideLoading();
      Get.back();
      MySnackBar.showErrorToast(message: "Payment unSuccessful");
      return;
    } else {
      hideLoading();
      await Get.find<AppointmentController>().getAppointments();
      Get.back();
      MySnackBar.showToast(message: "Payment successful");
    }
  }

  @override
  void onReady() async {
    await itemController.getItems();
    isDirty.value = false;
    super.onReady();
  }

  @override
  void dispose() {
    // for (var controller in quantityControllers) {
    //   controller.dispose();
    // }
    // for (var controller in amountControllers) {
    //   controller.dispose();
    // }
    // for (var controller in descriptionControllers) {
    //   controller.dispose();
    // }
    // for (var controller in editQuantityControllers) {
    //   controller.dispose();
    // }
    // for (var controller in editAmountControllers) {
    //   controller.dispose();
    // }
    // for (var controller in editDescriptionControllers) {
    //   controller.dispose();
    // }
    noteTextController.dispose();
    createDiscountTextController.dispose();
    toTextController.dispose();
    bccTextController.dispose();
    subjectTextController.dispose();
    emailBodyTextController.dispose();
    editDiscountTextController.dispose();
    editNoteTextController.dispose();
    cashAmtTextController.dispose();
    checkAmtTextController.dispose();
    checkNameTextController.dispose();
    checkNumberTextController.dispose();

    super.dispose();
  }
}
