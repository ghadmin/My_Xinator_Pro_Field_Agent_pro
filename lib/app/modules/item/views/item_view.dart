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
import '../../../components/global-widgets/splash_container.dart';
import '../../../components/global-widgets/text_widget.dart';
import '../controllers/item_controller.dart';

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
      body: Obx(
        () => Padding(
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
                            //     fontWeight: FontWeight.w400,
                            //   ),
                            // ),
                          ],
                        ),
                        // SplashContainer(
                        //     width: 130.sp,
                        //     color: theme.primaryColor,
                        //     radius: 5,
                        //     onPressed: () {},
                        //     child: Container(
                        //       padding: EdgeInsets.symmetric(
                        //         horizontal: 10.sp,
                        //         vertical: 5.sp,
                        //       ),
                        //       decoration: BoxDecoration(
                        //         border: Border.all(
                        //           color: theme.primaryColor,
                        //         ),
                        //         borderRadius: BorderRadius.circular(5.r),
                        //       ),
                        //       child: Row(
                        //         children: [
                        //           Icon(
                        //             Icons.add_circle_outline,
                        //             color: Colors.white,
                        //             size: 18.sp,
                        //           ),
                        //           SizedBox(width: 8.sp),
                        //            TextWidget(text:
                        //             "Create New",
                        //             style:
                        //                 theme.textTheme.bodyMedium?.copyWith(
                        //               color: Colors.white,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     )),
                      ],
                    ),
                    SizedBox(height: 20.sp),

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
                        onRefresh: () async => await controller.getItems(true),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.sortedItems.length,
                          itemBuilder: (context, index) {
                            final item = controller.sortedItems[index];
                            return SplashContainer(
                              radius: 8,
                              color: Colors.white,
                              onPressed: () {
                                // Handle navigation / details
                              },
                              child: Padding(
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
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 15.sp),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
