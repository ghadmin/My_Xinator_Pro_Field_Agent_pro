import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/constants.dart';
import '../../../components/drawer/custom_drawer.dart';
import '../../../components/global-widgets/asset_image_box.dart';
import '../../../components/global-widgets/empty_widget.dart';
import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/splash_container.dart';
import '../../../routes/app_pages.dart';
import '../controllers/customer_controller.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      drawer: CustomDrawer(indexClicked: 5),
      appBar: AppBar(
        // title: const Text('Customers'),
        actions: [
          // InkWell(
          //   onTap: () {},
          //   child: Padding(
          //     padding: EdgeInsets.only(right: 18.sp),
          //     child: SizedBox(
          //       width: 35.sp, // Specify the width and height you want
          //       height: 35.sp,
          //       child: CircleAvatar(
          //         child: ClipOval(
          //           child: AssetImageBox(
          //             height: 35.sp,
          //             width: 35.sp,
          //             assetImage: AppImages.kDemoUser,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: SafeArea(
          child: Obx(
        () => Padding(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GeneralTextField(
                          hint: "Search here...",
                          theme: theme,
                          onChanged: (_) => controller.sortAppointmentsText(),
                          textEditingController: controller.sortTextController),
                    ),
                    SizedBox(height: 20.sp),
                    Expanded(
                      child: RefreshIndicator(
                        color: theme.primaryColor,
                        onRefresh: () async => await controller.getCustomers(),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: BouncingScrollPhysics(),
                          itemCount: controller.sortedCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = controller.sortedCustomers[index];
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
                                controller.mobileNumber = customer.mobile ?? "";
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
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "${customer.firstName ?? ""} ${customer.lastName ?? ""}",
                                                style: theme
                                                    .textTheme.headlineSmall
                                                    ?.copyWith(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Row(children: [
                                              Icon(
                                                Icons.mail_outline,
                                                size: 15.sp,
                                                color: Colors.grey,
                                              ),
                                              customer.email == ""
                                                  ? Text(" N/A",
                                                      style: theme
                                                          .textTheme.bodyMedium!
                                                          .copyWith(
                                                              color:
                                                                  Colors.grey))
                                                  : Flexible(
                                                      child: Text(
                                                          " ${customer.email ?? " N/A"}",
                                                          style: theme.textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  color: Colors
                                                                      .grey)),
                                                    )
                                            ]),
                                            Row(children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 15.sp,
                                                color: Colors.grey,
                                              ),
                                              customer.address1 == ""
                                                  ? Text(" N/A",
                                                      style: theme
                                                          .textTheme.bodyMedium!
                                                          .copyWith(
                                                              color:
                                                                  Colors.grey))
                                                  : Flexible(
                                                      child: Text(
                                                          " ${customer.address1 ?? " N/A"}",
                                                          style: theme.textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  color: Colors
                                                                      .grey)),
                                                    )
                                            ]),
                                            Row(children: [
                                              Icon(
                                                Icons.phone_outlined,
                                                size: 15.sp,
                                                color: Colors.grey,
                                              ),
                                              customer.phone == ""
                                                  ? Text(" N/A",
                                                      style: theme
                                                          .textTheme.bodyMedium!
                                                          .copyWith(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              color:
                                                                  Colors.grey))
                                                  : Text(
                                                      " ${customer.phone ?? " N/A"}",
                                                      style: theme
                                                          .textTheme.bodyMedium!
                                                          .copyWith(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              color:
                                                                  Colors.grey))
                                            ]),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
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
                                            Container(
                                              alignment: Alignment.center,
                                              height: 30.h,
                                              width: 85.h,
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Text(
                                                'Scheduled',
                                                style: theme
                                                    .textTheme.bodyLarge!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                            ),
                                            Text(
                                              "Click to see details",
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.primaryColor,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
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
        ),
      )),
    );
  }
}
