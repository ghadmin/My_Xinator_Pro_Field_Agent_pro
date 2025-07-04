import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../../../config/theme/light_theme_colors.dart';
import '../../../utils/constants.dart';
import '../../components/global-widgets/my_buttons.dart';

class DialogHelper {
  static get context => null;

  ///show error dialog
  static void showErrorDialog(String title, String description) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        elevation: 6,
        shadowColor: Colors.black12.withOpacity(.2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: SizedBox(
            width: 200.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (Get.isDialogOpen!) Get.back();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        )),
                  ],
                ),
                Icon(
                  Remix.error_warning_fill,
                  color: Colors.red,
                  size: 60.sp,
                ),
                SizedBox(height: 15.sp),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 15.sp),
                AnimatedTextKit(repeatForever: true, animatedTexts: [
                  ColorizeAnimatedText(description,
                      textStyle: Get.textTheme.bodyMedium as TextStyle,
                      textAlign: TextAlign.center,
                      colors: [
                        Colors.white,
                        Colors.red.shade50,
                        Colors.redAccent.shade100,
                        Colors.white,
                      ]),
                ]),
                SizedBox(height: 15.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///show Download dialog
  static void showDownloadDialog(String fileName, dynamic onPressed) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black12.withOpacity(.2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: SizedBox(
            width: 350.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Download PDF?",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        color: LightThemeColors.bodyTextColor,
                      ),
                    ),
                    IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (Get.isDialogOpen!) Get.back();
                        },
                        icon: const Icon(
                          Icons.close,
                          // color: Colors.white,
                        )),
                  ],
                ),
                SizedBox(height: 20.sp),
                Text(
                  fileName,
                  style: TextStyle(
                    color: LightThemeColors.bodyTextSecondaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.sp),
                Text(
                  "Download the PDF of this conversation?",
                  style: TextStyle(
                    color: LightThemeColors.bodyTextSecondaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                            height: 40.sp,
                            width: 100.sp,
                            child: SecondaryButton(
                                title: "Cancel",
                                onPressed: () {
                                  Get.back();
                                },
                                inactive: false)),
                        SizedBox(width: 10.sp),
                        SizedBox(
                          height: 40.sp,
                          width: 100.sp,
                          child: PrimaryButton(
                              title: "Download",
                              onPressed: onPressed,
                              inactive: false),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///show loading
  static Future<void> showLoading() async {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
      Get.dialog(
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(.1),
        // barrierColor: LightThemeColors.bodyTextColor,
        Center(
          child: Container(
            height: 80.h,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // App Icon
                Container(
                  height: 50.sp,
                  width: 50.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                        AppImages.kLoaderIcon,
                      ),
                    ),
                  ),
                ),
                // Loader
                SizedBox(
                  height: 60.sp,
                  width: 60.sp,
                  child: const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      Get.dialog(
        barrierDismissible: false,
        barrierColor: LightThemeColors.bodyTextColor.withOpacity(.1),
        //  barrierColor: LightThemeColors.bodyTextColor,
        Center(
          child: Container(
            height: 80.h,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // App Icon
                Container(
                  height: 50.sp,
                  width: 50.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage(
                      AppImages.kLoaderIcon,
                    )),
                  ),
                ),
                // Loader
                SizedBox(
                  height: 60.sp,
                  width: 60.sp,
                  child: const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  ///hide loading
  static Future<void> hideLoading() async {
    if (Get.isDialogOpen!) {
      if (Get.isSnackbarOpen) {
        await SnackBarDurations.kMySnackBarDuration.delay();
        Get.closeAllSnackbars();
        Get.back();
      } else {
        Get.back();
      }
    }
  }
}
