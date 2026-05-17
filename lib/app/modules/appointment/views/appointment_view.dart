import 'dart:convert';

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
      appBar: Get.size.width <= 440
          ? AppBar(
              title: Text("Appointments"),
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
            )
          : PreferredSize(
              preferredSize: Size.fromHeight(40.sp),
              child: Padding(
                padding: EdgeInsets.only(top: 15.sp),
                child: AppBar(
                  title: Padding(
                    padding: EdgeInsets.only(top: 8.sp),
                    child: Text(
                      "Appointments",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  actions: [
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.only(right: 18.sp, top: 8.sp),
                        child: SizedBox(
                          width: 20.sp, // Specify the width and height you want
                          height: 20.sp,
                          child: CircleAvatar(
                            child: ClipOval(
                              child: AssetImageBox(
                                height: 20.sp,
                                width: 20.sp,
                                assetImage: AppImages.kDemoUser,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      drawer: CustomDrawer(indexClicked: 0),
      body: Obx(
        () => Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
          child: controller.isAppointmentEmpty.value
              ? EmptyWidget(
                  title: "No Appointments Found",
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
                              isEnabled: true,
                              hint: "Search here...",
                              theme: theme,
                              onChanged: (_) =>
                                  controller.sortAppointmentsText(),
                              textEditingController:
                                  controller.sortTextController,
                            ),
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
                      child: SizedBox(height: 5.h),
                    ),
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
                          SizedBox(width: 10.w),
                          IconButton(
                            onPressed: () {
                              controller.clearSort();
                            },
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: RefreshIndicator(
                        color: theme.primaryColor,
                        onRefresh: () async {
                          await controller.getAppointments();
                        },
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: controller.sortedAppointments
                              .where((e) => e.status!.statusName != "Completed")
                              .length,
                          itemBuilder: (context, index) {
                            final appointment = controller.sortedAppointments
                                .where(
                                  (e) => e.status!.statusName != "Completed",
                                )
                                .toList()[index];
                            return SplashContainer(
                              radius: 8,
                              color: Colors.white,
                              onPressed: () async {
                                controller.isTyping(false);
                                controller.selectedAptIndex.value = index;

                                await controller.selectSingleAppointments(
                                  appointment,
                                  controller.sortedAppointments.indexWhere(
                                    (element) =>
                                        element.apptID == appointment.apptID,
                                  ),
                                  // false,
                                );
                                // controller.getTagList();
                                controller.getCurrentUserId();
                                // var createdDateTime = dateTimeConverter(
                                //     inputFormat: "yyyy/MM/dd hh:mm a",
                                //     inputTime: appointment.createdDateTime
                                //         .toString(),
                                //     outputFormat: "MM/dd/yyyy hh:mm a");
                                // var startTime = dateTimeConverter(
                                //     inputFormat: "yyyy/MM/dd hh:mm a",
                                //     inputTime:
                                //         appointment.startDateTime.toString(),
                                //     outputFormat: "MM/dd/yyyy hh:mm a");
                                // var endTime = dateTimeConverter(
                                //     inputFormat: "yyyy/MM/dd hh:mm a",
                                //     inputTime:
                                //         appointment.endDateTime.toString(),
                                //     outputFormat: "MM/dd/yyyy hh:mm a");
                                // controller.createdBy =
                                //     appointment.createdBy ?? "";
                                // controller.appointmentID =
                                //     "${appointment.apptID ?? ""}";
                                // controller.appointmentUID =
                                //     appointment.appoinmentUId ?? "";
                                // controller.customerID =
                                //     "${appointment.customerID ?? ""}";
                                // controller.promoCode =
                                //     appointment.promoCode ?? "";
                                // controller.serviceTypeID =
                                //     appointment.serviceTypeId ?? "";
                                // controller.resourceID =
                                //     appointment.resourceID!;
                                // controller.timeSlotID =
                                //     appointment.timeSlotId!;
                                // controller.contactName =
                                //     "${appointment.customer?.firstName ?? ""} ${appointment.customer?.lastName ?? ""}";
                                // controller.address =
                                //     "${appointment.customer?.address1}, "
                                //     "${appointment.customer?.city}, "
                                //     "${appointment.customer?.state}, ";
                                // controller.mobileNumber =
                                //     appointment.customer?.mobile ?? "";
                                // controller.phoneNumber =
                                //     appointment.customer?.phone ?? "";
                                // controller.customerTitle =
                                //     "${appointment.customer?.title ?? ""} ${appointment.customer?.title2 ?? ""}";
                                // controller.email =
                                //     appointment.customer?.email ?? "";
                                // controller.invoiceController.toTextController
                                //     .text = appointment.customer?.email ?? "";
                                // controller.invoiceController.customerFirstName
                                //         .value =
                                //     appointment.customer?.firstName ?? "";
                                // controller.requestDate = createdDateTime;
                                // controller.startDate = startTime;
                                // controller.endDate = endTime;
                                // controller.timeSlot =
                                //     appointment.timeSlot ?? "";
                                // controller.serviceType =
                                //     appointment.serviceType?.serviceName ??
                                //         "";

                                // controller.selectedStatusValue.value =
                                //     appointment.status?.statusId ?? 0;
                                // controller.selectedTicketStatusValue.value =
                                //     appointment.ticketStatus?.statusId ?? 0;
                                // controller.resource =
                                //     appointment.resource?.name ?? "";

                                // controller.notes = appointment.note ?? "";
                                // controller.noteTextController.text =
                                //     appointment.note ?? "";
                                // controller.selectedAptIndex.value = index;
                                controller.selectedCustomer(
                                  appointment.customer,
                                );
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
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${appointment.customer?.firstName ?? ""} ${appointment.customer?.lastName ?? ""}",
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
                                            Text(
                                              appointment
                                                      .serviceType
                                                      ?.serviceName ??
                                                  "",
                                            ),
                                            Text(
                                              "${appointment.customer?.address1}, "
                                              "${appointment.customer?.city}, "
                                              "${appointment.customer?.state}, ",
                                            ),
                                            SizedBox(height: 4.sp),
                                            Text(
                                              dateTimeConverter(
                                                inputFormat:
                                                    "yyyy/MM/dd hh:mm a",
                                                inputTime: appointment
                                                    .startDateTime
                                                    .toString(),
                                                outputFormat:
                                                    "MM/dd/yyyy hh:mm a",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120.sp,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                                    BorderRadius.circular(15.r),
                                                color:
                                                    appointment
                                                            .status
                                                            ?.statusName ==
                                                        "Installation In Progress"
                                                    ? Color(0xffE98862)
                                                    : appointment
                                                              .status
                                                              ?.statusName ==
                                                          "Installation in Progress"
                                                    ? Color(0xffE98862)
                                                    : appointment
                                                              .status
                                                              ?.statusName ==
                                                          "Scheduled"
                                                    ? Color(0xff2E888B)
                                                    : appointment
                                                              .status
                                                              ?.statusName ==
                                                          "Cancelled"
                                                    ? Colors.red
                                                    : Color(0xff0CBC8B),
                                              ),
                                              child: Text(
                                                appointment
                                                            .status
                                                            ?.statusName ==
                                                        "Installation In Progress"
                                                    ? "In Progress"
                                                    : appointment
                                                              .status
                                                              ?.statusName ==
                                                          "Installation in Progress"
                                                    ? "In Progress"
                                                    : appointment
                                                              .status
                                                              ?.statusName ??
                                                          "",
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
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
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 20.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // FloatingActionButton(
            //   heroTag: "rag_chat",
            //   backgroundColor: Colors.deepPurple,
            //   onPressed: () {
            //     Get.toNamed(Routes.RAG_CHAT);
            //   },
            //   child: Icon(Icons.psychology, color: Colors.white),
            // ),
            SizedBox(height: 10.sp),
            FloatingActionButton(
              heroTag: "twilio_support",
              backgroundColor: Colors.blue,
              onPressed: () {
                Get.toNamed(Routes.TWILIO_CHAT);
              },
              child: Icon(Icons.support_agent, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
