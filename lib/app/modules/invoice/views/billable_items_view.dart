import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../config/theme/light_theme_colors.dart';
import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../../../components/global-widgets/infinite_scroll_listview.dart';
import '../../../modules/item/models/item_bundle_model.dart';
import '../../../modules/item/models/item_list_model.dart';
import '../controllers/invoice_controller.dart';

class BillableItemsView extends GetView<InvoiceController> {
  const BillableItemsView({super.key, this.isFromCreateInvoice = false});
  final bool isFromCreateInvoice;
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
            // Search Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search By Dropdown
                    Row(
                      children: [
                        Text(
                          "Search Items By: ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: Obx(
                            () => DropdownButton<SearchByType>(
                              value: controller.searchByType.value,
                              isExpanded: true,
                              items: controller.searchOptions.map((
                                SearchByType value,
                              ) {
                                return DropdownMenuItem<SearchByType>(
                                  value: value,
                                  child: Text(value.displayName),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                controller.searchByType.value = newValue!;
                                // Reset specific filters when type changes
                                controller
                                        .itemController
                                        .selectedItemGroup
                                        .value =
                                    null;
                                controller
                                        .itemController
                                        .selectedItemBundle
                                        .value =
                                    null;

                                // Load item groups when Group is selected
                                if (newValue == SearchByType.group &&
                                    controller
                                        .itemController
                                        .itemGroups
                                        .isEmpty) {
                                  controller.itemController.getItemGroups();
                                }

                                // Load item bundles when Bundle is selected
                                if (newValue == SearchByType.bundle &&
                                    controller
                                        .itemController
                                        .itemBundles
                                        .isEmpty) {
                                  controller.itemController.getBundles(false);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.sp),

                    // Conditional Group/Bundle Dropdowns
                    Obx(() {
                      if (controller.searchByType.value == SearchByType.group) {
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "Select Group",
                            border: OutlineInputBorder(),
                          ),
                          initialValue: controller
                              .itemController
                              .selectedItemGroup
                              .value
                              ?.groupName,
                          items: controller.itemController.itemGroups.map((
                            group,
                          ) {
                            return DropdownMenuItem(
                              value: group.groupName,
                              child: Text(group.groupName ?? ""),
                            );
                          }).toList(),
                          onChanged: (val) {
                            final selectedGroup = controller
                                .itemController
                                .itemGroups
                                .firstWhere((group) => group.groupName == val);
                            controller.itemController.selectedItemGroup.value =
                                selectedGroup;

                            // Load group items when group is selected (uses selectedGroup.value.id internally)
                            if (selectedGroup.id != null) {
                              controller.itemController.getItemGroupById(
                                isShowLoading: false,
                              );
                            }

                            // controller.itemController.sortItems();
                          },
                        );
                      } else if (controller.searchByType.value ==
                          SearchByType.bundle) {
                        return DropdownButtonFormField<ItemBundleModel>(
                          decoration: const InputDecoration(
                            labelText: "Select Bundle",
                            border: OutlineInputBorder(),
                          ),
                          initialValue: controller
                              .itemController
                              .selectedItemBundle
                              .value,
                          items: controller.itemController.itemBundles.map((
                            bundle,
                          ) {
                            return DropdownMenuItem(
                              value: bundle,
                              child: Text(bundle.bundleName ?? ""),
                            );
                          }).toList(),
                          onChanged: (val) {
                            controller.itemController.selectedItemBundle.value =
                                val;
                            // Load bundle items when bundle is selected (uses selectedItemBundle.value.id internally)
                            if (val != null && val.id != null) {
                              controller.itemController.getItemsByBundleId(
                                isShowLoading: false,
                              );
                            }
                            controller.itemController.sortItems();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    SizedBox(height: 12.sp),

                    // Search TextField
                    SizedBox(
                      height: 40.sp,
                      child: GeneralTextField(
                        hint: "Search item",
                        focusNode:
                            controller.invoiceDetailsSearchFocusnode.value,
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.sp),

            // Table Section
            Expanded(
              child: Column(
                children: [
                  // Table Header
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Center(child: SizedBox(width: 24, height: 24)),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.sp),
                            child: Text(
                              "Item Name",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.sp),
                            child: Text(
                              "Description",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.sp),
                            child: Text(
                              "Qty",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.sp),
                            child: Text(
                              "Unit Cost",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Body
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Obx(() {
                        // Get items based on search type
                        List<ItemListModel> items;
                        if (controller.searchByType.value ==
                            SearchByType.name) {
                          items = controller.itemController.sortedItems;
                        } else if (controller.searchByType.value ==
                            SearchByType.group) {
                          items =
                              controller
                                  .itemController
                                  .selectedItemGroup
                                  .value
                                  ?.items ??
                              [];
                        } else {
                          items =
                              controller
                                  .itemController
                                  .selectedItemBundle
                                  .value
                                  ?.items ??
                              [];
                        }

                        final selectedIds = controller.selectedItemList
                            .map((e) => e.id)
                            .toSet();

                        // Determine load more function based on search type
                        Future<void> loadMore() async {
                          if (controller.searchByType.value ==
                              SearchByType.group) {
                            await controller.itemController
                                .loadMoreGroupItems();
                          } else if (controller.searchByType.value ==
                              SearchByType.bundle) {
                            await controller.itemController
                                .loadMoreBundleItems();
                          }
                        }

                        return InfiniteScrollListView<ItemListModel>(
                          items: items,
                          hasMore: controller.itemController.hasMoreItems.value,
                          isLoading:
                              controller.itemController.isLoadingMore.value,
                          onLoadMore: loadMore,
                          itemBuilder: (context, index, item) {
                            final alreadySelected = selectedIds.contains(
                              item.id,
                            );
                            final isSelected = controller.selectedItemList
                                .contains(item);

                            return Material(
                              color: index.isEven
                                  ? Colors.white
                                  : Colors.grey.shade50,
                              child: InkWell(
                                hoverColor: theme.primaryColor.withValues(
                                  alpha: 0.05,
                                ),
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.sp,
                                    vertical: 12.sp,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Center(
                                          child: isFromCreateInvoice
                                              ? Checkbox(
                                                  activeColor:
                                                      theme.primaryColor,
                                                  value: isSelected,
                                                  onChanged: (checked) {
                                                    if (checked == true &&
                                                        !isSelected) {
                                                      controller
                                                          .selectedItemList
                                                          .add(item);
                                                      controller
                                                          .amountControllers
                                                          .add(
                                                            TextEditingController(
                                                              text: item.price
                                                                  .toString(),
                                                            ),
                                                          );
                                                      controller
                                                          .descriptionControllers
                                                          .add(
                                                            TextEditingController(
                                                              text:
                                                                  item.description ??
                                                                  "",
                                                            ),
                                                          );
                                                      controller
                                                          .quantityControllers
                                                          .add(
                                                            TextEditingController(
                                                              text: '1',
                                                            ),
                                                          );
                                                    } else if (checked ==
                                                            false &&
                                                        isSelected) {
                                                      final idx = controller
                                                          .selectedItemList
                                                          .indexOf(item);
                                                      controller
                                                          .selectedItemList
                                                          .removeAt(idx);
                                                      controller
                                                          .amountControllers
                                                          .removeAt(idx);
                                                      controller
                                                          .descriptionControllers
                                                          .removeAt(idx);
                                                      controller
                                                          .quantityControllers
                                                          .removeAt(idx);
                                                    }
                                                    controller.createTotal();
                                                  },
                                                )
                                              : Checkbox(
                                                  activeColor:
                                                      theme.primaryColor,
                                                  value: alreadySelected,
                                                  onChanged: (checked) {
                                                    if (checked == true &&
                                                        !controller
                                                            .selectedItemList
                                                            .any(
                                                              (selected) =>
                                                                  selected.id ==
                                                                  item.id,
                                                            )) {
                                                      controller
                                                          .selectedItemList
                                                          .add(item);
                                                      controller
                                                          .editAmountControllers
                                                          .add(
                                                            TextEditingController(
                                                              text: item.price
                                                                  .toString(),
                                                            ),
                                                          );
                                                      controller
                                                          .editDescriptionControllers
                                                          .add(
                                                            TextEditingController(
                                                              text:
                                                                  item.description ??
                                                                  "",
                                                            ),
                                                          );
                                                      controller
                                                          .editQuantityControllers
                                                          .add(
                                                            TextEditingController(
                                                              text: '1',
                                                            ),
                                                          );
                                                      controller
                                                          .createTotalForEdit();
                                                      controller
                                                          .updateRequestedDepositAmount();
                                                    } else if (checked ==
                                                            false &&
                                                        controller
                                                            .selectedItemList
                                                            .any(
                                                              (selected) =>
                                                                  selected.id ==
                                                                  item.id,
                                                            )) {
                                                      final itemIndex =
                                                          controller
                                                              .selectedItemList
                                                              .indexWhere(
                                                                (selected) =>
                                                                    selected
                                                                        .id ==
                                                                    item.id,
                                                              );
                                                      if (itemIndex != -1) {
                                                        controller
                                                            .selectedItemList
                                                            .removeAt(
                                                              itemIndex,
                                                            );
                                                        controller
                                                            .editAmountControllers
                                                            .removeAt(
                                                              itemIndex,
                                                            );
                                                        controller
                                                            .editDescriptionControllers
                                                            .removeAt(
                                                              itemIndex,
                                                            );
                                                        controller
                                                            .editQuantityControllers
                                                            .removeAt(
                                                              itemIndex,
                                                            );
                                                        controller
                                                            .createTotalForEdit();
                                                        controller
                                                            .updateRequestedDepositAmount();
                                                      }
                                                    }
                                                  },
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.sp,
                                          ),
                                          child: Text(
                                            item.name ?? "",
                                            style: TextStyle(
                                              color:
                                                  LightThemeColors.primaryColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14.sp,
                                            ),
                                            maxLines: null,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.sp,
                                          ),
                                          child: Text(
                                            item.description ?? "",
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(fontSize: 13.sp),
                                            maxLines: null,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.sp,
                                          ),
                                          child: Text(
                                            "${item.quantityOnHand ?? 0}",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(fontSize: 13.sp),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.sp,
                                          ),
                                          child: Text(
                                            "\$${(item.price ?? 0.00).toStringAsFixed(2)}",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13.sp,
                                                ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.sp),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.all(20.sp),
        child: PrimaryButton(
          title: "Done",
          onPressed: () {
            controller.resetTaxIfNonTaxableItems();
            // controller.createTotalForEdit();
            Get.back();
          },
          inactive: false,
        ),
      ),
    );
  }
}
