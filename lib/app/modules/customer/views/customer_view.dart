import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart'
    show TextWidget;
import 'package:xinator_fsm_pro/app/modules/appointment/controllers/appointment_controller.dart';
import '../../../components/drawer/custom_drawer.dart';
import '../../../components/global-widgets/empty_widget.dart';
import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/splash_container.dart';
import '../../../routes/app_pages.dart';
import '../controllers/customer_controller.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});
  @override
  Widget build(BuildContext context) {
    final appointmentC = Get.find<AppointmentController>();
    var theme = Theme.of(context);
    return Scaffold(
      drawer: CustomDrawer(indexClicked: 4),
      appBar: AppBar(
        toolbarHeight:
            Platform.isAndroid ? kToolbarHeight : kToolbarHeight + 60,
        // title: const  TextWidget(text:'Customers'),
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
                    TextWidget(
                      text: "Customers List",
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
                            final selectedApp = appointmentC.appointments.where(
                                (p0) =>
                                    p0.customer!.customerID ==
                                    customer.customerID);
                            return SplashContainer(
                              radius: 8,
                              color: Colors.white,
                              onPressed: () {
                                // controller.businessName =
                                //     "${customer.firstName ?? ""} ${customer.lastName ?? ""}";
                                // controller.title = customer.jobTitle ?? "";
                                // controller.address = "${customer.address1}, "
                                //     "${customer.city}, "
                                //     "${customer.state}, ";
                                // controller.phoneNumber = customer.phone ?? "";
                                // controller.mobileNumber = customer.mobile ?? "";
                                // controller.email = customer.email ?? "";
                                // controller.selectedCustomer(customer);
                                // Get.toNamed(Routes.CUSTOMER_DETAILS);
                                appointmentC.selectedAppointment.value = null;

                                final appointment = selectedApp.isEmpty
                                    ? null
                                    : selectedApp.first;
                                appointmentC.selectSingleAppointments(
                                    appointment,
                                    appointmentC.appointments
                                        .indexOf(appointment),
                                    false);
                                Get.toNamed(Routes.APPOINTMENT_DETAILS);
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
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  TextWidget(
                                                    text:
                                                        "${customer.firstName ?? ""} ${customer.lastName ?? ""}",
                                                    style: theme
                                                        .textTheme.headlineSmall
                                                        ?.copyWith(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (selectedApp.isNotEmpty)
                                                    Icon(
                                                      Icons.event,
                                                      size: 35.r,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              246,
                                                              120,
                                                              82),
                                                    )
                                                ],
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
                                                  ? TextWidget(
                                                      text: " N/A",
                                                      style: theme
                                                          .textTheme.bodyMedium!
                                                          .copyWith(
                                                              color:
                                                                  Colors.grey))
                                                  : Flexible(
                                                      child: TextWidget(
                                                          text:
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
                                                  ? TextWidget(
                                                      text: " N/A",
                                                      style: theme
                                                          .textTheme.bodyMedium!
                                                          .copyWith(
                                                              color:
                                                                  Colors.grey))
                                                  : Flexible(
                                                      child: TextWidget(
                                                          text:
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
                                                  ? TextWidget(
                                                      text: " N/A",
                                                      style: theme
                                                          .textTheme.bodyMedium!
                                                          .copyWith(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              color:
                                                                  Colors.grey))
                                                  : TextWidget(
                                                      text:
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
                                      SizedBox.shrink(),
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: Column(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     crossAxisAlignment:
                                      //         CrossAxisAlignment.end,
                                      //     children: [
                                      //       // Container(
                                      //       //   padding: EdgeInsets.symmetric(
                                      //       //       horizontal: 10.sp, vertical: 5.sp),
                                      //       //   decoration: BoxDecoration(
                                      //       //     borderRadius: BorderRadius.circular(15.r),
                                      //       //     color: customer.status?.statusName ==
                                      //       //             "Installation in Progress"
                                      //       //         ? Color(0xffE98862)
                                      //       //         : customer.status?.statusName ==
                                      //       //                 "Scheduled"
                                      //       //             ? Color(0xff2E888B)
                                      //       //             : customer.status?.statusName ==
                                      //       //                     "Cancelled"
                                      //       //                 ? Colors.red
                                      //       //                 : Color(0xff0CBC8B),
                                      //       //   ),
                                      //       //   child:  TextWidget(text:
                                      //       //     customer.status?.statusName ==
                                      //       //             "Installation in Progress"
                                      //       //         ? "In Progress"
                                      //       //         : customer.status?.statusName ?? "",
                                      //       //     style:
                                      //       //         theme.textTheme.bodyMedium?.copyWith(
                                      //       //       color: Colors.white,
                                      //       //       fontWeight: FontWeight.w500,
                                      //       //     ),
                                      //       //   ),
                                      //       // ),
                                      //       // Container(
                                      //       //   alignment: Alignment.center,
                                      //       //   // height: 30.h,
                                      //       //   // width: 85.h,
                                      //       //   padding: EdgeInsets.all(5),
                                      //       //   decoration: BoxDecoration(
                                      //       //       color: Colors.green,
                                      //       //       borderRadius:
                                      //       //           BorderRadius.circular(
                                      //       //               20)),
                                      //       //   child: TextWidget(
                                      //       //     text: 'Scheduled',
                                      //       //     style: theme
                                      //       //         .textTheme.bodyLarge!
                                      //       //         .copyWith(
                                      //       //             color: Colors.white),
                                      //       //   ),
                                      //       // ),
                                      //       // TextWidget(
                                      //       //   text: "Click to see details",
                                      //       //   style: theme.textTheme.bodySmall
                                      //       //       ?.copyWith(
                                      //       //     color: theme.primaryColor,
                                      //       //     fontSize: 10.sp,
                                      //       //     fontWeight: FontWeight.bold,
                                      //       //   ),
                                      //       // ),
                                      //     ],
                                      //   ),
                                      // )
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
