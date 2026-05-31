import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../config/theme/light_theme_colors.dart';
import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../controllers/invoice_controller.dart';

class BillableItemsView extends GetView<InvoiceController> {
  const BillableItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Add Billable Items'), centerTitle: false),
      body: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          children: [
            // Search By Dropdown
            Row(
              children: [
                Text("Search Items By: ", style: theme.textTheme.bodyMedium),
                SizedBox(width: 10.sp),
                Expanded(
                  child: Obx(
                    () => DropdownButton<String>(
                      value: controller.searchByType.value,
                      isExpanded: true,
                      items: controller.searchOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        controller.searchByType.value = newValue!;
                        // Reset specific filters when type changes
                        controller.selectedGroup.value = "";
                        controller.selectedBundle.value = "";
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.sp),

            // Conditional Group/Bundle Dropdowns
            Obx(() {
              if (controller.searchByType.value == "Group") {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.sp),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Select Group",
                    ),
                    value: controller.selectedGroup.value.isEmpty
                        ? null
                        : controller.selectedGroup.value,
                    items: controller.groupList.map((group) {
                      return DropdownMenuItem(value: group, child: Text(group));
                    }).toList(),
                    onChanged: (val) {
                      controller.selectedGroup.value = val!;
                      controller.itemController.sortItems();
                    },
                  ),
                );
              } else if (controller.searchByType.value == "Bundle") {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.sp),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Select Bundle",
                    ),
                    value: controller.selectedBundle.value.isEmpty
                        ? null
                        : controller.selectedBundle.value,
                    items: controller.bundleList.map((bundle) {
                      return DropdownMenuItem(
                        value: bundle,
                        child: Text(bundle),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.selectedBundle.value = val!;
                      controller.itemController.sortItems();
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 40.sp,
                  ),
                  child: Column(
                    children: [
                      // Header Row for the table
                      SizedBox(height: 15.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.sp,
                          vertical: 12.sp,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(8.r),
                          ),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 48), // Placeholder for checkbox
                            SizedBox(
                              width: 180,
                              child: Text(
                                "Item Name",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 250,
                              child: Text(
                                "Description",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                "Qty on Hand",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                "Unit Cost",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      SizedBox(
                        width: 758,
                        height: MediaQuery.of(context).size.height * 0.40,
                        child: Obx(() {
                          // Track both sortedItems and selectedItemList for reactivity
                          final items = controller.itemController.sortedItems;
                          final selectedIds = controller.selectedItemList
                              .map((e) => e.id)
                              .toSet();

                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final alreadySelected = selectedIds.contains(
                                item.id,
                              );

                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 12.sp),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.sp),
                                      child: Checkbox(
                                        activeColor: theme.primaryColor,
                                        value: alreadySelected,
                                        onChanged: (checked) {
                                          // controller.markAsDirty();
                                          if (checked == true &&
                                              !controller.selectedItemList.any(
                                                (selected) =>
                                                    selected.id == item.id,
                                              )) {
                                            controller.selectedItemList.add(
                                              item,
                                            );
                                            controller.editAmountControllers
                                                .add(
                                                  TextEditingController(
                                                    text: item.price.toString(),
                                                  ),
                                                );
                                            controller
                                                .editDescriptionControllers
                                                .add(
                                                  TextEditingController(
                                                    text:
                                                        item.description ?? "",
                                                  ),
                                                );
                                            controller.editQuantityControllers
                                                .add(
                                                  TextEditingController(
                                                    text: '1',
                                                  ),
                                                );
                                            controller.createTotalForEdit();
                                            controller
                                                .updateRequestedDepositAmount();
                                          } else if (checked == false &&
                                              controller.selectedItemList.any(
                                                (selected) =>
                                                    selected.id == item.id,
                                              )) {
                                            final itemIndex = controller
                                                .selectedItemList
                                                .indexWhere(
                                                  (selected) =>
                                                      selected.id == item.id,
                                                );
                                            if (itemIndex != -1) {
                                              controller.selectedItemList
                                                  .removeAt(itemIndex);
                                              controller.editAmountControllers
                                                  .removeAt(itemIndex);
                                              controller
                                                  .editDescriptionControllers
                                                  .removeAt(itemIndex);
                                              controller.editQuantityControllers
                                                  .removeAt(itemIndex);
                                              controller.createTotalForEdit();
                                              controller
                                                  .updateRequestedDepositAmount();
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 160,
                                      child: Text(
                                        item.name ?? "",
                                        style: TextStyle(
                                          color: LightThemeColors.primaryColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 230,
                                      child: Text(
                                        item.description ?? "",
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        "${item.quantityOnHand ?? 0}",
                                        style: theme.textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        "\$${(item.price ?? 0.00).toStringAsFixed(2)}",
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.sp),
            PrimaryButton(
              title: "Done",
              onPressed: () {
                controller.resetTaxIfNonTaxableItems();
                controller.createTotalForEdit();
                Get.back();
              },
              inactive: false,
            ),
          ],
        ),
      ),
    );
  }
}
