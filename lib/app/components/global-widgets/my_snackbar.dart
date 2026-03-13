import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants.dart';

class MySnackBar {
  /// Get current context safely
  static BuildContext? get _context {
    return Get.context;
  }

  /// SnackBar ///

  // 1. success snackbar
  static void showSnackBar({
    required String title,
    required String message,
    Duration? duration,
  }) {
    final context = _context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration ?? const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_outlined,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.fixed,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          right: 10,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // 2. error snackbar
  static void showErrorSnackBar({
    required String title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    final context = _context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration ?? const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_outlined,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color ?? Colors.redAccent,
        behavior: SnackBarBehavior.fixed,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          right: 10,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Toast ///

  // 1. success toast
  static void showToast({
    required String message,
    Color? color,
    Duration? duration,
    SnackBarBehavior? behavior,
  }) {
    final context = _context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration:
            duration ??
            Duration(seconds: SnackBarDurations.kMySnackBarDuration),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_outlined,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? Colors.green,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  // 2. info toast
  static void showInfoToast({
    required String message,
    Color? color,
    Duration? duration,
    SnackBarBehavior? behavior,
  }) {
    final context = _context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration:
            duration ??
            Duration(seconds: SnackBarDurations.kMySnackBarDuration),
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? const Color(0xff2E9AFE),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  // 3. error toast
  static void showErrorToast({
    required String message,
    Color? color,
    Duration? duration,
    SnackBarBehavior? behavior,
  }) {
    final context = _context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration:
            duration ??
            Duration(seconds: SnackBarDurations.kMySnackBarDuration),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_outlined,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? Colors.red.withValues(alpha: .9),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  static void showBottomToast({
    required String message,
    Color? color,
    Duration? duration,
  }) {
    final context = _context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration:
            duration ??
            Duration(seconds: SnackBarDurations.kMySnackBarDuration),
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? const Color(0xff2E9AFE),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}
