import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';
import 'my_fonts.dart';

class MyStyles {
  // Elevation Shadows
  static List<BoxShadow> get elevation1 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          offset: const Offset(0, 1),
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get elevation2 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get elevation3 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get elevation4 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  ///icons theme
  static IconThemeData getIconTheme({required bool isLightTheme}) =>
      IconThemeData(
        color: isLightTheme
            ? LightThemeColors.iconColor
            : DarkThemeColors.iconColor,
      );

  ///app bar theme
  static AppBarTheme getAppBarTheme({required bool isLightTheme}) =>
      AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: getTextTheme(isLightTheme: isLightTheme).titleLarge,
        iconTheme: IconThemeData(
            size: 24.sp,
            color: isLightTheme
                ? LightThemeColors.appBarIconsColor
                : DarkThemeColors.appBarIconsColor),
        backgroundColor: isLightTheme
            ? LightThemeColors.appBarColor
            : DarkThemeColors.appbarColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: isLightTheme
            ? LightThemeColors.shadowColor
            : DarkThemeColors.shadowColor,
      );

  ///text theme
  static TextTheme getTextTheme({required bool isLightTheme}) => TextTheme(
        // Display styles - largest text
        displayLarge: (MyFonts.headlineTextStyle).copyWith(
          fontSize: MyFonts.headline1TextSize,
          fontWeight: MyFonts.fontWeightBold,
          height: MyFonts.lineHeightTight,
          letterSpacing: MyFonts.letterSpacingTight,
          color: isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
        ),
        displayMedium: (MyFonts.headlineTextStyle).copyWith(
          fontSize: MyFonts.headline2TextSize,
          fontWeight: MyFonts.fontWeightBold,
          height: MyFonts.lineHeightTight,
          letterSpacing: MyFonts.letterSpacingTight,
          color: isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
        ),
        displaySmall: (MyFonts.headlineTextStyle).copyWith(
          fontSize: MyFonts.headline3TextSize,
          fontWeight: MyFonts.fontWeightSemiBold,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
        ),

        // Headline styles
        headlineLarge: (MyFonts.headlineTextStyle).copyWith(
          fontSize: MyFonts.headline3TextSize,
          fontWeight: MyFonts.fontWeightSemiBold,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
        ),
        headlineMedium: (MyFonts.headlineTextStyle).copyWith(
          fontSize: MyFonts.headline4TextSize,
          fontWeight: MyFonts.fontWeightSemiBold,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
        ),
        headlineSmall: (MyFonts.headlineTextStyle).copyWith(
          fontSize: MyFonts.headline5TextSize,
          fontWeight: MyFonts.fontWeightMedium,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
        ),

        // Title styles
        titleLarge: (MyFonts.headlineTextStyle).copyWith(
          fontSize: MyFonts.titleLargeTextSize,
          fontWeight: MyFonts.fontWeightSemiBold,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
        ),
        titleMedium: (MyFonts.headlineTextStyle).copyWith(
          fontSize: MyFonts.titleMediumTextSize,
          fontWeight: MyFonts.fontWeightMedium,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
        ),
        titleSmall: (MyFonts.headlineTextStyle).copyWith(
          fontSize: MyFonts.titleSmallTextSize,
          fontWeight: MyFonts.fontWeightMedium,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
        ),

        // Body styles
        bodyLarge: (MyFonts.bodyTextStyle).copyWith(
          fontSize: MyFonts.bodyLargeTextSize,
          fontWeight: MyFonts.fontWeightRegular,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.bodyTextColor
              : DarkThemeColors.bodyTextColor,
        ),
        bodyMedium: (MyFonts.bodyTextStyle).copyWith(
          fontSize: MyFonts.bodyMediumTextSize,
          fontWeight: MyFonts.fontWeightRegular,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.bodyTextColor
              : DarkThemeColors.bodyTextColor,
        ),
        bodySmall: (MyFonts.bodyTextStyle).copyWith(
          fontSize: MyFonts.bodySmallTextSize,
          fontWeight: MyFonts.fontWeightRegular,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.bodyTextColor
              : DarkThemeColors.bodyTextColor,
        ),

        // Label styles
        labelLarge: (MyFonts.buttonTextStyle).copyWith(
          fontSize: MyFonts.buttonTextSize,
          fontWeight: MyFonts.fontWeightSemiBold,
          height: MyFonts.lineHeightNormal,
          color: isLightTheme
              ? LightThemeColors.buttonTextColor
              : DarkThemeColors.buttonTextColor,
        ),
        labelMedium: MyFonts.chipTextStyle.copyWith(
          fontSize: MyFonts.labelTextSize,
          fontWeight: MyFonts.fontWeightMedium,
          height: MyFonts.lineHeightNormal,
        ),
        labelSmall: MyFonts.chipTextStyle.copyWith(
          fontSize: MyFonts.captionTextSize,
          fontWeight: MyFonts.fontWeightMedium,
          height: MyFonts.lineHeightNormal,
        ),
      );

  static ChipThemeData getChipTheme({required bool isLightTheme}) {
    return ChipThemeData(
      backgroundColor: isLightTheme
          ? LightThemeColors.chipBackground
          : DarkThemeColors.chipBackground,
      brightness: isLightTheme ? Brightness.light : Brightness.dark,
      labelStyle: getChipTextStyle(isLightTheme: isLightTheme),
      secondaryLabelStyle: getChipTextStyle(isLightTheme: isLightTheme),
      selectedColor: isLightTheme
          ? LightThemeColors.chipSelectedBackground
          : DarkThemeColors.chipSelectedBackground,
      disabledColor: isLightTheme
          ? LightThemeColors.buttonDisabledColor
          : DarkThemeColors.buttonDisabledColor,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      elevation: 0,
    );
  }

  ///Chips text style
  static TextStyle getChipTextStyle({required bool isLightTheme}) {
    return MyFonts.chipTextStyle.copyWith(
      fontSize: MyFonts.chipTextSize,
      fontWeight: MyFonts.fontWeightMedium,
      color: isLightTheme
          ? LightThemeColors.chipTextColor
          : DarkThemeColors.chipTextColor,
    );
  }

  // elevated button text style
  static WidgetStateProperty<TextStyle?>? getElevatedButtonTextStyle(
      bool isLightTheme,
      {bool isBold = true,
      double? fontSize}) {
    return WidgetStateProperty.resolveWith<TextStyle>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return MyFonts.buttonTextStyle.copyWith(
              fontWeight: MyFonts.fontWeightSemiBold,
              fontSize: fontSize ?? MyFonts.buttonTextSize,
              height: MyFonts.lineHeightNormal,
              color: isLightTheme
                  ? LightThemeColors.buttonTextColor
                  : DarkThemeColors.buttonTextColor);
        } else if (states.contains(WidgetState.disabled)) {
          return MyFonts.buttonTextStyle.copyWith(
              fontSize: fontSize ?? MyFonts.buttonTextSize,
              fontWeight: MyFonts.fontWeightMedium,
              height: MyFonts.lineHeightNormal,
              color: isLightTheme
                  ? LightThemeColors.buttonDisabledTextColor
                  : DarkThemeColors.buttonDisabledTextColor);
        }
        return MyFonts.buttonTextStyle.copyWith(
            fontSize: fontSize ?? MyFonts.buttonTextSize,
            fontWeight: MyFonts.fontWeightSemiBold,
            height: MyFonts.lineHeightNormal,
            color: isLightTheme
                ? LightThemeColors.buttonTextColor
                : DarkThemeColors.buttonTextColor);
      },
    );
  }

  //elevated button theme data
  static ElevatedButtonThemeData getElevatedButtonTheme(
          {required bool isLightTheme}) =>
      ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h)),
          textStyle: getElevatedButtonTextStyle(isLightTheme),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return isLightTheme
                    ? LightThemeColors.primaryDark
                    : DarkThemeColors.primaryDark;
              } else if (states.contains(WidgetState.disabled)) {
                return isLightTheme
                    ? LightThemeColors.buttonDisabledColor
                    : DarkThemeColors.buttonDisabledColor;
              } else if (states.contains(WidgetState.hovered)) {
                return isLightTheme
                    ? LightThemeColors.primaryLight
                    : DarkThemeColors.primaryLight;
              }
              return isLightTheme
                  ? LightThemeColors.buttonColor
                  : DarkThemeColors.buttonColor;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return isLightTheme
                    ? LightThemeColors.buttonDisabledTextColor
                    : DarkThemeColors.buttonDisabledTextColor;
              }
              return isLightTheme
                  ? LightThemeColors.buttonTextColor
                  : DarkThemeColors.buttonTextColor;
            },
          ),
        ),
      );

  // Card theme
  static CardTheme getCardTheme({required bool isLightTheme}) => CardTheme(
        color: isLightTheme
            ? LightThemeColors.cardColor
            : DarkThemeColors.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        shadowColor: isLightTheme
            ? LightThemeColors.shadowColor
            : DarkThemeColors.shadowColor,
      );

  // Input decoration theme
  static InputDecorationTheme getInputDecorationTheme(
          {required bool isLightTheme}) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isLightTheme
            ? LightThemeColors.surfaceColor
            : DarkThemeColors.surfaceColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isLightTheme
                ? LightThemeColors.dividerColor
                : DarkThemeColors.dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isLightTheme
                ? LightThemeColors.dividerColor
                : DarkThemeColors.dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isLightTheme
                ? LightThemeColors.primaryColor
                : DarkThemeColors.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isLightTheme
                ? LightThemeColors.errorColor
                : DarkThemeColors.errorColor,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isLightTheme
                ? LightThemeColors.errorColor
                : DarkThemeColors.errorColor,
            width: 2,
          ),
        ),
        hintStyle: TextStyle(
          fontSize: MyFonts.bodyMediumTextSize,
          color: isLightTheme
              ? LightThemeColors.hintTextColor
              : DarkThemeColors.hintTextColor,
        ),
        labelStyle: TextStyle(
          fontSize: MyFonts.bodyMediumTextSize,
          color: isLightTheme
              ? LightThemeColors.textSecondary
              : DarkThemeColors.textSecondary,
        ),
      );
}
