import 'dart:async';

import 'package:flutter/services.dart';

// 🔔 Event types from native SDK
class ClearentEvent {
  final String type;
  final Map<String, dynamic>? data;

  ClearentEvent(this.type, [this.data]);

  @override
  String toString() => 'ClearentEvent($type, $data)';
}

class ClearentService {
  // ✅ Better channel name (use your domain)
  static const MethodChannel _channel =
      MethodChannel('com.xceleran.XinatorBMSFieldAgentPro/clearent');

  // 🔁 Use a Stream to emit events (best practice)
  final StreamController<ClearentEvent> _eventController =
      StreamController.broadcast();

  Stream<ClearentEvent> get onEvent => _eventController.stream;

  ClearentService() {
    _setupMethodChannel();
  }

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'onReady':
          _eventController.add(ClearentEvent('ready'));
          break;

        case 'onSuccess':
          // Expecting: { transactionToken: "...", last4: "1111", cardBrand: "VISA" }
          _eventController.add(ClearentEvent('success', call.arguments));
          break;

        case 'onError':
          _eventController.add(ClearentEvent('error', {
            'message': call.arguments?['error'] ?? 'Unknown error',
          }));
          break;

        case 'onMessage':
          _eventController.add(ClearentEvent('message', {
            'text': call.arguments?['message'] ?? '',
          }));
          break;

        default:
          break;
      }
      return Future.value();
    });
  }

  /// 🔌 Initialize SDK and connect to reader
  Future<void> connectReader() async {
    try {
      final result = await _channel.invokeMethod('initializeSDK');
      _eventController.add(ClearentEvent('info', {
        'text': 'SDK init started: $result',
      }));
    } on PlatformException catch (e) {
      _eventController.add(ClearentEvent('error', {
        'message': 'Failed to connect: ${e.message}',
      }));
    }
  }

  /// 💳 Start a transaction
  Future<void> startTransaction(double amount) async {
    if (amount <= 0) return;

    try {
      await _channel.invokeMethod('startTransaction', {'amount': amount});
      _eventController.add(ClearentEvent('info', {
        'text': 'Transaction started for \$${amount.toStringAsFixed(2)}',
      }));
    } on PlatformException catch (e) {
      _eventController.add(ClearentEvent('error', {
        'message': 'Transaction failed: ${e.message}',
      }));
    }
  }

  /// 🧹 Call this when done
  void dispose() {
    _eventController.close();
  }
}
