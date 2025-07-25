import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
        title: Text(
          "Appointments",
          textScaler: TextScaler.linear(1.0),
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
                        Text(
                          "Appointment List",
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
                              Text(
                                textAlign: TextAlign.center,
                                controller.selectedDateString.value,
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
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 180.sp,
                                                child: Text(
                                                  "${appointment.customer?.firstName ?? ""} ${appointment.customer?.lastName ?? ""}",
                                                  style: theme
                                                      .textTheme.headlineSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(height: 2.sp),
                                              Text(appointment.serviceType
                                                      ?.serviceName ??
                                                  ""),
                                              SizedBox(
                                                width: 180.sp,
                                                child: Text(
                                                    "${appointment.customer?.address1}, "
                                                    "${appointment.customer?.city}, "
                                                    "${appointment.customer?.state}, "),
                                              ),
                                              SizedBox(height: 4.sp),
                                              Text(dateTimeConverter(
                                                  inputFormat:
                                                      "yyyy/MM/dd hh:mm a",
                                                  inputTime: appointment
                                                      .startDateTime
                                                      .toString(),
                                                  outputFormat:
                                                      "MM/dd/yyyy hh:mm a")),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.sp,
                                                    vertical: 5.sp),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.r),
                                                  color: appointment.status
                                                              ?.statusName ==
                                                          "Installation In Progress"
                                                      ? Color(0xffE98862)
                                                      : appointment.status
                                                                  ?.statusName ==
                                                              "Installation in Progress"
                                                          ? Color(0xffE98862)
                                                          : appointment.status
                                                                      ?.statusName ==
                                                                  "Scheduled"
                                                              ? Color(
                                                                  0xff2E888B)
                                                              : appointment
                                                                          .status
                                                                          ?.statusName ==
                                                                      "Cancelled"
                                                                  ? Colors.red
                                                                  : Color(
                                                                      0xff0CBC8B),
                                                ),
                                                child: Text(
                                                  appointment.status
                                                              ?.statusName ==
                                                          "Installation In Progress"
                                                      ? "In Progress"
                                                      : appointment.status
                                                                  ?.statusName ==
                                                              "Installation in Progress"
                                                          ? "In Progress"
                                                          : appointment.status
                                                                  ?.statusName ??
                                                              "",
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
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
            ),
          )),
    );
  }
}
