// import 'dart:developer';
// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
// import 'package:mime/mime.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import '../../../../utils/date_converter.dart';
// import '../../../../utils/klog.dart';
// import '../../../components/global-widgets/my_snackbar.dart';
// import '../../../data/local/hive/my_hive.dart';
// import '../../../data/local/my_shared_pref.dart';
// import '../../../routes/app_pages.dart';
// import '../../../service/REST/api_urls.dart';
// import '../../../service/REST/dio_client.dart';
// import '../../../service/handler/exception_handler.dart';
// import '../../appointment/controllers/appointment_controller.dart';
// import '../../appointment/models/appointment_model.dart';
// import '../../auth/controllers/auth_controller.dart';
// import '../../item/controllers/item_controller.dart';
// import '../../item/models/item_list_model.dart';
// import '../../signature/controllers/signature_controller.dart';
// import '../models/qbo_class_dropdown_model.dart';
// import '../models/qbo_location_dropdown_model.dart';
// import '../models/tax_model.dart';

// class InvoiceController extends GetxController with ExceptionHandler {
//   // Dropdown values  @override
//   void onInit() {
//     super.onInit();
//     getQBOClasses();
//     getQBOLocations();
//     // Load immediately when controller is created
//   }

//   final selectedLocation = Rx<QboLocationModel?>(null);
//   final selectedClass = Rx<QboClassModel?>(null);

//   final isLocAndClassShow = RxBool(true);
//   // Checkbox
//   var isNoneSelected = false.obs;

//   // Dropdown options (example)
//   // final List<String> locations = ["location 1", "location 2", "location 3"];
//   // final List<String> classes = ["class 1", "class 2", "class 3"];

//   late final WebViewController webController;
//   bool isWebControllerInitialized = false;
//   RxBool isSendXPayLink = false.obs;
//   final ScrollController scrollController = ScrollController();
//   final xpayLinkLoading = RxBool(false);
//   Future<void> paymentViaXpayLink() async {
//     try {
//       xpayLinkLoading(true);
//       var companyID = await MySharedPref.getCompanyID();
//       var userName = await MySharedPref.getUserName();
//       final body = {
//         'companyId': companyID,
//         'customerId': customerID,
//         'invoiceId': invoiceNumber,
//         'customerName': customerName,
//         'email': userName,
//         'amount': total.value, // or '10' if the API expects string
//       };
//       var response = await DioClient()
//           .get(url: ApiUrl.xpayLink, params: body)
//           .catchError(handleError);

//       if (response == null) return;
//       log("Xpay Link Response: $response");
//       log("Xpay Link body: $body");
//       if (response['XPayLink'] != '') {
//         log(
//           "XPayLink: ${response['XPayLink']} and condition = ${response['XPayLink'] != ''} ",
//         );
//         await initializeWebXpayLinkController(response['XPayLink']);
//         Get.toNamed(Routes.X_PAY_LINK_WEB);
//       } else {
//         MySnackBar.showErrorToast(message: "Failed to fetch payment.");
//       }
//     } catch (e, s) {
//       log("Error fetching tax: $e");
//       log("Error stack trace: $s");
//       MySnackBar.showErrorToast(message: "Failed to fetch payment.");
//     } finally {
//       xpayLinkLoading(false);
//     }
//   }

//   Future<void> initializeWebController(String amount) async {
//     if (isWebControllerInitialized) {
//       return;
//     }
//     var companyID = await MySharedPref.getCompanyID();
//     var userID = await MySharedPref.getUserName();

//     var platform = Platform.isIOS ? "iOS" : "Android";
//     final url =
//         "${ApiUrl.paymentBaseUrl}?appname=cec&device=$platform&cid=$companyID&uid=$userID&inv=$invoiceNumber&amount=${double.parse(amount).abs().toStringAsFixed(2)}";
//     // "https://dev-services.myserviceforce.com/webterminal/Clearent/AppCCPayment_CL.aspx?appname=cec&device=$platform&cid=$companyID&uid=$userID&inv=$invoiceNumber&amount=${double.parse( amount).abs().toString()}";
//     log('WebView URL: $url');

//     // Logger().i('WebView URL: $url');
//     webController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..enableZoom(true)
//       ..setBackgroundColor(Colors.white)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (url) {
//             isLoading.value = true;
//             Logger().i('Page started: $url');
//           },
//           onPageFinished: (url) {
//             isLoading.value = false;
//             webController.runJavaScript("""
//       var meta = document.createElement('meta');
//       meta.name = 'viewport';
//       meta.content = 'width=device-width, initial-scale=.8, maximum-scale=1.0 user-scalable=no';
//       document.getElementsByTagName('head')[0].appendChild(meta);
//       document.body.style.zoom = "1";
//     """);
//             Logger().i('Page finished: $url');
//           },
//           onNavigationRequest: (request) {
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(url));
//     isWebControllerInitialized = true;
//   }

//   Future<void> initializeWebXpayLinkController(String url) async {
//     if (isWebControllerInitialized) {
//       return;
//     }

//     log('WebView URL: $url');
//     webController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (url) {
//             // Logger().i('Page started: $url');
//           },
//           onPageFinished: (url) {
//             // Logger().i('Page finished: $url');
//           },
//           onNavigationRequest: (request) {
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(url));
//     isWebControllerInitialized = true;
//   }

//   List<Map<String, String>> createTypes = [
//     {"name": "Invoice", "value": "1"},
//     {"name": "Estimate", "value": "2"},
//   ];
//   RxString selectedCreateType = "Invoice".obs;

//   final authController = Get.put(AuthController());
//   final signatureController = Get.put(SignatureGetxController());
//   final itemController = Get.put(ItemController());
//   final TextEditingController itemSearchController = TextEditingController();
//   final TextEditingController noteTextController = TextEditingController();
//   final TextEditingController editNoteTextController = TextEditingController();
//   final TextEditingController toTextController = TextEditingController();
//   final TextEditingController bccTextController = TextEditingController();
//   final TextEditingController subjectTextController = TextEditingController();
//   final TextEditingController emailBodyTextController = TextEditingController();
//   final TextEditingController cashAmtTextController = TextEditingController();
//   final TextEditingController checkAmtTextController = TextEditingController();
//   final TextEditingController checkNameTextController = TextEditingController();
//   final TextEditingController checkNumberTextController =
//       TextEditingController();

//   // Focus nodes for create invoice form
//   final Rx<FocusNode> createInvoiceDiscountFocusnode = FocusNode().obs;
//   final Rx<FocusNode> createInvoiceNotesFocusnode = FocusNode().obs;
//   final Rx<FocusNode> createInvoiceSearchFocusnode = FocusNode().obs;
//   final Rx<FocusNode> createInvoiceEmailToFocusnode = FocusNode().obs;
//   final Rx<FocusNode> createInvoiceEmailBccFocusnode = FocusNode().obs;
//   final Rx<FocusNode> createInvoiceEmailSubjectFocusnode = FocusNode().obs;
//   final Rx<FocusNode> createInvoiceEmailBodyFocusnode = FocusNode().obs;

//   // List<TextEditingController> quantityControllers = [];
//   // List<TextEditingController> amountControllers = [];
//   // List<TextEditingController> descriptionControllers = [];
//   // List<TextEditingController> editQuantityControllers = [];
//   // List<TextEditingController> editAmountControllers = [];
//   // List<TextEditingController> editDescriptionControllers = [];
//   final TextEditingController createDiscountTextController =
//       TextEditingController();
//   final TextEditingController editDiscountTextController =
//       TextEditingController();
//   RxString showingDate = "".obs;
//   RxString finalCollectionAmount = "".obs;
//   String createCustomerName = "";
//   String createCustomerAddress = "";
//   String createCustomerPhone = "";
//   String createCustomerEmail = "";
//   RxString customerID = "".obs;
//   String invoiceNumber = "";
//   RxString invoiceID = "".obs;
//   String customerName = "";
//   String address = "";
//   RxString type = "".obs;
//   String date = "";
//   RxBool isConverted = false.obs;
//   String subtotal = "";
//   String discount = "";
//   RxString tax = "0.00".obs;
//   RxString total = "".obs;
//   RxString newTotal = "".obs;
//   String appointmentID = "";
//   String paid = "";
//   String status = "";
//   String due = "";
//   RxBool isApplyingSurcharge = false.obs;
//   String notes = "";
//   RxInt selectedInvoiceIndex = 0.obs;
//   RxBool isInvoiceEmpty = false.obs;
//   RxString selectedTaxName = "".obs;
//   RxString selectedDiscountOption = "2".obs;
//   List discountOptions = [
//     {"name": "Fixed", "value": "2"},
//     {"name": "Percentage", "value": "1"},
//   ];
//   RxString initialTaxID = "".obs;
//   void toggleBlockStatus(bool isBlocked) {
//     isApplyingSurcharge.value = isBlocked;
//   }

//   RxDouble invoiceDiscountDetails = 0.00.obs;
//   RxDouble discountValue =
//       0.00.obs; // Reactive variable to track discount input

//   RxString invoiceTotal = "0.00".obs;
//   RxDouble invoiceSubtotal = 0.00.obs;

//   RxDouble invoiceTax = 0.00.obs;
//   RxString selectedTaxID = "".obs;
//   RxDouble invoiceDiscount = 0.00.obs;

//   RxDouble discountedTaxableTotalInEdit = 0.00.obs;
//   RxDouble discountedTaxableTotalInCreate = 0.00.obs;
//   RxDouble amountAfterDiscount = 0.00.obs;
//   final isDirty = false.obs;

//   // Call this whenever a change is made
//   void markAsDirty() {
//     isDirty.value = true;
//   }

//   // Unfocus all focus nodes
//   void unfocusAllCreateInvoiceNodes() {
//     createInvoiceDiscountFocusnode.value.unfocus();
//     createInvoiceNotesFocusnode.value.unfocus();
//     createInvoiceSearchFocusnode.value.unfocus();
//     createInvoiceEmailToFocusnode.value.unfocus();
//     createInvoiceEmailBccFocusnode.value.unfocus();
//     createInvoiceEmailSubjectFocusnode.value.unfocus();
//     createInvoiceEmailBodyFocusnode.value.unfocus();
//   }

//   RxDouble get subTotal {
//     RxDouble amount = 0.0.obs;
//     for (var element in selectedItemList) {
//       amount.value += element.totalPrice;
//     }
//     return amount;
//   }

//   RxDouble get discountAmounts {
//     double amount = 0.0;
//     if (discountValue.value == 0.0) {
//       return 0.0.obs;
//     }
//     if (selectedDiscountOption.value == "1") {
//       kLog("Calculating percentage discount");
//       // Percentage discount
//       amount = (subTotal.value * discountValue.value / 100);
//     } else {
//       // Fixed discount
//       amount = discountValue.value;
//     }
//     return amount.obs;
//   }

//   RxDouble get amountAfterDiscounts {
//     return (subTotal.value - discountAmounts.value).obs;
//   }

//   RxDouble get totalAmountWithSurcharge {
//     if (!isApplyingSurcharge.value) {
//       return amountAfterDiscounts;
//     } else {
//       return (amountAfterDiscounts.value +
//               (amountAfterDiscounts.value * 3 / 100))
//           .obs;
//     }
//   }

//   //final amount
//   RxDouble get amountAfterAddingTax {
//     return (totalAmountWithSurcharge.value + taxAmount.value).obs;
//   }

//   RxDouble get nonTaxableTotalInDetails {
//     RxDouble total = 0.0.obs;
//     if (!selectedItemList.any((item) => item.selectedItem!.isTaxable == true)) {
//       // If no taxable items, return the subtotal minus discount
//       total.value = invoiceSubtotal.value - invoiceDiscount.value;
//       return total;
//     } else {
//       for (int i = 0; i < selectedItemList.length; i++) {
//         final item = selectedItemList[i];
//         if (item.selectedItem!.isTaxable == false) {
//           final qty = item.quantity;
//           final price = item.totalPrice;
//           total.value += price * (qty ?? 1);
//         }
//       }
//       return total;
//     }
//   }

//   RxDouble get nonTaxableItemTotalInCreate {
//     RxDouble total = 0.0.obs;
//     if (!selectedItemList.any((item) => item.selectedItem!.isTaxable == true)) {
//       // If no taxable items, return the subtotal minus discount
//       total.value = invoiceSubtotal.value - invoiceDiscount.value;
//       return total;
//     } else {
//       for (int i = 0; i < selectedItemList.length; i++) {
//         final item = selectedItemList[i];
//         if (item.selectedItem!.isTaxable == false) {
//           final price = item.totalPrice;
//           final qty = item.quantity ?? 1;
//           total.value += price * qty;
//         }
//       }
//       return total;
//     }
//   }

//   RxDouble get taxableTotal {
//     RxDouble amount = 0.0.obs;
//     if (selectedItemList.isEmpty) {
//       return 0.0.obs;
//     }
//     for (var element in selectedItemList) {
//       if (element.selectedItem!.isTaxable ?? false) {
//         amount.value += element.totalPrice;
//       }
//     }

//     return amount;
//   }

//   RxDouble get discountedTaxableTotal {
//     RxDouble amount = 0.0.obs;
//     if (selectedItemList.isEmpty) {
//       return 0.0.obs;
//     }
//     for (var element in selectedItemList) {
//       if (element.selectedItem!.isTaxable ?? false) {
//         amount.value += element.totalPrice;
//       }
//     }

//     if (amount > 0.0) {
//       if (selectedDiscountOption.value == '2') {
//         double discount = double.parse(
//           createDiscountTextController.text.isEmpty
//               ? "0.00"
//               : createDiscountTextController.text,
//         );
//         amount.value -= discount;
//       } else {
//         double discount = double.parse(
//           createDiscountTextController.text.isEmpty
//               ? "0.00"
//               : createDiscountTextController.text,
//         );
//         amount.value -= (amount.value * discount / 100);
//       }
//     }
//     return amount;
//   }

//   RxDouble get taxAmount {
//     RxDouble amount = 0.0.obs;
//     amount(discountedTaxableTotal.value * (double.parse(tax.value) / 100));
//     return amount;
//   }

//   // RxDouble totalChargedToCC = 0.0.obs;
//   // void createTotal() {
//   //   double subTotal = 0.00;
//   //   for (int i = 0; i < selectedItemList.length; i++) {
//   //     subTotal += selectedItemList[i].totalPrice;
//   //   }
//   //   invoiceSubtotal.value = subTotal;

//   //   // Discount
//   //   double discount = double.parse(createDiscountTextController.text.isEmpty
//   //       ? "0.00"
//   //       : createDiscountTextController.text);
//   //   double discountAmount = selectedDiscountOption.value == "1"
//   //       ? (subTotal * discount / 100)
//   //       : discount;
//   //   invoiceDiscount.value = discountAmount;
//   //   amountAfterDiscount.value = subTotal - discountAmount;

//   //   // Non-taxable handling
//   //   double nonTaxable = nonTaxableItemTotalInCreate.value;
//   //   double taxableSubTotal = subTotal - nonTaxable;

//   //   // Discount on taxable portion
//   //   double discountRatio = (subTotal != 0) ? discountAmount / subTotal : 0;
//   //   double taxableDiscountAmount = taxableSubTotal * discountRatio;
//   //   double discountedTaxableTotal = taxableSubTotal - taxableDiscountAmount;

//   //   discountedTaxableTotalInCreate.value = discountedTaxableTotal;

//   //   // Tax calculation
//   //   double taxPercentage = double.parse(tax.value);
//   //   double taxOnTaxableTotal = discountedTaxableTotal * (taxPercentage / 100);
//   //   invoiceTax.value = double.parse((taxOnTaxableTotal).toStringAsFixed(2));

//   //   // Final invoice total (before surcharge)
//   //   double invoiceTotalBeforeSurcharge =
//   //       amountAfterDiscount.value + taxOnTaxableTotal;
//   //   invoiceTotal.value = invoiceTotalBeforeSurcharge.toStringAsFixed(2);

//   //   // >>> SURCHARGE CALCULATION (After final invoice total) <<<
//   //   double surchargeAmount = 0.0;
//   //   if (isApplyingSurcharge.value) {
//   //     surchargeAmount =
//   //         invoiceTotalBeforeSurcharge * 0.03; // 3% of final invoice total
//   //   }
//   //   surcharges.value = surchargeAmount;

//   //   // Total charged to credit card (invoice total + surcharge)
//   //   totalChargedToCC.value = invoiceTotalBeforeSurcharge + surchargeAmount;
//   // }

//   void createTotalForEdit() {
//     double subTotal = 0.00;
//     for (int i = 0; i < selectedItemList.length; i++) {
//       double price = selectedItemList[i].totalPrice;
//       double quantity = selectedItemList[i].quantity ?? 1.00;
//       subTotal += quantity * price;
//     }
//     invoiceSubtotal.value = subTotal;

//     double discount = double.parse(
//       editDiscountTextController.text.isEmpty
//           ? "0.00"
//           : editDiscountTextController.text,
//     );
//     double discountAmount = selectedDiscountOption.value == "1"
//         ? (subTotal * discount / 100)
//         : discount;
//     invoiceDiscount.value = discountAmount;
//     amountAfterDiscount.value = subTotal - discountAmount;

//     double nonTaxable = nonTaxableTotalInDetails.value;
//     double taxableSubTotal = subTotal - nonTaxable;

//     double discountRatio = (subTotal != 0) ? discount / subTotal : 0;
//     double discountedTaxableTotal = selectedDiscountOption.value == "1"
//         ? taxableSubTotal * (discount / 100)
//         : taxableSubTotal * discountRatio;

//     discountedTaxableTotalInEdit.value =
//         taxableSubTotal - discountedTaxableTotal;

//     double taxPercentage = double.parse(tax.value);
//     double taxOnTaxableTotal =
//         discountedTaxableTotalInEdit.value * (taxPercentage / 100);
//     invoiceTax.value = double.parse((taxOnTaxableTotal).toStringAsFixed(2));

//     // >>> SURCHARGE <<<
//     double surchargeAmount = 0.0;
//     if (isApplyingSurcharge.value) {
//       surchargeAmount = amountAfterDiscount.value * 0.03;
//     }
//     // surcharges.value = surchargeAmount;

//     double total =
//         amountAfterDiscount.value + taxOnTaxableTotal + surchargeAmount;
//     invoiceTotal.value = total.toStringAsFixed(2);
//   }

//   void removeItem(int index) {
//     selectedItemList.removeAt(index);

//     // amountControllers[index].dispose();
//     // descriptionControllers[index].dispose();
//     // quantityControllers[index].dispose();

//     // amountControllers.removeAt(index);
//     // descriptionControllers.removeAt(index);
//     // quantityControllers.removeAt(index);

//     // createTotal();
//   }

//   final removedList = RxList<String>([]);
//   void removeItemFromEdit(int index) {
//     removedList.add(selectedItemList[index].selectedItem!.id!);
//     selectedItemList.removeAt(index);

//     // editAmountControllers[index].dispose();
//     // editDescriptionControllers[index].dispose();
//     // editQuantityControllers[index].dispose();

//     // editAmountControllers.removeAt(index);
//     // editDescriptionControllers.removeAt(index);
//     // editQuantityControllers.removeAt(index);

//     createTotalForEdit();
//     updateRequestedDepositAmount();
//   }

//   void clearAllItems() {
//     // for (var controller in descriptionControllers) {
//     //   controller.dispose();
//     // }
//     // for (var controller in amountControllers) {
//     //   controller.dispose();
//     // }
//     // for (var controller in quantityControllers) {
//     //   controller.dispose();
//     // }

//     selectedItemList.clear();
//     // descriptionControllers.clear();
//     // amountControllers.clear();
//     // quantityControllers.clear();

//     invoiceSubtotal.value = 0.00;
//     invoiceTax.value = 0.00;
//     invoiceDiscount.value = 0.00;
//     invoiceTotal.value = "0.00";

//     noteTextController.clear();
//     createDiscountTextController.clear();
//     selectedDiscountOption.value = "1";
//     selectedTaxName.value = "";
//     tax.value = "0.00";
//     isApplyingSurcharge.value = false;

//     // createTotal();
//   }

//   /// API ///
//   final invoiceItemList = RxList<Items>();
//   final depositList = RxList<Payment>();

//   final taxes = RxList<TaxModel>();
//   Future<void> getTax() async {
//     var companyID = await MySharedPref.getCompanyID();
//     var response = await DioClient().get(
//         url: ApiUrl.getTax,
//         params: {"CompanyId": companyID}).catchError(handleError);

//     if (response == null) return;

//     taxes.assignAll(
//       (response as List).map((e) => TaxModel.fromJson(e)).toList(),
//     );

//     await MyHive.saveTax(taxes);
//     var savedTax = MyHive.getAllTax();
//     taxes.assignAll(savedTax);
//   }

//   final qboClassList = RxList<QboClassModel>([]);
//   final selectedQboClass = Rx<QboClassModel?>(null);
//   final isLoadingQboClass = RxBool(false);
//   final qboLocationList = RxList<QboLocationModel>([]);
//   final selectedQboLocation = Rx<QboLocationModel?>(null);
//   Future<void> getQBOLocations() async {
//     try {
//       var companyID = await MySharedPref.getCompanyID();

//       var response = await DioClient().get(
//           url: ApiUrl.getQBOLocationsUrl,
//           params: {"companyId": companyID}).catchError(handleError);
//       log("all in data $response");
//       if (response == null) return;

//       // Ensure the response is a list
//       if (response is List && response.isNotEmpty) {
//         qboLocationList.value =
//             response.map((e) => QboLocationModel.fromJson(e)).toList();
//       } else {
//         qboLocationList.value = [];
//         // Get.showSnackbar(GetSnackBar(
//         //   title: "No QBO Classes found",
//         //   message: '',
//         // ));
//       }
//     } catch (e) {
//       log("err $e");

//       // Get.showSnackbar(GetSnackBar(
//       //   title: "No QBO Classes found",
//       //   message: '',
//       // ));
//     }
//   }

//   Future<void> getQBOClasses() async {
//     try {
//       var companyID = await MySharedPref.getCompanyID();

//       var response = await DioClient().get(
//           url: ApiUrl.getQBOClassesUrl,
//           params: {"companyId": companyID}).catchError(handleError);
//       log("all in data $response");
//       if (response == null) return;

//       // Ensure the response is a list
//       if (response is List && response.isNotEmpty) {
//         qboClassList.value =
//             response.map((e) => QboClassModel.fromJson(e)).toList();
//       } else {
//         qboClassList.value = [];
//         // Get.showSnackbar(GetSnackBar(
//         //   title: "No QBO Classes found",
//         //   message: '',
//         // ));
//       }
//     } catch (e) {
//       log("err $e");

//       // Get.showSnackbar(GetSnackBar(
//       //   title: "No QBO Classes found",
//       //   message: '',
//       // ));
//     }
//   }

//   RxString invoiceName = "".obs;
//   Future<void> getInvoiceName() async {
//     var companyID = await MySharedPref.getCompanyID();
//     var response = await DioClient().get(
//       url: ApiUrl.getInvoiceName,
//       params: {
//         "CompanyId": companyID,
//         "IsInvoice": selectedCreateType.value == "Invoice" ? true : false,
//       },
//     ).catchError(handleError);
//     kLog("invoice name response $response");
//     if (response == null) return;

//     invoiceName.value = response["InvoiceNo"];
//   }

//   void showEmptyWidget() {
//     isInvoiceEmpty.value = true;
//   }

//   final RxBool isLoading = true.obs;
//   final selectedItemList = RxList<SelectedItemListModel>([]);

//   RxBool isInvoiceSaved = false.obs;
//   Future<bool> createInvoice() async {
//     showLoading();
//     var companyID = await MySharedPref.getCompanyID();
//     var userID = await MySharedPref.getUserName();
//     isInvoiceSaved.value = false;
//     var response = await DioClient().post(
//       url: ApiUrl.createInvoice,
//       body: {
//         "invoice": {
//           "Number": invoiceName.value,
//           "CompanyID": "",
//           "CompnyID": companyID,
//           "DisplayNumber": null,
//           "CustomerId": customerID.value,
//           "UserId": userID,
//           "Subtotal": subTotal.value,
//           "Discount": invoiceDiscount.value,
//           "QboClassId": selectedQboClass.value?.qboClassId ?? 0,
//           "QboLocationId": selectedQboLocation.value?.qboLocationId ?? 0,

//           "Tax": taxAmount.toStringAsFixed(2),

//           "Total": amountAfterAddingTax.toStringAsFixed(2),
//           "Status": 1,
//           "InvoiceType": null,
//           "ModifiedDate": null,
//           "ModifiedBy": null,
//           "Note": noteTextController.text,
//           "CreatedDate": dateTimeConverter(
//             inputTime: DateTime.now().toString(),
//             outputFormat: "yyyy/MM/dd",
//           ),
//           "CreatedBy": userID,
//           "InvoiceDate": dateTimeConverter(
//             inputTime: DateTime.now().toString(),
//             outputFormat: "yyyy/MM/dd",
//           ),
//           "AmountCollect": 0.00,
//           "TaxType": selectedTaxID.value,
//           "AppointmentId": appointmentID,
//           "Type": selectedCreateType.value,
//           "QboId": 0,

//           "DiscountRate": createDiscountTextController.text,
//           "DiscountOption": selectedDiscountOption.value,
//           "QboEstimateId": 0,
//           "ExpirationDate": null,
//           "SyncToken": "0",
//           "QboPaymentID": "0",
//           "DepositAmount": 0.00,
//           "LoanStatus": null,
//           "IsConverted": false,
//           "ConvertedInvocieID": "",
//           "ConvertedInvocieNumber": null,
//           "items": selectedItemList.map((item) {
//             return {
//               ...item.selectedItem!.toJson(),
//               "IsTaxable": item.selectedItem!.isTaxable == true ? "TAX" : "NON",
//               "Quantity": item.quantity,
//               "UnitPrice":
//                   item.selectedItem!.price?.toStringAsFixed(2) ?? "0.00",
//               "TotalPrice": item.totalPrice,
//               // "ItemTyId": item.itemTypeId ?? "",
//               "ItemId": item.selectedItem!.id ?? "",
//             };
//           }).toList(),

//           /// There will be item
//         },
//       },
//     ).catchError(handleError);

//     if (response == null) return false;

//     invoiceID.value = response["Id"].toString();

//     isInvoiceSaved.value = true;
//     await getInvoiceName();
//     clearAllItems(); //
//     isNoneSelected(false);
//     await Get.find<AppointmentController>().getAppointments(showLoader: false);
//     // hideLoading();
//     MySnackBar.showToast(
//       message: "${selectedCreateType.value} created successfully!",
//     );

//     return true;
//   }

//   RxList<File> selectedFiles = <File>[].obs;

//   RxList<File> docFileList = <File>[].obs;

//   Future<void> pickFiles() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//     );

//     if (result != null) {
//       List<File> files = result.paths.map((path) => File(path!)).toList();

//       selectedFiles.addAll(
//         files.where((file) => !selectedFiles.any((f) => f.path == file.path)),
//       );

//       docFileList = RxList.from(selectedFiles); // Update docFileList for upload
//     }
//   }

//   RxBool depositRequestPay = false.obs;
//   final TextEditingController requestedDepositAmountEditTextController =
//       TextEditingController();
//   final TextEditingController requestDepositRateEditTextController =
//       TextEditingController();
//   RxBool convertToInvoice = false.obs;
//   void updateRequestedDepositAmount() {
//     final rate =
//         double.tryParse(requestDepositRateEditTextController.text) ?? 0.0;
//     final total = ((invoiceSubtotal.value - invoiceDiscount.value) -
//                 nonTaxableTotalInDetails.value) *
//             (double.tryParse(tax.value) ?? 0) /
//             100 +
//         ((invoiceSubtotal.value) - (invoiceDiscount.value));
//     final depositAmount =
//         ((total - double.parse(this.depositAmount.value)) * rate / 100)
//             .toStringAsFixed(2);
//     requestedDepositAmountEditTextController.text = depositAmount;
//   }

//   RxString selectedDepositRequestOption = "0".obs; // percentage
//   RxString selectedDepositRequestOptionName = "No Deposit Request".obs;
//   List depositRequestOptions = [
//     {"name": "No Request", "value": "0"},
//     {"name": "Requested Deposit Amount:(%)", "value": "1"},
//     {"name": "Requested Deposit Amount:(\$)", "value": "2"},
//   ];

//   Future<void> editInvoice() async {
//     showLoading();
//     var companyID = await MySharedPref.getCompanyID();
//     var userID = await MySharedPref.getUserName();
//     var response = await DioClient().post(
//       url: ApiUrl.editInvoice,
//       body: {
//         "invoice": {
//           "InvoiceID": invoiceID.value,
//           "Number": invoiceNumber,
//           "ConvertedInvocieID": "",
//           "CompanyID": "",
//           "CompnyID": companyID,
//           "DisplayNumber": null,
//           "CustomerId": customerID.value,
//           "UserId": userID,
//           "Subtotal": invoiceSubtotal.value,
//           "Discount": invoiceDiscount.value,
//           "Tax": double.parse(invoiceTax.value.toStringAsFixed(2)),
//           "Total": double.parse(invoiceTotal.value).toStringAsFixed(2),
//           "Status": 1,
//           "InvoiceType": null,
//           "ModifiedBy": null,
//           "QboClassId": selectedQboClass.value?.qboClassId,
//           "QboLocationId": selectedQboLocation.value?.qboLocationId,
//           "Note": editNoteTextController.text,
//           "CreatedBy": userID,
//           "InvoiceDate": dateTimeConverter(
//             inputTime: date,
//             inputFormat: "MM/dd/yyyy",
//             outputFormat: "yyyy/MM/dd",
//           ),
//           "ModifiedDate": dateTimeConverter(
//             inputTime: DateTime.now().toString(),
//             outputFormat: "yyyy/MM/dd",
//           ),
//           "RequestedDepositAmount":
//               requestedDepositAmountEditTextController.text,
//           "RequestedDepositPercentage":
//               selectedDepositRequestOption.value == "2"
//                   ? "0.00"
//                   : requestDepositRateEditTextController.text,
//           "RequestedAmtType": int.parse(selectedDepositRequestOption.value),
//           "TaxType": initialTaxID.value,
//           "AppointmentId": appointmentID,
//           "Type": type.value,
//           "QboId": 0,
//           "DiscountRate": editDiscountTextController.text,
//           "DiscountOption": selectedDiscountOption.value,
//           "QboEstimateId": 0,
//           "ExpirationDate": null,
//           "SyncToken": "",
//           "QboPaymentID": "",
//           "AmountCollect": double.parse(
//             depositAmount.value,
//           ).toStringAsFixed(2),
//           "DepositAmount": double.parse(
//             depositAmount.value,
//           ).toStringAsFixed(2),
//           "LoanStatus": null,
//           "IsConverted": false,
//           "items": selectedItemList.map((item) {
//             return {
//               ...item.selectedItem!.toJson(),
//               "IsTaxable": item.selectedItem!.isTaxable == true ? "TAX" : "NON",
//               "Quantity": item.quantity,
//               "UnitPrice":
//                   item.selectedItem!.price?.toStringAsFixed(2) ?? "0.00",
//               "TotalPrice": item.totalPrice,
//               // "ItemTyId": item.itemTypeId ?? "",
//               "ItemId": item.selectedItem!.id ?? "",
//             };
//           }).toList(),
//         },
//       },
//     ).catchError(handleError);

//     if (response == null) return;
//     if (convertToInvoice.value) {
//       await convertEstimate();
//       convertToInvoice.value = false;
//       isConverted.value = true;
//     }
//     isDirty.value = false;
//     hideLoading();
//     await Get.find<AppointmentController>().getAppointments();
//   }

//   Future<void> convertEstimate() async {
//     var companyID = MySharedPref.getCompanyID();
//     var userID = MySharedPref.getUserName();
//     var response = await DioClient().post(
//       url: ApiUrl.convertEST,
//       body: {
//         "invoiceId": invoiceID.value,
//         "modifiedBy": userID,
//         "companyId": companyID,
//       },
//     ).catchError(handleError);
//     if (response == null) return;
//   }

//   RxString customerFirstName = "".obs;

//   Future<void> getEmailAutofill({required String emailType}) async {
//     showLoading();
//     var companyID = await MySharedPref.getCompanyID();
//     var companyName = await MySharedPref.getCompanyName();
//     var response = await DioClient().get(
//       url: ApiUrl.emailAutofill,
//       params: {"companyId": companyID, "type": emailType},
//     ).catchError(handleError);
//     if (response == null) return;
//     bccTextController.text = response["EmailBCC"] ?? "";
//     subjectTextController.text = emailType == "Invoice"
//         ? response['InvoiceMailSubject']
//         : response['ProposalMailSubject'];
//     emailBodyTextController.text = emailType == "Invoice"
//         ? (response['InvoiceMailBody'] as String)
//             .replaceAll('[First Name]', customerFirstName.value)
//             .replaceAll('[Company Name]', companyName)
//         : (response['ProposalMailBody'] as String)
//             .replaceAll('[First Name]', customerFirstName.value)
//             .replaceAll('[Company Name]', companyName);

//     hideLoading();
//   }

//   Future<void> sendEmail({
//     required String pdfType,
//     required String emailType,
//   }) async {
//     showLoading();
//     var companyID = await MySharedPref.getCompanyID();
//     var userID = await MySharedPref.getUserName();

//     List<Map<String, dynamic>> emailContents = [];

//     for (var file in selectedFiles) {
//       List<int> fileBytes = await file.readAsBytes(); // Not base64
//       String fileName = file.path.split('/').last;
//       String? mimeType =
//           lookupMimeType(file.path) ?? "application/octet-stream";

//       emailContents.add({
//         "FileContent": fileBytes,
//         "FileName": fileName,
//         "FileType": mimeType,
//         "FileUrl": "",
//       });
//     }

//     var response = await DioClient().post(
//       url: ApiUrl.sendEmail,
//       body: {
//         "companyID": companyID,
//         "customerID": customerID.value,
//         "emailType": "$emailType Email",
//         "subject": subjectTextController.text,
//         "body": emailBodyTextController.text,
//         "recepientToEmail": toTextController.text,
//         "recepientCCEmail": "",
//         "recepientBCCEmail": bccTextController.text,
//         "emailContents": selectedFiles.isEmpty ? [] : emailContents,
//         "userId": userID,
//         "currentPdfType": pdfType,
//         "invoiceNo": invoiceID.value,
//         "isSendPaymentLink": isSendXPayLink.value,
//       },
//     ).catchError(handleError);

//     if (response == null) return;

//     hideLoading();

//     selectedFiles.clear();
//     Get.back();
//     MySnackBar.showToast(message: response["Message"]);
//   }

//   RxString depositAmount = "0.00".obs;
//   Future<void> makePayment(String type) async {
//     var companyID = await MySharedPref.getCompanyID();

//     var response = await DioClient().post(
//       url: ApiUrl.makePayment,
//       body: {
//         "payment": {
//           "CompanyID": companyID,
//           "InvocieId": invoiceID.value,
//           "Amount": finalCollectionAmount.value,
//           "Type": type,
//           "Source": "Xinator BMS",
//           "CheckName": checkNameTextController.text,
//           "CheckNumber": checkNumberTextController.text,
//         },
//       },
//     ).catchError(handleError);

//     if (response == null) return;

//     checkNumberTextController.clear();
//     checkNameTextController.clear();
//     await Get.find<AppointmentController>().getAppointments();

//     Get.back();
//     Get.back();
//     Get.back();
//   }

//   Future<void> makeDepositPay(String amount, String type) async {
//     var companyID = await MySharedPref.getCompanyID();

//     var response = await DioClient().post(
//       url: ApiUrl.makePayment,
//       body: {
//         "payment": {
//           "CompanyID": companyID,
//           "InvocieId": invoiceID.value,
//           "Amount": amount.isEmpty ? "0.00" : amount,
//           "Type": type,
//           "Source": "Xinator BMS",
//           "CheckName": checkNameTextController.text,
//           "CheckNumber": checkNumberTextController.text,
//         },
//       },
//     ).catchError(handleError);

//     if (response == null) return;
//     await Get.find<AppointmentController>().getAppointments();
//     Get.back();
//     Get.back();
//     Get.back();
//   }

//   Future<void> paymentStatus() async {
//     showLoading();
//     var companyID = await MySharedPref.getCompanyID();
//     var uri =
//         "https://dev-services.myserviceforce.com/xceleranccportal/webterminal/Clearent/cecCCPaymentStatus.aspx";

//     var response = await DioClient().post(url: uri, params: {
//       "cid": companyID,
//       "invNo": invoiceNumber
//     }).catchError(handleError);

//     if (response["Status"] != "Success Approved") {
//       hideLoading();
//       Get.back();
//       MySnackBar.showErrorToast(message: "Payment unSuccessful");
//       return;
//     } else {
//       hideLoading();
//       await Get.find<AppointmentController>().getAppointments();
//       Get.back();
//       MySnackBar.showToast(message: "Payment successful");
//     }
//   }

//   @override
//   void onReady() async {
//     await itemController.getItems();
//     isDirty.value = false;
//     super.onReady();
//   }

//   @override
//   void dispose() {
//     // for (var controller in quantityControllers) {
//     //   controller.dispose();
//     // }
//     // for (var controller in amountControllers) {
//     //   controller.dispose();
//     // }
//     // for (var controller in descriptionControllers) {
//     //   controller.dispose();
//     // }
//     // for (var controller in editQuantityControllers) {
//     //   controller.dispose();
//     // }
//     // for (var controller in editAmountControllers) {
//     //   controller.dispose();
//     // }
//     // for (var controller in editDescriptionControllers) {
//     //   controller.dispose();
//     // }
//     noteTextController.dispose();
//     createDiscountTextController.dispose();
//     toTextController.dispose();
//     bccTextController.dispose();
//     subjectTextController.dispose();
//     emailBodyTextController.dispose();
//     editDiscountTextController.dispose();
//     editNoteTextController.dispose();
//     cashAmtTextController.dispose();
//     checkAmtTextController.dispose();
//     checkNameTextController.dispose();
//     checkNumberTextController.dispose();

//     // Dispose focus nodes
//     createInvoiceDiscountFocusnode.value.dispose();
//     createInvoiceNotesFocusnode.value.dispose();
//     createInvoiceSearchFocusnode.value.dispose();
//     createInvoiceEmailToFocusnode.value.dispose();
//     createInvoiceEmailBccFocusnode.value.dispose();
//     createInvoiceEmailSubjectFocusnode.value.dispose();
//     createInvoiceEmailBodyFocusnode.value.dispose();

//     super.dispose();
//   }
// }
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../utils/date_converter.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../routes/app_pages.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../../appointment/controllers/appointment_controller.dart';
import '../../appointment/models/appointment_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../item/controllers/item_controller.dart';
import '../../item/models/item_list_model.dart';
import '../models/invoice_backup_model.dart';
import '../models/qbo_class_dropdown_model.dart';
import '../models/qbo_location_dropdown_model.dart';
import '../models/tax_model.dart';

class InvoiceController extends GetxController with ExceptionHandler {
  late final WebViewController webController;
  late final WebViewController webController2;
  bool isWebControllerInitialized = false;
  bool isWebControllerInitialized2 = false;
  RxBool isSendXPayLink = false.obs;
  RxBool isSendTuaPayLink = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoading2 = true.obs;

  // TUA Pay Link variables
  final TextEditingController tuaBaseAmountController = TextEditingController();
// Default or Custom
  final TextEditingController tuaCustomPercentageController =
      TextEditingController(text: "5");
  final RxDouble tuaDefaultPercentage = 5.0.obs;
  final TextEditingController tuaRemainAmountController =
      TextEditingController();
  final TextEditingController tuaEmailController = TextEditingController();
  final TextEditingController tuaFirstNameController = TextEditingController();
  final TextEditingController tuaLastNameController = TextEditingController();
  final TextEditingController tuaMobileController = TextEditingController();
  final TextEditingController tuaAddressController = TextEditingController();
  final TextEditingController tuaCityController = TextEditingController();
  final TextEditingController tuaStateController = TextEditingController();
  final TextEditingController tuaZipCodeController = TextEditingController();
  final RxBool tuaSendTextLink = false.obs;

  // Focus Nodes
  final Rx<FocusNode> invoiceDetailsNoteFocusnode = FocusNode().obs;
  final Rx<FocusNode> invoiceDetailsEmailToFocusnode = FocusNode().obs;
  final Rx<FocusNode> invoiceDetailsEmailBccFocusnode = FocusNode().obs;
  final Rx<FocusNode> invoiceDetailsEmailSubjectFocusnode = FocusNode().obs;
  final Rx<FocusNode> invoiceDetailsEmailBodyFocusnode = FocusNode().obs;
  final Rx<FocusNode> invoiceDetailsSearchFocusnode = FocusNode().obs;
  final Rx<FocusNode> invoiceDetailsEditDiscountFocusnode = FocusNode().obs;
  final Rx<FocusNode> invoiceDetailsDepositRateFocusnode = FocusNode().obs;

  // Create Invoice Focus Nodes
  final Rx<FocusNode> createInvoiceDiscountFocusnode = FocusNode().obs;
  final Rx<FocusNode> createInvoiceNotesFocusnode = FocusNode().obs;
  final Rx<FocusNode> createInvoiceSearchFocusnode = FocusNode().obs;
  final Rx<FocusNode> createInvoiceEmailToFocusnode = FocusNode().obs;
  final Rx<FocusNode> createInvoiceEmailBccFocusnode = FocusNode().obs;
  final Rx<FocusNode> createInvoiceEmailSubjectFocusnode = FocusNode().obs;
  final Rx<FocusNode> createInvoiceEmailBodyFocusnode = FocusNode().obs;

  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(Duration(seconds: 1), () {});
    getQBOClasses();
    getQBOLocations();
    // Load immediately when controller is created
  }

  Future<void> initializeWebController(String amount) async {
    if (isWebControllerInitialized) {
      return;
    }
    var companyID = MySharedPref.getCompanyID();
    var userID = MySharedPref.getUserName();

    var platform = Platform.isIOS ? "iOS" : "Android";
    final url =
        "${ApiUrl.paymentBaseUrl}?appname=cec&device=$platform&cid=$companyID&uid=$userID&inv=$invoiceNumber&amount=${double.parse(amount).abs().toStringAsFixed(2)}";
    // "https://dev-services.myserviceforce.com/webterminal/Clearent/AppCCPayment_CL.aspx?appname=cec&device=$platform&cid=$companyID&uid=$userID&inv=$invoiceNumber&amount=${double.parse( amount).abs().toString()}";
    log('WebView URL: $url');
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            isLoading.value = true;
            log('Page started: $url');
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
            log('Page finished: $url');
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    isWebControllerInitialized = true;
  }

  Future<void> initializeWebController2(String xPayLink) async {
    if (isWebControllerInitialized2) {
      return;
    }

    final url = xPayLink;

    log('WebView URL: $url');
    webController2 = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            isLoading2.value = true;
            log('Page started: $url');
          },
          onPageFinished: (url) {
            isLoading2.value = false;
            webController2.runJavaScript("""
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = 'width=device-width,  maximum-scale=1.0 user-scalable=no';
      document.getElementsByTagName('head')[0].appendChild(meta);
      document.body.style.zoom = "1"; 
    """);
            log('Page finished: $url');
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    isWebControllerInitialized2 = true;
  }

  List<Map<String, String>> createTypes = [
    {"name": "Invoice", "value": "1"},
    {"name": "Estimate", "value": "2"},
  ];
  RxString selectedCreateType = "Invoice".obs;
  final ScrollController scrollController = ScrollController();
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
  final TextEditingController requestDepositRateEditTextController =
      TextEditingController();
  final TextEditingController requestDepositRateCreateTextController =
      TextEditingController();
  final TextEditingController requestedDepositAmountEditTextController =
      TextEditingController();
  final TextEditingController requestedDepositAmountCreateTextController =
      TextEditingController();

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
  RxString finalCollectionAmount = "0.00".obs;
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
  RxBool depositRequestPay = false.obs;
  String appointmentID = "";
  String paid = "";
  String status = "";
  String due = "";
  RxBool isApplyingSurcharge = false.obs;
  // var isNoneSelected = false.obs;
  String notes = "";
  String surcharges = "0.00"; // Fixed surcharge amount
  RxInt selectedInvoiceIndex = 0.obs;
  RxBool isInvoiceEmpty = false.obs;
  RxString selectedTaxName = "".obs;
  RxString selectedDiscountOption = "2".obs;
  final isLocAndClassShow = RxBool(true);
  List discountOptions = [
    {"name": "Fixed", "value": "2"},
    {"name": "Percentage", "value": "1"},
  ];
  RxString initialTaxID = "".obs;
  void toggleBlockStatus(bool isBlocked) {
    isApplyingSurcharge.value = isBlocked;
  }

  final qboClassList = RxList<QboClassModel>([]);
  final selectedQboClass = Rx<QboClassModel?>(null);
  final selectedClass = Rx<QboClassModel?>(null);
  final qboLocationList = RxList<QboLocationModel>([]);
  final selectedQboLocation = Rx<QboLocationModel?>(null);
  final isLoadingQboClass = RxBool(false);
  RxString selectedDepositRequestOption = "0".obs; // percentage
  RxString selectedDepositRequestOptionName = "No Deposit Request".obs;
  List depositRequestOptions = [
    {"name": "Select Deposit Request", "value": "0"},
    {"name": "Requested Deposit Amount:(%)", "value": "1"},
    {"name": "Requested Deposit Amount:(\$)", "value": "2"},
  ];

  RxDouble invoiceDiscountDetails = 0.00.obs;

  RxString invoiceTotal = "0.00".obs;
  RxDouble invoiceSubtotal = 0.00.obs;
  RxDouble discountedTaxableTotalInEdit = 0.00.obs;
  RxDouble discountedTaxableTotalInCreate = 0.00.obs;

  RxDouble invoiceTax = 0.00.obs;
  RxString selectedTaxID = "".obs;
  RxDouble invoiceDiscount = 0.00.obs;
  RxDouble amountAfterDiscount = 0.00.obs;

  RxDouble get nonTaxableTotalInDetails {
    RxDouble total = 0.0.obs;
    if (!selectedItemList.any((item) => item.isTaxable == true)) {
      // If no taxable items, return the subtotal minus discount
      total.value = invoiceSubtotal.value;
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
      total.value = invoiceSubtotal.value;
      return total;
    } else {
      for (int i = 0; i < selectedItemList.length; i++) {
        final item = selectedItemList[i];
        if (item.isTaxable == false) {
          final price = double.tryParse(amountControllers[i].text) ?? 0.0;
          final qty = double.tryParse(quantityControllers[i].text) ?? 1.0;
          total.value += price * qty;
        }
      }
      return total;
    }
  }

  // ============================================
  // SURCHARGE FEATURE (Commented out for now)
  // ============================================
  // // Calculate total amount with surcharge (3% of amount after discount)
  // RxDouble get totalAmountWithSurcharge {
  //   double surchargeAmount = isApplyingSurcharge.value
  //       ? (amountAfterDiscount.value * 3 / 100)
  //       : 0.0;
  //   return (amountAfterDiscount.value + surchargeAmount).obs;
  // }
  // ============================================

  final isLoadingQboLocation = RxBool(false);
  Future<void> getQBOLocations() async {
    try {
      var companyID = MySharedPref.getCompanyID();

      var response = await DioClient().get(
          url: ApiUrl.getQBOLocationsUrl,
          params: {"companyId": companyID}).catchError(handleError);
      if (response == null) return;

      log("qbo locations response: $response");
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
      // Get.showSnackbar(GetSnackBar(
      //   title: "No QBO Classes found",
      //   message: '',
      // ));
    }
  }

  Future<void> getQBOClasses() async {
    try {
      var companyID = MySharedPref.getCompanyID();

      var response = await DioClient().get(
          url: ApiUrl.getQBOClassesUrl,
          params: {"companyId": companyID}).catchError(handleError);
      if (response == null) return;
      log("qbo class response: $response");
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
      // Get.showSnackbar(GetSnackBar(
      //   title: "No QBO Classes found",
      //   message: '',
      // ));
    }
  }

  void createTotal() {
    double subTotal = 0.00;
    // Calculate subtotal based on selected items
    for (int i = 0; i < selectedItemList.length; i++) {
      double price = double.tryParse(amountControllers[i].text) ??
          selectedItemList[i].price ??
          0.00;
      double quantity = double.tryParse(quantityControllers[i].text) ?? 1.0;
      subTotal += quantity * price;
    }

    invoiceSubtotal.value = subTotal;

    // Calculate discount
    double discount = double.parse(
      createDiscountTextController.text.isEmpty
          ? "0.00"
          : createDiscountTextController.text,
    );

    double discountAmount = selectedDiscountOption.value == "1"
        ? (subTotal * discount / 100)
        : discount;

    invoiceDiscount.value = discountAmount;

    amountAfterDiscount.value = subTotal - discountAmount;
    double discountRatio = discount / subTotal;
    double discountedTaxableTotal = selectedDiscountOption.value ==
            "1" // Percentage discount
        ? ((subTotal - nonTaxableItemTotalInCreate.value) * (discount / 100))
        : (subTotal - nonTaxableItemTotalInCreate.value) * discountRatio;
    discountedTaxableTotalInCreate.value =
        (subTotal - nonTaxableItemTotalInCreate.value) - discountedTaxableTotal;
    double taxPercentage = double.parse(tax.value);

    double taxOnTaxableTotal =
        (discountedTaxableTotalInCreate.value) * (taxPercentage / 100);

    // ============================================
    // SURCHARGE FEATURE (Commented out for now)
    // ============================================
    // // Calculate surcharge (3% of amount after discount if enabled)
    // double surchargeAmount = isApplyingSurcharge.value
    //     ? (amountAfterDiscount.value * 3 / 100)
    //     : 0.0;
    //
    // double total = (amountAfterDiscount.value + taxOnTaxableTotal + surchargeAmount);
    // ============================================

    double total = (amountAfterDiscount.value + taxOnTaxableTotal);

    // Update observable values
    invoiceTax.value = double.parse((taxOnTaxableTotal).toStringAsFixed(2));
    invoiceTotal.value = total.toStringAsFixed(2);
  }

  void createTotalForEdit() {
    double subTotal = 0.00;

    // Calculate subtotal based on selected items
    for (int i = 0; i < selectedItemList.length; i++) {
      double price = double.tryParse(editAmountControllers[i].text) ??
          selectedItemList[i].price ??
          0.00;
      double quantity = double.tryParse(editQuantityControllers[i].text) ?? 1.0;
      subTotal += quantity * price;
    }

    invoiceSubtotal.value = subTotal;

    // Calculate discount
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
    double discountRatio = discount / subTotal;
    double discountedTaxableTotal = selectedDiscountOption.value == "1"
        ? ((subTotal - nonTaxableTotalInDetails.value) * (discount / 100))
        : (subTotal - nonTaxableTotalInDetails.value) * discountRatio;
    discountedTaxableTotalInEdit.value =
        (subTotal - nonTaxableTotalInDetails.value) - discountedTaxableTotal;

    double taxPercentage = double.parse(tax.value);

    double taxOnTaxableTotal =
        (discountedTaxableTotalInEdit.value) * (taxPercentage / 100);

    // ============================================
    // SURCHARGE FEATURE (Commented out for now)
    // ============================================
    // // Calculate surcharge (3% of amount after discount if enabled)
    // double surchargeAmount = isApplyingSurcharge.value
    //     ? (amountAfterDiscount.value * 3 / 100)
    //     : 0.0;
    //
    // double total = (amountAfterDiscount.value + taxOnTaxableTotal + surchargeAmount);
    // ============================================

    double total = (amountAfterDiscount.value + taxOnTaxableTotal);

    // Update observable values
    invoiceTax.value = double.parse((taxOnTaxableTotal).toStringAsFixed(2));
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

  final removedList = RxList<String>([]);
  void removeItemFromEdit(int index) {
    removedList.add(selectedItemList[index].id!);
    selectedItemList.removeAt(index);

    editAmountControllers[index].dispose();
    editDescriptionControllers[index].dispose();
    editQuantityControllers[index].dispose();

    editAmountControllers.removeAt(index);
    editDescriptionControllers.removeAt(index);
    editQuantityControllers.removeAt(index);

    createTotalForEdit();
    updateRequestedDepositAmount();
  }

  /// Clear all items and reset everything (for new invoice)
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

    _resetInvoiceFields();
  }

  /// Reset only invoice totals and fields (keep items for next invoice)
  void resetInvoiceFields() {
    _resetInvoiceFields();
  }

  /// Internal method to reset common fields
  void _resetInvoiceFields() {
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

  /// Save current state to backup before navigating back
  void saveBackup(String type) {
    final backup = _backups[type];
    if (backup == null) return;

    backup.clear();
    backup.items.assignAll(selectedItemList);
    backup.note = noteTextController.text;
    backup.discount = createDiscountTextController.text;
    backup.tax = tax.value;

    // Backup controller values as strings
    for (var controller in quantityControllers) {
      backup.quantities.add(controller.text);
    }
    for (var controller in amountControllers) {
      backup.amounts.add(controller.text);
    }
    for (var controller in descriptionControllers) {
      backup.descriptions.add(controller.text);
    }
  }

  /// Restore from backup when returning to create/edit screen
  void restoreBackup(String type) {
    // Only restore if the type has changed (prevent multiple restores)
    if (_currentRestoreType == type) return;
    _currentRestoreType = type;

    final backup = _backups[type];
    if (backup == null || backup.isEmpty) {
      // No backup exists, clear current items for fresh start
      clearAllItems();
      return;
    }

    clearAllItems();
    selectedItemList.assignAll(backup.items);
    noteTextController.text = backup.note;
    createDiscountTextController.text = backup.discount;
    tax.value = backup.tax;

    // Restore controllers - use the minimum length to avoid index out of bounds
    final itemCount = backup.items.length;
    for (int i = 0; i < itemCount; i++) {
      quantityControllers.add(TextEditingController());
      amountControllers.add(TextEditingController());
      descriptionControllers.add(TextEditingController());

      // Set values if available
      if (i < backup.quantities.length) {
        quantityControllers[i].text = backup.quantities[i];
      }
      if (i < backup.amounts.length) {
        amountControllers[i].text = backup.amounts[i];
      }
      if (i < backup.descriptions.length) {
        descriptionControllers[i].text = backup.descriptions[i];
      }
    }

    createTotal();
  }

  /// Clear both backup and current after successful submission
  void clearBackupAndCurrent(String type) {
    final backup = _backups[type];
    if (backup != null) {
      backup.clear();
    }
    clearAllItems();
  }

  /// Reset restore flag to allow restoring new backup
  void resetRestoreFlag() {
    _currentRestoreType = "";
  }

  /// API ///
  final invoiceItemList = RxList<Items>();
  final depositList = RxList<Payment>();

  final taxes = RxList<TaxModel>();
  Future<void> getTax() async {
    var companyID = MySharedPref.getCompanyID();
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

  RxString invoiceName = "".obs;
  Future<void> getInvoiceName() async {
    var companyID = MySharedPref.getCompanyID();
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

  final existingItemType =
      Rx<SelectedItemCategory>(SelectedItemCategory.newOne);
  final RxList<ItemListModel> selectedItemList = <ItemListModel>[].obs;

  // Backup models for Invoice and Estimate drafts
  final Map<String, InvoiceBackupModel> _backups = {
    "Invoice": InvoiceBackupModel.empty(),
    "Estimate": InvoiceBackupModel.empty(),
  };

  // Track if we've already restored for this session
  String _currentRestoreType = "";

  void selectItem(ItemListModel item) {
    selectedItemList.add(item);
  }

  RxBool isInvoiceSaved = false.obs;
  Future<void> createInvoice() async {
    showLoading(debugInfo: "createInvoice - Start");
    isInvoiceSaved.value = false;
    var companyID = MySharedPref.getCompanyID();
    var userID = MySharedPref.getUserName();
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
          "QboClassId": selectedQboClass.value?.qboClassId ?? 0,
          "QboLocationId": selectedQboLocation.value?.qboLocationId ?? 0,

          "Tax": double.parse(
            invoiceTax.value.toStringAsFixed(2),
          ).toStringAsFixed(2),

          "Total": double.parse(invoiceTotal.value).toStringAsFixed(2),
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
          "RequestedDepositAmount": "0.00",
          "RequestedDepositPercentage": "0.00",
          "RequestedAmtType": 0,
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
                          (double.tryParse(
                                quantityControllers[
                                        selectedItemList.indexOf(item)]
                                    .text,
                              ) ??
                              1.0))
                      .toStringAsFixed(2)
                  : "0.00"),
              // "ItemTyId": item.itemTypeId ?? "",
              "ItemId": item.id ?? "",
            };
          }).toList(),

          /// There will be item
        },
      },
    ).catchError(handleError);

    if (response == null) return;

    invoiceID.value = response["Id"].toString();

    isInvoiceSaved.value = true;
    await getInvoiceName();
    // Clear backup and current after successful submission
    clearBackupAndCurrent(selectedCreateType.value);

    // Close loading dialog first
    await hideLoading(debugInfo: "createInvoice - Success");

    // Wait for dialog to fully close and overlays to reset
    await Future.delayed(const Duration(milliseconds: 200));

    // Show toast after dialog is closed
    MySnackBar.showToast(
      message: "${selectedCreateType.value} created successfully!",
    );

    // Refresh appointments in background
    await Get.find<AppointmentController>().getAppointments();

    // Wait for toast to be visible
    await Future.delayed(const Duration(milliseconds: 800));
    // Then navigate back
    Get.back();
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

  RxBool convertToInvoice = false.obs;
  Future<void> editInvoice() async {
    showLoading(debugInfo: "editInvoice - Start");
    var companyID = MySharedPref.getCompanyID();
    var userID = MySharedPref.getUserName();

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
          "QboClassId": selectedQboClass.value?.qboClassId ?? 0,
          "QboLocationId": selectedQboLocation.value?.qboLocationId ?? 0,
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
              ...item.toJson(),
              "IsTaxable": item.isTaxable == true ? "TAX" : "NON",
              "Quantity":
                  editQuantityControllers[selectedItemList.indexOf(item)].text,
              "UnitPrice": editAmountControllers[selectedItemList.indexOf(item)]
                          .text !=
                      ''
                  ? editAmountControllers[selectedItemList.indexOf(item)].text
                  : item.price != null
                      ? item.price!.toStringAsFixed(2)
                      : "0.00",

              "TotalPrice":
                  editAmountControllers[selectedItemList.indexOf(item)].text !=
                          ''
                      ? (double.parse(editAmountControllers[
                                      selectedItemList.indexOf(item)]
                                  .text) *
                              (double.tryParse(
                                    editQuantityControllers[
                                            selectedItemList.indexOf(item)]
                                        .text,
                                  ) ??
                                  1.0))
                          .toStringAsFixed(2)
                      : item.price != null
                          ? (item.price! *
                                  double.parse(
                                    editQuantityControllers[
                                            selectedItemList.indexOf(item)]
                                        .text,
                                  ))
                              .toStringAsFixed(2)
                          : "0.00",
              // "ItemTyId": item.itemTypeId ?? "",
              "ItemId": item.id ?? "",
            };
          }).toList(),
        },
      },
    ).catchError(handleError);

    if (response == null) return;
    MySnackBar.showToast(
      message: "${type.value} updated successfully!",
    );
    if (convertToInvoice.value) {
      await convertEstimate();
      convertToInvoice.value = false;
      isConverted.value = true;
    }
    isDirty.value = false;
    hideLoading(debugInfo: "editInvoice - Success");
    Get.find<AppointmentController>().getAppointments(showLoader: false);
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
    showLoading(debugInfo: "getEmailAutofill - Start");
    var companyID = MySharedPref.getCompanyID();
    var companyName = MySharedPref.getCompanyName();
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
            .replaceAll('[Company Name]', companyName!)
        : (response['ProposalMailBody'] as String)
            .replaceAll('[First Name]', customerFirstName.value)
            .replaceAll('[Company Name]', companyName!);

    hideLoading(debugInfo: "getEmailAutofill - Success");
  }

  Future<void> sendEmail({
    required String pdfType,
    required String emailType,
  }) async {
    showLoading(debugInfo: "sendEmail - Start");
    var companyID = MySharedPref.getCompanyID();
    var userID = MySharedPref.getUserName();

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

    // Close loading dialog first
    await hideLoading(debugInfo: "sendEmail - Success");

    // Wait for dialog to fully close and overlays to reset
    await Future.delayed(const Duration(milliseconds: 200));

    selectedFiles.clear();
    // Show toast after dialog is closed
    MySnackBar.showToast(message: response["Message"]);
    log(response["Message"]);
    await Future.delayed(const Duration(milliseconds: 800));
    Get.back();
  }

  RxString depositAmount = "0.00".obs;
  Future<void> makePayment(String type) async {
    var companyID = MySharedPref.getCompanyID();

    var response = await DioClient().post(
      url: ApiUrl.makePayment,
      body: {
        "payment": {
          "CompanyID": companyID,
          "InvocieId": invoiceID.value,
          "Amount": double.parse(finalCollectionAmount.value)
              .abs()
              .toStringAsFixed(2),
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
    final apptC = Get.find<AppointmentController>();
    await apptC.getAppointments();
    invoiceController.selectedItemList.clear();
    final appt = appointmentController.sortedAppointments
        .where((element) =>
            element.apptID.toString() == apptC.appointmentID.toString())
        .first;
    final proposal = appt.invoices!.firstWhere(
        (element) => element.invoiceID.toString() == invoiceID.value);

    invoiceItemList.value = proposal.items ?? [];
    invoiceController.depositList.value = proposal.paymentList ?? [];
    invoiceController.selectedDiscountOption.value =
        proposal.discountOption ?? "2";
    invoiceController.invoiceNumber = proposal.number ?? "";
    invoiceController.isConverted.value = proposal.isConverted ?? false;
    invoiceController.customerName = proposal.fullName ?? "";
    address = "${proposal.city}, ";
    invoiceController.depositAmount.value =
        proposal.depositAmount?.toStringAsFixed(
              2,
            ) ??
            "0.00";
    invoiceID.value = proposal.invoiceID.toString();
    date = dateTimeConverter(
      inputFormat: "yyyy/MM/dd",
      inputTime: proposal.invoiceDate.toString(),
      outputFormat: "MM/dd/yyyy",
    );
    invoiceController.subtotal = proposal.subtotal?.toStringAsFixed(2) ?? "";
    invoiceController.customerID.value = proposal.customerId ?? "";
    status = proposal.status ?? "";
    invoiceController.type.value = proposal.type ?? "";
    total.value = proposal.total?.toStringAsFixed(2) ?? "";
    if (proposal.requestedAmountType == 2) {
      // type = fixed
      selectedDepositRequestOption.value = "2";
      invoiceController.requestedDepositAmountEditTextController.text =
          proposal.requestedDepositAmount ?? "0.00";
      invoiceController.selectedDepositRequestOptionName.value =
          invoiceController.depositRequestOptions[2]["name"];
    }
    if (proposal.requestedAmountType == 1) {
      // type = percentage
      invoiceController.selectedDepositRequestOption.value = "1";
      invoiceController.requestDepositRateEditTextController.text =
          proposal.requestedDepositPercentage ?? "0.00";
      invoiceController.requestedDepositAmountEditTextController.text =
          proposal.requestedDepositAmount ?? "0.00";
      invoiceController.selectedDepositRequestOptionName.value =
          invoiceController.depositRequestOptions[1]["name"];
    }
    if (proposal.requestedAmountType == 0) {
      // type = null
      invoiceController.selectedDepositRequestOption.value = "0";
      invoiceController.requestDepositRateEditTextController.text =
          proposal.requestedDepositPercentage ?? "0.00";
      invoiceController.requestedDepositAmountEditTextController.text =
          proposal.requestedDepositAmount ?? "0.00";
      invoiceController.selectedDepositRequestOptionName.value =
          invoiceController.depositRequestOptions[0]["name"];
    }
    notes = proposal.note ?? "";
    invoiceController.editNoteTextController.text = proposal.note ?? "";
    due = proposal.due ?? "";
    invoiceController.showingDate.value = dateTimeConverter(
      inputFormat: "yyyy/MM/dd hh:mm a",
      inputTime: proposal.invoiceDate.toString(),
      outputFormat: "MM/dd/yyyy",
    );
    if (proposal.taxType != "") {
      invoiceController.initialTaxID.value = proposal.taxType ?? "";
    }

    // Set discount values
    invoiceController.invoiceDiscountDetails.value = proposal.discount ?? 0.00;
    if (proposal.discountOption == "1") {
      invoiceController.editDiscountTextController.text = (((double.parse(
                    proposal.discount?.toString() ?? "0.00",
                  )) *
                  100) /
              double.parse(
                proposal.subtotal?.toStringAsFixed(
                      2,
                    ) ??
                    "0.00",
              ))
          .toStringAsFixed(2);
    } else {
      invoiceController.editDiscountTextController.text = double.parse(
        proposal.discount?.toString() ?? "0.00",
      ).toStringAsFixed(2);
    }

    // Set tax values

    tax.value = taxes
            .firstWhereOrNull(
              (tax) =>
                  tax.id ==
                  int.tryParse(
                    invoiceController.initialTaxID.value,
                  ),
            )
            ?.rate
            ?.toStringAsFixed(2) ??
        "0.00";
    invoiceController.selectedTaxName.value = taxes
            .firstWhereOrNull(
              (tax) =>
                  tax.id ==
                  int.tryParse(
                    invoiceController.initialTaxID.value,
                  ),
            )
            ?.name ??
        "";

    // Populate selectedItemList and initialize controllers
    if (proposal.items != null && proposal.items!.isNotEmpty) {
      for (var item in proposal.items!) {
        invoiceController.selectedItemList.add(
          ItemListModel(
            id: item.itemId,
            name: item.name,
            description: item.description,
            price: double.tryParse(
              item.unitPrice ?? "0.00",
            ),
            isTaxable: item.isTaxable == "TAX" ? true : false,
            // itemTypeId: int.parse(item.itemTyId!),
          ),
        );

        // Initialize controllers with existing values
        invoiceController.editAmountControllers.add(
          TextEditingController(
            text: item.unitPrice ?? "0.00",
          ),
        );

        invoiceController.editDescriptionControllers.add(
          TextEditingController(
            text: item.description ?? "",
          ),
        );

        invoiceController.editQuantityControllers.add(
          TextEditingController(
            text: item.quantity ?? "1",
          ),
        );
      }
    }
    invoiceController.createTotalForEdit();
    await 0.5.delay();
    invoiceController.selectedQboClass(
      qboClassList
          .where(
            (e) => e.qboClassId.toString() == proposal.qboClassId,
          )
          .firstOrNull,
    );
    invoiceController.selectedQboLocation(
      invoiceController.qboLocationList
          .where(
            (e) => e.qboLocationId.toString() == proposal.qboLocationId,
          )
          .firstOrNull,
    );
    removedList.clear(); // Optional small delay before navigation

    final x = MySharedPref.getCompanyType() ?? '';
    isLocAndClassShow.value = x == 'PCS';
    selectedInvoice.value = proposal;
    requestDepositRateEditTextController.clear();
    requestedDepositAmountEditTextController.clear();
    editNoteTextController.clear();
    hideLoading(debugInfo: "getInvoiceDetails - Success");

    // Show success toast if payment was successful
    if (response['IsValid'] == true && response['Message'] != null) {
      MySnackBar.showToast(
        message: response['Message'],
      );
    }

    // Get.back();
    Get.back();
    Get.back();
  }

  Future<void> makeDepositPay(String amount, String type) async {
    showLoading(debugInfo: "makeDepositPay - Start");
    var companyID = MySharedPref.getCompanyID();

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

    if (response == null) {
      hideLoading(debugInfo: "makeDepositPay - Response null");
      return;
    }
    final apptC = Get.find<AppointmentController>();

    // Refresh appointments to show updated payment data
    await apptC.getAppointments(showLoader: false);
    log("appt Id ${apptC.appointmentID}");
    log("appt Id $appointmentID");
    invoiceController.selectedItemList.clear();
    final appt = appointmentController.sortedAppointments
        .where((element) =>
            element.apptID.toString() == apptC.appointmentID.toString())
        .first;
    final proposal = appt.invoices!.firstWhere(
        (element) => element.invoiceID.toString() == invoiceID.value);

    invoiceItemList.value = proposal.items ?? [];
    invoiceController.depositList.value = proposal.paymentList ?? [];
    invoiceController.selectedDiscountOption.value =
        proposal.discountOption ?? "2";
    invoiceController.invoiceNumber = proposal.number ?? "";
    invoiceController.isConverted.value = proposal.isConverted ?? false;
    invoiceController.customerName = proposal.fullName ?? "";
    address = "${proposal.city}, ";
    invoiceController.depositAmount.value =
        proposal.depositAmount?.toStringAsFixed(
              2,
            ) ??
            "0.00";
    invoiceID.value = proposal.invoiceID.toString();
    date = dateTimeConverter(
      inputFormat: "yyyy/MM/dd",
      inputTime: proposal.invoiceDate.toString(),
      outputFormat: "MM/dd/yyyy",
    );
    invoiceController.subtotal = proposal.subtotal?.toStringAsFixed(2) ?? "";
    invoiceController.customerID.value = proposal.customerId ?? "";
    status = proposal.status ?? "";
    invoiceController.type.value = proposal.type ?? "";
    total.value = proposal.total?.toStringAsFixed(2) ?? "";
    if (proposal.requestedAmountType == 2) {
      // type = fixed
      selectedDepositRequestOption.value = "2";
      invoiceController.requestedDepositAmountEditTextController.text =
          proposal.requestedDepositAmount ?? "0.00";
      invoiceController.selectedDepositRequestOptionName.value =
          invoiceController.depositRequestOptions[2]["name"];
    }
    if (proposal.requestedAmountType == 1) {
      // type = percentage
      invoiceController.selectedDepositRequestOption.value = "1";
      invoiceController.requestDepositRateEditTextController.text =
          proposal.requestedDepositPercentage ?? "0.00";
      invoiceController.requestedDepositAmountEditTextController.text =
          proposal.requestedDepositAmount ?? "0.00";
      invoiceController.selectedDepositRequestOptionName.value =
          invoiceController.depositRequestOptions[1]["name"];
    }
    if (proposal.requestedAmountType == 0) {
      // type = null
      invoiceController.selectedDepositRequestOption.value = "0";
      invoiceController.requestDepositRateEditTextController.text =
          proposal.requestedDepositPercentage ?? "0.00";
      invoiceController.requestedDepositAmountEditTextController.text =
          proposal.requestedDepositAmount ?? "0.00";
      invoiceController.selectedDepositRequestOptionName.value =
          invoiceController.depositRequestOptions[0]["name"];
    }
    notes = proposal.note ?? "";
    invoiceController.editNoteTextController.text = proposal.note ?? "";
    due = proposal.due ?? "";
    invoiceController.showingDate.value = dateTimeConverter(
      inputFormat: "yyyy/MM/dd hh:mm a",
      inputTime: proposal.invoiceDate.toString(),
      outputFormat: "MM/dd/yyyy",
    );
    if (proposal.taxType != "") {
      invoiceController.initialTaxID.value = proposal.taxType ?? "";
    }

    // Set discount values
    invoiceController.invoiceDiscountDetails.value = proposal.discount ?? 0.00;
    if (proposal.discountOption == "1") {
      invoiceController.editDiscountTextController.text = (((double.parse(
                    proposal.discount?.toString() ?? "0.00",
                  )) *
                  100) /
              double.parse(
                proposal.subtotal?.toStringAsFixed(
                      2,
                    ) ??
                    "0.00",
              ))
          .toStringAsFixed(2);
    } else {
      invoiceController.editDiscountTextController.text = double.parse(
        proposal.discount?.toString() ?? "0.00",
      ).toStringAsFixed(2);
    }

    // Set tax values

    tax.value = taxes
            .firstWhereOrNull(
              (tax) =>
                  tax.id ==
                  int.tryParse(
                    invoiceController.initialTaxID.value,
                  ),
            )
            ?.rate
            ?.toStringAsFixed(2) ??
        "0.00";
    invoiceController.selectedTaxName.value = taxes
            .firstWhereOrNull(
              (tax) =>
                  tax.id ==
                  int.tryParse(
                    invoiceController.initialTaxID.value,
                  ),
            )
            ?.name ??
        "";

    // Populate selectedItemList and initialize controllers
    if (proposal.items != null && proposal.items!.isNotEmpty) {
      for (var item in proposal.items!) {
        invoiceController.selectedItemList.add(
          ItemListModel(
            id: item.itemId,
            name: item.name,
            description: item.description,
            price: double.tryParse(
              item.unitPrice ?? "0.00",
            ),
            isTaxable: item.isTaxable == "TAX" ? true : false,
            // itemTypeId: int.parse(item.itemTyId!),
          ),
        );

        // Initialize controllers with existing values
        invoiceController.editAmountControllers.add(
          TextEditingController(
            text: item.unitPrice ?? "0.00",
          ),
        );

        invoiceController.editDescriptionControllers.add(
          TextEditingController(
            text: item.description ?? "",
          ),
        );

        invoiceController.editQuantityControllers.add(
          TextEditingController(
            text: item.quantity ?? "1",
          ),
        );
      }
    }
    invoiceController.createTotalForEdit();
    await 0.5.delay();
    invoiceController.selectedQboClass(
      qboClassList
          .where(
            (e) => e.qboClassId.toString() == proposal.qboClassId,
          )
          .firstOrNull,
    );
    invoiceController.selectedQboLocation(
      invoiceController.qboLocationList
          .where(
            (e) => e.qboLocationId.toString() == proposal.qboLocationId,
          )
          .firstOrNull,
    );
    removedList.clear(); // Optional small delay before navigation

    final x = MySharedPref.getCompanyType() ?? '';
    isLocAndClassShow.value = x == 'PCS';
    selectedInvoice.value = proposal;
    requestDepositRateEditTextController.clear();
    requestedDepositAmountEditTextController.clear();
    editNoteTextController.clear();
    hideLoading(debugInfo: "getInvoiceDetails - Success");

    // Show success toast if payment was successful
    if (response['IsValid'] == true && response['Message'] != null) {
      MySnackBar.showToast(
        message: response['Message'],
      );
    }

    Get.back();
    Get.back();
    log("Deposit Response: $response");
  }

  final selectedInvoice = Rxn<Invoices>();
  Future<void> generateTuaPaymentLink() async {
    showLoading(debugInfo: "generateTuaPaymentLink - Start");
    var companyID = MySharedPref.getCompanyID();

    var response = await DioClient().post(
      url: ApiUrl.generateTuaPaymentLink,
      body: {
        "request": {
          "CompanyID": companyID,
          "MerchantName": '',
          "CustomerID": customerID.value,
          "FirstName": tuaFirstNameController.text,
          "LastName": tuaLastNameController.text,
          "Email": tuaEmailController.text,
          "Mobile": tuaMobileController.text,
          "Address": tuaAddressController.text,
          "City": tuaCityController.text,
          "State": tuaStateController.text,
          "ZipCode": tuaZipCodeController.text,
          "InvoiceNumber": invoiceNumber,
          "LoanAmount": tuaRemainAmountController.text,
          "BaseAmount": tuaBaseAmountController.text,
          "Percentage": 10,
          "QBOCustomerID":
              int.parse(selectedInvoice.value!.qBOCustomerId ?? '0'),
          "QBOInvoiceID": int.parse(selectedInvoice.value!.qBOId ?? '0'),
          "SendTextLink": true,
        }
      },
    ).catchError(handleError);

    if (response == null) return;

    hideLoading(debugInfo: "generateTuaPaymentLink - Success");
    MySnackBar.showToast(
        message: response["Message"] ?? "Payment link generated successfully");
    log(response["Message"] ?? "Payment link generated successfully");
  }

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

  Future<void> getXPayLink(String amount) async {
    showLoading(debugInfo: "getXPayLink - Start");
    var companyID = MySharedPref.getCompanyID();
    var response = await DioClient().get(
      url:
          "https://jobs-msschedules.myserviceforce.com/Services/DeviceService.asmx/GenerateXPayLink?companyId=$companyID&customerId=${customerID.value}&invoiceId=${invoiceID.value}&customerName=$customerName&email=$createCustomerEmail&amount=$amount",
      params: {},
    ).catchError(handleError);

    if (response == null) return;
    log("XPay Link: $response");
    hideLoading(debugInfo: "getXPayLink - Success");
    await initializeWebController2(response['XPayLink']);
    Get.toNamed(Routes.XPAY_PAYMENT);
  }

  ///
  final isDirty = false.obs;

  // Call this whenever a change is made
  void markAsDirty() {
    isDirty.value = true;
  }

  // Unfocus all create invoice focus nodes
  void unfocusAllCreateInvoiceNodes() {
    createInvoiceDiscountFocusnode.value.unfocus();
    createInvoiceNotesFocusnode.value.unfocus();
    createInvoiceSearchFocusnode.value.unfocus();
    createInvoiceEmailToFocusnode.value.unfocus();
    createInvoiceEmailBccFocusnode.value.unfocus();
    createInvoiceEmailSubjectFocusnode.value.unfocus();
    createInvoiceEmailBodyFocusnode.value.unfocus();
  }

  @override
  void onReady() async {
    await itemController.getItems(false);
    isDirty.value = false;
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

    // Dispose focus nodes
    invoiceDetailsNoteFocusnode.value.dispose();
    invoiceDetailsEmailToFocusnode.value.dispose();
    invoiceDetailsEmailBccFocusnode.value.dispose();
    invoiceDetailsEmailSubjectFocusnode.value.dispose();
    invoiceDetailsEmailBodyFocusnode.value.dispose();
    invoiceDetailsSearchFocusnode.value.dispose();
    invoiceDetailsEditDiscountFocusnode.value.dispose();
    invoiceDetailsDepositRateFocusnode.value.dispose();

    // Dispose create invoice focus nodes
    createInvoiceDiscountFocusnode.value.dispose();
    createInvoiceNotesFocusnode.value.dispose();
    createInvoiceSearchFocusnode.value.dispose();
    createInvoiceEmailToFocusnode.value.dispose();
    createInvoiceEmailBccFocusnode.value.dispose();
    createInvoiceEmailSubjectFocusnode.value.dispose();
    createInvoiceEmailBodyFocusnode.value.dispose();

    super.dispose();
  }
}
