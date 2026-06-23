import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:ionicons/ionicons.dart'; // Replaced with Icons class due to compatibility issues
import 'package:lottie/lottie.dart';

import '../../../config/translations/strings_enum.dart';
import 'text_widget.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.onPressed,
    this.title,
    this.isRefreshShown = true,
  });
  final VoidCallback onPressed;
  final String? title;
  final bool isRefreshShown;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(
          'animations/error.json',
          height: 120.h,
          repeat: true,
          reverse: true,
          fit: BoxFit.cover,
        ),
        Center(
          child: TextWidget(
            textAlign: TextAlign.center,
            text: title ?? Strings.empty.tr,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: theme.hintColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        if (!isRefreshShown) SizedBox(height: 50.h),
        if (isRefreshShown)
          SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade50,
                elevation: .5,
                shadowColor: theme.hintColor,
                padding: EdgeInsets.zero,
              ),
              child: Icon(
                Icons.refresh,
                size: 24,
                color: theme.primaryColor.withValues(alpha: 0.7),
              ),
            ),
          ),
        const SizedBox(height: 5),
        if (isRefreshShown)
          TextWidget(
            text: Strings.refresh.tr,
            style: TextStyle(color: theme.hintColor.withValues(alpha: 0.5)),
          ),
      ],
    );
  }
}
