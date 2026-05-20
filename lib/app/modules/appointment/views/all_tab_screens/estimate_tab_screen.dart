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
                  subtitle: 'Create an invoice or estimate for this appointment.',
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
    Invoices proposal, {
    bool isExtended = false,
  }) {
    final isEstimate = proposal.type == "Estimate";
    return OrganicCard(
      margin: EdgeInsets.only(bottom: 10.h),
      shadow: WarmOrganicBlueTheme.softShadow,
      onTap: () async {
        controller.showLoading();
        controller.invoiceController.isExternalInvoice.value = isExtended;
        await _loadInvoiceDetails(proposal);
        controller.hideLoading();
        Get.toNamed(Routes.INVOICE_DETAILS);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isEstimate
                      ? WarmOrganicBlueTheme.statusYellowLight
                      : WarmOrganicBlueTheme.statusGreenLight,
                  borderRadius: BorderRadius.circular(
                    WarmOrganicBlueTheme.radiusFull,
                  ),
                ),
                child: Text(
                  isEstimate ? 'Estimate' : 'Invoice',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: isEstimate
                        ? WarmOrganicBlueTheme.statusYellow
                        : WarmOrganicBlueTheme.statusGreen,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                proposal.number ?? "",
                style: WarmOrganicBlueTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildCSLRow(
            'Amount',
            '\$${proposal.total?.toStringAsFixed(2) ?? "0.00"}',
          ),
          _buildCSLRow(
            'Date',
            dateTimeConverter(
              inputFormat: "yyyy/MM/dd hh:mm a",
              inputTime: proposal.invoiceDate.toString(),
              outputFormat: "MM/dd/yyyy",
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: OrganicSecondaryButton(
              text: 'View Details',
              height: 36.h,
              onPressed: () async {
                controller.showLoading();
                controller.invoiceController.isExternalInvoice.value = false;
                if (controller.invoiceController.existingItemType.value ==
                    SelectedItemCategory.newOne) {
                  controller.invoiceController.saveBackup("new");
                }

                controller.invoiceController.existingItemType.value =
                    SelectedItemCategory.existingOne;

                controller.invoiceController.selectedItemList.clear();
                for (var c
                    in controller.invoiceController.editAmountControllers) {
                  c.dispose();
                }
                for (var c
                    in controller.invoiceController.editDescriptionControllers) {
                  c.dispose();
                }
                for (var c
                    in controller.invoiceController.editQuantityControllers) {
                  c.dispose();
                }
                controller.invoiceController.editAmountControllers.clear();
                controller.invoiceController.editDescriptionControllers.clear();
                controller.invoiceController.editQuantityControllers.clear();
                controller.invoiceController.editNoteTextController.clear();
                controller.invoiceController.editDiscountTextController.clear();
                controller.invoiceController.initialTaxID.value = "";

                controller.invoiceController.invoiceItemList.value =
                    proposal.items ?? [];
                controller.invoiceController.depositList.value =
                    proposal.paymentList ?? [];
                controller.invoiceController.selectedDiscountOption.value =
                    proposal.discountOption ?? "2";
                controller.invoiceController.invoiceNumber =
                    proposal.number ?? "";
                controller.invoiceController.isConverted.value =
                    proposal.isConverted ?? false;
                controller.invoiceController.customerName =
                    proposal.fullName ?? "";
                controller.invoiceController.address = "${proposal.city}, ";
                controller.invoiceController.depositAmount.value =
                    proposal.depositAmount?.toStringAsFixed(2) ?? "0.00";
                controller.invoiceController.invoiceID.value = proposal
                    .invoiceID
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
                  controller
                          .invoiceController
                          .selectedDepositRequestOption
                          .value =
                      "2";
                  controller
                          .invoiceController
                          .requestedDepositAmountEditTextController
                          .text =
                      proposal.requestedDepositAmount ?? "0.00";
                  controller
                      .invoiceController
                      .selectedDepositRequestOptionName
                      .value = controller
                      .invoiceController
                      .depositRequestOptions[2]["name"];
                }
                if (proposal.requestedAmountType == 1) {
                  controller
                          .invoiceController
                          .selectedDepositRequestOption
                          .value =
                      "1";
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
                  controller
                      .invoiceController
                      .selectedDepositRequestOptionName
                      .value = controller
                      .invoiceController
                      .depositRequestOptions[1]["name"];
                }
                if (proposal.requestedAmountType == 0) {
                  controller
                          .invoiceController
                          .selectedDepositRequestOption
                          .value =
                      "0";
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
                  controller
                      .invoiceController
                      .selectedDepositRequestOptionName
                      .value = controller
                      .invoiceController
                      .depositRequestOptions[0]["name"];
                }
                controller.invoiceController.notes = proposal.note ?? "";
                controller.invoiceController.editNoteTextController.text =
                    proposal.note ?? "";
                controller.invoiceController.due = proposal.due ?? "";
                controller.invoiceController.showingDate.value =
                    dateTimeConverter(
                      inputFormat: "yyyy/MM/dd hh:mm a",
                      inputTime: proposal.invoiceDate.toString(),
                      outputFormat: "MM/dd/yyyy",
                    );
                if (proposal.taxType != "") {
                  controller.invoiceController.initialTaxID.value =
                      proposal.taxType ?? "";
                }

                controller.invoiceController.invoiceDiscountDetails.value =
                    proposal.discount ?? 0.00;
                if (proposal.discountOption == "1") {
                  controller.invoiceController.editDiscountTextController.text =
                      (((double.parse(
                                    proposal.discount?.toString() ?? "0.00",
                                  )) *
                                  100) /
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

                if (proposal.items != null && proposal.items!.isNotEmpty) {
                  for (var item in proposal.items!) {
                    controller.invoiceController.selectedItemList.add(
                      ItemListModel(
                        id: item.itemId,
                        name: item.name,
                        description: item.description,
                        price: double.tryParse(item.unitPrice ?? "0.00"),
                        isTaxable: item.isTaxable == "TAX" ? true : false,
                      ),
                    );

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
                      .where(
                        (e) => e.qboClassId.toString() == proposal.qboClassId,
                      )
                      .firstOrNull,
                );
                controller.invoiceController.selectedQboLocation(
                  controller.invoiceController.qboLocationList
                      .where(
                        (e) =>
                            e.qboLocationId.toString() ==
                            proposal.qboLocationId,
                      )
                      .firstOrNull,
                );
                controller.invoiceController.removedList.clear();
                controller.hideLoading();
                final x = MySharedPref.getCompanyType() ?? '';
                controller.invoiceController.isLocAndClassShow.value =
                    x == 'PCS';
                controller.invoiceController.selectedInvoice.value = proposal;
                Get.toNamed(Routes.INVOICE_DETAILS);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCSLRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: WarmOrganicBlueTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: WarmOrganicBlueTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadInvoiceDetails(dynamic invoice) async {
    controller.invoiceController.existingItemType.value =
        SelectedItemCategory.existingOne;
    controller.invoiceController.selectedItemList.clear();
  }

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
