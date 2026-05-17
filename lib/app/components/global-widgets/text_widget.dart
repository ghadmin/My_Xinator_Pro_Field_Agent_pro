import 'package:flutter/material.dart';

import '../../../config/theme/light_theme_colors.dart';
import '../../../config/theme/dark_theme_colors.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
      {super.key,
      this.style,
      required this.text,
      this.maxLines,
      this.textAlign = TextAlign.left,
      this.overflow = TextOverflow.ellipsis,
      this.color,
      this.fontSize,
      this.fontWeight,
      this.height,
      this.decoration,
      this.softWrap});
  final String text;
  final TextStyle? style;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final int? maxLines;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final TextDecoration? decoration;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines != null ? overflow : null,
      softWrap: softWrap,
      textScaler: TextScaler.noScaling,
      style: (style ?? DefaultTextStyle.of(context).style).copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        decoration: decoration,
      ),
    );
  }
}

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.type = AppTextType.bodyMedium,
    this.color,
    this.fontWeight,
    this.align,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.decoration,
    this.height,
  });

  final String text;
  final AppTextType type;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow overflow;
  final TextDecoration? decoration;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = type.getDefaultColor(isDark);

    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines != null ? overflow : null,
      style: type.getTextStyle(isDark).copyWith(
        color: color ?? defaultColor,
        fontWeight: fontWeight ?? type.fontWeight,
        decoration: decoration,
        height: height,
      ),
    );
  }
}

enum AppTextType {
  // Display
  displayLarge(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  ),
  displayMedium(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  ),
  displaySmall(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  ),

  // Headline
  headlineLarge(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  ),
  headlineMedium(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  ),
  headlineSmall(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ),

  // Title
  titleLarge(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  ),
  titleMedium(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ),
  titleSmall(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ),

  // Body
  bodyLarge(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ),
  bodyMedium(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ),
  bodySmall(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ),

  // Label
  labelLarge(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  ),
  labelMedium(
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ),
  labelSmall(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  const AppTextType({
    required this.fontSize,
    required this.fontWeight,
    this.letterSpacing = 0,
    required this.height,
  });

  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final double height;

  TextStyle getTextStyle(bool isDark) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  Color? getDefaultColor(bool isDark) {
    switch (this) {
      case AppTextType.displayLarge:
      case AppTextType.displayMedium:
      case AppTextType.displaySmall:
      case AppTextType.headlineLarge:
      case AppTextType.headlineMedium:
      case AppTextType.headlineSmall:
      case AppTextType.titleLarge:
      case AppTextType.titleMedium:
      case AppTextType.titleSmall:
      case AppTextType.bodyLarge:
      case AppTextType.bodyMedium:
      case AppTextType.bodySmall:
        return isDark
            ? DarkThemeColors.textPrimary
            : LightThemeColors.textPrimary;
      case AppTextType.labelLarge:
      case AppTextType.labelMedium:
      case AppTextType.labelSmall:
        return isDark
            ? DarkThemeColors.textSecondary
            : LightThemeColors.textSecondary;
    }
  }
}
