//ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

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
    var theme = Theme.of(context);
    final authController = Get.put(AuthController());
    return Drawer(
      child: ListView(
        children: [
          MediaQuery.of(context).size.shortestSide > 599
              ? SizedBox(
                  height: 60.sp,
                  width: double.infinity,
                  child: DrawerHeader(
                    curve: Curves.fastLinearToSlowEaseIn,
                    decoration: const BoxDecoration(
                      color: LightThemeColors.bodyTextColor,
                    ),
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.symmetric(horizontal: 20.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: AssetImageBox(
                                height: 30.sp,
                                width: 30.sp,
                                assetImage: AppImages.kDemoUser,
                              ),
                            ),
                            SizedBox(width: 12.sp),
                            SizedBox(
                              width: 70.sp,
                              child: Text(
                                "${MySharedPref.getUserName()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 80.sp,
                  width: double.infinity,
                  child: DrawerHeader(
                    curve: Curves.fastLinearToSlowEaseIn,
                    decoration: const BoxDecoration(
                      color: LightThemeColors.bodyTextColor,
                    ),
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.symmetric(horizontal: 20.sp),
                    child: Row(
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
                              child: Text(
                                "${MySharedPref.getUserName()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
            child: Text(
              "All",
              style: theme.textTheme.bodyLarge,
            ),
          ),
          _drawerItem(
            icon: Remix.calendar_line,
            text: 'Appointments',
            indexNumber: 0,
            onTap: () async {
              Get.toNamed(Routes.APPOINTMENT);
              indexClicked = indexClicked;
            },
          ),
          _drawerItem(
            icon: Remix.receipt_line,
            text: 'Items',
            indexNumber: 1,
            onTap: () async {
              Get.toNamed(Routes.ITEM);
              indexClicked = indexClicked;
            },
          ),
          SizedBox(height: 25.sp),
          Divider(height: 2, color: LightThemeColors.bodyTextColor),
          _drawerItem(
            icon: Remix.logout_box_r_line,
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
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      content: const Text('Are you sure you want to log out?'),
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
    );
  }

  Widget _drawerItem(
      {required IconData icon,
      required String text,
      required int indexNumber,
      required GestureTapCallback onTap}) {
    return ListTile(
      selected: indexClicked == indexNumber,
      selectedTileColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.sp),
      title: Row(
        children: [
          Icon(
            icon,
            color: indexClicked == indexNumber
                ? LightThemeColors.primaryColor
                : LightThemeColors.bodyTextColor,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.sp),
            child: Text(
              text,
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
