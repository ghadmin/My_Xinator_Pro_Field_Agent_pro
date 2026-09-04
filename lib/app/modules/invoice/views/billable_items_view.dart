import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../config/theme/light_theme_colors.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../components/global-widgets/infinite_scroll_listview.dart';
import '../../../modules/item/models/item_bundle_model.dart';
import '../../../modules/item/models/item_list_model.dart';
import '../controllers/invoice_controller.dart';

class BillableItemsView extends GetView<InvoiceController> {
  BillableItemsView({super.key, this.isFromCreateInvoice = false});
  final bool isFromCreateInvoice;

  final RxList<ItemListModel> _customItems = <ItemListModel>[].obs;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LightThemeColors.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilterCard(context, theme),
          _buildItemsHeaderRow(theme),
          Expanded(child: _buildItemsSection(theme)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: Text(
        "Add Billable Items",
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: LightThemeColors.appBlackColor,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: LightThemeColors.appBarBorderColor),
      ),
    );
  }

  Widget _buildSearchAndFilterCard(BuildContext context, ThemeData theme) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.sp, 16.sp, 16.sp, 0),
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: LightThemeColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SEARCH ITEMS BY",
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: LightThemeColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.sp),
          _buildSearchByDropdown(theme),
          Obx(() {
            if (controller.searchByType.value == SearchByType.group) {
              return Padding(
                padding: EdgeInsets.only(top: 10.sp),
                child: DropdownButtonFormField<String>(
                  decoration: _dropdownFieldDecoration("Select Group"),
                  initialValue: controller
                      .itemController
                      .selectedItemGroup
                      .value
                      ?.groupName,
                  items: controller.itemController.itemGroups.map((group) {
                    return DropdownMenuItem(
                      value: group.groupName,
                      child: Text(
                        group.groupName ?? "",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: LightThemeColors.appBlackColor,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    final selectedGroup = controller.itemController.itemGroups
                        .firstWhere((group) => group.groupName == val);
                    controller.itemController.selectedItemGroup.value =
                        selectedGroup;
                    if (selectedGroup.id != null) {
                      controller.itemController.getItemGroupById(
                        isShowLoading: false,
                      );
                    }
                  },
                ),
              );
            } else if (controller.searchByType.value == SearchByType.bundle) {
              return Padding(
                padding: EdgeInsets.only(top: 10.sp),
                child: DropdownButtonFormField<ItemBundleModel>(
                  decoration: _dropdownFieldDecoration("Select Bundle"),
                  initialValue:
                      controller.itemController.selectedItemBundle.value,
                  items: controller.itemController.itemBundles.map((bundle) {
                    return DropdownMenuItem(
                      value: bundle,
                      child: Text(
                        bundle.bundleName ?? "",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: LightThemeColors.appBlackColor,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.itemController.selectedItemBundle.value = val;
                    if (val != null && val.id != null) {
                      controller.itemController.getItemsByBundleId(
                        isShowLoading: false,
                      );
                    }
                    controller.itemController.sortItems();
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          SizedBox(height: 10.sp),
          _buildSearchField(theme),
          SizedBox(height: 10.sp),
          _buildAddCustomItemButton(context),
        ],
      ),
    );
  }

  InputDecoration _dropdownFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: LightThemeColors.textSecondary,
      ),
      filled: true,
      fillColor: LightThemeColors.surfaceColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: LightThemeColors.primaryColor,
          width: 1.2,
        ),
      ),
    );
  }

  Widget _buildSearchByDropdown(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: LightThemeColors.surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<SearchByType>(
            value: controller.searchByType.value,
            isExpanded: true,
            isDense: true,
            borderRadius: BorderRadius.circular(10),
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.expand_more,
              size: 20.sp,
              color: LightThemeColors.textSecondary,
            ),
            items: controller.searchOptions.map((SearchByType value) {
              return DropdownMenuItem<SearchByType>(
                value: value,
                child: Text(
                  value.displayName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: LightThemeColors.appBlackColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              controller.searchByType.value = newValue!;
              controller.itemController.selectedItemGroup.value = null;
              controller.itemController.selectedItemBundle.value = null;
              if (newValue == SearchByType.group &&
                  controller.itemController.itemGroups.isEmpty) {
                controller.itemController.getItemGroups();
              }
              if (newValue == SearchByType.bundle &&
                  controller.itemController.itemBundles.isEmpty) {
                controller.itemController.getBundles(false);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      controller: controller.itemController.sortTextController,
      focusNode: controller.invoiceDetailsSearchFocusnode.value,
      textInputAction: TextInputAction.search,
      onChanged: (_) => controller.itemController.sortItems(),
      cursorColor: LightThemeColors.primaryColor,
      style: TextStyle(fontSize: 13.sp, color: LightThemeColors.appBlackColor),
      decoration: InputDecoration(
        hintText: "Search billable items or services...",
        hintStyle: TextStyle(
          fontSize: 13.sp,
          color: LightThemeColors.textTertiary,
        ),
        prefixIcon: Icon(
          Icons.search,
          size: 20.sp,
          color: LightThemeColors.textSecondary,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller.itemController.sortTextController,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.cancel,
                size: 18.sp,
                color: LightThemeColors.textTertiary,
              ),
              onPressed: () {
                controller.itemController.sortTextController.clear();
                controller.itemController.sortItems();
              },
            );
          },
        ),
        isDense: true,
        filled: true,
        fillColor: LightThemeColors.surfaceColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.sp,
          vertical: 14.sp,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: LightThemeColors.primaryColor,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  static const Color _sheetFieldColor = Color(0xFFEFF4FF);

  Widget _buildAddCustomItemButton(BuildContext context) {
    return Material(
      color: LightThemeColors.primaryContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showAddCustomItemSheet(context),
        child: SizedBox(
          height: 44.sp,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18.sp,
                color: LightThemeColors.primaryColor,
              ),
              SizedBox(width: 6.sp),
              Text(
                "Add Custom Item",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: LightThemeColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCustomItemSheet(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController(text: "1.0");
    final priceController = TextEditingController();
    bool isTaxable = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
                ),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48.sp,
                            height: 5.sp,
                            decoration: BoxDecoration(
                              color: LightThemeColors.textDisabled,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(height: 14.sp),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 34.sp,
                              height: 34.sp,
                              decoration: BoxDecoration(
                                color: LightThemeColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_task,
                                size: 20.sp,
                                color: LightThemeColors.primaryDark,
                              ),
                            ),
                            SizedBox(width: 8.sp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add Custom Item",
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                      color: LightThemeColors.appBlackColor,
                                    ),
                                  ),
                                  Text(
                                    "Configure line item for this invoice only",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: LightThemeColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Navigator.of(sheetContext).pop(),
                              child: Container(
                                width: 34.sp,
                                height: 34.sp,
                                decoration: BoxDecoration(
                                  color: LightThemeColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 20.sp,
                                  color: LightThemeColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.sp),
                        Text(
                          "Item or Service Name *",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: LightThemeColors.appBlackColor,
                          ),
                        ),
                        SizedBox(height: 6.sp),
                        TextField(
                          controller: nameController,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: LightThemeColors.appBlackColor,
                          ),
                          decoration: _sheetFieldDecoration(
                            "e.g., Expedited Shipping",
                          ),
                        ),
                        SizedBox(height: 12.sp),
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: LightThemeColors.appBlackColor,
                          ),
                        ),
                        SizedBox(height: 6.sp),
                        TextField(
                          controller: descriptionController,
                          maxLines: 2,
                          minLines: 1,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: LightThemeColors.appBlackColor,
                          ),
                          decoration: _sheetFieldDecoration(
                            "Add specific task or deliverable scope...",
                          ),
                        ),
                        SizedBox(height: 12.sp),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Quantity / Count",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: LightThemeColors.appBlackColor,
                                    ),
                                  ),
                                  SizedBox(height: 6.sp),
                                  TextField(
                                    controller: quantityController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: LightThemeColors.appBlackColor,
                                    ),
                                    decoration: _sheetFieldDecoration(
                                      "1.0",
                                      suffixText: "Units",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.sp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Unit Price / Rate (\$)",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: LightThemeColors.appBlackColor,
                                    ),
                                  ),
                                  SizedBox(height: 6.sp),
                                  TextField(
                                    controller: priceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: LightThemeColors.appBlackColor,
                                    ),
                                    decoration: _sheetFieldDecoration(
                                      "0.00",
                                      prefixText: "\$",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.sp),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Taxable",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: LightThemeColors.appBlackColor,
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isTaxable,
                                onChanged: (value) =>
                                    setSheetState(() => isTaxable = value),
                                activeThumbColor: LightThemeColors.primaryColor,
                                activeTrackColor: LightThemeColors.primaryColor
                                    .withValues(alpha: 0.3),
                                inactiveTrackColor: Colors.grey.shade300,
                                inactiveThumbColor: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.sp),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Material(
                                color: LightThemeColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => Navigator.of(sheetContext).pop(),
                                  child: Container(
                                    height: 48.sp,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: LightThemeColors.appBlackColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.sp),
                            Expanded(
                              flex: 2,
                              child: PrimaryButtonWithIcon(
                                title: "Add to Invoice",
                                iconData: Icons.check,
                                height: 48.sp,
                                onPressed: () {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty) {
                                    MySnackBar.showErrorToast(
                                      message: "Please enter an item name",
                                    );
                                    return;
                                  }
                                  final price =
                                      double.tryParse(
                                        priceController.text.trim().replaceAll(
                                          ",",
                                          "",
                                        ),
                                      ) ??
                                      0.00;
                                  final quantity =
                                      double.tryParse(
                                        quantityController.text.trim(),
                                      ) ??
                                      1.0;
                                  final customItem = ItemListModel(
                                    id: null,
                                    name: name,
                                    description: descriptionController.text
                                        .trim(),
                                    price: price,
                                    isTaxable: isTaxable,
                                  );
                                  _customItems.add(customItem);
                                  _toggleCustomItem(
                                    customItem,
                                    quantity: quantity.toString(),
                                  );
                                  Navigator.of(sheetContext).pop();
                                },
                                inactive: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _sheetFieldDecoration(
    String hint, {
    String? prefixText,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14.sp,
        color: LightThemeColors.textTertiary,
      ),
      prefixText: prefixText,
      prefixStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: LightThemeColors.textSecondary,
      ),
      suffixText: suffixText,
      suffixStyle: TextStyle(
        fontSize: 11.sp,
        color: LightThemeColors.textSecondary,
      ),
      filled: true,
      fillColor: _sheetFieldColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 14.sp),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: LightThemeColors.primaryColor,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _buildItemsHeaderRow(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.sp, 16.sp, 20.sp, 10.sp),
      child: Obx(() {
        final count = _activeItems().length + _customItems.length;
        return Row(
          children: [
            Text(
              "Available Items",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: LightThemeColors.appBlackColor,
              ),
            ),
            SizedBox(width: 8.sp),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 3.sp),
              decoration: BoxDecoration(
                color: LightThemeColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$count total",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: LightThemeColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<ItemListModel> _activeItems() {
    if (controller.searchByType.value == SearchByType.name) {
      return controller.itemController.sortedItems;
    } else if (controller.searchByType.value == SearchByType.group) {
      return controller.itemController.selectedItemGroup.value?.items ?? [];
    } else {
      return controller.itemController.selectedItemBundle.value?.items ?? [];
    }
  }

  void _toggleCustomItem(ItemListModel item, {String quantity = '1'}) {
    final idx = controller.selectedItemList.indexOf(item);
    if (idx != -1) {
      controller.selectedItemList.removeAt(idx);
      if (isFromCreateInvoice) {
        controller.amountControllers.removeAt(idx);
        controller.descriptionControllers.removeAt(idx);
        controller.quantityControllers.removeAt(idx);
        controller.createTotal();
      } else {
        controller.editAmountControllers.removeAt(idx);
        controller.editDescriptionControllers.removeAt(idx);
        controller.editQuantityControllers.removeAt(idx);
        controller.createTotalForEdit();
        controller.updateRequestedDepositAmount();
      }
      return;
    }
    controller.selectedItemList.add(item);
    if (isFromCreateInvoice) {
      controller.amountControllers.add(
        TextEditingController(text: item.price.toString()),
      );
      controller.descriptionControllers.add(
        TextEditingController(text: item.description ?? ""),
      );
      controller.quantityControllers.add(TextEditingController(text: quantity));
      controller.createTotal();
    } else {
      controller.editAmountControllers.add(
        TextEditingController(text: item.price.toString()),
      );
      controller.editDescriptionControllers.add(
        TextEditingController(text: item.description ?? ""),
      );
      controller.editQuantityControllers.add(
        TextEditingController(text: quantity),
      );
      controller.createTotalForEdit();
      controller.updateRequestedDepositAmount();
    }
  }

  Widget _buildItemsSection(ThemeData theme) {
    return Obx(() {
      List<ItemListModel> items;
      if (controller.searchByType.value == SearchByType.name) {
        items = controller.itemController.sortedItems;
      } else if (controller.searchByType.value == SearchByType.group) {
        items = controller.itemController.selectedItemGroup.value?.items ?? [];
      } else {
        items = controller.itemController.selectedItemBundle.value?.items ?? [];
      }
      items = [..._customItems, ...items];
      final selectedIds = controller.selectedItemList.map((e) => e.id).toSet();
      Future<void> loadMore() async {
        if (controller.searchByType.value == SearchByType.group) {
          await controller.itemController.loadMoreGroupItems();
        } else if (controller.searchByType.value == SearchByType.bundle) {
          await controller.itemController.loadMoreBundleItems();
        }
      }

      if (items.isEmpty) {
        return _buildEmptyState(theme);
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(16.sp, 0, 16.sp, 16.sp),
        child: InfiniteScrollListView<ItemListModel>(
          items: items,
          hasMore: controller.itemController.hasMoreItems.value,
          isLoading: controller.itemController.isLoadingMore.value,
          onLoadMore: loadMore,
          separatorBuilder: SizedBox(height: 10.sp),
          itemBuilder: (context, index, item) {
            final alreadySelected = selectedIds.contains(item.id);
            final isSelected = controller.selectedItemList.contains(item);
            final isCustom = _customItems.contains(item);
            final visuallySelected = isCustom
                ? isSelected
                : (isFromCreateInvoice ? isSelected : alreadySelected);
            void toggleForCreate() {
              if (!isSelected) {
                controller.selectedItemList.add(item);
                controller.amountControllers.add(
                  TextEditingController(text: item.price.toString()),
                );
                controller.descriptionControllers.add(
                  TextEditingController(text: item.description ?? ""),
                );
                controller.quantityControllers.add(
                  TextEditingController(text: '1'),
                );
              } else {
                final idx = controller.selectedItemList.indexOf(item);
                controller.selectedItemList.removeAt(idx);
                controller.amountControllers.removeAt(idx);
                controller.descriptionControllers.removeAt(idx);
                controller.quantityControllers.removeAt(idx);
              }
              controller.createTotal();
            }

            void toggleForEdit() {
              final alreadyInList = controller.selectedItemList.any(
                (selected) => selected.id == item.id,
              );
              if (!alreadyInList) {
                controller.selectedItemList.add(item);
                controller.editAmountControllers.add(
                  TextEditingController(text: item.price.toString()),
                );
                controller.editDescriptionControllers.add(
                  TextEditingController(text: item.description ?? ""),
                );
                controller.editQuantityControllers.add(
                  TextEditingController(text: '1'),
                );
                controller.createTotalForEdit();
                controller.updateRequestedDepositAmount();
              } else {
                final itemIndex = controller.selectedItemList.indexWhere(
                  (selected) => selected.id == item.id,
                );
                if (itemIndex != -1) {
                  controller.selectedItemList.removeAt(itemIndex);
                  controller.editAmountControllers.removeAt(itemIndex);
                  controller.editDescriptionControllers.removeAt(itemIndex);
                  controller.editQuantityControllers.removeAt(itemIndex);
                  controller.createTotalForEdit();
                  controller.updateRequestedDepositAmount();
                }
              }
            }

            final onToggle = isCustom
                ? () => _toggleCustomItem(item)
                : (isFromCreateInvoice ? toggleForCreate : toggleForEdit);
            return _buildItemCard(
              theme,
              item: item,
              isSelected: visuallySelected,
              isCustom: isCustom,
              onToggle: onToggle,
            );
          },
        ),
      );
    });
  }

  Widget _buildItemCard(
    ThemeData theme, {
    required ItemListModel item,
    required bool isSelected,
    bool isCustom = false,
    required VoidCallback onToggle,
  }) {
    final taxable = item.isTaxable == true;
    final description = item.description ?? "";
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? LightThemeColors.primaryColor.withValues(alpha: 0.35)
              : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: LightThemeColors.shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                  activeColor: LightThemeColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 4.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name ?? "",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: LightThemeColors.appBlackColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.sp),
                          if (isCustom) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.sp,
                                vertical: 3.sp,
                              ),
                              decoration: BoxDecoration(
                                color: LightThemeColors.successLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 11.sp,
                                    color: LightThemeColors.successColor,
                                  ),
                                  SizedBox(width: 2.sp),
                                  Text(
                                    "Custom",
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: LightThemeColors.successColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6.sp),
                          ],
                          _taxBadge(taxable),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        SizedBox(height: 3.sp),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: LightThemeColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 10.sp),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.sp,
                          vertical: 7.sp,
                        ),
                        decoration: BoxDecoration(
                          color: LightThemeColors.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (isCustom)
                              Text(
                                "Custom line item",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: LightThemeColors.textSecondary,
                                ),
                              )
                            else ...[
                              Text(
                                "On Hand: ",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: LightThemeColors.textSecondary,
                                ),
                              ),
                              Text(
                                "${item.quantityOnHand ?? 0}",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: LightThemeColors.appBlackColor,
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              "\$${(item.price ?? 0.00).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: LightThemeColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _taxBadge(bool taxable) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 3.sp),
      decoration: BoxDecoration(
        color: taxable
            ? LightThemeColors.successLight
            : LightThemeColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        taxable ? "Taxable" : "Non-Taxable",
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: taxable
              ? LightThemeColors.successColor
              : LightThemeColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72.sp,
            height: 72.sp,
            decoration: BoxDecoration(
              color: LightThemeColors.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 32.sp,
              color: LightThemeColors.textTertiary,
            ),
          ),
          SizedBox(height: 12.sp),
          Text(
            "No billable items found",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: LightThemeColors.appBlackColor,
            ),
          ),
          SizedBox(height: 4.sp),
          Text(
            "Try a different search term or switch the filter above.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: LightThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: LightThemeColors.appBarBorderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: LightThemeColors.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
        child: PrimaryButton(
          title: "Done",
          onPressed: () {
            controller.resetTaxIfNonTaxableItems();
            Get.back();
          },
          inactive: false,
        ),
      ),
    );
  }
}
