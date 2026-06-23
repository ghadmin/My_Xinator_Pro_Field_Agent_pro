class SnackBarDurations {
  static int get kMySnackBarDuration => 3;
}

class AppImages {
  static String get kAppIcon => 'assets/images/icon-splash/app_icon.png';
  static String get kLoaderIcon => 'assets/images/loader_icon/loader_icon.png';
  static String get kNoImage => 'assets/images/no_image.png';
  static String get kFSMProIcon => 'assets/images/splashIcon.png';
  static String get kCECBrand => 'assets/images/brandIcon.png';

  static String get kDemoUser => 'assets/images/demo_user.png';
}

class Onboarding {
  static String get kBoard1 =>
      'assets/images/onBoarding/onboarding_main_icon.png';
  static String get kBoard2 =>
      'assets/images/onBoarding/onboarding_date_icon.png';
}

class SideBar {
  static String get homeIcon => 'assets/images/side_bar/home_icon.png';
  static String get customerServiceIcon =>
      'assets/images/side_bar/customer_service_list_icon.png';
  static String get dispatchingIcon =>
      'assets/images/side_bar/dispatch_calendar_icon.png';
  static String get formIcon => 'assets/images/side_bar/form_icon.png';
  static String get settingsIcon => 'assets/images/side_bar/settings_icon.png';
  static String get logoutIcon => 'assets/images/side_bar/logout_icon.png';
  static String get itemsIcon => 'assets/images/side_bar/items_icon.png';
  static String get profileGoIcon =>
      'assets/images/side_bar/profile_go_icon.png';
}

// Spacing System
class AppSpacing {
  // Extra small spacing
  static const double xs = 4.0;

  // Small spacing
  static const double sm = 8.0;

  // Medium spacing
  static const double md = 16.0;

  // Large spacing
  static const double lg = 24.0;

  // Extra large spacing
  static const double xl = 32.0;

  // 2X large spacing
  static const double xxl = 48.0;

  // 3X large spacing
  static const double xxxl = 64.0;
}

// Border Radius
class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double circle = 9999.0;
}

// Duration
class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
}

// Border Width
class AppBorderWidth {
  static const double thin = 1.0;
  static const double medium = 1.5;
  static const double thick = 2.0;
}
