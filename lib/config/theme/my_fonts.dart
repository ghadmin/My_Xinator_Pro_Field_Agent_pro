import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/data/local/my_shared_pref.dart';
import '../translations/localization_service.dart';

class MyFonts {
  // return the right font depending on app language
  static TextStyle get getAppFontType =>
      LocalizationService.supportedLanguagesFontsFamilies[
          MySharedPref.getCurrentLocal().languageCode]!;

  // headlines text font
  static TextStyle get headlineTextStyle => getAppFontType;

  // body text font
  static TextStyle get bodyTextStyle => getAppFontType;

  // button text font
  static TextStyle get buttonTextStyle => getAppFontType;

  // app bar text font
  static TextStyle get appBarTextStyle => getAppFontType;

  // chips text font
  static TextStyle get chipTextStyle => getAppFontType;

  // App Bar Font Size
  static double get appBarTittleSize => 18.sp;

  // Body Font Sizes - Improved for better readability
  static double get bodyLargeTextSize => 16.sp;
  static double get bodyMediumTextSize => 14.sp;
  static double get bodySmallTextSize => 12.sp;

  // Legacy body font sizes (keeping for compatibility)
  static double get body1TextSize => 16.sp;
  static double get body2TextSize => 14.sp;
  static double get body3TextSize => 12.sp;

  // Headline Font Sizes - Better visual hierarchy
  static double get headline1TextSize => 32.sp;
  static double get headline2TextSize => 28.sp;
  static double get headline3TextSize => 24.sp;
  static double get headline4TextSize => 20.sp;
  static double get headline5TextSize => 18.sp;
  static double get headline6TextSize => 16.sp;

  // Title Font Sizes
  static double get titleLargeTextSize => 22.sp;
  static double get titleMediumTextSize => 16.sp;
  static double get titleSmallTextSize => 14.sp;

  // Button Font Size
  static double get buttonTextSize => 15.sp;

  // Caption Font Size
  static double get captionTextSize => 12.sp;

  // Chip Font Size
  static double get chipTextSize => 13.sp;

  // Label Font Size
  static double get labelTextSize => 14.sp;

  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Line Heights
  static double get lineHeightTight => 1.2;
  static double get lineHeightNormal => 1.5;
  static double get lineHeightRelaxed => 1.75;

  // Letter Spacing
  static double get letterSpacingTight => -0.5;
  static double get letterSpacingNormal => 0.0;
  static double get letterSpacingWide => 0.5;
}
