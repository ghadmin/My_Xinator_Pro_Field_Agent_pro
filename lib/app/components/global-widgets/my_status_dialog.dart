import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/theme/dark_theme_colors.dart';
import '../../../config/theme/light_theme_colors.dart';
import 'my_buttons.dart';

/// Visual severity of a [MyStatusDialog] - drives the icon badge and accent color.
enum DialogSeverity { info, success, warning, error }

/// A reusable, theme-aware status dialog.
///
/// Shows a tinted icon badge, a title, a message (or custom content) and
/// stacked full-width action buttons, following the app design language.
///
/// Returns `true` when the primary action is pressed, `false` otherwise.
class MyStatusDialog {
  MyStatusDialog._();

  static Future<bool> show({
    required String title,
    String? message,
    Widget? content,
    DialogSeverity severity = DialogSeverity.info,
    IconData? icon,
    String? primaryLabel,
    VoidCallback? onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
    bool barrierDismissible = true,
  }) async {
    assert(
      message != null || content != null,
      'MyStatusDialog requires a message or custom content',
    );

    return await Get.dialog<bool>(
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Builder(
              builder: (context) => _buildBody(
                context,
                severity: severity,
                icon: icon,
                title: title,
                message: message,
                content: content,
                primaryLabel: primaryLabel,
                onPrimary: onPrimary,
                onSecondary: onSecondary,
                secondaryLabel: secondaryLabel,
              ),
            ),
          ),
          barrierDismissible: barrierDismissible,
        ) ??
        false;
  }

  static Widget _buildBody(
    BuildContext context, {
    required DialogSeverity severity,
    IconData? icon,
    required String title,
    String? message,
    Widget? content,
    String? primaryLabel,
    VoidCallback? onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? DarkThemeColors.cardColor : LightThemeColors.cardColor;
    final textPrimary = isDark ? DarkThemeColors.textPrimary : LightThemeColors.textPrimary;
    final textSecondary = isDark ? DarkThemeColors.textSecondary : LightThemeColors.textSecondary;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIconBadge(severity, isDark, icon),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: textPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(fontSize: 14, height: 1.5, color: textSecondary),
              ),
            ],
            ?content,
            const SizedBox(height: 24),
            if (primaryLabel != null) ...[
              PrimaryButton(
                title: primaryLabel,
                inactive: false,
                width: double.infinity,
                onPressed: () {
                  Get.back<bool>(result: true);
                  onPrimary?.call();
                },
              ),
              if (secondaryLabel != null) const SizedBox(height: 8),
            ],
            if (secondaryLabel != null)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Get.back<bool>(result: false);
                    onSecondary?.call();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    secondaryLabel,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildIconBadge(DialogSeverity severity, bool isDark, IconData? iconOverride) {
    final accent = _accentColor(severity, isDark);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(iconOverride ?? _defaultIcon(severity), color: accent, size: 28),
    );
  }

  static IconData _defaultIcon(DialogSeverity severity) {
    switch (severity) {
      case DialogSeverity.info:
        return Icons.info_outline_rounded;
      case DialogSeverity.success:
        return Icons.check_circle_outline_rounded;
      case DialogSeverity.warning:
        return Icons.warning_amber_rounded;
      case DialogSeverity.error:
        return Icons.error_outline_rounded;
    }
  }

  static Color _accentColor(DialogSeverity severity, bool isDark) {
    switch (severity) {
      case DialogSeverity.info:
        return isDark ? DarkThemeColors.infoColor : LightThemeColors.infoColor;
      case DialogSeverity.success:
        return isDark ? DarkThemeColors.successColor : LightThemeColors.successColor;
      case DialogSeverity.warning:
        return isDark ? DarkThemeColors.warningColor : LightThemeColors.warningColor;
      case DialogSeverity.error:
        return isDark ? DarkThemeColors.errorColor : LightThemeColors.errorColor;
    }
  }
}
