import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme/light_theme_colors.dart';
import 'text_widget.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.inactive,
    this.borderColor,
    this.backgroundColor,
    this.fontColor,
    this.foregroundColor,
  });
  final String title;
  final VoidCallback onPressed;
  final bool inactive;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final Color? fontColor;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return SizedBox(
      height: 55.h,
      child: ElevatedButton(
        onPressed: inactive == true ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor ?? Colors.white,
          backgroundColor: backgroundColor ?? theme.primaryColor,
          splashFactory: NoSplash.splashFactory,
          shadowColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: borderColor == null
                ? BorderSide.none
                : BorderSide(color: borderColor!),
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        child: TextWidget(
          text: title,
          style: TextStyle(
            fontSize: 16.sp,
            color: fontColor ?? Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.inactive,
  });
  final String title;
  final VoidCallback onPressed;
  final bool inactive;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55.h,
      child: ElevatedButton(
        onPressed: inactive == true ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: LightThemeColors.bodyTextColor,
          backgroundColor: Colors.white,
          splashFactory: NoSplash.splashFactory,
          shadowColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: LightThemeColors.buttonBorderColor,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        child: TextWidget(
          text: title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class SecondaryButtonWithIcon extends StatelessWidget {
  const SecondaryButtonWithIcon({
    super.key,
    required this.title,
    required this.onPressed,
    required this.iconData,
    required this.inactive,
  });
  final String title;
  final VoidCallback onPressed;
  final IconData iconData;
  final bool inactive;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55.h,
      child: ElevatedButton(
        onPressed: inactive == true ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: LightThemeColors.bodyTextColor,
          backgroundColor: Colors.white,
          splashFactory: NoSplash.splashFactory,
          shadowColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: LightThemeColors.buttonBorderColor,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 20.sp, color: LightThemeColors.primaryColor),
            SizedBox(width: 15.w),
            TextWidget(
              text: title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryButtonWithIcon extends StatelessWidget {
  const PrimaryButtonWithIcon({
    super.key,
    required this.title,
    required this.onPressed,
    required this.iconData,
    required this.inactive,
  });
  final String title;
  final VoidCallback onPressed;
  final IconData iconData;
  final bool inactive;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return SizedBox(
      height: 55.h,
      child: ElevatedButton(
        onPressed: inactive == true ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: theme.primaryColor,
          splashFactory: NoSplash.splashFactory,
          shadowColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData),
            SizedBox(width: 15.w),
            TextWidget(
              text: title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.onPressed,
    required this.socialIcon,
  });

  final VoidCallback onPressed;
  final String socialIcon;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return SizedBox(
      height: 45.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: theme.primaryColor,
          backgroundColor: Colors.white,
          splashFactory: NoSplash.splashFactory,
          shadowColor: theme.primaryColor.withValues(alpha: .4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 3,
        ),
        child: Image.asset(socialIcon),
      ),
    );
  }
}
