import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme/light_theme_colors.dart';
import '../../../config/theme/dark_theme_colors.dart';
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
    this.width,
    this.height,
  });

  final String title;
  final VoidCallback onPressed;
  final bool inactive;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final Color? fontColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height ?? 52.h,
      child: ElevatedButton(
        onPressed: inactive ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor ?? Colors.white,
          backgroundColor:
              backgroundColor ?? (isDark ? DarkThemeColors.buttonColor : LightThemeColors.buttonColor),
          disabledBackgroundColor: isDark
              ? DarkThemeColors.buttonDisabledColor
              : LightThemeColors.buttonDisabledColor,
          splashFactory: InkSplash.splashFactory,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.5)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        ),
        child: TextWidget(
          text: title,
          style: TextStyle(
            fontSize: 15.sp,
            color: inactive
                ? (isDark
                    ? DarkThemeColors.buttonDisabledTextColor
                    : LightThemeColors.buttonDisabledTextColor)
                : (fontColor ?? Colors.white),
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
    this.width,
    this.height,
  });

  final String title;
  final VoidCallback onPressed;
  final bool inactive;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height ?? 52.h,
      child: ElevatedButton(
        onPressed: inactive ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: isDark
              ? DarkThemeColors.textPrimary
              : LightThemeColors.textPrimary,
          backgroundColor: isDark
              ? DarkThemeColors.secondaryButtonColor
              : LightThemeColors.secondaryButtonColor,
          disabledBackgroundColor: isDark
              ? DarkThemeColors.buttonDisabledColor
              : LightThemeColors.buttonDisabledColor,
          splashFactory: InkSplash.splashFactory,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isDark
                  ? DarkThemeColors.buttonBorderColor
                  : LightThemeColors.buttonBorderColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        ),
        child: TextWidget(
          text: title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: inactive
                ? (isDark
                    ? DarkThemeColors.buttonDisabledTextColor
                    : LightThemeColors.buttonDisabledTextColor)
                : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
    this.width,
    this.height,
  });

  final String title;
  final VoidCallback onPressed;
  final IconData iconData;
  final bool inactive;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height ?? 52.h,
      child: ElevatedButton(
        onPressed: inactive ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: isDark
              ? DarkThemeColors.textPrimary
              : LightThemeColors.textPrimary,
          backgroundColor: isDark
              ? DarkThemeColors.secondaryButtonColor
              : LightThemeColors.secondaryButtonColor,
          disabledBackgroundColor: isDark
              ? DarkThemeColors.buttonDisabledColor
              : LightThemeColors.buttonDisabledColor,
          splashFactory: InkSplash.splashFactory,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isDark
                  ? DarkThemeColors.buttonBorderColor
                  : LightThemeColors.buttonBorderColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 18.sp,
              color: inactive
                  ? (isDark
                      ? DarkThemeColors.buttonDisabledTextColor
                      : LightThemeColors.buttonDisabledTextColor)
                  : (isDark
                      ? DarkThemeColors.primaryColor
                      : LightThemeColors.primaryColor),
            ),
            SizedBox(width: 12.w),
            TextWidget(
              text: title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: inactive
                    ? (isDark
                        ? DarkThemeColors.buttonDisabledTextColor
                        : LightThemeColors.buttonDisabledTextColor)
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    this.width,
    this.height,
  });

  final String title;
  final VoidCallback onPressed;
  final IconData iconData;
  final bool inactive;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height ?? 52.h,
      child: ElevatedButton(
        onPressed: inactive ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor:
              isDark ? DarkThemeColors.buttonColor : LightThemeColors.buttonColor,
          disabledBackgroundColor: isDark
              ? DarkThemeColors.buttonDisabledColor
              : LightThemeColors.buttonDisabledColor,
          splashFactory: InkSplash.splashFactory,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 18.sp,
              color: inactive
                  ? (isDark
                      ? DarkThemeColors.buttonDisabledTextColor
                      : LightThemeColors.buttonDisabledTextColor)
                  : Colors.white,
            ),
            SizedBox(width: 12.w),
            TextWidget(
              text: title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: inactive
                    ? (isDark
                        ? DarkThemeColors.buttonDisabledTextColor
                        : LightThemeColors.buttonDisabledTextColor)
                    : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    this.width,
    this.height,
  });

  final VoidCallback onPressed;
  final String socialIcon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height ?? 52.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: isDark
              ? DarkThemeColors.primaryColor
              : LightThemeColors.primaryColor,
          backgroundColor: Colors.white,
          splashFactory: InkSplash.splashFactory,
          shadowColor: (isDark
                  ? DarkThemeColors.primaryColor
                  : LightThemeColors.primaryColor)
              .withValues(alpha: 0.15),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        ),
        child: Image.asset(
          socialIcon,
          height: 24.sp,
        ),
      ),
    );
  }
}

class TextButtonWidget extends StatelessWidget {
  const TextButtonWidget({
    super.key,
    required this.title,
    required this.onPressed,
    this.inactive = false,
    this.textColor,
    this.fontSize,
  });

  final String title;
  final VoidCallback onPressed;
  final bool inactive;
  final Color? textColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextButton(
      onPressed: inactive ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ??
            (isDark
                ? DarkThemeColors.primaryColor
                : LightThemeColors.primaryColor),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: TextWidget(
        text: title,
        style: TextStyle(
          fontSize: fontSize ?? 14.sp,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

class IconButtonWidget extends StatelessWidget {
  const IconButtonWidget({
    super.key,
    required this.icon,
    required this.onPressed,
    this.inactive = false,
    this.iconColor,
    this.backgroundColor,
    this.size,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool inactive;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: backgroundColor ??
          (isDark
              ? DarkThemeColors.surfaceColor
              : LightThemeColors.surfaceColor),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: inactive ? null : onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: size ?? 44.sp,
          height: size ?? 44.sp,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20.sp,
            color: inactive
                ? (isDark
                    ? DarkThemeColors.textDisabled
                    : LightThemeColors.textDisabled)
                : (iconColor ??
                    (isDark
                        ? DarkThemeColors.iconActiveColor
                        : LightThemeColors.iconActiveColor)),
          ),
        ),
      ),
    );
  }
}
