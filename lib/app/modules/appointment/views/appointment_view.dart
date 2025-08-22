import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart';
import 'package:xinator_fsm_pro/app/service/payment_services.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/date_converter.dart';
import '../../../components/drawer/custom_drawer.dart';
import '../../../components/global-widgets/asset_image_box.dart';
import '../../../components/global-widgets/empty_widget.dart';
import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/splash_container.dart';
import '../../../routes/app_pages.dart';
import '../controllers/appointment_controller.dart';

class AppointmentView extends GetView<AppointmentController> {
  const AppointmentView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            Platform.isAndroid ? kToolbarHeight : kToolbarHeight + 60,
        title: TextWidget(
          text: "Appointments",
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.only(right: 18.sp),
              child: SizedBox(
                width: 35.sp, // Specify the width and height you want
                height: 35.sp,
                child: CircleAvatar(
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
      drawer: CustomDrawer(indexClicked: 0),
      body: Obx(() => SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
              child: controller.isAppointmentEmpty.value
                  ? EmptyWidget(
                      onPressed: () async {
                        await controller.getAppointments();
                      },
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: "Appointment List",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextWidget(
                          text: "Schedule your appointment now",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: LightThemeColors.hintTextColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 20.sp),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GeneralTextField(
                                    hint: "Search here...",
                                    theme: theme,
                                    onChanged: (_) =>
                                        controller.sortAppointmentsText(),
                                    textEditingController:
                                        controller.sortTextController),
                              ),
                              SizedBox(width: 10.w),
                              IconButton(
                                icon: Icon(Icons.calendar_month),
                                onPressed: controller.pickDate,
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                            visible: controller.selectedDateString.value != '',
                            child: SizedBox(height: 5.h)),
                        Visibility(
                          visible: controller.selectedDateString.value != '',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextWidget(
                                text: controller.selectedDateString.value,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: LightThemeColors.hintTextColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              IconButton(
                                  onPressed: () {
                                    controller.clearSort();
                                  },
                                  icon: Icon(
                                    Icons.close,
                                  ))
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Expanded(
                          child: RefreshIndicator(
                              color: theme.primaryColor,
                              onRefresh: () async =>
                                  await controller.getAppointments(),
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: controller.sortedAppointments.length,
                                itemBuilder: (context, index) {
                                  final appointment =
                                      controller.sortedAppointments[index];
                                  return SplashContainer(
                                    radius: 8,
                                    color: Colors.white,
                                    onPressed: () {
                                      controller.selectSingleAppointments(
                                          appointment, index);
                                      Get.toNamed(Routes.APPOINTMENT_DETAILS);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(15.sp),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            /// Left side
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text:
                                                        "${appointment.customer?.firstName ?? ""} ${appointment.customer?.lastName ?? ""}",
                                                    style: theme
                                                        .textTheme.headlineSmall
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 2.sp),
                                                  TextWidget(
                                                    text: appointment
                                                            .serviceType
                                                            ?.serviceName ??
                                                        "",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 2.sp),
                                                  TextWidget(
                                                    text:
                                                        "${appointment.customer?.address1}, ${appointment.customer?.city}, ${appointment.customer?.state}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4.sp),
                                                  TextWidget(
                                                    text: dateTimeConverter(
                                                      inputFormat:
                                                          "yyyy/MM/dd hh:mm a",
                                                      inputTime: appointment
                                                          .startDateTime
                                                          .toString(),
                                                      outputFormat:
                                                          "MM/dd/yyyy hh:mm a",
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),

                                            /// Right side
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10.sp,
                                                    vertical: 5.sp,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.r),
                                                    color: _getStatusColor(
                                                        appointment.status
                                                            ?.statusName),
                                                  ),
                                                  child: TextWidget(
                                                    maxLines: 2,
                                                    text: _getStatusText(
                                                        appointment.status
                                                            ?.statusName),
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                TextWidget(
                                                  text: "Click to see details",
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme.primaryColor,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 15.sp),
                              )

                              /// Helper methods

                              ),
                        ),
                      ],
                    ),
            ),
          )),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "Installation In Progress":
      case "Installation in Progress":
        return const Color(0xffE98862);
      case "Scheduled":
        return const Color(0xff2E888B);
      case "Cancelled":
        return Colors.red;
      default:
        return const Color(0xff0CBC8B);
    }
  }

  String _getStatusText(String? status) {
    if (status == "Installation In Progress" ||
        status == "Installation in Progress") {
      return "In Progress";
    }
    return status ?? "";
  }
}
