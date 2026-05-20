import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/appointment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/views/widgets/warm_organic_components.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';

class CustomerLocationScreen extends GetView<AppointmentController> {
  const CustomerLocationScreen({super.key});

  Future<void> openMapWithRoute(String address) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openGoogleMaps(String address) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmOrganicBlueTheme.warmGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WarmOrganicBlueTheme.warmGray,
        title: Text(
          'Customer Location',
          style: WarmOrganicBlueTheme.headingMedium,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            /// ==============================
            /// BASIC INFORMATION CARD
            /// ==============================
            OrganicCard(
              shadow: WarmOrganicBlueTheme.softShadow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          gradient: WarmOrganicBlueTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            WarmOrganicBlueTheme.radiusSm,
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 22.sp,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Text(
                          'Basic Information',
                          style: WarmOrganicBlueTheme.headingSmall,
                        ),
                      ),
                    ],
                  ),

                  /// Expanded Content
                  AnimatedCrossFade(
                    firstChild: const SizedBox(),
                    secondChild: Column(
                      children: [
                        SizedBox(height: 16.h),
                        const OrganicDivider(),

                        SizedBox(height: 8.h),

                        _buildInfoRow(
                          title: 'Customer Name',
                          value:
                              '${controller.selectedSite.value?.firstName ?? ''} ${controller.selectedSite.value?.lastName ?? ''}'
                                  .trim(),
                        ),

                        if (controller.selectedSite.value?.siteName != null &&
                            controller.selectedSite.value!.siteName!.isNotEmpty)
                          _buildInfoRow(
                            title: 'Site Name',
                            value: controller.selectedSite.value!.siteName!,
                          ),

                        if (controller.selectedSite.value?.address != null &&
                            controller.selectedSite.value!.address!.isNotEmpty)
                          _buildInfoRow(
                            title: 'Address',
                            value: controller.selectedSite.value!.address!,
                          ),

                        if (controller.selectedSite.value?.phoneNumber !=
                                null &&
                            controller
                                .selectedSite
                                .value!
                                .phoneNumber!
                                .isNotEmpty)
                          _buildInfoRow(
                            title: 'Phone',
                            value: controller.selectedSite.value!.phoneNumber!,
                          ),

                        if (controller.selectedSite.value?.email != null &&
                            controller.selectedSite.value!.email!.isNotEmpty)
                          _buildInfoRow(
                            title: 'Email',
                            value: controller.selectedSite.value!.email!,
                          ),

                        _buildInfoRow(
                          title: 'Created On',
                          value:
                              controller
                                  .selectedAppointment
                                  .value
                                  ?.customer
                                  ?.createdDateTime ??
                              "N/A",
                        ),
                      ],
                    ),
                    crossFadeState: CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            /// ==============================
            /// LOCATION CARD
            /// ==============================
            OrganicCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title Row
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                gradient: WarmOrganicBlueTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                  WarmOrganicBlueTheme.radiusSm,
                                ),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                            ),

                            SizedBox(width: 12.w),

                            Expanded(
                              child: Text(
                                'Customer Location',
                                style: WarmOrganicBlueTheme.headingSmall,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        /// Address
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: WarmOrganicBlueTheme.warmSilver,
                            borderRadius: BorderRadius.circular(
                              WarmOrganicBlueTheme.radiusMd,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.place_rounded,
                                size: 20.sp,
                                color: WarmOrganicBlueTheme.accentCyan,
                              ),

                              SizedBox(width: 10.w),

                              Expanded(
                                child: Text(
                                  controller.address,
                                  style: WarmOrganicBlueTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        /// Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OrganicPrimaryButton(
                                text: 'Navigate',
                                icon: Icons.directions_rounded,
                                onPressed: () {
                                  openMapWithRoute(controller.address);
                                },
                              ),
                            ),

                            SizedBox(width: 12.w),

                            Expanded(
                              child: OrganicPrimaryButton(
                                text: 'Open Maps',
                                icon: Icons.map_rounded,
                                onPressed: () {
                                  openGoogleMaps(controller.address);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// MAP
                  // ClipRRect(
                  //   borderRadius: BorderRadius.vertical(
                  //     bottom: Radius.circular(WarmOrganicBlueTheme.radiusLg),
                  //   ),
                  //   child: SizedBox(
                  //     height: 280.h,
                  //     width: double.infinity,
                  //     child: Container(
                  //       color: WarmOrganicBlueTheme.warmSilver,
                  //       child: Center(
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Icon(
                  //               Icons.map_outlined,
                  //               size: 48.sp,
                  //               color: WarmOrganicBlueTheme.coolGray,
                  //             ),
                  //             SizedBox(height: 12.h),
                  //             Text(
                  //               'Map View',
                  //               style: WarmOrganicBlueTheme.bodyMedium,
                  //             ),
                  //             SizedBox(height: 8.h),
                  //             Padding(
                  //               padding: EdgeInsets.symmetric(horizontal: 20.w),
                  //               child: Text(
                  //                 controller.address,
                  //                 style: WarmOrganicBlueTheme.caption,
                  //                 textAlign: TextAlign.center,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String title, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(title, style: WarmOrganicBlueTheme.caption),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: WarmOrganicBlueTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
