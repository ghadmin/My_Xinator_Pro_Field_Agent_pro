import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/main_divider.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../components/global-widgets/splash_container.dart'
    show SplashContainer;
import '../../../routes/app_pages.dart';
import '../../appointment/controllers/appointment_controller.dart';
import '../controllers/invoice_controller.dart';
import '../models/qbo_class_dropdown_model.dart';
import '../models/qbo_location_dropdown_model.dart';

class InvoiceDetailsView extends GetView<InvoiceController> {
  const InvoiceDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return WillPopScope(
      // important! controls hardware back button behavior
      onWillPop: () async {
        if (controller.isDirty.value) {
          final shouldSave = await _showUnsavedChangesDialogAsync(context);
          if (shouldSave == true) {
            await controller.editInvoice();
            // controller.isDetailsView(false); // Save automatically
            return true;
          } else {
            // controller.isDetailsView(false);
            Get.back();
            return false; // Prevent pop
          }
        }
        return true; // Allow pop
      },
      child: Scaffold(
        appBar: buildPreferredSize(context, theme),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.invoiceDetailsNoteFocusnode.value.unfocus();
            controller.invoiceDetailsEmailToFocusnode.value.unfocus();
            controller.invoiceDetailsEmailBccFocusnode.value.unfocus();
            controller.invoiceDetailsEmailSubjectFocusnode.value.unfocus();
            controller.invoiceDetailsEmailBodyFocusnode.value.unfocus();
            controller.invoiceDetailsSearchFocusnode.value.unfocus();
            controller.invoiceDetailsEditDiscountFocusnode.value.unfocus();
            controller.invoiceDetailsDepositRateFocusnode.value.unfocus();
          },
          child: SafeArea(
            child: Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.sp,
                  vertical: 20.sp,
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.sp,
                          vertical: 6.sp,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.r),
                          color: controller.type.value == "Invoice"
                              ? theme.primaryColor
                              : controller.type.value == "Estimate" &&
                                    controller.isConverted.value == true
                              ? Colors.green
                              : Colors.yellow,
                        ),
                        child: Text(
                          "${controller.type.value}: ${controller.invoiceNumber}",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color:
                                controller.type.value == "Estimate" &&
                                    controller.isConverted.value == false
                                ? Colors.black
                                : Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      estimateDetails(theme),
                      SizedBox(height: 20.sp),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0.sp),
                        child: Text(
                          "Billable Items",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      itemsList(theme),
                      SizedBox(height: 15.sp),
                      SizedBox(
                        height: 52.h,
                        child: SecondaryButtonWithIcon(
                          title: "Add Item",
                          iconData: Icons.add_circle_outline,
                          onPressed: () {
                            controller.invoiceDetailsNoteFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsEmailToFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsEmailBccFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsEmailSubjectFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsEmailBodyFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsSearchFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsEditDiscountFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsDepositRateFocusnode.value
                                .unfocus();
                            controller.itemController.sortTextController
                                .clear();
                            controller.itemController.sortItems();
                            return _showAddItemDialog(context, theme);
                          },
                          inactive: false,
                        ),
                      ),
                      SizedBox(height: 20.sp),
                      if (controller.isLocAndClassShow.value)
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            "Location",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: LightThemeColors.bodyTextSecondaryColor,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      if (controller.isLocAndClassShow.value)
                        SizedBox(height: 5.sp),
                      if (controller.isLocAndClassShow.value)
                        DropdownButtonFormField<QboLocationModel>(
                          initialValue: controller.selectedQboLocation.value,
                          hint: Text("Select Location"),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.sp,
                              vertical: 8.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          items: controller.qboLocationList.map((loc) {
                            return DropdownMenuItem(
                              value: loc,
                              child: Text(loc.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            controller.selectedQboLocation(val);
                          },
                        ),
                      if (controller.isLocAndClassShow.value)
                        if (controller.isLocAndClassShow.value)
                          SizedBox(height: 5.sp),

                      // Class Dropdown
                      if (controller.isLocAndClassShow.value)
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            "Class",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: LightThemeColors.bodyTextSecondaryColor,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      SizedBox(height: 5.sp),
                      if (controller.isLocAndClassShow.value)
                        Obx(() {
                          // This forces Obx to listen to the loading state
                          final isLoading = controller.isLoadingQboClass.value;
                          final classList = controller.qboClassList;

                          return DropdownButtonFormField<QboClassModel>(
                            initialValue: controller.selectedQboClass.value,
                            hint: const Text("Select Class"),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.sp,
                                vertical: 8.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            items: isLoading
                                ? [
                                    const DropdownMenuItem(
                                      value: null,
                                      enabled: false,
                                      child: Text("Loading..."),
                                    ),
                                  ]
                                : classList.isEmpty
                                ? [
                                    const DropdownMenuItem(
                                      value: null,
                                      enabled: false,
                                      child: Text("No data available"),
                                    ),
                                  ]
                                : classList.map((cls) {
                                    return DropdownMenuItem(
                                      value: cls,
                                      child: Text(cls.name),
                                    );
                                  }).toList(),
                            onChanged: (val) {
                              controller.selectedQboClass.value = val;
                            },
                          );
                        }),
                      SizedBox(height: 5.sp),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0.sp),
                        child: Text(
                          "Deposit List",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      Card(
                        color: Colors.white,
                        elevation: 0,
                        child: SizedBox(
                          width: double.infinity,
                          child: RawScrollbar(
                            thumbVisibility: true,
                            trackVisibility: true,
                            interactive: true,
                            thickness: 5.sp,
                            radius: Radius.circular(100.r),
                            thumbColor: theme.primaryColor,
                            trackColor: Colors.grey.shade400,
                            trackRadius: Radius.circular(8.r),
                            controller: controller.scrollController,
                            child: SingleChildScrollView(
                              controller: controller.scrollController,
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowHeight: 40.sp,
                                headingRowColor: WidgetStatePropertyAll(
                                  theme.primaryColor,
                                ),
                                headingTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                dividerThickness: 2,
                                columns: const [
                                  DataColumn(label: Text("Date")),
                                  DataColumn(label: Text("Amount")),
                                  DataColumn(label: Text("Type")),
                                  DataColumn(label: Text("Check Name")),
                                  DataColumn(label: Text("Check Number")),
                                  DataColumn(label: Text("Source")),
                                ],
                                rows: controller.depositList.map<DataRow>((
                                  deposit,
                                ) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(deposit.createdDate ?? "")),
                                      DataCell(
                                        Text(
                                          "\$${deposit.amount?.toStringAsFixed(2) ?? "0.00"}",
                                        ),
                                      ),
                                      DataCell(Text(deposit.type ?? "")),
                                      DataCell(Text(deposit.checkName ?? "")),
                                      DataCell(Text(deposit.checkNumber ?? "")),
                                      DataCell(Text(deposit.source ?? "")),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.sp),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0.sp),
                        child: Text(
                          "Payments Details",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      paymentDetails(theme, context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget buildPreferredSize(
    BuildContext context,
    ThemeData theme,
  ) {
    return Get.size.width <= 440
        ? AppBar(
            title: Text('${controller.type.value} Details'),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 15.sp),
                child: IconButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    controller.invoiceDetailsNoteFocusnode.value.unfocus();
                    controller.invoiceDetailsEmailToFocusnode.value.unfocus();
                    controller.invoiceDetailsEmailBccFocusnode.value.unfocus();
                    controller.invoiceDetailsEmailSubjectFocusnode.value
                        .unfocus();
                    controller.invoiceDetailsEmailBodyFocusnode.value.unfocus();
                    controller.invoiceDetailsSearchFocusnode.value.unfocus();
                    await Future.delayed(Duration(milliseconds: 100));
                    await controller.getEmailAutofill(
                      emailType: controller.type.value,
                    );
                    if (context.mounted) {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        useSafeArea: true,
                        enableDrag: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                controller.invoiceDetailsNoteFocusnode.value
                                    .unfocus();
                                controller.invoiceDetailsEmailToFocusnode.value
                                    .unfocus();
                                controller.invoiceDetailsEmailBccFocusnode.value
                                    .unfocus();
                                controller
                                    .invoiceDetailsEmailSubjectFocusnode
                                    .value
                                    .unfocus();
                                controller
                                    .invoiceDetailsEmailBodyFocusnode
                                    .value
                                    .unfocus();
                                controller.invoiceDetailsSearchFocusnode.value
                                    .unfocus();
                                controller
                                    .invoiceDetailsEditDiscountFocusnode
                                    .value
                                    .unfocus();
                                controller
                                    .invoiceDetailsDepositRateFocusnode
                                    .value
                                    .unfocus();
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 20.sp,
                                  right: 20.sp,
                                  bottom: 20.sp,
                                  top: 5.sp,
                                ),
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Send Email",
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      SizedBox(height: 15.sp),
                                      GeneralTextField(
                                        hint: "To",
                                        theme: theme,
                                        focusNode: controller
                                            .invoiceDetailsEmailToFocusnode
                                            .value,
                                        textInputType:
                                            TextInputType.emailAddress,
                                        textEditingController:
                                            controller.toTextController,
                                      ),
                                      SizedBox(height: 10.sp),
                                      GeneralTextField(
                                        hint: "Bcc",
                                        theme: theme,
                                        focusNode: controller
                                            .invoiceDetailsEmailBccFocusnode
                                            .value,
                                        textInputType:
                                            TextInputType.emailAddress,
                                        textEditingController:
                                            controller.bccTextController,
                                      ),
                                      SizedBox(height: 10.sp),
                                      GeneralTextField(
                                        hint: "Subject",
                                        maxLine: 3,
                                        theme: theme,
                                        focusNode: controller
                                            .invoiceDetailsEmailSubjectFocusnode
                                            .value,
                                        textEditingController:
                                            controller.subjectTextController,
                                      ),
                                      SizedBox(height: 10.sp),
                                      GeneralTextField(
                                        hint: "Email body",
                                        theme: theme,
                                        maxLine: 8,
                                        minLine: 6,
                                        focusNode: controller
                                            .invoiceDetailsEmailBodyFocusnode
                                            .value,
                                        textInputType: TextInputType.multiline,
                                        textInputAction:
                                            TextInputAction.newline,
                                        textEditingController:
                                            controller.emailBodyTextController,
                                      ),
                                      SizedBox(height: 10.sp),
                                      Row(
                                        children: [
                                          Obx(
                                            () => Checkbox(
                                              activeColor: theme.primaryColor,
                                              checkColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                              ),
                                              side: BorderSide(
                                                color: LightThemeColors
                                                    .primaryColor,
                                                width: 1.sp,
                                              ),
                                              value: controller
                                                  .isSendXPayLink
                                                  .value,
                                              onChanged: (value) {
                                                controller
                                                    .invoiceDetailsNoteFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                    .invoiceDetailsEmailToFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                    .invoiceDetailsEmailBccFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                    .invoiceDetailsEmailSubjectFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                    .invoiceDetailsEmailBodyFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                    .invoiceDetailsSearchFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                        .isSendXPayLink
                                                        .value =
                                                    value!;
                                              },
                                            ),
                                          ),
                                          Text(
                                            "Send XPayLink",
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  color: LightThemeColors
                                                      .hintTextColor,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.sp),
                                      Row(
                                        children: [
                                          Obx(
                                            () => Checkbox(
                                              activeColor: theme.primaryColor,
                                              checkColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                              ),
                                              side: BorderSide(
                                                color: LightThemeColors
                                                    .primaryColor,
                                                width: 1.sp,
                                              ),
                                              value: controller
                                                  .isSendTuaPayLink
                                                  .value,
                                              onChanged: (value) {
                                                controller
                                                    .invoiceDetailsNoteFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                    .invoiceDetailsEmailToFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                    .invoiceDetailsEmailBccFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                    .invoiceDetailsEmailSubjectFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                    .invoiceDetailsEmailBodyFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                    .invoiceDetailsSearchFocusnode
                                                    .value
                                                    .unfocus();
                                                controller
                                                        .isSendTuaPayLink
                                                        .value =
                                                    value!;
                                              },
                                            ),
                                          ),
                                          Text(
                                            "Send TUA PAY Link",
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  color: LightThemeColors
                                                      .hintTextColor,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Obx(
                                        () => SizedBox(
                                          height:
                                              controller.selectedFiles.length <
                                                  5
                                              ? controller
                                                        .selectedFiles
                                                        .length *
                                                    50.sp
                                              : 200.sp,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                controller
                                                        .selectedFiles
                                                        .length <
                                                    4
                                                ? NeverScrollableScrollPhysics()
                                                : BouncingScrollPhysics(),
                                            itemCount:
                                                controller.selectedFiles.length,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                leading: Icon(
                                                  Remix.file_2_line,
                                                  color: Colors.green,
                                                  size: 16.sp,
                                                ),
                                                title: Text(
                                                  controller
                                                      .selectedFiles[index]
                                                      .path
                                                      .split('/')
                                                      .last,
                                                ),
                                                trailing: IconButton(
                                                  icon: Icon(
                                                    Icons.remove_circle,
                                                    color: Colors.red.shade300,
                                                  ),
                                                  onPressed: () {
                                                    controller.selectedFiles
                                                        .removeAt(index);
                                                    controller
                                                        .docFileList = RxList.from(
                                                      controller.selectedFiles,
                                                    ); // Update docFileList for upload
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   height: 52.h,
                                      //   child: SecondaryButtonWithIcon(
                                      //       title: "Add Attachment",
                                      //       onPressed: () async {
                                      //         await controller.pickFiles();
                                      //       },
                                      //       iconData: Remix.attachment_line,
                                      //       inactive: false),
                                      // ),
                                      SizedBox(height: 10.sp),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 52.h,
                                              child: SecondaryButton(
                                                title: "Cancel",
                                                onPressed: () {
                                                  controller.selectedFiles
                                                      .clear();
                                                  Get.back();
                                                },
                                                inactive: false,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10.sp),
                                          Expanded(
                                            child: SizedBox(
                                              height: 52.h,
                                              child: PrimaryButton(
                                                title: "Send",
                                                onPressed: () async {
                                                  // Check if TUA PAY Link is selected

                                                  await controller.sendEmail(
                                                    pdfType:
                                                        controller.type.value,
                                                    emailType:
                                                        controller.type.value,
                                                  );
                                                  if (controller
                                                      .isSendTuaPayLink
                                                      .value) {
                                                    _showTuaPayLinkDialog(
                                                      context,
                                                      theme,
                                                      controller,
                                                    );
                                                  }
                                                },
                                                inactive: false,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 50.sp),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  icon: Icon(Remix.telegram_2_fill, color: theme.primaryColor),
                ),
              ),
            ],
            centerTitle: false,
          )
        : PreferredSize(
            preferredSize: Size.fromHeight(40.sp),
            child: Padding(
              padding: EdgeInsets.only(top: 15.sp),
              child: AppBar(
                title: Text('${controller.type.value} Details'),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 15.sp),
                    child: IconButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        controller.invoiceDetailsNoteFocusnode.value.unfocus();
                        controller.invoiceDetailsEmailToFocusnode.value
                            .unfocus();
                        controller.invoiceDetailsEmailBccFocusnode.value
                            .unfocus();
                        controller.invoiceDetailsEmailSubjectFocusnode.value
                            .unfocus();
                        controller.invoiceDetailsEmailBodyFocusnode.value
                            .unfocus();
                        controller.invoiceDetailsSearchFocusnode.value
                            .unfocus();
                        controller.invoiceDetailsEditDiscountFocusnode.value
                            .unfocus();
                        controller.invoiceDetailsDepositRateFocusnode.value
                            .unfocus();
                        await Future.delayed(Duration(milliseconds: 100));
                        await controller.getEmailAutofill(
                          emailType: controller.type.value,
                        );
                        if (context.mounted) {
                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            isScrollControlled: true,
                            useSafeArea: true,
                            enableDrag: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (BuildContext context) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(
                                    context,
                                  ).viewInsets.bottom,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    controller.invoiceDetailsNoteFocusnode.value
                                        .unfocus();
                                    controller
                                        .invoiceDetailsEmailToFocusnode
                                        .value
                                        .unfocus();
                                    controller
                                        .invoiceDetailsEmailBccFocusnode
                                        .value
                                        .unfocus();
                                    controller
                                        .invoiceDetailsEmailSubjectFocusnode
                                        .value
                                        .unfocus();
                                    controller
                                        .invoiceDetailsEmailBodyFocusnode
                                        .value
                                        .unfocus();
                                    controller
                                        .invoiceDetailsSearchFocusnode
                                        .value
                                        .unfocus();
                                    controller
                                        .invoiceDetailsEditDiscountFocusnode
                                        .value
                                        .unfocus();
                                    controller
                                        .invoiceDetailsDepositRateFocusnode
                                        .value
                                        .unfocus();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: 20.sp,
                                      right: 20.sp,
                                      bottom: 20.sp,
                                      top: 5.sp,
                                    ),
                                    child: SingleChildScrollView(
                                      physics: BouncingScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Send Email",
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          SizedBox(height: 15.sp),
                                          GeneralTextField(
                                            hint: "To",
                                            theme: theme,
                                            focusNode: controller
                                                .invoiceDetailsEmailToFocusnode
                                                .value,
                                            textInputType:
                                                TextInputType.emailAddress,
                                            textEditingController:
                                                controller.toTextController,
                                          ),
                                          SizedBox(height: 10.sp),
                                          GeneralTextField(
                                            hint: "Bcc",
                                            theme: theme,
                                            focusNode: controller
                                                .invoiceDetailsEmailBccFocusnode
                                                .value,
                                            textInputType:
                                                TextInputType.emailAddress,
                                            textEditingController:
                                                controller.bccTextController,
                                          ),
                                          SizedBox(height: 10.sp),
                                          GeneralTextField(
                                            hint: "Subject",
                                            maxLine: 3,
                                            theme: theme,
                                            focusNode: controller
                                                .invoiceDetailsEmailSubjectFocusnode
                                                .value,
                                            textEditingController: controller
                                                .subjectTextController,
                                          ),
                                          SizedBox(height: 10.sp),
                                          GeneralTextField(
                                            hint: "Email body",
                                            theme: theme,
                                            maxLine: 8,
                                            minLine: 6,
                                            focusNode: controller
                                                .invoiceDetailsEmailBodyFocusnode
                                                .value,
                                            textInputType:
                                                TextInputType.multiline,
                                            textInputAction:
                                                TextInputAction.newline,
                                            textEditingController: controller
                                                .emailBodyTextController,
                                          ),
                                          SizedBox(height: 10.sp),
                                          Row(
                                            children: [
                                              Obx(
                                                () => Checkbox(
                                                  activeColor:
                                                      theme.primaryColor,
                                                  checkColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4.r,
                                                        ),
                                                  ),
                                                  side: BorderSide(
                                                    color: LightThemeColors
                                                        .primaryColor,
                                                    width: 1.sp,
                                                  ),
                                                  value: controller
                                                      .isSendXPayLink
                                                      .value,
                                                  onChanged: (value) {
                                                    controller
                                                            .isSendXPayLink
                                                            .value =
                                                        value!;
                                                  },
                                                ),
                                              ),
                                              Text(
                                                "Send XPayLink",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                      color: LightThemeColors
                                                          .hintTextColor,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5.sp),
                                          Row(
                                            children: [
                                              Obx(
                                                () => Checkbox(
                                                  activeColor:
                                                      theme.primaryColor,
                                                  checkColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4.r,
                                                        ),
                                                  ),
                                                  side: BorderSide(
                                                    color: LightThemeColors
                                                        .primaryColor,
                                                    width: 1.sp,
                                                  ),
                                                  value: controller
                                                      .isSendTuaPayLink
                                                      .value,
                                                  onChanged: (value) {
                                                    controller
                                                            .isSendTuaPayLink
                                                            .value =
                                                        value!;
                                                  },
                                                ),
                                              ),
                                              Text(
                                                "Send TUA PAY Link",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                      color: LightThemeColors
                                                          .hintTextColor,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          // Obx(() => SizedBox(
                                          //       height: controller.selectedFiles.length < 5
                                          //           ? controller.selectedFiles.length *
                                          //               50.sp
                                          //           : 200.sp,
                                          //       child: ListView.builder(
                                          //         shrinkWrap: true,
                                          //         physics:
                                          //             controller.selectedFiles.length < 4
                                          //                 ? NeverScrollableScrollPhysics()
                                          //                 : BouncingScrollPhysics(),
                                          //         itemCount:
                                          //             controller.selectedFiles.length,
                                          //         itemBuilder: (context, index) {
                                          //           return ListTile(
                                          //             leading: Icon(
                                          //               Remix.file_2_line,
                                          //               color: Colors.green,
                                          //               size: 16.sp,
                                          //             ),
                                          //             title: Text(controller
                                          //                 .selectedFiles[index].path
                                          //                 .split('/')
                                          //                 .last),
                                          //             trailing: IconButton(
                                          //               icon: Icon(
                                          //                 Icons.remove_circle,
                                          //                 color: Colors.red.shade300,
                                          //               ),
                                          //               onPressed: () {
                                          //                 controller.selectedFiles
                                          //                     .removeAt(index);
                                          //                 controller.docFileList =
                                          //                     RxList.from(controller
                                          //                         .selectedFiles); // Update docFileList for upload
                                          //               },
                                          //             ),
                                          //           );
                                          //         },
                                          //       ),
                                          //     )),
                                          // SizedBox(
                                          //   height: 52.h,
                                          //   child: SecondaryButtonWithIcon(
                                          //       title: "Add Attachment",
                                          //       onPressed: () async {
                                          //         await controller.pickFiles();
                                          //       },
                                          //       iconData: Remix.attachment_line,
                                          //       inactive: false),
                                          // ),
                                          SizedBox(height: 10.sp),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 52.h,
                                                  child: SecondaryButton(
                                                    title: "Cancel",
                                                    onPressed: () {
                                                      controller.selectedFiles
                                                          .clear();
                                                      Get.back();
                                                    },
                                                    inactive: false,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10.sp),
                                              Expanded(
                                                child: SizedBox(
                                                  height: 52.h,
                                                  child: PrimaryButton(
                                                    title: "Send",
                                                    onPressed: () async {
                                                      // Check if TUA PAY Link is selected
                                                      if (controller
                                                          .isSendTuaPayLink
                                                          .value) {
                                                        _showTuaPayLinkDialog(
                                                          context,
                                                          theme,
                                                          controller,
                                                        );
                                                      } else {
                                                        await controller
                                                            .sendEmail(
                                                              pdfType:
                                                                  controller
                                                                      .type
                                                                      .value,
                                                              emailType:
                                                                  controller
                                                                      .type
                                                                      .value,
                                                            );
                                                      }
                                                    },
                                                    inactive: false,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 50.sp),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      icon: Icon(
                        Remix.telegram_2_fill,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
                centerTitle: false,
              ),
            ),
          );
  }

  Card estimateDetails(ThemeData theme) {
    final apptC = Get.find<AppointmentController>();
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            contentPadding: Get.size.width <= 440
                ? null
                : EdgeInsets.symmetric(vertical: 8.sp, horizontal: 8.sp),
            title: Text(
              "Customer Name",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: LightThemeColors.hintTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              "${apptC.selectedCustomer.value!.firstName!} ${apptC.selectedCustomer.value!.lastName!}",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
          ),
          MainDivider(),
          Padding(
            padding: Get.size.width <= 440
                ? EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp)
                : EdgeInsets.symmetric(vertical: 8.sp, horizontal: 8.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Address",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: LightThemeColors.hintTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 16.sp),
                Expanded(
                  child: Text(
                    apptC.selectedCustomer.value!.address1 != null
                        ? "${apptC.selectedCustomer.value!.address1!} ${apptC.selectedCustomer.value!.city!}, ${apptC.selectedCustomer.value!.state!} ${apptC.selectedCustomer.value!.zipCode!}"
                        : "N/A",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
          MainDivider(),
          ListTile(
            contentPadding: Get.size.width <= 440
                ? null
                : EdgeInsets.symmetric(vertical: 8.sp, horizontal: 8.sp),
            title: Text(
              "Type",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: LightThemeColors.hintTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              controller.type.value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          MainDivider(),
          ListTile(
            contentPadding: Get.size.width <= 440
                ? null
                : EdgeInsets.symmetric(vertical: 8.sp, horizontal: 8.sp),
            title: Text(
              "Date",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: LightThemeColors.hintTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              controller.showingDate.value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemsList(ThemeData theme) {
    // log("selectedItem list length ${controller.selectedItemList.length}");
    return controller.selectedItemList.isEmpty
        ? SizedBox.shrink()
        : Card(
            elevation: 0,
            color: Colors.white,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
              itemCount: controller.selectedItemList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = controller.selectedItemList[index];
                return SplashContainer(
                  radius: 8,
                  onPressed: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: .5.sp,
                        color: theme.primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name ?? "",
                                  style: theme.textTheme.bodyLarge,
                                ),
                                SizedBox(height: 4.sp),
                                controller
                                        .editDescriptionControllers[index]
                                        .text
                                        .isEmpty
                                    ? SizedBox.shrink()
                                    : Text(
                                        controller
                                            .editDescriptionControllers[index]
                                            .text,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                SizedBox(height: 4.sp),
                                Text(
                                  "${controller.editQuantityControllers[index].text.isEmpty ? "1" : controller.editQuantityControllers[index].text} X \$${controller.editAmountControllers[index].text}",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 4.sp),
                                Text(
                                  "Taxable: ${item.isTaxable == true ? "Yes" : "No"}",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Remix.edit_2_line),
                                onPressed: () {
                                  controller.invoiceDetailsNoteFocusnode.value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailToFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailBccFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailSubjectFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailBodyFocusnode
                                      .value
                                      .unfocus();
                                  controller.invoiceDetailsSearchFocusnode.value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEditDiscountFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsDepositRateFocusnode
                                      .value
                                      .unfocus();
                                  showAdaptiveDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return Dialog(
                                        insetPadding: EdgeInsets.symmetric(
                                          horizontal: 16.sp,
                                        ), // Add padding for smaller screens
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 1
                                                .sw, // Enforce the calculated width
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(16.sp),
                                                child: Text(
                                                  'Edit Item',
                                                  style: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        color:
                                                            theme.primaryColor,
                                                      ),
                                                ),
                                              ),

                                              // Content
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16.sp,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Description",
                                                          style: theme
                                                              .textTheme
                                                              .bodyLarge,
                                                        ),
                                                        SizedBox(width: 10.sp),
                                                        Expanded(
                                                          child: GeneralTextField(
                                                            hint: "Description",
                                                            theme: theme,
                                                            maxLine: 4,
                                                            textEditingController:
                                                                controller
                                                                    .editDescriptionControllers[index],
                                                            onChanged: (v) {
                                                              controller
                                                                      .selectedItemList[index]
                                                                      .description =
                                                                  v;
                                                              controller
                                                                  .markAsDirty();
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10.sp),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Amount: \$",
                                                          style: theme
                                                              .textTheme
                                                              .bodyLarge,
                                                        ),
                                                        SizedBox(width: 18.sp),
                                                        Expanded(
                                                          child: GeneralTextField(
                                                            hint: "Amount",
                                                            textInputType:
                                                                TextInputType.numberWithOptions(
                                                                  decimal: true,
                                                                ),
                                                            theme: theme,
                                                            textEditingController:
                                                                controller
                                                                    .editAmountControllers[index],
                                                            onChanged: (value) {
                                                              controller
                                                                      .selectedItemList[index]
                                                                      .price =
                                                                  double.tryParse(
                                                                    value,
                                                                  ) ??
                                                                  0.00;

                                                              controller
                                                                  .markAsDirty();
                                                              controller
                                                                  .createTotalForEdit(); // Recalculate total when amount changes

                                                              controller
                                                                  .updateRequestedDepositAmount();
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10.sp),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Quantity:",
                                                          style: theme
                                                              .textTheme
                                                              .bodyLarge,
                                                        ),
                                                        SizedBox(width: 25.sp),
                                                        Expanded(
                                                          child: GeneralTextField(
                                                            hint: '1',
                                                            textInputType:
                                                                TextInputType.numberWithOptions(
                                                                  decimal: true,
                                                                  signed: false,
                                                                ),
                                                            theme: theme,
                                                            textEditingController:
                                                                controller
                                                                    .editQuantityControllers[index],
                                                            onChanged: (value) {
                                                              controller
                                                                  .markAsDirty();
                                                              controller
                                                                  .createTotalForEdit();
                                                              controller
                                                                  .updateRequestedDepositAmount();
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10.sp),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Taxable:",
                                                          style: theme
                                                              .textTheme
                                                              .bodyLarge,
                                                        ),
                                                        SizedBox(width: 30.sp),
                                                        Obx(
                                                          () => DropdownButton<bool>(
                                                            value:
                                                                controller
                                                                    .selectedItemList[index]
                                                                    .isTaxable ??
                                                                true,
                                                            dropdownColor:
                                                                Colors.white,
                                                            items: [
                                                              DropdownMenuItem(
                                                                value: true,
                                                                child: Text(
                                                                  "Yes",
                                                                ),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: false,
                                                                child: Text(
                                                                  "No",
                                                                ),
                                                              ),
                                                            ],
                                                            onChanged: (value) {
                                                              controller
                                                                  .markAsDirty();
                                                              controller
                                                                      .selectedItemList[index]
                                                                      .isTaxable =
                                                                  value;

                                                              controller
                                                                  .createTotalForEdit();
                                                              controller
                                                                  .selectedItemList
                                                                  .refresh();

                                                              controller
                                                                  .updateRequestedDepositAmount();
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(height: 15.sp),
                                              Padding(
                                                padding: EdgeInsets.all(16.sp),
                                                child: SizedBox(
                                                  height: 50.sp,
                                                  width: .5.sw,
                                                  child: PrimaryButton(
                                                    title: "Close",
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    inactive: false,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Remix.delete_bin_2_line,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  controller.invoiceDetailsNoteFocusnode.value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailToFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailBccFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailSubjectFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailBodyFocusnode
                                      .value
                                      .unfocus();
                                  controller.invoiceDetailsSearchFocusnode.value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEditDiscountFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsDepositRateFocusnode
                                      .value
                                      .unfocus();
                                  showAdaptiveDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        "Delete Item",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      content: Text(
                                        "Are you sure you want to delete this item?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: Get.back,
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            controller.markAsDirty();
                                            controller.removeItemFromEdit(
                                              index,
                                            );
                                            Get.back();
                                          },
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: 8.sp),
            ),
          );
  }

  Obx paymentDetails(ThemeData theme, context) {
    double screenWidth = Get.width;
    return Obx(
      () => Card(
        elevation: 0,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: Get.size.width <= 440
                  ? null
                  : EdgeInsets.symmetric(vertical: 8.sp, horizontal: 8.sp),
              title: Text(
                "Subtotal",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: LightThemeColors.hintTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Text(
                "\$${controller.invoiceSubtotal.value.toStringAsFixed(2)}",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            MainDivider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 10.sp),
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      return Container(
                        margin: EdgeInsets.only(
                          right: screenWidth > 374 ? 30.sp : 50.sp,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.sp,
                          vertical: 5.sp,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(
                            color: LightThemeColors.primaryColor,
                            width: 1.sp,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Discount",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: LightThemeColors.bodyTextSecondaryColor,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(width: 5.sp),
                            Icon(
                              Icons.arrow_drop_down,
                              color: LightThemeColors.primaryColor,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        controller.selectedDiscountOption.value == "2"
                            ? "\$"
                            : "%",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5.sp),
                      SizedBox(
                        height: Get.size.width <= 440 ? 35.sp : null,
                        width: 100.sp,
                        child: GeneralTextField(
                          hint: "0.00",
                          textInputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          theme: theme,
                          textAlignment: TextAlign.end,
                          focusNode: controller
                              .invoiceDetailsEditDiscountFocusnode
                              .value,
                          textEditingController:
                              controller.editDiscountTextController,
                          onChanged: (value) {
                            controller.markAsDirty();
                            final sanitized = value.replaceAll(
                              RegExp(r'[^0-9.]'),
                              '',
                            );
                            if (sanitized.isEmpty) {
                              controller.discount = "0.00";
                            } else {
                              controller.discount = sanitized;
                            }

                            controller.createTotalForEdit();
                            controller.updateRequestedDepositAmount();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 18.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    controller.selectedDiscountOption.value == "2"
                        ? "Fixed"
                        : "Percentage",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: LightThemeColors.bodyTextSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Discount amount:",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 10.sp,
                    color: LightThemeColors.bodyTextSecondaryColor,
                  ),
                ),
                SizedBox(width: 20.sp),
                Padding(
                  padding: EdgeInsets.only(right: 12.sp),
                  child: Text(
                    "-\$${(controller.invoiceDiscount.value).toStringAsFixed(2)}",
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.sp),
            Divider(height: 1.sp, color: Colors.black),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Amount after discount:",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 10.sp,
                    color: LightThemeColors.bodyTextSecondaryColor,
                  ),
                ),
                SizedBox(width: 20.sp),
                Padding(
                  padding: EdgeInsets.only(right: 12.sp),
                  child: Text(
                    "\$${(controller.amountAfterDiscount.value).toStringAsFixed(2)}",
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Taxable total",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 10.sp,
                    color: LightThemeColors.bodyTextSecondaryColor,
                  ),
                ),
                SizedBox(width: 20.sp),
                Padding(
                  padding: EdgeInsets.only(right: 12.sp),
                  child: Text(
                    "\$${(controller.invoiceSubtotal.value - controller.nonTaxableTotalInDetails.value).toStringAsFixed(2)}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Discounted Taxable total",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 10.sp,
                    color: LightThemeColors.bodyTextSecondaryColor,
                  ),
                ),
                SizedBox(width: 20.sp),
                Padding(
                  padding: EdgeInsets.only(right: 12.sp),
                  child: Text(
                    "\$${(controller.discountedTaxableTotalInEdit.value).toStringAsFixed(2)}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => ListTile(
                title: Builder(
                  builder: (context) {
                    final allNonTaxable = controller.areAllItemsNonTaxable;
                    return SplashContainer(
                      color: allNonTaxable
                          ? Colors.grey.shade200
                          : Colors.white,
                      radius: 8,
                      onPressed: allNonTaxable
                          ? () {}
                          : () {
                              // Dismiss keyboard when opening dropdowns

                              FocusScope.of(context).unfocus();

                              RenderBox renderBox =
                                  context.findRenderObject() as RenderBox;
                              Offset offset = renderBox.localToGlobal(
                                Offset(0, 32.sp),
                              );
                              final RenderBox overlay =
                                  Overlay.of(context).context.findRenderObject()
                                      as RenderBox;
                              showMenu(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.r),
                                  ),
                                ),
                                context: context,
                                position: RelativeRect.fromRect(
                                  offset &
                                      Size(
                                        32.sp,
                                        32.sp,
                                      ), // smaller rect, the touch area
                                  Offset.zero &
                                      overlay
                                          .size, // Bigger rect, the entire screen
                                ),
                                items: [
                                  PopupMenuItem(
                                    value: "",
                                    child: Text(
                                      "NO TAX",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),

                                  ...controller.taxes.map((tax) {
                                    return PopupMenuItem(
                                      value: tax.id,
                                      child: Text(tax.name ?? ""),
                                    );
                                  }),
                                ],
                              ).then((selectedTaxID) async {
                                if (selectedTaxID != null) {
                                  FocusScope.of(context).unfocus();
                                  controller.invoiceDetailsNoteFocusnode.value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailToFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailBccFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailSubjectFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEmailBodyFocusnode
                                      .value
                                      .unfocus();
                                  controller.invoiceDetailsSearchFocusnode.value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsEditDiscountFocusnode
                                      .value
                                      .unfocus();
                                  controller
                                      .invoiceDetailsDepositRateFocusnode
                                      .value
                                      .unfocus();
                                  controller.markAsDirty();
                                  if (selectedTaxID == "") {
                                    controller.selectedTaxName.value = "NO TAX";
                                    controller.tax.value = "0.00";
                                    controller.selectedTaxID.value = "";
                                    controller.createTotalForEdit();
                                  } else if (selectedTaxID == -1) {
                                    _showManualTaxDialog(context);
                                  } else {
                                    final selectedTax = controller.taxes
                                        .firstWhereOrNull(
                                          (tax) => tax.id == selectedTaxID,
                                        );
                                    if (selectedTax != null) {
                                      controller.selectedTaxName.value =
                                          selectedTax.name ?? "";
                                      controller.tax.value =
                                          selectedTax.rate?.toStringAsFixed(
                                            2,
                                          ) ??
                                          "0.00";
                                      controller.selectedTaxID.value =
                                          selectedTax.id.toString();
                                      controller.createTotalForEdit();
                                      controller.updateRequestedDepositAmount();
                                    }
                                  }
                                }
                              });
                            },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.sp,
                          vertical: 5.sp,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(
                            color: allNonTaxable
                                ? Colors.grey
                                : LightThemeColors.primaryColor,
                            width: 1.sp,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Tax Rate",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: allNonTaxable
                                    ? Colors.grey
                                    : LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 5.sp),
                            Icon(
                              allNonTaxable
                                  ? Icons.block
                                  : Icons.arrow_drop_down,
                              color: allNonTaxable
                                  ? Colors.grey
                                  : LightThemeColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                trailing: SizedBox(
                  width: screenWidth > 374 ? 150.sp : 165.sp,
                  child: Text(
                    "\$${(controller.discountedTaxableTotalInEdit.value).toStringAsFixed(2)} x ${double.parse(controller.tax.value).toStringAsFixed(2)}%",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
            controller.selectedTaxName.value == ""
                ? Padding(
                    padding: EdgeInsets.only(left: 18.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "NO TAX (0.00%)",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: LightThemeColors.bodyTextSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(left: 18.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "${controller.selectedTaxName.value} (${controller.tax.value}%)",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: LightThemeColors.bodyTextSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Tax amount:",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 10.sp,
                    color: LightThemeColors.bodyTextSecondaryColor,
                  ),
                ),
                SizedBox(width: 20.sp),
                Padding(
                  padding: EdgeInsets.only(right: 12.sp),
                  child: Text(
                    "+\$${(controller.invoiceTax.value).toStringAsFixed(2)}",
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.sp),
            Divider(height: 1.sp, color: Colors.black),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Amount after adding Tax:",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 10.sp,
                    color: LightThemeColors.bodyTextSecondaryColor,
                  ),
                ),
                SizedBox(width: 20.sp),
                Padding(
                  padding: EdgeInsets.only(right: 12.sp),
                  child: Text(
                    "\$${controller.invoiceTotal.value}",
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.sp),
            Divider(height: 1.sp, color: theme.primaryColor),
            controller.type.value == "Invoice"
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Payment Made",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: LightThemeColors.bodyTextSecondaryColor,
                        ),
                      ),
                      SizedBox(width: 35.sp),
                      Padding(
                        padding: EdgeInsets.only(right: 12.sp),
                        child: Text(
                          "\$${controller.depositAmount.value}",
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            SizedBox(height: 5.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  controller.type.value == "Invoice" ? "Total Due" : "Total",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: LightThemeColors.bodyTextSecondaryColor,
                  ),
                ),
                SizedBox(width: 20.sp),
                Padding(
                  padding: EdgeInsets.only(right: 12.sp),
                  child: controller.type.value == "Invoice"
                      ? Text(
                          "\$${(double.parse(controller.total.value) - double.parse(controller.depositAmount.value)).toStringAsFixed(2)}",
                          style: theme.textTheme.bodyLarge,
                        )
                      : Text(
                          "\$${controller.invoiceTotal.value}",
                          style: theme.textTheme.bodyLarge,
                        ),
                ),
              ],
            ),
            SizedBox(height: 10.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Paid Amount",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: LightThemeColors.bodyTextSecondaryColor,
                  ),
                ),
                SizedBox(width: 20.sp),
                Padding(
                  padding: EdgeInsets.only(right: 12.sp),
                  child: Text(
                    "\$${controller.depositAmount.value}",
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Balance Due",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: LightThemeColors.bodyTextSecondaryColor,
                  ),
                ),
                SizedBox(width: 20.sp),
                Padding(
                  padding: EdgeInsets.only(right: 12.sp),
                  child: Text(
                    "\$${(double.parse(controller.invoiceTotal.value) - double.parse(controller.depositAmount.value)).toStringAsFixed(2)}",
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.sp),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp),
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
                    padding: EdgeInsets.symmetric(vertical: 8.sp),
                    child: GeneralTextField(
                      hint: "Add a note here..",
                      theme: theme,
                      maxLine: 5,
                      minLine: 1,
                      focusNode: controller.invoiceDetailsNoteFocusnode.value,
                      textInputType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      textEditingController: controller.editNoteTextController,
                      onChanged: (_) => controller.markAsDirty(),
                    ),
                  ),
                ],
              ),
            ),
            controller.type.value == "Invoice"
                ? SizedBox.shrink()
                : controller.isConverted.value
                ? SizedBox.shrink()
                : Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          activeColor: theme.primaryColor,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          side: BorderSide(
                            color: LightThemeColors.primaryColor,
                            width: 1.sp,
                          ),
                          value: controller.convertToInvoice.value,
                          onChanged: (value) {
                            controller.invoiceDetailsNoteFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsEmailToFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsEmailBccFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsEmailSubjectFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsEmailBodyFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsSearchFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsEditDiscountFocusnode.value
                                .unfocus();
                            controller.invoiceDetailsDepositRateFocusnode.value
                                .unfocus();
                            controller.convertToInvoice.value = value!;
                            controller.markAsDirty();
                          },
                        ),
                      ),
                      Text(
                        "Convert to Invoice",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: LightThemeColors.hintTextColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
            MainDivider(),
            SizedBox(height: 20.sp),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
              child: Builder(
                builder: (context) {
                  return SplashContainer(
                    color: Colors.white,
                    radius: 8,
                    onPressed: () {
                      // Dismiss keyboard when opening dropdowns

                      FocusScope.of(context).unfocus();

                      RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      Offset offset = renderBox.localToGlobal(Offset(0, 36.sp));
                      final RenderBox overlay =
                          Overlay.of(context).context.findRenderObject()
                              as RenderBox;
                      showMenu(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.r)),
                        ),
                        context: context,
                        position: RelativeRect.fromRect(
                          offset &
                              Size(
                                32.sp,
                                32.sp,
                              ), // smaller rect, the touch area
                          Offset.zero &
                              overlay.size, // Bigger rect, the entire screen
                        ),
                        items: controller.depositRequestOptions.map((e) {
                          return PopupMenuItem(
                            value: e["value"],
                            child: controller.type.value == "Invoice"
                                ? Text(
                                    e["name"] == "Requested Deposit Amount:(%)"
                                        ? "Requested Payment Amount:(%)"
                                        : e["name"] ==
                                              "Requested Deposit Amount:(\$)"
                                        ? "Requested Payment Amount:(\$)"
                                        : e["name"],
                                  )
                                : Text(e["name"] ?? ""),
                          );
                        }).toList(),
                      ).then((selectedValue) {
                        if (selectedValue != null) {
                          FocusScope.of(context).unfocus();
                          controller.invoiceDetailsNoteFocusnode.value
                              .unfocus();
                          controller.invoiceDetailsEmailToFocusnode.value
                              .unfocus();
                          controller.invoiceDetailsEmailBccFocusnode.value
                              .unfocus();
                          controller.invoiceDetailsEmailSubjectFocusnode.value
                              .unfocus();
                          controller.invoiceDetailsEmailBodyFocusnode.value
                              .unfocus();
                          controller.invoiceDetailsSearchFocusnode.value
                              .unfocus();
                          controller.invoiceDetailsEditDiscountFocusnode.value
                              .unfocus();
                          controller.invoiceDetailsDepositRateFocusnode.value
                              .unfocus();
                          controller.markAsDirty();
                          controller.requestedDepositAmountEditTextController
                              .clear();
                          controller.requestDepositRateEditTextController
                              .clear();
                          final selectedDeposit = controller
                              .depositRequestOptions
                              .firstWhere(
                                (element) => element["value"] == selectedValue,
                              );
                          controller.selectedDepositRequestOption.value =
                              selectedDeposit["value"];
                          controller.selectedDepositRequestOptionName.value =
                              selectedDeposit["name"] ?? "";
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.sp,
                        vertical: 8.sp,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(
                          color: LightThemeColors.primaryColor,
                          width: 1.sp,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          controller.type.value == "Invoice"
                              ? Text(
                                  controller
                                              .selectedDepositRequestOptionName
                                              .value ==
                                          "Requested Deposit Amount:(%)"
                                      ? "Requested Payment Amount:(%)"
                                      : controller
                                                .selectedDepositRequestOptionName
                                                .value ==
                                            "Requested Deposit Amount:(\$)"
                                      ? "Requested Payment Amount:(\$)"
                                      : controller
                                            .selectedDepositRequestOptionName
                                            .value,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        LightThemeColors.bodyTextSecondaryColor,
                                    fontSize: 14.sp,
                                  ),
                                )
                              : Text(
                                  controller
                                      .selectedDepositRequestOptionName
                                      .value,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        LightThemeColors.bodyTextSecondaryColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                          SizedBox(width: 5.sp),
                          Icon(
                            Icons.arrow_drop_down,
                            color: LightThemeColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            controller.selectedDepositRequestOption.value == "1"
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.sp,
                      horizontal: 12.sp,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Rate:"),
                        SizedBox(width: 32.sp),
                        SizedBox(
                          height: Get.size.width <= 440 ? 35.sp : null,
                          width: 120.sp,
                          child: GeneralTextField(
                            hint: "0.00",
                            theme: theme,
                            focusNode: controller
                                .invoiceDetailsDepositRateFocusnode
                                .value,
                            textInputType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (v) {
                              controller.markAsDirty();
                              final rate = double.tryParse(v) ?? 0.0;
                              final total =
                                  ((controller.invoiceSubtotal.value -
                                              controller
                                                  .invoiceDiscount
                                                  .value) -
                                          controller
                                              .nonTaxableTotalInDetails
                                              .value) *
                                      (double.tryParse(controller.tax.value) ??
                                          0) /
                                      100 +
                                  ((controller.invoiceSubtotal.value) -
                                      (controller.invoiceDiscount.value));
                              final depositAmount =
                                  ((total -
                                              double.parse(
                                                controller.depositAmount.value,
                                              )) *
                                          rate /
                                          100)
                                      .toStringAsFixed(2);
                              controller
                                      .requestedDepositAmountEditTextController
                                      .text =
                                  depositAmount;
                            },
                            textEditingController:
                                controller.requestDepositRateEditTextController,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Amount:"),
                  SizedBox(width: 10.sp),
                  SizedBox(
                    height: Get.size.width <= 440 ? 35.sp : null,
                    width: 120.sp,
                    child: TextField(
                      controller:
                          controller.requestedDepositAmountEditTextController,
                      decoration: InputDecoration(
                        hintText: "0.00",
                        contentPadding: Get.size.width <= 440
                            ? EdgeInsets.symmetric(horizontal: 15.sp)
                            : null,
                        filled: true,
                        fillColor: LightThemeColors.fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: LightThemeColors.buttonBorderColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: LightThemeColors.buttonBorderColor,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      readOnly:
                          controller.selectedDepositRequestOption.value ==
                                  "1" ||
                              controller.selectedDepositRequestOption.value ==
                                  "0"
                          ? true
                          : false,
                      style: theme.textTheme.bodyMedium,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      onChanged: (_) => controller.markAsDirty(),
                    ),
                  ),
                ],
              ),
            ),
            MainDivider(),
            SizedBox(height: 5.sp),
            SizedBox(
              height: 52.h,
              width: double.infinity,
              child: PrimaryButton(
                title: "Save",
                onPressed: () async {
                  try {
                    await controller.editInvoice();
                  } catch (e, s) {
                    log(" Error in saving invoice: $e");
                    log(s.toString());
                  }
                },
                inactive: controller.selectedItemList.isEmpty,
              ),
            ),
            SizedBox(height: 10.sp),
            controller.selectedDepositRequestOption.value == "0"
                ? SizedBox(
                    height: 52.h,
                    width: double.infinity,
                    child: PrimaryButton(
                      title: "Pay Now",
                      onPressed: () {
                        if (controller.isDirty.value) {
                          _showUnsavedChangesDialog(context, () {
                            // User confirms to proceed
                            controller.depositRequestPay.value = false;
                            Get.toNamed(Routes.PAYMENT_METHOD_SELECTION)!.then((
                              _,
                            ) {
                              // Refresh invoice data when returning from payment
                              controller.getInvoiceName();
                            });
                          });
                        } else {
                          controller.depositRequestPay.value = false;
                          Get.toNamed(Routes.PAYMENT_METHOD_SELECTION)!.then((
                            _,
                          ) {
                            // Refresh invoice data when returning from payment
                            controller.getInvoiceName();
                          });
                        }
                      },
                      inactive: controller.selectedItemList.isEmpty,
                    ),
                  )
                : SizedBox(
                    height: 52.h,
                    width: double.infinity,
                    child: PrimaryButton(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      title: controller.type.value == "Invoice"
                          ? "Pay Invoice"
                          : "Pay Deposit",
                      onPressed: () {
                        if (controller.isDirty.value) {
                          _showUnsavedChangesDialog(context, () {
                            controller.depositRequestPay.value = true;
                            Get.toNamed(Routes.PAYMENT_METHOD_SELECTION)!.then((
                              _,
                            ) {
                              // Refresh invoice data when returning from payment
                              controller.getInvoiceName();
                            });
                          });
                        } else {
                          controller.depositRequestPay.value = true;
                          Get.toNamed(Routes.PAYMENT_METHOD_SELECTION)!.then((
                            _,
                          ) {
                            // Refresh invoice data when returning from payment
                            controller.getInvoiceName();
                          });
                        }
                      },
                      inactive: false,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, theme) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Container(
            height: .8.sh,
            padding: EdgeInsets.all(20.sp),
            child: Column(
              children: [
                SizedBox(
                  height: 40.sp,
                  child: GeneralTextField(
                    hint: "Search item",
                    focusNode: controller.invoiceDetailsSearchFocusnode.value,
                    suffixIcon: Icon(
                      Icons.search,
                      color: LightThemeColors.bodyTextSecondaryColor,
                    ),
                    theme: theme,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => controller.itemController.sortItems(),
                    textEditingController:
                        controller.itemController.sortTextController,
                  ),
                ),
                SizedBox(height: 10.sp),
                Expanded(
                  child: Obx(
                    () => ListView(
                      children: controller.itemController.sortedItems.map((
                        item,
                      ) {
                        final alreadySelected = controller.selectedItemList.any(
                          (selected) => selected.id == item.id,
                        );
                        return CheckboxListTile(
                          activeColor: theme.primaryColor,
                          value: alreadySelected,
                          onChanged: (checked) {
                            controller.markAsDirty();
                            if (checked == true && !alreadySelected) {
                              controller.selectedItemList.add(item);
                              controller.editAmountControllers.add(
                                TextEditingController(
                                  text: item.price.toString(),
                                ),
                              );
                              controller.editDescriptionControllers.add(
                                TextEditingController(
                                  text: item.description ?? "",
                                ),
                              );
                              controller.editQuantityControllers.add(
                                TextEditingController(text: '1'),
                              );
                              controller.createTotalForEdit();
                              controller.updateRequestedDepositAmount();
                            } else if (checked == false && alreadySelected) {
                              final index = controller.selectedItemList
                                  .indexWhere(
                                    (selected) => selected.id == item.id,
                                  );
                              if (index != -1) {
                                controller.selectedItemList.removeAt(index);
                                controller.editAmountControllers.removeAt(
                                  index,
                                );
                                controller.editDescriptionControllers.removeAt(
                                  index,
                                );
                                controller.editQuantityControllers.removeAt(
                                  index,
                                );
                                controller.createTotalForEdit();
                                controller.updateRequestedDepositAmount();
                              }
                            }
                          },
                          title: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.sp,
                              vertical: 10.sp,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.sp),
                              border: Border.all(
                                color: LightThemeColors.bodyTextSecondaryColor,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name ?? "",
                                  style: TextStyle(
                                    color: LightThemeColors.primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 5.sp),
                                item.description == ""
                                    ? SizedBox.shrink()
                                    : Text(item.description ?? ""),
                                SizedBox(height: 8.sp),
                                Row(
                                  children: [
                                    Text(
                                      "Price: ",
                                      style: TextStyle(
                                        color: LightThemeColors
                                            .bodyTextSecondaryColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    Text(
                                      "\$${(item.price ?? 0.00).toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.sp),
                                Text(
                                  "Taxable: ${item.isTaxable == true ? "Yes" : "No"}",
                                  style: TextStyle(
                                    color:
                                        LightThemeColors.bodyTextSecondaryColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 20.sp),
                SizedBox(
                  height: 50.sp,
                  width: 150.sp,
                  child: PrimaryButton(
                    title: "Close",
                    onPressed: () {
                      Get.back();
                    },
                    inactive: false,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showUnsavedChangesDialogAsync(BuildContext context) {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Unsaved Changes", style: theme.textTheme.titleLarge),
        content: Text(
          "You have unsaved changes. Do you want to save them before leaving?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Don't Save"),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true); // Save and proceed
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () => Get.back(result: null), // Cancel navigation
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _showUnsavedChangesDialog(
    BuildContext context,
    VoidCallback onConfirmed,
  ) {
    final theme = Theme.of(context);
    showAdaptiveDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Unsaved Changes", style: theme.textTheme.titleLarge),
        content: Text(
          "You have unsaved changes. Please save before continuing.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              onConfirmed(); // Proceed without saving (only if allowed)
            },
            child: Text("Ignore & Continue"),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.editInvoice();
              onConfirmed();
            },
            child: Text("Save & Continue"),
          ),
          TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
        ],
      ),
    );
  }

  void _showManualTaxDialog(BuildContext context) {
    final theme = Theme.of(context);
    final TextEditingController taxController = TextEditingController(
      text: controller.selectedTaxID.value == "-1" ? controller.tax.value : "",
    );

    showAdaptiveDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Tax Rate", style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter tax percentage:"),
            SizedBox(height: 10),
            TextField(
              controller: taxController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: "8.25",
                suffixText: "%",
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              final input = taxController.text.trim();
              final taxRate = double.tryParse(input);
              if (taxRate == null || taxRate < 0) {
                Get.snackbar(
                  "Invalid Input",
                  "Please enter a valid tax percentage",
                );
                return;
              }
              controller.selectedTaxName.value = "Manual";
              controller.tax.value = taxRate.toStringAsFixed(2);
              controller.selectedTaxID.value = "-1";
              controller.createTotalForEdit();
              controller.updateRequestedDepositAmount();
              Get.back();
            },
            child: Text("Apply"),
          ),
        ],
      ),
    );
  }

  void _showTuaPayLinkDialog(
    BuildContext context,
    ThemeData theme,
    InvoiceController controller,
  ) {
    final apptC = Get.find<AppointmentController>();
    // Calculate base amount (invoice total after discount but before payments)
    final payAmount =
        (double.parse(controller.invoiceTotal.value) -
                double.parse(controller.depositAmount.value))
            .toStringAsFixed(2);

    // Pre-fill base amount
    controller.tuaBaseAmountController.text = double.parse(
      controller.invoiceTotal.value,
    ).toStringAsFixed(2);
    controller.tuaRemainAmountController.text = payAmount;

    // Pre-fill customer information if available
    controller.tuaEmailController.text = controller.toTextController.text;
    controller.tuaFirstNameController.text =
        apptC.selectedCustomer.value!.firstName ?? "";
    controller.tuaLastNameController.text =
        apptC.selectedCustomer.value!.lastName ?? "";
    // Last name and mobile need to be extracted or left empty
    controller.tuaAddressController.text =
        apptC.selectedCustomer.value!.address1 ?? "";
    controller.tuaMobileController.text =
        apptC.selectedCustomer.value!.mobile ?? "";
    controller.tuaCityController.text =
        apptC.selectedCustomer.value!.city ?? "";
    controller.tuaZipCodeController.text =
        apptC.selectedCustomer.value!.zipCode ?? "";
    controller.tuaStateController.text =
        apptC.selectedCustomer.value!.state ?? "";

    showAdaptiveDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          constraints: BoxConstraints(maxHeight: .85.sh),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Text(
                  "TuaPay Link",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              SizedBox(height: 4.sp),
              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.sp),

                      // Amount Section
                      _buildSectionTitle("Amount Details", theme),
                      SizedBox(height: 12.sp),
                      _buildAmountField(
                        label: "Base Amount",
                        prefix: "\$",
                        controller: controller.tuaBaseAmountController,
                        readOnly: true,
                        theme: theme,
                        invoiceController: controller,
                      ),
                      SizedBox(height: 12.sp),
                      _buildAmountField(
                        label: "Request Amount",
                        prefix: "\$",
                        controller: controller.tuaRemainAmountController,
                        readOnly: false,
                        theme: theme,
                        invoiceController: controller,
                      ),

                      SizedBox(height: 16.sp),
                      _buildDivider(),

                      // Customer Information
                      _buildSectionTitle("Customer Information", theme),
                      SizedBox(height: 12.sp),
                      GeneralTextField(
                        hint: "Email Address *",
                        theme: theme,
                        textEditingController: controller.tuaEmailController,
                        textInputType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 12.sp),
                      Row(
                        children: [
                          Expanded(
                            child: GeneralTextField(
                              hint: "First Name *",
                              theme: theme,
                              textEditingController:
                                  controller.tuaFirstNameController,
                            ),
                          ),
                          SizedBox(width: 12.sp),
                          Expanded(
                            child: GeneralTextField(
                              hint: "Last Name",
                              theme: theme,
                              textEditingController:
                                  controller.tuaLastNameController,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.sp),
                      GeneralTextField(
                        hint: "Mobile Number",
                        theme: theme,
                        textEditingController: controller.tuaMobileController,
                        textInputType: TextInputType.phone,
                      ),
                      SizedBox(height: 12.sp),
                      GeneralTextField(
                        hint: "Address",
                        theme: theme,
                        textEditingController: controller.tuaAddressController,
                        maxLine: 2,
                      ),
                      SizedBox(height: 12.sp),
                      Row(
                        children: [
                          Expanded(
                            child: GeneralTextField(
                              hint: "City",
                              theme: theme,
                              textEditingController:
                                  controller.tuaCityController,
                            ),
                          ),
                          SizedBox(width: 12.sp),
                          Expanded(
                            child: GeneralTextField(
                              hint: "State",
                              theme: theme,
                              textEditingController:
                                  controller.tuaStateController,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.sp),
                      GeneralTextField(
                        hint: "Zip Code *",
                        theme: theme,
                        textEditingController: controller.tuaZipCodeController,
                        textInputType: TextInputType.number,
                      ),

                      SizedBox(height: 16.sp),
                      _buildDivider(),

                      // Invoice Details
                      _buildSectionTitle("Invoice Details", theme),
                      SizedBox(height: 12.sp),
                      GeneralTextField(
                        hint: "Invoice Number",
                        theme: theme,
                        textEditingController: TextEditingController(
                          text: controller.invoiceNumber,
                        ),
                        readOnly: true,
                      ),

                      SizedBox(height: 16.sp),
                      _buildDivider(),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: LightThemeColors.buttonBorderColor.withValues(
                        alpha: 0.3,
                      ),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: PrimaryButton(
                        title: "Submit",
                        onPressed: () async {
                          // Validate required fields
                          if (controller.tuaEmailController.text.isEmpty) {
                            MySnackBar.showToast(
                              message: "Please enter email address",
                            );
                            return;
                          }
                          if (controller.tuaFirstNameController.text.isEmpty) {
                            MySnackBar.showToast(
                              message: "Please enter first name",
                            );
                            return;
                          }
                          if (controller.tuaLastNameController.text.isEmpty) {
                            MySnackBar.showToast(
                              message: "Please enter last name",
                            );
                            return;
                          }
                          if (controller.tuaZipCodeController.text.isEmpty) {
                            MySnackBar.showToast(
                              message: "Please enter zip code",
                            );
                            return;
                          }

                          // Proceed with sending email

                          await controller.generateTuaPaymentLink();

                          // Clear controllers
                          _clearTuaControllers(controller);

                          // Get.back();
                          // Get.back();
                        },
                        inactive: false,
                      ),
                    ),
                    SizedBox(height: 12.sp),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: SecondaryButton(
                        title: "Cancel",
                        onPressed: () {
                          _clearTuaControllers(controller);
                          Get.back();
                        },
                        inactive: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearTuaControllers(InvoiceController controller) {
    controller.tuaBaseAmountController.clear();
    controller.tuaCustomPercentageController.clear();
    controller.tuaRemainAmountController.clear();
    controller.tuaEmailController.clear();
    controller.tuaFirstNameController.clear();
    controller.tuaLastNameController.clear();
    controller.tuaMobileController.clear();
    controller.tuaAddressController.clear();
    controller.tuaCityController.clear();
    controller.tuaZipCodeController.clear();
    controller.tuaStateController.clear();
    controller.tuaSendTextLink.value = false;
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(left: 4.sp),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: LightThemeColors.bodyTextSecondaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: LightThemeColors.buttonBorderColor.withValues(alpha: 0.3),
    );
  }

  Widget _buildAmountField({
    required String label,
    required String prefix,
    required TextEditingController controller,
    required bool readOnly,
    required ThemeData theme,
    required InvoiceController invoiceController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: LightThemeColors.bodyTextSecondaryColor,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 8.sp),
        Container(
          decoration: BoxDecoration(
            color: readOnly
                ? LightThemeColors.bodyTextSecondaryColor.withValues(alpha: 0.1)
                : LightThemeColors.fillColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: LightThemeColors.buttonBorderColor),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                child: Text(
                  prefix,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "0.00",
                    hintStyle: TextStyle(
                      color: LightThemeColors.bodyTextSecondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
