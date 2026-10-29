import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../utils/date_converter.dart';
import '../../../components/global-widgets/customer_signature_section.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../appointment/controllers/appointment_controller.dart';
import '../../item/models/item_list_model.dart';
import '../controllers/invoice_controller.dart';

class ManualPaymentView extends GetView<InvoiceController> {
  const ManualPaymentView({super.key});
  // Get invoiceId from navigation arguments
  String get invoiceId {
    // Try arguments first (passed via arguments parameter)
    if (Get.arguments is Map) {
      final args = Get.arguments as Map<String, dynamic>;
      return args['invoiceId']?.toString() ?? '';
    }
    // Fallback to direct argument (if passed as single value)
    return Get.arguments?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Manual Payment'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              _amount(theme),
              SizedBox(
                height: 350.sp,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Obx(
                    () => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.sp),
                          child: WebViewWidget(
                            controller: controller.webController,
                          ),
                        ),
                        if (controller.isLoading.value)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15.sp),
              // Customer Signature Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.sp),
                child: CustomerSignatureSection(),
              ),
              SizedBox(height: 30.h),
              _backButton(), SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Container _amount(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(12.sp),
      width: double.infinity,
      height: 40.sp,
      decoration: BoxDecoration(
        border: Border.all(color: theme.primaryColor, width: 1.sp),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Center(
        child: controller.depositRequestPay.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Amount to be collected: "),
                  Text(
                    "\$${controller.requestedDepositAmountEditTextController.text}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Amount to be collected: "),
                  Text(
                    "\$${controller.finalCollectionAmount.value}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  SizedBox _backButton() {
    return SizedBox(
      height: 48.h,
      width: 120.sp,
      child: PrimaryButton(
        title: "Back",
        onPressed: () async {
          controller.showLoading(debugInfo: "ManualPayment - Back button");
          final apptC = Get.find<AppointmentController>();
          final invoiceC = Get.find<InvoiceController>();
          await apptC.getAppointments();
          await apptC.getInvoiceList();
          invoiceC.selectedItemList.clear();
          final appt = !invoiceC.isExternalInvoice.value
              ? apptC.sortedAppointments
                    .where(
                      (element) =>
                          element.apptID.toString() ==
                          apptC.appointmentID.toString(),
                    )
                    .first
              : apptC.extendedAppointments
                    .where(
                      (element) =>
                          element.apptID.toString() ==
                          apptC.appointmentID.toString(),
                    )
                    .first;

          final proposal = appt.invoices!.firstWhere(
            (element) => element.invoiceID.toString() == invoiceId,
          );

          invoiceC.invoiceItemList.value = proposal.items ?? [];
          invoiceC.depositList.value = proposal.paymentList ?? [];
          await invoiceC.saveSignature(
            payment: invoiceC.depositList.isNotEmpty
                ? invoiceC.depositList.first
                : null,
          );
          invoiceC.selectedDiscountOption.value =
              proposal.discountOption ?? "2";
          invoiceC.invoiceNumber = proposal.number ?? "";
          invoiceC.isConverted.value = proposal.isConverted ?? false;
          invoiceC.customerName = proposal.fullName ?? "";
          invoiceC.address = "${proposal.city}, ";
          invoiceC.depositAmount.value =
              proposal.depositAmount?.toStringAsFixed(2) ?? "0.00";
          invoiceC.invoiceID.value = proposal.invoiceID.toString();
          invoiceC.date = dateTimeConverter(
            inputFormat: "yyyy/MM/dd",
            inputTime: proposal.invoiceDate.toString(),
            outputFormat: "MM/dd/yyyy",
          );
          invoiceC.subtotal = proposal.subtotal?.toStringAsFixed(2) ?? "";
          invoiceC.customerID.value = proposal.customerId ?? "";
          invoiceC.status = proposal.status ?? "";
          invoiceC.type.value = proposal.type ?? "";
          invoiceC.total.value = proposal.total?.toStringAsFixed(2) ?? "";
          if (proposal.requestedAmountType == 2) {
            // type = fixed
            invoiceC.selectedDepositRequestOption.value = "2";
            invoiceC.requestedDepositAmountEditTextController.text =
                proposal.requestedDepositAmount ?? "0.00";
            invoiceC.selectedDepositRequestOptionName.value =
                invoiceC.depositRequestOptions[2]["name"];
          }
          if (proposal.requestedAmountType == 1) {
            // type = percentage
            invoiceC.selectedDepositRequestOption.value = "1";
            invoiceC.requestDepositRateEditTextController.text =
                proposal.requestedDepositPercentage ?? "0.00";
            invoiceC.requestedDepositAmountEditTextController.text =
                proposal.requestedDepositAmount ?? "0.00";
            invoiceC.selectedDepositRequestOptionName.value =
                invoiceC.depositRequestOptions[1]["name"];
          }
          if (proposal.requestedAmountType == 0) {
            // type = null
            invoiceC.selectedDepositRequestOption.value = "0";
            invoiceC.requestDepositRateEditTextController.text =
                proposal.requestedDepositPercentage ?? "0.00";
            invoiceC.requestedDepositAmountEditTextController.text =
                proposal.requestedDepositAmount ?? "0.00";
            invoiceC.selectedDepositRequestOptionName.value =
                invoiceC.depositRequestOptions[0]["name"];
          }
          invoiceC.notes = proposal.note ?? "";
          invoiceC.editNoteTextController.text = proposal.note ?? "";
          invoiceC.due = proposal.due ?? "";
          invoiceC.showingDate.value = dateTimeConverter(
            inputFormat: "yyyy/MM/dd hh:mm a",
            inputTime: proposal.invoiceDate.toString(),
            outputFormat: "MM/dd/yyyy",
          );

          // Set discount values
          invoiceC.invoiceDiscountDetails.value = proposal.discount ?? 0.00;
          if (proposal.discountOption == "1") {
            invoiceC.editDiscountTextController.text =
                (((double.parse(proposal.discount?.toString() ?? "0.00")) *
                            100) /
                        double.parse(
                          proposal.subtotal?.toStringAsFixed(2) ?? "0.00",
                        ))
                    .toStringAsFixed(2);
          } else {
            invoiceC.editDiscountTextController.text = double.parse(
              proposal.discount?.toString() ?? "0.00",
            ).toStringAsFixed(2);
          }

          // Set tax values
          invoiceC.tax.value =
              invoiceC.taxes
                  .firstWhereOrNull(
                    (tax) =>
                        tax.id == int.tryParse(proposal.taxType ?? ""),
                  )
                  ?.rate
                  ?.toStringAsFixed(2) ??
              "0.00";
          invoiceC.selectedTaxName.value =
              invoiceC.taxes
                  .firstWhereOrNull(
                    (tax) =>
                        tax.id == int.tryParse(proposal.taxType ?? ""),
                  )
                  ?.name ??
              "";

          // Populate selectedItemList and initialize controllers
          if (proposal.items != null && proposal.items!.isNotEmpty) {
            for (var item in proposal.items!) {
              invoiceC.selectedItemList.add(
                ItemListModel(
                  id: item.itemId,
                  name: item.name,
                  description: item.description,
                  price: double.tryParse(item.unitPrice ?? "0.00"),
                  isTaxable: item.isTaxable == "TAX" ? true : false,
                  // itemTypeId: int.parse(item.itemTyId!),
                ),
              );

              // Initialize controllers with existing values
              invoiceC.editAmountControllers.add(
                TextEditingController(text: item.unitPrice ?? "0.00"),
              );

              invoiceC.editDescriptionControllers.add(
                TextEditingController(text: item.description ?? ""),
              );

              invoiceC.editQuantityControllers.add(
                TextEditingController(text: item.quantity ?? "1"),
              );
            }
          }
          invoiceC.createTotalForEdit();
          await 0.5.delay();
          invoiceC.selectedQboClass(
            invoiceC.qboClassList
                .where((e) => e.qboClassId.toString() == proposal.qboClassId)
                .firstOrNull,
          );
          invoiceC.selectedQboLocation(
            invoiceC.qboLocationList
                .where(
                  (e) => e.qboLocationId.toString() == proposal.qboLocationId,
                )
                .firstOrNull,
          );
          invoiceC.removedList
              .clear(); // Optional small delay before navigation

          final x = MySharedPref.getCompanyType() ?? '';
          invoiceC.isLocAndClassShow.value = x == 'PCS';
          invoiceC.selectedInvoice.value = proposal;
          invoiceC.requestDepositRateEditTextController.clear();
          invoiceC.requestedDepositAmountEditTextController.clear();
          invoiceC.editNoteTextController.clear();

          await controller.hideLoading(
            debugInfo: "ManualPayment - Back button - Data loaded",
          );
          Get.back();
          Get.back();
        },
        inactive: false,
      ),
    );
  }
}
