import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/general_text_field.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/my_buttons.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/date_converter.dart';
import '../../../../utils/url_launcher.dart';
import '../../../components/global-widgets/main_divider.dart';
import '../../../components/global-widgets/splash_container.dart';
import '../../../routes/app_pages.dart';
import '../../item/models/item_list_model.dart';
import '../controllers/appointment_controller.dart';

class AppointmentDetailsView extends GetView<AppointmentController> {
  const AppointmentDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment Details"),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            onTap: () async {
                              controller.showLoading();
                              await controller.customerController
                                  .getCustomers();
                              controller.customerController.businessName =
                                  controller.contactName;
                              controller.customerController.title =
                                  controller.customerTitle;
                              controller.customerController.address =
                                  controller.address;
                              controller.customerController.phoneNumber =
                                  controller.phoneNumber;
                              controller.customerController.mobileNumber =
                                  controller.mobileNumber;
                              controller.customerController.email =
                                  controller.email;

                              controller.hideLoading();

                              Get.toNamed(Routes.CUSTOMER_DETAILS);
                            },
                            title: Text(
                              "Contact Name",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              controller.contactName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Address",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 200.sp,
                              child: Text(
                                controller.address,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Request Date",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              controller.requestDate,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Start Date",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              controller.startDate,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "End Date",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              controller.endDate,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Time Slot",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              controller.timeSlot,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Service Type",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              controller.serviceType,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Mobile",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () async {
                                await UrlLauncher.phoneCall(
                                    controller.mobileNumber);
                              },
                              child: Text(
                                controller.mobileNumber,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Phone",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () async {
                                await UrlLauncher.phoneCall(
                                    controller.phoneNumber);
                              },
                              child: Text(
                                controller.phoneNumber,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Email",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 200.sp,
                              child: InkWell(
                                onTap: () async {
                                  await UrlLauncher.email(controller.email);
                                },
                                child: Text(
                                  controller.email,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.primaryColor,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Resource",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              controller.resource,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          MainDivider(),
                          Obx(() => Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12.sp),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Status",
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color:
                                                LightThemeColors.hintTextColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 8.sp),
                                        Container(
                                          height: 40.sp,
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.sp),
                                          decoration: BoxDecoration(
                                            color: LightThemeColors.fillColor,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            border: Border.all(
                                              width: 1,
                                              color: LightThemeColors
                                                  .hintTextColor,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2<int>(
                                              isExpanded: true,
                                              dropdownStyleData:
                                                  DropdownStyleData(
                                                      maxHeight: 245.sp,
                                                      width: 220.sp,
                                                      padding: EdgeInsets.zero,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.r),
                                                        color: LightThemeColors
                                                            .fillColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 0.2),
                                                            offset:
                                                                const Offset(
                                                                    0, 4),
                                                            blurRadius: 10,
                                                            spreadRadius: 0,
                                                          ),
                                                        ],
                                                      )),
                                              value: controller
                                                          .selectedStatusValue
                                                          .value ==
                                                      0
                                                  ? null
                                                  : controller
                                                      .selectedStatusValue
                                                      .value,
                                              hint: Text(
                                                'Select an option',
                                                style: TextStyle(
                                                  color: LightThemeColors
                                                      .hintTextColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              style: theme.textTheme.bodyMedium,
                                              items: controller
                                                  .settingController
                                                  .appointmentsStatus
                                                  .map((e) {
                                                return DropdownMenuItem<int>(
                                                  value: e.statusId,
                                                  child: Text(
                                                    e.statusName ?? "",
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (int? newValue) {
                                                if (newValue == 4) {
                                                  showAdaptiveDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                            'Warning!',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          content: const Text(
                                                              'Choosing close will remove the appointment from the list.Are you sure you want to close?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Get.back();
                                                              },
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Get.back();
                                                                controller
                                                                        .selectedStatusValue
                                                                        .value =
                                                                    newValue!;
                                                              },
                                                              child: Text(
                                                                'Close',
                                                                style:
                                                                    TextStyle(
                                                                  color: LightThemeColors
                                                                      .bodyTextSecondaryColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                } else {
                                                  controller.selectedStatusValue
                                                      .value = newValue!;
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10.sp),
                                  MainDivider(),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12.sp),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Ticket Status",
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color:
                                                LightThemeColors.hintTextColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 8.sp),
                                        Container(
                                          height: 40.sp,
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.sp),
                                          decoration: BoxDecoration(
                                            color: LightThemeColors.fillColor,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            border: Border.all(
                                              width: 1,
                                              color: LightThemeColors
                                                  .hintTextColor,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2<int>(
                                              isExpanded: true,
                                              dropdownStyleData:
                                                  DropdownStyleData(
                                                      maxHeight: 200.sp,
                                                      width: 220.sp,
                                                      padding: EdgeInsets.zero,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.r),
                                                        color: LightThemeColors
                                                            .fillColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 0.2),
                                                            offset:
                                                                const Offset(
                                                                    0, 4),
                                                            blurRadius: 10,
                                                            spreadRadius: 0,
                                                          ),
                                                        ],
                                                      )),
                                              value: controller
                                                          .selectedTicketStatusValue
                                                          .value ==
                                                      0
                                                  ? null
                                                  : controller
                                                      .selectedTicketStatusValue
                                                      .value,
                                              hint: Text(
                                                'Select an option',
                                                style: TextStyle(
                                                  color: LightThemeColors
                                                      .hintTextColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              style: theme.textTheme.bodyMedium,
                                              items: controller
                                                  .settingController.tickets
                                                  .map((e) {
                                                return DropdownMenuItem<int>(
                                                  value: e.statusId,
                                                  child: Text(
                                                    e.statusName ?? "",
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (int? newValue) {
                                                controller
                                                    .selectedTicketStatusValue
                                                    .value = newValue!;
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          MainDivider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.sp, horizontal: 12.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Notes",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: LightThemeColors.hintTextColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GeneralTextField(
                                      maxLine: 4,
                                      hint: "Add a note here..",
                                      theme: theme,
                                      textEditingController:
                                          controller.noteTextController),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    SizedBox(
                      width: double.infinity,
                      height: 48.sp,
                      child: PrimaryButton(
                          title: "Update",
                          onPressed: () async {
                            await controller.updateAppointment(
                                controller.selectedTicketStatusValue.value
                                    .toString(),
                                controller.selectedStatusValue.value
                                    .toString());
                          },
                          inactive: false),
                    ),
                    SizedBox(height: 35.sp),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              "Estimate/Invoice Details",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.sp),
                          Builder(builder: (context) {
                            return SplashContainer(
                              height: 45.sp,
                              width: 150.sp,
                              radius: 5,
                              color: theme.primaryColor,
                              onPressed: () {
                                RenderBox renderBox =
                                    context.findRenderObject() as RenderBox;
                                Offset offset = renderBox
                                    .localToGlobal(Offset(32.sp, 40.sp));
                                final RenderBox overlay = Overlay.of(context)
                                    .context
                                    .findRenderObject() as RenderBox;
                                showMenu(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.r)),
                                  ),
                                  context: context,
                                  position: RelativeRect.fromRect(
                                      offset &
                                          Size(
                                              32.sp,
                                              32
                                                  .sp), // smaller rect, the touch area
                                      Offset.zero &
                                          overlay
                                              .size // Bigger rect, the entire screen
                                      ),
                                  items: controller
                                      .invoiceController.createTypes
                                      .map((e) {
                                    return PopupMenuItem(
                                      value: e["name"],
                                      child: Text("${e["name"]}"),
                                    );
                                  }).toList(),
                                ).then((v) async {
                                  if (v != null) {
                                    controller.invoiceController
                                        .clearAllItems();
                                    controller.invoiceController
                                        .selectedCreateType.value = v;

                                    if (v == "Invoice") {
                                      controller.invoiceController
                                              .createCustomerName =
                                          controller.contactName;
                                      controller.invoiceController
                                              .createCustomerAddress =
                                          controller.address;
                                      controller.invoiceController
                                              .createCustomerPhone =
                                          controller.mobileNumber;
                                      controller.invoiceController
                                              .createCustomerEmail =
                                          controller.email;
                                      controller.invoiceController.customerID
                                          .value = controller.customerID;
                                      controller
                                              .invoiceController.appointmentID =
                                          controller.appointmentID;
                                      controller.invoiceController.selectedTaxID
                                          .value = "";
                                      controller.invoiceController
                                          .createDiscountTextController
                                          .clear();
                                      await controller.invoiceController
                                          .getInvoiceName();
                                      Get.toNamed(Routes.INVOICE_CREATE);
                                    } else {
                                      controller.invoiceController
                                              .createCustomerName =
                                          controller.contactName;
                                      controller.invoiceController
                                              .createCustomerAddress =
                                          controller.address;
                                      controller.invoiceController
                                              .createCustomerPhone =
                                          controller.mobileNumber;
                                      controller.invoiceController
                                              .createCustomerEmail =
                                          controller.email;
                                      controller.invoiceController.customerID
                                          .value = controller.customerID;

                                      controller
                                              .invoiceController.appointmentID =
                                          controller.appointmentID;
                                      controller.invoiceController.selectedTaxID
                                          .value = "";
                                      controller.invoiceController
                                          .createDiscountTextController
                                          .clear();
                                      await controller.invoiceController
                                          .getInvoiceName();
                                      Get.toNamed(Routes.INVOICE_CREATE);
                                    }
                                  }
                                });
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 5.sp),
                                    Text(
                                      "Create New",
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.sp),
                    Obx(() => ListView.separated(
                          itemBuilder: (context, index) {
                            final proposal = controller
                                .appointments[controller.selectedAptIndex.value]
                                .invoices![index];

                            return GestureDetector(
                              onTap: () async {
                                controller.showLoading();

                                // Clear previous selection if needed
                                controller.invoiceController.selectedItemList
                                    .clear();
                                for (var c in controller
                                    .invoiceController.editAmountControllers) {
                                  c.dispose();
                                }
                                for (var c in controller.invoiceController
                                    .editDescriptionControllers) {
                                  c.dispose();
                                }
                                for (var c in controller.invoiceController
                                    .editQuantityControllers) {
                                  c.dispose();
                                }
                                controller
                                    .invoiceController.editAmountControllers
                                    .clear();
                                controller.invoiceController
                                    .editDescriptionControllers
                                    .clear();
                                controller
                                    .invoiceController.editQuantityControllers
                                    .clear();
                                controller
                                    .invoiceController.editNoteTextController
                                    .clear();
                                controller.invoiceController
                                    .editDiscountTextController
                                    .clear();
                                controller
                                    .invoiceController.initialTaxID.value = "";

                                // Set basic info
                                controller.invoiceController.invoiceItemList
                                    .value = proposal.items ?? [];
                                controller.invoiceController.depositList.value =
                                    proposal.paymentList ?? [];
                                controller
                                    .invoiceController
                                    .selectedDiscountOption
                                    .value = proposal.discountOption ?? "2";
                                controller.invoiceController.invoiceNumber =
                                    proposal.number ?? "";
                                controller.invoiceController.isConverted.value =
                                    proposal.isConverted ?? false;
                                controller.invoiceController.customerName =
                                    proposal.fullName ?? "";
                                controller.invoiceController.address =
                                    "${proposal.city}";
                                controller.invoiceController.depositAmount
                                    .value = proposal.depositAmount.toString();
                                controller.invoiceController.invoiceID.value =
                                    proposal.invoiceID.toString();
                                controller.invoiceController.date =
                                    dateTimeConverter(
                                        inputFormat: "yyyy/MM/dd",
                                        inputTime:
                                            proposal.invoiceDate.toString(),
                                        outputFormat: "MM/dd/yyyy");
                                controller.invoiceController.subtotal =
                                    proposal.subtotal?.toStringAsFixed(1) ?? "";
                                controller.invoiceController.customerID.value =
                                    proposal.customerId ?? "";
                                controller.invoiceController.status =
                                    proposal.status ?? "";
                                controller.invoiceController.type.value =
                                    proposal.type ?? "";
                                controller.invoiceController.total.value =
                                    proposal.total?.toStringAsFixed(1) ?? "";
                                controller.invoiceController.newTotal.value =
                                    controller.invoiceController.total.value;
                                controller.invoiceController.notes =
                                    proposal.note ?? "";
                                controller
                                    .invoiceController
                                    .editNoteTextController
                                    .text = proposal.note ?? "";
                                controller.invoiceController.due =
                                    proposal.due ?? "";
                                controller.invoiceController.showingDate.value =
                                    dateTimeConverter(
                                        inputFormat: "yyyy/MM/dd hh:mm a",
                                        inputTime:
                                            proposal.invoiceDate.toString(),
                                        outputFormat: "MM/dd/yyyy");
                                if (proposal.taxType != "") {
                                  controller.invoiceController.initialTaxID
                                      .value = proposal.taxType ?? "";
                                }
                                // Set discount values
                                controller
                                    .invoiceController
                                    .invoiceDiscountDetails
                                    .value = proposal.discount ?? 0.00;
                                if (proposal.discountOption == "1") {
                                  controller
                                      .invoiceController
                                      .editDiscountTextController
                                      .text = (((double.parse(proposal.discount
                                                      ?.toString() ??
                                                  "0.00")) *
                                              100) /
                                          double.parse(proposal.subtotal
                                                  ?.toStringAsFixed(2) ??
                                              "0.00"))
                                      .toStringAsFixed(2);
                                } else {
                                  controller
                                      .invoiceController
                                      .editDiscountTextController
                                      .text = double.parse(
                                          proposal.discount?.toString() ??
                                              "0.00")
                                      .toStringAsFixed(2);
                                }

                                // Set tax values

                                controller.invoiceController.tax.value =
                                    controller.invoiceController.taxes
                                            .firstWhereOrNull((tax) =>
                                                tax.id ==
                                                int.tryParse(controller
                                                    .invoiceController
                                                    .initialTaxID
                                                    .value))
                                            ?.rate
                                            ?.toStringAsFixed(2) ??
                                        "0.00";

                                // Populate selectedItemList and initialize controllers
                                if (proposal.items != null &&
                                    proposal.items!.isNotEmpty) {
                                  for (var item in proposal.items!) {
                                    controller
                                        .invoiceController.selectedItemList
                                        .add(ItemListModel(
                                      id: item.itemId,
                                      name: item.name,
                                      description: item.description,
                                      price: double.tryParse(
                                          item.unitPrice ?? "0.00"),
                                      isTaxable: item.isTaxable == "TAX"
                                          ? true
                                          : false,
                                      // itemTypeId: int.parse(item.itemTyId!),
                                    ));

                                    // Initialize controllers with existing values
                                    controller
                                        .invoiceController.editAmountControllers
                                        .add(TextEditingController(
                                            text: item.unitPrice ?? "0.00"));

                                    controller.invoiceController
                                        .editDescriptionControllers
                                        .add(TextEditingController(
                                            text: item.description ?? ""));

                                    controller.invoiceController
                                        .editQuantityControllers
                                        .add(TextEditingController(
                                            text: item.quantity ?? "1"));
                                  }
                                }
                                controller.invoiceController
                                    .createTotalForEdit();
                                await 0.5
                                    .delay(); // Optional small delay before navigation
                                controller.hideLoading();
                                Get.toNamed(Routes.INVOICE_DETAILS);
                              },
                              child: Card(
                                elevation: 0,
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        "${proposal.type ?? ""} Number",
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: LightThemeColors.hintTextColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.sp, vertical: 2.sp),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          color: proposal.type == "Invoice"
                                              ? theme.primaryColor
                                              : proposal.type == "Estimate" &&
                                                      proposal.isConverted ==
                                                          true
                                                  ? Colors.green
                                                  : Colors.yellow,
                                        ),
                                        child: Text(
                                          proposal.number ?? "",
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                proposal.type == "Estimate" &&
                                                        proposal.isConverted ==
                                                            false
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    MainDivider(),
                                    ListTile(
                                      title: Text(
                                        "Date",
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: LightThemeColors.hintTextColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: proposal.invoiceDate != ""
                                          ? Text(
                                              dateTimeConverter(
                                                  inputFormat:
                                                      "yyyy/MM/dd hh:mm a",
                                                  inputTime: proposal
                                                      .invoiceDate
                                                      .toString(),
                                                  outputFormat: "MM/dd/yyyy"),
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          : Text(""),
                                    ),
                                    MainDivider(),
                                    ListTile(
                                      title: Text(
                                        "Required Amount",
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: LightThemeColors.hintTextColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: Text(
                                        "\$${proposal.total?.toStringAsFixed(2) ?? ""}",
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    MainDivider(),
                                    ListTile(
                                      title: Text(
                                        "Amount Received",
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: LightThemeColors.hintTextColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: Text(
                                        "\$${proposal.depositAmount?.toStringAsFixed(2) ?? ""}",
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              SizedBox(height: 8.sp),
                          itemCount: controller
                              .appointments[controller.selectedAptIndex.value]
                              .invoices!
                              .length,
                          shrinkWrap: true,
                          reverse: true,
                          physics: NeverScrollableScrollPhysics(),
                        )),
                    SizedBox(height: 15.sp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
