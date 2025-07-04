import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/constants.dart';
import '../../../components/global-widgets/asset_image_box.dart';
import '../../../components/global-widgets/empty_widget.dart';
import '../../../components/global-widgets/splash_container.dart';
import '../../../routes/app_pages.dart';
import '../controllers/customer_controller.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          InkWell(
            onTap: () {},
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
      body: Obx(() => Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: controller.isCustomerEmpty.value
                ? EmptyWidget(
                    onPressed: () async {
                      await controller.getCustomers();
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customers List",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Schedule your appointment now",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: LightThemeColors.hintTextColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 20.sp),
                      // SplashContainer(
                      //     width: 80.sp,
                      //     color: Colors.white,
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
                      //             Iconsax.filter,
                      //             color: theme.primaryColor,
                      //             size: 18.sp,
                      //           ),
                      //           SizedBox(width: 8.sp),
                      //           Text(
                      //             "Filter",
                      //             style: theme.textTheme.bodyMedium?.copyWith(
                      //               color: theme.primaryColor,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     )),
                      // SizedBox(height: 20.sp),
                      Expanded(
                        child: RefreshIndicator(
                          color: theme.primaryColor,
                          onRefresh: () async =>
                              await controller.getCustomers(),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            physics: BouncingScrollPhysics(),
                            itemCount: controller.customers.length,
                            itemBuilder: (context, index) {
                              final customer = controller.customers[index];
                              return SplashContainer(
                                radius: 8,
                                color: Colors.white,
                                onPressed: () {
                                  controller.businessName =
                                      "${customer.firstName ?? ""} ${customer.lastName ?? ""}";
                                  controller.title = customer.jobTitle ?? "";
                                  controller.address = "${customer.address1}, "
                                      "${customer.city}, "
                                      "${customer.state}, ";
                                  controller.phoneNumber = customer.phone ?? "";
                                  controller.mobileNumber =
                                      customer.mobile ?? "";
                                  controller.email = customer.email ?? "";

                                  Get.toNamed(Routes.CUSTOMER_DETAILS);
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
                                              width: 180.sp,
                                              child: Text(
                                                "${customer.firstName ?? ""} ${customer.lastName ?? ""}",
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
                                            customer.jobTitle == ""
                                                ? SizedBox.shrink()
                                                : Text(customer.jobTitle ?? ""),
                                            SizedBox(
                                              width: 180.sp,
                                              child:
                                                  Text("${customer.address1}, "
                                                      "${customer.city}, "
                                                      "${customer.state}, "),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            // Container(
                                            //   padding: EdgeInsets.symmetric(
                                            //       horizontal: 10.sp, vertical: 5.sp),
                                            //   decoration: BoxDecoration(
                                            //     borderRadius: BorderRadius.circular(15.r),
                                            //     color: customer.status?.statusName ==
                                            //             "Installation in Progress"
                                            //         ? Color(0xffE98862)
                                            //         : customer.status?.statusName ==
                                            //                 "Scheduled"
                                            //             ? Color(0xff2E888B)
                                            //             : customer.status?.statusName ==
                                            //                     "Cancelled"
                                            //                 ? Colors.red
                                            //                 : Color(0xff0CBC8B),
                                            //   ),
                                            //   child: Text(
                                            //     customer.status?.statusName ==
                                            //             "Installation in Progress"
                                            //         ? "In Progress"
                                            //         : customer.status?.statusName ?? "",
                                            //     style:
                                            //         theme.textTheme.bodyMedium?.copyWith(
                                            //       color: Colors.white,
                                            //       fontWeight: FontWeight.w500,
                                            //     ),
                                            //   ),
                                            // ),
                                            Text(
                                              "Click to see details",
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.primaryColor,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
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
