import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../components/global-widgets/splash_container.dart';
import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("General Settings"),
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
                //     leading: Icon(
                //       IconlyLight.profile,
                //       color: LightThemeColors.appBlackColor,
                //     ),
                //     title: Text(
                //       "Account",
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
                //     leading: Icon(
                //       IconlyLight.notification,
                //       color: LightThemeColors.appBlackColor,
                //     ),
                //     title: Text(
                //       "Notification",
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
                //     leading: Icon(
                //       Remix.history_line,
                //       color: LightThemeColors.appBlackColor,
                //     ),
                //     title: Text(
                //       "Login History",
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
                //     leading: Icon(
                //       Remix.lock_line,
                //       color: LightThemeColors.appBlackColor,
                //     ),
                //     title: Text(
                //       "Security",
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
                  onPressed: () {
                    Get.toNamed(Routes.APPOINTMENT_SETTINGS);
                  },
                  child: ListTile(
                    leading: Icon(
                      Remix.file_settings_line,
                      color: LightThemeColors.appBlackColor,
                    ),
                    title: Text(
                      "Appointment Settings",
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
                //     leading: Icon(
                //       Remix.list_settings_line,
                //       color: LightThemeColors.appBlackColor,
                //     ),
                //     title: Text(
                //       "Resource Settings",
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
                //     leading: Icon(
                //       Remix.questionnaire_line,
                //       color: LightThemeColors.appBlackColor,
                //     ),
                //     title: Text(
                //       "Get Help",
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
