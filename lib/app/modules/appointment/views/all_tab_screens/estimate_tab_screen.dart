import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/text_widget.dart';
import 'package:myxinator_pro_field_agent_pro/app/data/local/my_shared_pref.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/appointment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/models/appointment_model.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/views/widgets/warm_organic_components.dart';
import 'package:myxinator_pro_field_agent_pro/app/routes/app_pages.dart';
import 'package:myxinator_pro_field_agent_pro/utils/date_converter.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/item/models/item_list_model.dart';

import '../../../../../config/theme/light_theme_colors.dart';
import '../../../../components/global-widgets/main_divider.dart';

class EstimateTabScreen extends StatefulWidget {
  const EstimateTabScreen({super.key});

  @override
  State<EstimateTabScreen> createState() => _EstimateTabScreenState();
}

class _EstimateTabScreenState extends State<EstimateTabScreen> {
  final AppointmentController controller = Get.find<AppointmentController>();
  final GlobalKey _createInvoiceButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmOrganicBlueTheme.warmGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WarmOrganicBlueTheme.warmGray,
        title: Text(
          'Estimate / Invoice',
          style: WarmOrganicBlueTheme.headingMedium,
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              OrganicPrimaryButton(
                key: _createInvoiceButtonKey,
                text: 'Create New',
                icon: Icons.add_rounded,
                height: 40.h,
                width: 140.w,
                onPressed: () => _showCreateInvoiceMenu(context),
              ),
              SizedBox(height: 12.h),

              if (controller
                          .sortedAppointments[controller.selectedAptIndex.value]
                          .invoices ==
                      null ||
                  controller
                      .sortedAppointments[controller.selectedAptIndex.value]
                      .invoices!
                      .isEmpty)
                OrganicEmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'No Invoices',
                  subtitle:
                      'Create an invoice or estimate for this appointment.',
                )
              else
                ...controller
                    .sortedAppointments[controller.selectedAptIndex.value]
                    .invoices!
                    .map((proposal) => _buildInvoiceCard(context, proposal)),

              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    Invoices proposal,
    //{
    // bool isExtended = false,
    // }
  ) {
    final theme = Theme.of(context);
    // final isEstimate = proposal.type == "Estimate";

    return GestureDetector(
      onTap: () async {
        // controller.showLoading();

        // Save backup if we were in "new" mode before switching to "existing"
        if (controller.invoiceController.existingItemType.value ==
            SelectedItemCategory.newOne) {
          controller.invoiceController.saveBackup("new");
        }

        controller.invoiceController.existingItemType(
          SelectedItemCategory.existingOne,
        );

        // Clear previous selection if needed
        controller.invoiceController.selectedItemList.clear();
        for (var c in controller.invoiceController.editAmountControllers) {
          c.dispose();
        }
        for (var c in controller.invoiceController.editDescriptionControllers) {
          c.dispose();
        }
        for (var c in controller.invoiceController.editQuantityControllers) {
          c.dispose();
        }
        controller.invoiceController.editAmountControllers.clear();
        controller.invoiceController.editDescriptionControllers.clear();
        controller.invoiceController.editQuantityControllers.clear();
        controller.invoiceController.editNoteTextController.clear();
        controller.invoiceController.editDiscountTextController.clear();
        controller.invoiceController.initialTaxID.value = "";

        // Set basic info

        controller.invoiceController.invoiceItemList.value =
            proposal.items ?? [];
        controller.invoiceController.depositList.value =
            proposal.paymentList ?? [];
        controller.invoiceController.selectedDiscountOption.value =
            proposal.discountOption ?? "2";
        controller.invoiceController.invoiceNumber = proposal.number ?? "";
        controller.invoiceController.isConverted.value =
            proposal.isConverted ?? false;
        controller.invoiceController.customerName = proposal.fullName ?? "";
        controller.invoiceController.address = "${proposal.city}, ";
        controller.invoiceController.depositAmount.value =
            proposal.depositAmount?.toStringAsFixed(2) ?? "0.00";
        controller.invoiceController.invoiceID.value = proposal.invoiceID
            .toString();
        controller.invoiceController.date = dateTimeConverter(
          inputFormat: "yyyy/MM/dd",
          inputTime: proposal.invoiceDate.toString(),
          outputFormat: "MM/dd/yyyy",
        );
        controller.invoiceController.subtotal =
            proposal.subtotal?.toStringAsFixed(2) ?? "";
        controller.invoiceController.customerID.value =
            proposal.customerId ?? "";
        controller.invoiceController.status = proposal.status ?? "";
        controller.invoiceController.type.value = proposal.type ?? "";
        controller.invoiceController.total.value =
            proposal.total?.toStringAsFixed(2) ?? "";
        if (proposal.requestedAmountType == 2) {
          // type = fixed
          controller.invoiceController.selectedDepositRequestOption.value = "2";
          controller
                  .invoiceController
                  .requestedDepositAmountEditTextController
                  .text =
              proposal.requestedDepositAmount ?? "0.00";
          controller.invoiceController.selectedDepositRequestOptionName.value =
              controller.invoiceController.depositRequestOptions[2]["name"];
        }
        if (proposal.requestedAmountType == 1) {
          // type = percentage
          controller.invoiceController.selectedDepositRequestOption.value = "1";
          controller
                  .invoiceController
                  .requestDepositRateEditTextController
                  .text =
              proposal.requestedDepositPercentage ?? "0.00";
          controller
                  .invoiceController
                  .requestedDepositAmountEditTextController
                  .text =
              proposal.requestedDepositAmount ?? "0.00";
          controller.invoiceController.selectedDepositRequestOptionName.value =
              controller.invoiceController.depositRequestOptions[1]["name"];
        }
        if (proposal.requestedAmountType == 0) {
          // type = null
          controller.invoiceController.selectedDepositRequestOption.value = "0";
          controller
                  .invoiceController
                  .requestDepositRateEditTextController
                  .text =
              proposal.requestedDepositPercentage ?? "0.00";
          controller
                  .invoiceController
                  .requestedDepositAmountEditTextController
                  .text =
              proposal.requestedDepositAmount ?? "0.00";
          controller.invoiceController.selectedDepositRequestOptionName.value =
              controller.invoiceController.depositRequestOptions[0]["name"];
        }
        controller.invoiceController.notes = proposal.note ?? "";
        controller.invoiceController.editNoteTextController.text =
            proposal.note ?? "";
        controller.invoiceController.due = proposal.due ?? "";
        controller.invoiceController.showingDate.value = dateTimeConverter(
          inputFormat: "yyyy/MM/dd hh:mm a",
          inputTime: proposal.invoiceDate.toString(),
          outputFormat: "MM/dd/yyyy",
        );
        if (proposal.taxType != "") {
          controller.invoiceController.initialTaxID.value =
              proposal.taxType ?? "";
        }

        // Set discount values
        controller.invoiceController.invoiceDiscountDetails.value =
            proposal.discount ?? 0.00;
        if (proposal.discountOption == "1") {
          controller.invoiceController.editDiscountTextController.text =
              (((double.parse(proposal.discount?.toString() ?? "0.00")) * 100) /
                      double.parse(
                        proposal.subtotal?.toStringAsFixed(2) ?? "0.00",
                      ))
                  .toStringAsFixed(2);
        } else {
          controller.invoiceController.editDiscountTextController.text =
              double.parse(
                proposal.discount?.toString() ?? "0.00",
              ).toStringAsFixed(2);
        }

        // Set tax values

        controller.invoiceController.tax.value =
            controller.invoiceController.taxes
                .firstWhereOrNull(
                  (tax) =>
                      tax.id ==
                      int.tryParse(
                        controller.invoiceController.initialTaxID.value,
                      ),
                )
                ?.rate
                ?.toStringAsFixed(2) ??
            "0.00";
        controller.invoiceController.selectedTaxName.value =
            controller.invoiceController.taxes
                .firstWhereOrNull(
                  (tax) =>
                      tax.id ==
                      int.tryParse(
                        controller.invoiceController.initialTaxID.value,
                      ),
                )
                ?.name ??
            "";

        // Populate selectedItemList and initialize controllers
        if (proposal.items != null && proposal.items!.isNotEmpty) {
          for (var item in proposal.items!) {
            controller.invoiceController.selectedItemList.add(
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
            controller.invoiceController.editAmountControllers.add(
              TextEditingController(text: item.unitPrice ?? "0.00"),
            );

            controller.invoiceController.editDescriptionControllers.add(
              TextEditingController(text: item.description ?? ""),
            );

            controller.invoiceController.editQuantityControllers.add(
              TextEditingController(text: item.quantity ?? "1"),
            );
          }
        }
        controller.invoiceController.createTotalForEdit();
        await 0.5.delay();
        controller.invoiceController.selectedQboClass(
          controller.invoiceController.qboClassList
              .where((e) => e.qboClassId.toString() == proposal.qboClassId)
              .firstOrNull,
        );
        controller.invoiceController.selectedQboLocation(
          controller.invoiceController.qboLocationList
              .where(
                (e) => e.qboLocationId.toString() == proposal.qboLocationId,
              )
              .firstOrNull,
        );
        controller.invoiceController.removedList
            .clear(); // Optional small delay before navigation

        final x = MySharedPref.getCompanyType() ?? '';
        controller.invoiceController.isLocAndClassShow.value = x == 'PCS';
        controller.invoiceController.selectedInvoice.value = proposal;
        Get.toNamed(Routes.INVOICE_DETAILS);
        // controller.hideLoading();
      },

      child: Card(
        elevation: 0,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number Row
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.sp,
                horizontal: Get.size.width <= 440 ? 16.sp : 8.sp,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${proposal.type ?? ""} Number",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: LightThemeColors.hintTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.sp,
                        vertical: 2.sp,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.r),
                        color: proposal.type == "Invoice"
                            ? theme.primaryColor
                            : proposal.type == "Estimate" &&
                                  proposal.isConverted == true
                            ? Colors.green
                            : Colors.yellow,
                      ),
                      child: Text(
                        overflow: TextOverflow.visible,
                        proposal.number ?? "",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              proposal.type == "Estimate" &&
                                  proposal.isConverted == false
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            MainDivider(),

            // Date Row
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.sp,
                horizontal: Get.size.width <= 440 ? 16.sp : 8.sp,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Date",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: LightThemeColors.hintTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Flexible(
                    child: proposal.invoiceDate != ""
                        ? Text(
                            dateTimeConverter(
                              inputFormat: "yyyy/MM/dd hh:mm a",
                              inputTime: proposal.invoiceDate.toString(),
                              outputFormat: "MM/dd/yyyy",
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.visible,
                            maxLines: null,
                          )
                        : const Text(""),
                  ),
                ],
              ),
            ),
            MainDivider(),

            // Required Amount Row
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.sp,
                horizontal: Get.size.width <= 440 ? 16.sp : 8.sp,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Required Amount",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: LightThemeColors.hintTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Flexible(
                    child: Text(
                      "\$${proposal.total?.toStringAsFixed(2) ?? ""}",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
            MainDivider(),

            // Amount Received Row
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.sp,
                horizontal: Get.size.width <= 440 ? 16.sp : 8.sp,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Amount Received",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: LightThemeColors.hintTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Flexible(
                    child: Text(
                      "\$${proposal.depositAmount?.toStringAsFixed(2) ?? ""}",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _loadInvoiceDetails(dynamic invoice, in) async {
  //   controller.invoiceController.existingItemType.value =
  //       SelectedItemCategory.existingOne;
  //       controller.selectSingleAppointments(appointment, index)
  //   controller.invoiceController.selectedItemList.clear();
  // }

  void _showCreateInvoiceMenu(BuildContext context) {
    final RenderBox buttonRenderBox =
        _createInvoiceButtonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final buttonPosition = buttonRenderBox.localToGlobal(Offset.zero);
    final buttonSize = buttonRenderBox.size;

    showMenu(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      ),
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          buttonPosition.dx,
          buttonPosition.dy + buttonSize.height,
          buttonSize.width,
          buttonSize.height,
        ),
        Offset.zero & overlay.size,
      ),
      items: controller.invoiceController.createTypes.map((e) {
        return PopupMenuItem<String>(
          value: e["name"],
          child: TextWidget(text: "${e["name"]}"),
        );
      }).toList(),
    ).then((v) async {
      if (v != null) {
        controller.invoiceController.clearAllItems();
        controller.invoiceController.selectedCreateType.value = v;

        final x = MySharedPref.getCompanyType() ?? '';
        controller.invoiceController.isLocAndClassShow.value = x == 'IsPcs';

        controller.invoiceController.createCustomerName =
            controller.contactName;
        controller.invoiceController.createCustomerAddress = controller.address;
        controller.invoiceController.createCustomerPhone =
            controller.mobileNumber;
        controller.invoiceController.createCustomerEmail = controller.email;
        controller.invoiceController.customerID.value = controller.customerID;
        controller.invoiceController.appointmentID = controller.appointmentID;
        controller.invoiceController.selectedTaxID.value = "";
        controller.invoiceController.createDiscountTextController.clear();

        await controller.invoiceController.getInvoiceName();
        Get.toNamed(Routes.INVOICE_CREATE);
      }
    });
  }
}
