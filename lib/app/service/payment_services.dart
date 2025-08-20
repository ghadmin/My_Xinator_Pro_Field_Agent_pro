import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ThreeDSHelper {
  // Match the channel name used in Swift
  static const MethodChannel _channel =
      MethodChannel('com.yourcompany.payment/3ds');

  /// Initialize the 3DS SDK on iOS
  static Future<void> initialize3DS() async {
    // Only run on iOS
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await _channel.invokeMethod('initialize3DS');
        debugPrint('✅ 3DS SDK initialized successfully on iOS');
      } on PlatformException catch (e) {
        debugPrint('❌ 3DS SDK init failed: ${e.message}');
        if (e.details != null) {
          debugPrint('Details: ${e.details}');
        }
        // Handle error: show dialog, fallback, etc.
        throw Exception("3DS initialization failed: ${e.message}");
      }
    } else {
      debugPrint('ℹ️ 3DS initialization skipped (not iOS)');
    }
  }
}
