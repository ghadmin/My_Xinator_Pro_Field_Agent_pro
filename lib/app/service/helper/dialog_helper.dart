import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../../../config/theme/light_theme_colors.dart';
import '../../../utils/constants.dart';
import '../../components/global-widgets/my_buttons.dart';

class DialogHelper {
  static Null get context => null;

  ///show error dialog
  static void showErrorDialog(String title, String description) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        elevation: 6,
        shadowColor: Colors.black12.withValues(alpha: .2),
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
        shadowColor: Colors.black12.withValues(alpha: .2),
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

  /// Tracks whether a loading dialog was requested. GetX's `Get.isDialogOpen`
  /// is observer-driven state and can go stale, leaving the loader stuck on
  /// screen, so we keep our own source of truth here.
  static bool _isLoaderVisible = false;

  ///show loading
  static Future<void> showLoading() async {
    // Prevent stacking a second loader while one is already open/pending
    if (_isLoaderVisible) return;
    _isLoaderVisible = true;

    final completer = Completer<void>();

    void openDialog() {
      // hideLoading() ran before the dialog was opened
      if (!_isLoaderVisible) {
        completer.complete();
        return;
      }
      try {
        Get.dialog(
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: .1),
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
      } catch (_) {
        _isLoaderVisible = false;
      }
      // Complete after dialog is shown
      Future.delayed(const Duration(milliseconds: 50), completer.complete);
    }

    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      // Called during a build/layout pass — defer to the end of the frame
      WidgetsBinding.instance.addPostFrameCallback((_) => openDialog());
      WidgetsBinding.instance.scheduleFrame();
    } else {
      // Push the route now; the push schedules its own frame, so the loader
      // shows up immediately instead of waiting for an unrelated repaint.
      // (A post-frame callback alone never fires while the app is idle —
      // e.g. tap → network request → response, with no frame in between.)
      openDialog();
    }

    return completer.future;
  }

  ///hide loading
  static Future<void> hideLoading() async {
    _isLoaderVisible = false;
    try {
      // Pop by route type instead of relying on the observer-driven
      // `Get.isDialogOpen` flag — that flag can be false while the loader
      // is still on screen, which used to leave the spinner stuck forever.
      // popUntil is a no-op when no popup route exists.
      Get.until((route) => route is! PopupRoute);
      // Wait for dialog to fully close
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (_) {
      // Safe ignore
    }
  }

  ///show loading with optional message
  static Future<void> showLoadingWithMessage(String message) async {
    Get.dialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      Center(
        child: Container(
          padding: EdgeInsets.all(24.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern spinkit-style loader
              SizedBox(
                width: 50.sp,
                height: 50.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    LightThemeColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: LightThemeColors.bodyTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///show upload progress dialog
  static RxString uploadProgressMessage = "".obs;

  static Future<void> showUploadProgressDialog() async {
    uploadProgressMessage.value = "Preparing upload...";
    Get.dialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      Center(
        child: Container(
          padding: EdgeInsets.all(24.sp),
          margin: EdgeInsets.symmetric(horizontal: 20.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50.sp,
                height: 50.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    LightThemeColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Obx(() => Text(
                uploadProgressMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: LightThemeColors.bodyTextColor,
                  decoration: TextDecoration.none,
                  decorationColor: Colors.transparent,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  static void updateUploadProgress(String message) {
    uploadProgressMessage.value = message;
  }
}
