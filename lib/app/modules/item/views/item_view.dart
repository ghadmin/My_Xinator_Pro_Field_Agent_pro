import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/constants.dart';
import '../../../components/drawer/custom_drawer.dart';
import '../../../components/global-widgets/asset_image_box.dart';
import '../../../components/global-widgets/empty_widget.dart';
import '../../../components/global-widgets/general_text_field.dart'
    show GeneralTextField;
import '../../../components/global-widgets/text_widget.dart';
import '../controllers/item_controller.dart';
import '../models/item_bundle_model.dart';
import '../models/item_list_model.dart';

class ItemView extends GetView<ItemController> {
  const ItemView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: Platform.isAndroid
            ? kToolbarHeight
            : kToolbarHeight + 10.sp,
        title: const TextWidget(text: 'Items'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 18.sp),
            child: SizedBox(
              width: 35.sp, // Specify the width and height you want
              height: 35.sp,
              child: CircleAvatar(
                child: ClipOval(
                  child: AssetImageBox(
                    height: 35.sp,
                    width: 35.sp,
                    assetImage: AppImages.kDemoUser,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(indexClicked: 1),
      body: Obx(() {
        // Single display list for every search-by mode; the controller keeps
        // it filtered (see ItemController.sortItems).
        final List<ItemListModel> items = controller.sortedItems;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
          child: controller.isItemsEmpty.value
              ? EmptyWidget(
                  onPressed: () async {
                    await controller.getItems(true);
                  },
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TextWidget(
                            //   text: "Create  items now",
                            //   style: theme.textTheme.bodyLarge?.copyWith(
                            //     color: LightThemeColors.hintTextColor,
                            //     fontSize: 16.sp,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.sp),

                    // Search By dropdown (Name / Group / Bundle)
                    SizedBox(
                      height: 40.sp,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.sp),
                        decoration: BoxDecoration(
                          color: LightThemeColors.fillColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: LightThemeColors.buttonBorderColor,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SearchByType>(
                            value: controller.searchByType.value,
                            isExpanded: true,
                            isDense: true,
                            borderRadius: BorderRadius.circular(10),
                            icon: Icon(
                              Icons.expand_more,
                              color: LightThemeColors.bodyTextSecondaryColor,
                            ),
                            items: controller.searchOptions.map((
                              SearchByType value,
                            ) {
                              return DropdownMenuItem<SearchByType>(
                                value: value,
                                child: TextWidget(text: value.displayName),
                              );
                            }).toList(),
                            onChanged: (newValue) async {
                              controller.searchByType.value = newValue!;
                              controller.selectedItemGroup.value = null;
                              controller.selectedItemBundle.value = null;
                              controller.resetPagination();
                              controller.sortItems();
                              if (newValue == SearchByType.group) {
                                if (controller.itemGroups.isEmpty) {
                                  await controller.getItemGroups();
                                }
                                await controller.autoSelectFirstGroup();
                              }
                              if (newValue == SearchByType.bundle) {
                                if (controller.itemBundles.isEmpty) {
                                  await controller.getBundles(false);
                                }
                                await controller.autoSelectFirstBundle();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.sp),

                    // Group / Bundle selector (shown per search-by type)
                    if (controller.searchByType.value == SearchByType.group)
                      SizedBox(
                        height: 40.sp,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(controller.selectedItemGroup.value),
                          isDense: true,
                          decoration: _dropdownDecoration(),
                          initialValue:
                              controller.selectedItemGroup.value?.groupName,
                          items: controller.itemGroups.map((group) {
                            return DropdownMenuItem(
                              value: group.groupName,
                              child: TextWidget(text: group.groupName ?? ""),
                            );
                          }).toList(),
                          onChanged: (val) {
                            final selectedGroup = controller.itemGroups
                                .firstWhere((group) => group.groupName == val);
                            controller.selectedItemGroup.value = selectedGroup;
                            if (selectedGroup.id != null) {
                              controller.getItemGroupById(isShowLoading: false);
                            }
                          },
                        ),
                      ),
                    if (controller.searchByType.value == SearchByType.bundle)
                      SizedBox(
                        height: 40.sp,
                        child: DropdownButtonFormField<ItemBundleModel>(
                          key: ValueKey(controller.selectedItemBundle.value),
                          isDense: true,
                          decoration: _dropdownDecoration(),
                          initialValue: controller.selectedItemBundle.value,
                          items: controller.itemBundles.map((bundle) {
                            return DropdownMenuItem(
                              value: bundle,
                              child: TextWidget(text: bundle.bundleName ?? ""),
                            );
                          }).toList(),
                          onChanged: (val) {
                            controller.selectedItemBundle.value = val;
                            if (val != null && val.id != null) {
                              controller.getItemsByBundleId(
                                isShowLoading: false,
                              );
                            }
                            controller.sortItems();
                          },
                        ),
                      ),
                    if (controller.searchByType.value != SearchByType.name)
                      SizedBox(height: 10.sp),

                    // Search Field
                    SizedBox(
                      height: 40.sp,
                      child: GeneralTextField(
                        isEnabled: true,
                        hint: "Search item",
                        suffixIcon: Icon(
                          Icons.search,
                          color: LightThemeColors.bodyTextSecondaryColor,
                        ),
                        theme: theme,
                        textInputAction: TextInputAction.search,
                        onChanged: (_) => controller.sortItems(),
                        textEditingController: controller.sortTextController,
                      ),
                    ),
                    SizedBox(height: 15.sp),

                    Expanded(
                      child: RefreshIndicator(
                        color: theme.primaryColor,
                        onRefresh: () async {
                          if (controller.searchByType.value ==
                              SearchByType.group) {
                            await controller.getItemGroupById();
                          } else if (controller.searchByType.value ==
                              SearchByType.bundle) {
                            await controller.getItemsByBundleId();
                          } else {
                            await controller.getItems(true);
                          }
                        },
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo.metrics.axis != Axis.vertical) {
                              return false;
                            }
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                              if (controller.searchByType.value ==
                                  SearchByType.group) {
                                controller.loadMoreGroupItems();
                              } else if (controller.searchByType.value ==
                                  SearchByType.bundle) {
                                controller.loadMoreBundleItems();
                              }
                            }
                            return false;
                          },
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Padding(
                                padding: EdgeInsets.all(15.sp),
                                child: IntrinsicHeight(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// Left side → Expanded
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextWidget(
                                              text: item.name ?? "",
                                              style: theme
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2.sp),

                                            /// description
                                            // if ((item.description ?? "")
                                            //     .isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 2.sp,
                                              ),
                                              child: TextWidget(
                                                text:
                                                    item.description != null &&
                                                        item.description != ''
                                                    ? item.description!
                                                    : "N/A",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            /// barcode
                                            if ((item.barcode ?? "").isNotEmpty)
                                              TextWidget(
                                                text: item.barcode ?? "",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),

                                      /// Right side → shrink to fit
                                      IntrinsicWidth(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            TextWidget(
                                              text:
                                                  "\$${item.price?.toStringAsFixed(2) ?? ""}",
                                              style: theme
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => Container(
                              height: 1,
                              margin: EdgeInsets.symmetric(vertical: 7.sp),
                              color: LightThemeColors.dividerColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      }),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: LightThemeColors.fillColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: LightThemeColors.buttonBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: LightThemeColors.buttonBorderColor),
      ),
    );
  }
}
