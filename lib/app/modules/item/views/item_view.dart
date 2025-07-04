import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/constants.dart';
import '../../../components/drawer/custom_drawer.dart';
import '../../../components/global-widgets/asset_image_box.dart';
import '../../../components/global-widgets/empty_widget.dart';
import '../../../components/global-widgets/splash_container.dart';
import '../controllers/item_controller.dart';

class ItemView extends GetView<ItemController> {
  const ItemView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        actions: [
          InkWell(
            onTap: () {
              //  Get.toNamed(Routes.SETTINGS);
            },
            child: Padding(
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
          ),
        ],
      ),
      drawer: CustomDrawer(indexClicked: 1),
      body: Obx(() => Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: controller.isItemsEmpty.value
                ? EmptyWidget(
                    onPressed: () async {
                      await controller.getItems();
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
                              Text(
                                "Item List",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Create  items now",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: LightThemeColors.hintTextColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
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
                          //           Text(
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
                      Expanded(
                        child: RefreshIndicator(
                          color: theme.primaryColor,
                          onRefresh: () async => await controller.getItems(),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            physics: BouncingScrollPhysics(),
                            itemCount: controller.items.length,
                            itemBuilder: (context, index) {
                              final item = controller.items[index];
                              return SplashContainer(
                                radius: 8,
                                color: Colors.white,
                                onPressed: () {
                                  // controller.businessName =
                                  // "${customer.firstName ?? ""} ${customer.lastName ?? ""}";
                                  // controller.title = customer.jobTitle ?? "";
                                  // controller.address = "${customer.address1}, "
                                  //     "${customer.city}, "
                                  //     "${customer.state}, ";
                                  // controller.phoneNumber = customer.phone ?? "";
                                  // controller.mobileNumber =
                                  //     customer.mobile ?? "";
                                  // controller.email = customer.email ?? "";
                                  //
                                  // Get.toNamed(Routes.CUSTOMER_DETAILS);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(15.sp),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 200.sp,
                                              child: Text(
                                                item.name ?? "",
                                                style: theme
                                                    .textTheme.headlineSmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(height: 2.sp),
                                            item.description == ""
                                                ? SizedBox.shrink()
                                                : SizedBox(
                                                    width: 200.sp,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 2.sp),
                                                      child: Text(
                                                          item.description ??
                                                              ""),
                                                    ),
                                                  ),
                                            item.barcode == ""
                                                ? SizedBox.shrink()
                                                : Text(item.barcode ?? ""),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "\$${item.price ?? ""}",
                                              style: theme
                                                  .textTheme.headlineSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )
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
          )),
    );
  }
}
