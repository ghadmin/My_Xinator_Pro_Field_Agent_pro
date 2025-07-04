import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xinator_fsm_pro/app/modules/appointment/controllers/appointment_controller.dart';
import 'package:xinator_fsm_pro/app/modules/appointment/models/appointment_model.dart';

import '../../../../utils/date_converter.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../item/controllers/item_controller.dart';
import '../../item/models/item_list_model.dart';
import '../models/tax_model.dart';

class InvoiceController extends GetxController with ExceptionHandler {
  late final WebViewController webController;
  bool isWebControllerInitialized = false;
  final ScrollController scrollController = ScrollController();
  Future<void> initializeWebController() async {
    if (isWebControllerInitialized) {
      return;
    }
    var companyID = await MySharedPref.getCompanyID();
    var userID = await MySharedPref.getUserName();
    var platform = Platform.isIOS ? "iOS" : "Android";
    final url =
        "https://dev-services.myserviceforce.com/xceleranccportal/CCPayment.aspx?appname=cec&device=$platform&cid=$companyID&uid=$userID&inv=$invoiceNumber&amount=${finalCollectionAmount.value}";

    Logger().i('WebView URL: $url');
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            Logger().i('Page started: $url');
          },
          onPageFinished: (url) {
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

  List<Map<String, String>> createTypes = [
    {"name": "Invoice", "value": "1"},
    {"name": "Estimate", "value": "2"}
  ];
  RxString selectedCreateType = "Invoice".obs;

  final authController = Get.put(AuthController());
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
  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> amountControllers = [];
  List<TextEditingController> descriptionControllers = [];
  List<TextEditingController> editQuantityControllers = [];
  List<TextEditingController> editAmountControllers = [];
  List<TextEditingController> editDescriptionControllers = [];
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
  String surcharges = "0.00"; // Fixed surcharge amount
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

  RxDouble get nonTaxableTotalInDetails {
    RxDouble total = 0.0.obs;
    if (!selectedItemList.any((item) => item.isTaxable == true)) {
      // If no taxable items, return the subtotal minus discount
      total.value = invoiceSubtotal.value - invoiceDiscount.value;
      return total;
    } else {
      for (int i = 0; i < selectedItemList.length; i++) {
        final item = selectedItemList[i];
        if (item.isTaxable == false) {
          final qty = double.tryParse(editQuantityControllers[i].text) ?? 1.00;
          final price = double.tryParse(editAmountControllers[i].text) ?? 0.00;
          total.value += price * qty;
        }
      }
      return total;
    }
  }

  RxDouble get nonTaxableItemTotalInCreate {
    RxDouble total = 0.0.obs;
    if (!selectedItemList.any((item) => item.isTaxable == true)) {
      // If no taxable items, return the subtotal minus discount
      total.value = invoiceSubtotal.value - invoiceDiscount.value;
      return total;
    } else {
      for (int i = 0; i < selectedItemList.length; i++) {
        final item = selectedItemList[i];
        if (item.isTaxable == false) {
          final price = double.tryParse(amountControllers[i].text) ?? 0.0;
          final qty = int.tryParse(quantityControllers[i].text) ?? 1;
          total.value += price * qty;
        }
      }
      return total;
    }
  }

  void createTotal() {
    double subTotal = 0.00;

    // Calculate subtotal based on selected items
    for (int i = 0; i < selectedItemList.length; i++) {
      double price = double.tryParse(amountControllers[i].text) ??
          selectedItemList[i].price ??
          0.00;
      int quantity = int.tryParse(quantityControllers[i].text) ?? 1;
      subTotal += quantity * price;
    }

    invoiceSubtotal.value = subTotal;

    // Calculate discount
    double discount = double.parse(createDiscountTextController.text.isEmpty
        ? "0.00"
        : createDiscountTextController.text);

    double discountAmount = selectedDiscountOption.value == "1"
        ? (subTotal * discount / 100)
        : discount;

    invoiceDiscount.value = discountAmount;

    // Surcharge
    double surcharge =
        isApplyingSurcharge.value ? double.parse(surcharges) * 0.03 : 0.00;

    double taxPercentage = double.parse(tax.value);

    // New: tax on discount as percentage of discountAmount
    double taxOnDiscount = (subTotal - discountAmount) * (taxPercentage / 100);

    // Final total: subtotal + surcharge - discount + standard tax + tax on discount
    double total = (subTotal + surcharge - discountAmount + taxOnDiscount);

    // Update observable values
    invoiceTax.value = double.parse((taxOnDiscount).toStringAsFixed(2));
    invoiceTotal.value = total.toStringAsFixed(2);
  }

  void createTotalForEdit() {
    double subTotal = 0.00;

    // Calculate subtotal based on selected items
    for (int i = 0; i < selectedItemList.length; i++) {
      double price = double.tryParse(editAmountControllers[i].text) ??
          selectedItemList[i].price ??
          0.00;
      int quantity =
          double.tryParse(editQuantityControllers[i].text)?.toInt() ?? 1;
      subTotal += quantity * price;
    }

    invoiceSubtotal.value = subTotal;

    // Calculate discount
    double discount = double.parse(editDiscountTextController.text.isEmpty
        ? "0.00"
        : editDiscountTextController.text);

    double discountAmount = selectedDiscountOption.value == "1"
        ? (subTotal * discount / 100)
        : discount;

    invoiceDiscount.value = discountAmount;

    // Surcharge
    double surcharge =
        isApplyingSurcharge.value ? double.parse(surcharges) * 0.03 : 0.00;

    double taxPercentage = double.parse(tax.value);

    // New: tax on discount as percentage of discountAmount
    double taxOnDiscount = (subTotal - discountAmount) * (taxPercentage / 100);

    // Final total: subtotal + surcharge - discount + standard tax + tax on discount
    double total = (subTotal + surcharge - discountAmount + taxOnDiscount);

    // Update observable values
    invoiceTax.value = double.parse((taxOnDiscount).toStringAsFixed(2));
    invoiceTotal.value = total.toStringAsFixed(2);
  }

  void removeItem(int index) {
    selectedItemList.removeAt(index);

    amountControllers[index].dispose();
    descriptionControllers[index].dispose();
    quantityControllers[index].dispose();

    amountControllers.removeAt(index);
    descriptionControllers.removeAt(index);
    quantityControllers.removeAt(index);

    createTotal();
  }

  void removeItemFromEdit(int index) {
    selectedItemList.removeAt(index);

    editAmountControllers[index].dispose();
    editDescriptionControllers[index].dispose();
    editQuantityControllers[index].dispose();

    editAmountControllers.removeAt(index);
    editDescriptionControllers.removeAt(index);
    editQuantityControllers.removeAt(index);

    createTotalForEdit();
  }

  void clearAllItems() {
    for (var controller in descriptionControllers) {
      controller.dispose();
    }
    for (var controller in amountControllers) {
      controller.dispose();
    }
    for (var controller in quantityControllers) {
      controller.dispose();
    }

    selectedItemList.clear();
    descriptionControllers.clear();
    amountControllers.clear();
    quantityControllers.clear();

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

    createTotal();
  }

  /// API ///
  final invoiceItemList = RxList<Items>();
  final depositList = RxList<Payment>();

  final taxes = RxList<TaxModel>();
  getTax() async {
    var companyID = await MySharedPref.getCompanyID();
    var response = await DioClient().get(
      url: ApiUrl.getTax,
      params: {
        "CompanyId": companyID,
      },
    ).catchError(handleError);

    if (response == null) return;

    taxes.assignAll(
        (response as List).map((e) => TaxModel.fromJson(e)).toList());
    await MyHive.saveTax(taxes);
    var savedTax = MyHive.getAllTax();
    taxes.assignAll(savedTax);
  }

  RxString invoiceName = "".obs;
  getInvoiceName() async {
    var companyID = await MySharedPref.getCompanyID();
    var response = await DioClient().get(
      url: ApiUrl.getInvoiceName,
      params: {
        "CompanyId": companyID,
        "IsInvoice": selectedCreateType.value == "Invoice" ? true : false,
      },
    ).catchError(handleError);

    if (response == null) return;

    invoiceName.value = response["InvoiceNo"];
  }

  void showEmptyWidget() {
    isInvoiceEmpty.value = true;
  }

  final RxList<ItemListModel> selectedItemList = <ItemListModel>[].obs;

  void selectItem(ItemListModel item) {
    selectedItemList.add(item);
  }

  RxBool isInvoiceSaved = false.obs;
  createInvoice() async {
    showLoading();
    isInvoiceSaved.value = false;
    var companyID = await MySharedPref.getCompanyID();
    var userID = await MySharedPref.getUserName();
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
          "Subtotal": invoiceSubtotal.value,
          "Discount": invoiceDiscount.value,

          "Tax": double.parse(
              (((invoiceSubtotal.value - invoiceDiscount.value) -
                          nonTaxableItemTotalInCreate.value) *
                      (double.tryParse(tax.value) ?? 0) /
                      100)
                  .toStringAsFixed(2)),

          "Total": double.parse(
              ((((invoiceSubtotal.value - invoiceDiscount.value) -
                              nonTaxableItemTotalInCreate.value) *
                          (double.tryParse(tax.value) ?? 0) /
                          100) +
                      (invoiceSubtotal.value - invoiceDiscount.value))
                  .toStringAsFixed(2)),
          "Status": 1,
          "InvoiceType": null,
          "ModifiedDate": null,
          "ModifiedBy": null,
          "Note": noteTextController.text,
          "CreatedDate": dateTimeConverter(
              inputTime: DateTime.now().toString(), outputFormat: "yyyy/MM/dd"),
          "CreatedBy": userID,
          "InvoiceDate": dateTimeConverter(
              inputTime: DateTime.now().toString(), outputFormat: "yyyy/MM/dd"),
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
              ...item.toJson(),
              "IsTaxable": item.isTaxable == true ? "TAX" : "NON",
              "Quantity":
                  quantityControllers[selectedItemList.indexOf(item)].text,
              "UnitPrice": item.price?.toStringAsFixed(2) ?? "0.00",
              "TotalPrice": (item.price != null
                  ? (item.price! *
                          (int.tryParse(quantityControllers[
                                      selectedItemList.indexOf(item)]
                                  .text) ??
                              1))
                      .toStringAsFixed(2)
                  : "0.00"),
              // "ItemTyId": item.itemTypeId ?? "",
              "ItemId": item.id ?? "",
            };
          }).toList()

          /// There will be item
        }
      },
    ).catchError(handleError);

    if (response == null) return;

    invoiceID.value = response["Id"].toString();

    isInvoiceSaved.value = true;
    await getInvoiceName();
    clearAllItems();
    hideLoading();
    await Get.find<AppointmentController>().getAppointments();
    MySnackBar.showToast(
        message: "${selectedCreateType.value} created successfully!");
  }

  RxList<File> selectedFiles = <File>[].obs;

  RxList<File> docFileList = <File>[].obs;

  Future<void> pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();

      selectedFiles.addAll(files
          .where((file) => !selectedFiles.any((f) => f.path == file.path)));

      docFileList = RxList.from(selectedFiles); // Update docFileList for upload
    }
  }

  RxBool convertToInvoice = false.obs;
  editInvoice() async {
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
          "Tax": double.parse(
              (((invoiceSubtotal.value - invoiceDiscount.value) -
                          nonTaxableTotalInDetails.value) *
                      (double.tryParse(tax.value) ?? 0) /
                      100)
                  .toStringAsFixed(2)),
          "Total": double.parse(
              ((((invoiceSubtotal.value - invoiceDiscount.value) -
                              nonTaxableTotalInDetails.value) *
                          (double.tryParse(tax.value) ?? 0) /
                          100) +
                      (invoiceSubtotal.value - invoiceDiscount.value))
                  .toStringAsFixed(2)),
          "Status": 1,
          "InvoiceType": null,
          "ModifiedBy": null,
          "Note": editNoteTextController.text,
          "CreatedBy": userID,
          "InvoiceDate": dateTimeConverter(
              inputTime: date,
              inputFormat: "MM/dd/yyyy",
              outputFormat: "yyyy/MM/dd"),
          "ModifiedDate": dateTimeConverter(
              inputTime: DateTime.now().toString(), outputFormat: "yyyy/MM/dd"),
          "AmountCollect": 0.00,
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
          "DepositAmount": depositAmount.value,
          "LoanStatus": null,
          "IsConverted": false,
          "items": selectedItemList.map((item) {
            return {
              ...item.toJson(),
              "IsTaxable": item.isTaxable == true ? "TAX" : "NON",
              "Quantity":
                  editQuantityControllers[selectedItemList.indexOf(item)].text,
              "UnitPrice": item.price?.toStringAsFixed(2) ?? "0.00",
              "TotalPrice": (item.price != null
                  ? (item.price! *
                          (int.tryParse(editQuantityControllers[
                                      selectedItemList.indexOf(item)]
                                  .text) ??
                              1))
                      .toStringAsFixed(2)
                  : "0.00"),
              // "ItemTyId": item.itemTypeId ?? "",
              "ItemId": item.id ?? "",
            };
          }).toList()
        }
      },
    ).catchError(handleError);

    if (response == null) return;
    if (convertToInvoice.value) {
      await convertEstimate();
      convertToInvoice.value = false;
      isConverted.value = true;
    }
    hideLoading();
    await Get.find<AppointmentController>().getAppointments();

    MySnackBar.showToast(message: "${type.value} updated successfully!");
  }

  convertEstimate() async {
    var companyID = MySharedPref.getCompanyID();
    var userID = MySharedPref.getUserName();
    var response = await DioClient().post(
      url: ApiUrl.convertEST,
      body: {
        "invoiceId": invoiceID.value,
        "modifiedBy": userID,
        "companyId": companyID
      },
    ).catchError(handleError);
    if (response == null) return;
  }

  RxString customerFirstName = "".obs;

  getEmailAutofill({required String emailType}) async {
    showLoading();
    var companyID = await MySharedPref.getCompanyID();
    var companyName = await MySharedPref.getCompanyName();
    var response = await DioClient().get(url: ApiUrl.emailAutofill, params: {
      "companyId": companyID,
      "type": emailType
    }).catchError(handleError);
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

  sendEmail({required String pdfType, required String emailType}) async {
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
        "FileUrl": ""
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
        "invoiceNo": invoiceID.value
      },
    ).catchError(handleError);

    if (response == null) return;

    hideLoading();
    toTextController.clear();
    bccTextController.clear();
    subjectTextController.clear();
    emailBodyTextController.clear();
    selectedFiles.clear();
    Get.back();
    MySnackBar.showToast(message: response["Message"]);
  }

  RxString depositAmount = "0.00".obs;
  makePayment(String type) async {
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
          "CheckNumber": checkNumberTextController.text
        }
      },
    ).catchError(handleError);

    if (response == null) return;

    checkNumberTextController.clear();
    checkNameTextController.clear();
    // await appointmentController.getAppointments();
    await Get.find<AppointmentController>().getAppointments();

    Get.back();
    Get.back();
    Get.back();

    MySnackBar.showToast(message: response["Message"]);
  }

  paymentStatus() async {
    showLoading();
    var companyID = await MySharedPref.getCompanyID();
    var uri =
        "https://dev-services.myserviceforce.com/xceleranccportal/webterminal/Clearent/cecCCPaymentStatus.aspx";

    var response = await DioClient().post(url: uri, params: {
      "cid": companyID,
      "invNo": invoiceNumber,
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

    super.onReady();
  }

  @override
  void dispose() {
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    for (var controller in amountControllers) {
      controller.dispose();
    }
    for (var controller in descriptionControllers) {
      controller.dispose();
    }
    for (var controller in editQuantityControllers) {
      controller.dispose();
    }
    for (var controller in editAmountControllers) {
      controller.dispose();
    }
    for (var controller in editDescriptionControllers) {
      controller.dispose();
    }
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
