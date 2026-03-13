import 'package:flutter/foundation.dart';
import '../helper/dialog_helper.dart';

/// Common loading service for the entire app
/// Provides centralized loading dialog management with debug tracking
class LoadingService {
  // Private constructor to prevent instantiation
  LoadingService._();

  /// Show loading dialog with debug tracking
  static Future<void> show({String? debugInfo}) async {
    if (debugInfo != null) {
      debugPrint("🚀 [LOADING] SHOW - $debugInfo");
    } else {
      debugPrint("🚀 [LOADING] SHOW");
    }
    await DialogHelper.showLoading();
  }

  /// Hide loading dialog with debug tracking
  static Future<void> hide({String? debugInfo}) async {
    if (debugInfo != null) {
      debugPrint("✅ [LOADING] HIDE - $debugInfo");
    } else {
      debugPrint("✅ [LOADING] HIDE");
    }
    await DialogHelper.hideLoading();
  }
}
