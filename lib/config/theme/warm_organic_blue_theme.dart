import 'package:flutter/material.dart';

/// Warm Organic Blue Theme
/// Soft gradients, rounded corners, gentle shadows, blue palette
class WarmOrganicBlueTheme {
  WarmOrganicBlueTheme._();

  // ─── Primary Blues ─────────────────────────────────────
  static const Color primaryBlue = Color(0xFF4A7CFE);
  static const Color primaryBlueDark = Color(0xFF3366E6);
  static const Color primaryBlueLight = Color(0xFF7BA4FF);
  static const Color primaryBlueSoft = Color(0xFFE8EEFF);

  // ─── Accent Blues ──────────────────────────────────────
  static const Color accentBlue = Color(0xFF5B9CFE);
  static const Color accentCyan = Color(0xFF64D2FF);
  static const Color accentIndigo = Color(0xFF6C7BFF);
  static const Color accentSky = Color(0xFF87CEEB);

  // ─── Warm Organic Neutrals ─────────────────────────────
  static const Color warmWhite = Color(0xFFFDFBFF);
  static const Color warmGray = Color(0xFFF8F9FC);
  static const Color warmSilver = Color(0xFFEEF1F8);
  static const Color coolGray = Color(0xFF5A6278); // Brighter, more readable
  static const Color darkSlate = Color(0xFF1A202C); // Much darker for better contrast
  static const Color charcoal = Color(0xFF0F1419); // Almost black
  static const Color deepNavy = Color(0xFF0A1628); // Much darker navy

  // ─── Status Colors ────────────────────────────────────
  static const Color statusGreen = Color(0xFF48BB78);
  static const Color statusGreenLight = Color(0xFFE6FFED);
  static const Color statusYellow = Color(0xFFECC94B);
  static const Color statusYellowLight = Color(0xFFFFFBEB);
  static const Color statusRed = Color(0xFFFC8181);
  static const Color statusRedLight = Color(0xFFFFF5F5);
  static const Color statusOrange = Color(0xFFED8936);
  static const Color statusOrangeLight = Color(0xFFFFFAF0);
  static const Color statusBlue = Color(0xFF63B3ED);
  static const Color statusBlueLight = Color(0xFFEBF8FF);

  // ─── Gradients ────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A7CFE), Color(0xFF6C7BFF)],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8EEFF), Color(0xFFF8F9FC)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment(-0.5, -1.0),
    end: Alignment(0.8, 1.2),
    colors: [Color(0xFF4A7CFE), Color(0xFF6C7BFF), Color(0xFF7BA4FF)],
  );

  static const LinearGradient fabGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A7CFE), Color(0xFF5B9CFE)],
  );

  // ─── Shadows ──────────────────────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x1A4A7CFE),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D4A7CFE),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x154A7CFE),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x084A5568),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  // ─── Border Radius ────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 50.0;

  // ─── Spacing ──────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // ─── Typography ───────────────────────────────────────
  static const TextStyle headingLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: deepNavy,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: deepNavy,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: deepNavy,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: darkSlate,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: darkSlate,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: darkSlate,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: darkSlate,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
    height: 1.2,
  );

  // ─── Theme Data ───────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: warmGray,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: Colors.white,
        error: statusRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: deepNavy,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: deepNavy),
        titleTextStyle: headingMedium,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        elevation: 4,
        shape: StadiumBorder(),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryBlue,
        unselectedLabelColor: darkSlate,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(color: warmSilver, thickness: 1, space: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warmGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: bodySmall,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: warmSilver,
        selectedColor: primaryBlueSoft,
        labelStyle: bodySmall,
        secondaryLabelStyle: const TextStyle(color: primaryBlue),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
      ),
    );
  }
}
