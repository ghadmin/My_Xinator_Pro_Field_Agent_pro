import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../config/theme/light_theme_colors.dart';
import '../../../utils/constants.dart';
import '../../data/local/my_shared_pref.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../routes/app_pages.dart';
import '../global-widgets/asset_image_box.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key, required this.indexClicked});
  late int indexClicked;

  @override
  Widget build(BuildContext context) {
    // var theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final authController = Get.put(AuthController());
    return Drawer(
      width: size.width > 600 ? 230.w : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      child: Text(
                        textAlign: TextAlign.center,
                        "${MySharedPref.getUserName()}",
                        textScaler: TextScaler.linear(1.0),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.visible,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Image.asset(
                      SideBar.profileGoIcon,
                      color: LightThemeColors.primaryColor,
                    )),
              ],
            ),
            SizedBox(
              height: 35.h,
            ),
            _drawerItem(
              icon: SideBar.homeIcon,
              text: 'Home',
              indexNumber: 0,
              onTap: () async {
                Get.toNamed(Routes.APPOINTMENT);
                indexClicked = indexClicked;
              },
            ),
            // SizedBox(
            //   height: 10.h,
            // ),
            // _drawerItem(
            //   icon: SideBar.customerServiceIcon,
            //   text: 'Customer Service List',
            //   indexNumber: 1,
            //   onTap: () async {
            //     Get.toNamed(Routes.APPOINTMENT);
            //     indexClicked = indexClicked;
            //   },
            // ),
            // SizedBox(
            //   height: 10.h,
            // ),
            // _drawerItem(
            //   icon: SideBar.dispatchingIcon,
            //   text: 'Dispatching',
            //   indexNumber: 2,
            //   onTap: () async {
            //     Get.toNamed(Routes.ITEM);
            //     indexClicked = indexClicked;
            //   },
            // ),
            // SizedBox(
            //   height: 10.h,
            // ),
            // _drawerItem(
            //   icon: SideBar.formIcon,
            //   text: 'Forms',
            //   indexNumber: 3,
            //   onTap: () async {
            //     Get.toNamed(Routes.ITEM);
            //     indexClicked = indexClicked;
            //   },
            // ),
            // SizedBox(
            //   height: 10.h,
            // ),
            _drawerItem(
              icon: SideBar.itemsIcon,
              text: 'Items',
              indexNumber: 1,
              onTap: () async {
                Get.toNamed(Routes.ITEM);
                indexClicked = indexClicked;
              },
            ),
            _drawerItem(
              icon: SideBar.customerServiceIcon,
              text: 'Customers',
              indexNumber: 2,
              onTap: () async {
                Get.toNamed(Routes.CUSTOMER);
                indexClicked = indexClicked;
              },
            ),
            // _drawerItem(
            //   icon: SideBar.itemsIcon,
            //   text: 'Billable Items',
            //   indexNumber: 6,
            //   onTap: () async {
            //     Get.toNamed(Routes.BILLABLE_ITEMS);
            //     indexClicked = indexClicked;
            //   },
            // ),
            SizedBox(
              height: 10.h,
            ),
            // _drawerItem(
            //   icon: SideBar.settingsIcon,
            //   text: 'Settings',
            //   indexNumber: 7,
            //   onTap: () async {
            //     Get.toNamed(Routes.ITEM);
            //     indexClicked = indexClicked;
            //   },
            // ),
            SizedBox(
              height: 10.h,
            ),
            _drawerItem(
              icon: SideBar.logoutIcon,
              text: 'Log out',
              indexNumber: 3,
              onTap: () async {
                Get.back();
                showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          'Log out',
                          textScaler: TextScaler.linear(1.0),
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        content:
                            const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Get.back();
                              await authController.doLogout();
                            },
                            child: Text(
                              'Log out',
                              textScaler: TextScaler.linear(1.0),
                              style: TextStyle(
                                color: LightThemeColors.bodyTextSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    });

                indexClicked = indexClicked;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
      {required String icon,
      required String text,
      required int indexNumber,
      required GestureTapCallback onTap}) {
    return ListTile(
      selected: indexClicked == indexNumber,
      selectedTileColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.sp),
      title: Row(
        children: [
          Image.asset(height: 25.h, width: 25.w, icon),
          Padding(
            padding: EdgeInsets.only(left: 15.sp),
            child: Text(
              text,
              textScaler: TextScaler.linear(1.0),
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
    );
  }
}
