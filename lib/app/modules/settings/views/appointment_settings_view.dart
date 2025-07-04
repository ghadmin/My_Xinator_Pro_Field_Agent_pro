import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../components/global-widgets/splash_container.dart';
import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';

class AppointmentSettingsView extends GetView<SettingsController> {
  const AppointmentSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment Settings"),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: 15.sp,
              children: [
                // SplashContainer(
                //   radius: 8,
                //   color: Colors.white,
                //   onPressed: () {},
                //   child: ListTile(
                //     title: Text(
                //       "Blocks & Availability",
                //       style: theme.textTheme.bodyLarge?.copyWith(
                //         fontSize: 18.sp,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //     trailing: Icon(
                //       Icons.chevron_right,
                //       size: 30.sp,
                //       color: LightThemeColors.appBlackColor,
                //     ),
                //   ),
                // ),
                // SplashContainer(
                //   radius: 8,
                //   color: Colors.white,
                //   onPressed: () {},
                //   child: ListTile(
                //     title: Text(
                //       "Appointment Types",
                //       style: theme.textTheme.bodyLarge?.copyWith(
                //         fontSize: 18.sp,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //     trailing: Icon(
                //       Icons.chevron_right,
                //       size: 30.sp,
                //       color: LightThemeColors.appBlackColor,
                //     ),
                //   ),
                // ),
                SplashContainer(
                  radius: 8,
                  color: Colors.white,
                  onPressed: () async {
                    await controller.getAppointmentStatus();
                    Get.toNamed(Routes.APPOINTMENT_STATUS);
                  },
                  child: ListTile(
                    title: Text(
                      "Appointment Status",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 30.sp,
                      color: LightThemeColors.appBlackColor,
                    ),
                  ),
                ),
                // SplashContainer(
                //   radius: 8,
                //   color: Colors.white,
                //   onPressed: () {},
                //   child: ListTile(
                //     title: Text(
                //       "Appointment Resources",
                //       style: theme.textTheme.bodyLarge?.copyWith(
                //         fontSize: 18.sp,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //     trailing: Icon(
                //       Icons.chevron_right,
                //       size: 30.sp,
                //       color: LightThemeColors.appBlackColor,
                //     ),
                //   ),
                // ),
                SplashContainer(
                  radius: 8,
                  color: Colors.white,
                  onPressed: () async {
                    await controller.getTicketStatus();
                    Get.toNamed(Routes.TICKET_STATUS);
                  },
                  child: ListTile(
                    title: Text(
                      "Ticket Status",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 30.sp,
                      color: LightThemeColors.appBlackColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
