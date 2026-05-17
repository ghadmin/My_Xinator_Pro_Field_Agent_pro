import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme/light_theme_colors.dart';
import '../../../config/theme/dark_theme_colors.dart';

class SplashContainer extends StatelessWidget {
  const SplashContainer({
    super.key,
    this.color,
    this.height,
    this.width,
    required this.child,
    this.radius = 12,
    required this.onPressed,
    this.shadow,
    this.border,
    this.padding,
  });

  final Widget child;
  final Function() onPressed;
  final int radius;
  final Color? color;
  final double? height;
  final double? width;
  final List<BoxShadow>? shadow;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var theme = Theme.of(context);

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(radius.r),
      color: Colors.transparent,
      child: InkWell(
        splashColor: (isDark
                ? DarkThemeColors.primaryColor
                : LightThemeColors.primaryColor)
            .withValues(alpha: 0.1),
        splashFactory: InkSplash.splashFactory,
        highlightColor: (isDark
                ? DarkThemeColors.primaryColor
                : LightThemeColors.primaryColor)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(radius.r),
        radius: 80.r,
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.r),
            color: color ?? theme.cardColor,
            border: border ??
                Border.all(
                  color: isDark
                      ? DarkThemeColors.dividerColor
                      : LightThemeColors.dividerColor,
                  width: 1,
                ),
            boxShadow: shadow ??
                [
                  BoxShadow(
                    color: (isDark
                            ? DarkThemeColors.shadowColor
                            : LightThemeColors.shadowColor)
                        .withValues(alpha: 0.5),
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                    spreadRadius: 0,
                  ),
                ],
          ),
          child: Container(
            height: height,
            width: width,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class CardContainer extends StatelessWidget {
  const CardContainer({
    super.key,
    this.color,
    this.height,
    this.width,
    required this.child,
    this.radius = 16,
    this.onPressed,
    this.shadow,
    this.border,
    this.padding,
  });

  final Widget child;
  final Function()? onPressed;
  final int radius;
  final Color? color;
  final double? height;
  final double? width;
  final List<BoxShadow>? shadow;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var theme = Theme.of(context);

    Widget content = Container(
      height: height,
      width: width,
      padding: padding ?? EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        color: color ?? theme.cardColor,
        border: border,
        boxShadow: shadow ??
            [
              BoxShadow(
                color: (isDark
                        ? DarkThemeColors.shadowColor
                        : LightThemeColors.shadowColor)
                    .withValues(alpha: 0.8),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: (isDark
                        ? DarkThemeColors.shadowColor
                        : LightThemeColors.shadowColor)
                    .withValues(alpha: 0.4),
                offset: const Offset(0, 4),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
      ),
      child: child,
    );

    if (onPressed != null) {
      return Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(radius.r),
        color: Colors.transparent,
        child: InkWell(
          splashColor: (isDark
                  ? DarkThemeColors.primaryColor
                  : LightThemeColors.primaryColor)
              .withValues(alpha: 0.1),
          splashFactory: InkSplash.splashFactory,
          highlightColor: (isDark
                  ? DarkThemeColors.primaryColor
                  : LightThemeColors.primaryColor)
              .withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(radius.r),
          radius: 80.r,
          onTap: onPressed,
          child: content,
        ),
      );
    }

    return content;
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.titleColor,
    this.valueColor,
    this.borderColor,
  });

  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? valueColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark
                ? DarkThemeColors.surfaceColor
                : LightThemeColors.surfaceColor),
        borderRadius: BorderRadius.circular(12.r),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : Border.all(
                color: isDark
                    ? DarkThemeColors.dividerColor
                    : LightThemeColors.dividerColor,
                width: 1,
              ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: (iconColor ??
                        (isDark
                            ? DarkThemeColors.primaryColor
                            : LightThemeColors.primaryColor))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: iconColor ??
                    (isDark
                        ? DarkThemeColors.primaryColor
                        : LightThemeColors.primaryColor),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: titleColor ??
                        (isDark
                            ? DarkThemeColors.textSecondary
                            : LightThemeColors.textSecondary),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor ??
                        (isDark
                            ? DarkThemeColors.textPrimary
                            : LightThemeColors.textPrimary),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
