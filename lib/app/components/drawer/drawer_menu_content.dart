//ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../config/theme/light_theme_colors.dart';
import '../../../utils/constants.dart';
import '../../data/local/my_shared_pref.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/location_tracking/controllers/location_tracking_controller.dart';
import '../../routes/app_pages.dart';
import '../global-widgets/asset_image_box.dart';
import '../global-widgets/text_widget.dart';

/// The drawer menu shared by the phone drawer (CustomDrawer) and the tablet
/// side rail (AdaptiveNavShell). All items, handlers and styles are the ones
/// previously inlined in CustomDrawer — nothing redesigned, only moved.
///
/// [asRail] tweaks the two drawer-only affordances:
///  * the profile-row close button (Get.back) is hidden — there is no route
///    to pop when the menu is a permanent rail;
///  * Log out skips its Get.back() (drawer close) before the confirm dialog.
class DrawerMenuContent extends StatelessWidget {
  DrawerMenuContent({
    super.key,
    required this.indexClicked,
    this.asRail = false,
  });

  final int indexClicked;
  final bool asRail;

  /// The controller owns the tracking state (and persists it), so the switch
  /// also updates by itself when tracking auto-starts after the user returns
  /// from the permission settings page.
  LocationTrackingController get _trackingController =>
      Get.isRegistered<LocationTrackingController>()
          ? Get.find<LocationTrackingController>()
          : Get.put(LocationTrackingController());

  @override
  Widget build(BuildContext context) {
    // var theme = Theme.of(context);
    final authController = Get.put(AuthController());
    final trackingController = _trackingController;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            /// Scrollable part (all menu items including Logout)
            Expanded(
              child: ListView(
                children: [
                  /// profile section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: AssetImageBox(
                              height: 40.sp,
                              width: 40.sp,
                              assetImage: AppImages.kDemoUser,
                            ),
                          ),
                          SizedBox(width: 12.sp),
                          SizedBox(
                            width: 116.sp,
                            child: TextWidget(
                              text: "${MySharedPref.getUserName()}",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (!asRail)
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Image.asset(
                            SideBar.profileGoIcon,
                            color: LightThemeColors.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 35.h),

                  /// drawer items
                  _drawerItem(
                    icon: SideBar.homeIcon,
                    text: 'Home',
                    indexNumber: 0,
                    onTap: () => Get.toNamed(Routes.APPOINTMENT),
                  ),
                  SizedBox(height: 10.h),

                  // _drawerItem(
                  //   icon: SideBar.formIcon,
                  //   text: 'Forms',
                  //   indexNumber: 1,
                  //   onTap: () => Get.toNamed(Routes.FORMS),
                  // ),
                  SizedBox(height: 10.h),

                  _drawerItem(
                    icon: SideBar.itemsIcon,
                    text: 'Items',
                    indexNumber: 1,
                    onTap: () => Get.toNamed(Routes.ITEM),
                  ),
                  SizedBox(height: 10.h),

                  _drawerItem(
                    icon: SideBar.customerServiceIcon,
                    text: 'Customers',
                    indexNumber: 2,
                    onTap: () => Get.toNamed(Routes.CUSTOMER),
                  ),
                  SizedBox(height: 10.h),

                  //no need for now.. when i prompt to open it.. please uncomment it, and remove this comment .
                  // _drawerItem(
                  //   iconWidget: Icon(
                  //     Icons.school_outlined,
                  //     size: 25.h,
                  //     color: LightThemeColors.primaryColor,
                  //   ),
                  //   text: 'Training',
                  //   indexNumber: 4,
                  //   onTap: () => Get.toNamed(Routes.TRAINING),
                  // ),
                  SizedBox(height: 10.h),

                  /// tracking toggle
                  Obx(
                    () => _drawerItem(
                      iconWidget: Icon(
                        Icons.location_on_outlined,
                        size: 25.h,
                        color: LightThemeColors.primaryColor,
                      ),
                      text: 'Tracking',
                      indexNumber: 5,
                      onTap: () => trackingController.toggleTracking(),
                      trailing: Switch(
                        value: trackingController.isTrackingEnabled.value,
                        activeThumbColor: LightThemeColors.primaryColor,
                        onChanged: (_) =>
                            trackingController.toggleTracking(),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  /// 👇 logout is still part of ListView, right under Customers
                  _drawerItem(
                    icon: SideBar.logoutIcon,
                    text: 'Log out',
                    indexNumber: 3,
                    onTap: () async {
                      // The drawer slides away via Get.back(); the rail has
                      // no route to pop, so only the dialog is shown there.
                      if (!asRail) Get.back();
                      showAdaptiveDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const TextWidget(
                            text: 'Log out',
                            style: TextStyle(color: Colors.red),
                          ),
                          content: const TextWidget(
                            text: 'Are you sure you want to log out?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const TextWidget(text: 'Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Get.back();
                                await authController.doLogout();
                              },
                              child: TextWidget(
                                text: 'Log out',
                                style: TextStyle(
                                  color:
                                      LightThemeColors.bodyTextSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// fixed version text at very bottom
            Text(
              'Version: ${authController.versionController.appVersion.value}',
              style: TextStyle(
                fontSize: Get.size.width <= 440 ? 12.sp : 8.sp,
                color: LightThemeColors.bodyTextSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      );
  }

  Widget _drawerItem({
    String? icon,
    Widget? iconWidget,
    required String text,
    required int indexNumber,
    required GestureTapCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      selected: indexClicked == indexNumber,
      selectedTileColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.sp),
      title: Row(
        children: [
          iconWidget ?? Image.asset(height: 25.h, width: 25.w, icon!),
          Padding(
            padding: EdgeInsets.only(left: 15.sp),
            child: TextWidget(
              text: text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: indexClicked == indexNumber
                    ? LightThemeColors.primaryColor
                    : LightThemeColors.bodyTextColor,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
      trailing: trailing,
    );
  }
}
