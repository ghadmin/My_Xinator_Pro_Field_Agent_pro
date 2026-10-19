import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'xplorpay_models.dart';

/// Result of the Tap to Pay device/entitlement check.
///
/// Mirrors the SDK's `TapToPayDeviceSupportResult` (struct with `isSupported`
/// and `errorMessage`).
class TapToPaySupportResult {
  final bool isSupported;
  final String? errorMessage;

  const TapToPaySupportResult({required this.isSupported, this.errorMessage});

  factory TapToPaySupportResult.fromMap(Map<Object?, Object?> map) {
    return TapToPaySupportResult(
      isSupported: map['isSupported'] == true,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}

/// Events emitted on "xplorpay/tap_to_pay/events".
sealed class TapToPayEvent {
  const TapToPayEvent();

  static TapToPayEvent fromMap(Map<Object?, Object?> map) {
    switch (map['event']) {
      case 'closed':
        return TapToPayClosed(error: map['error'] as String?);
      case 'transaction':
        final raw = map['response'];
        final error = map['error'] as String?;
        XplorPayTransactionResult? parsed;
        if (raw is Map) {
          parsed = XplorPayTransactionResult.fromGatewayJson(
              Map<String, dynamic>.from(raw));
        } else if (error != null) {
          // No response payload: surface the SDK error type as a result.
          parsed = XplorPayTransactionResult(result: 'ERROR', displayMessage: error);
        }
        return TapToPayTransaction(result: parsed, raw: raw, error: error);
      default:
        return TapToPayUnknown(map['event']?.toString() ?? 'unknown');
    }
  }
}

/// The SDK's Tap to Pay UI was dismissed (Done or Cancel). Not a sale verdict.
class TapToPayClosed extends TapToPayEvent {
  final String? error;
  const TapToPayClosed({this.error});
}

/// Sale outcome reported by the SDK (`didFinishTransaction`).
class TapToPayTransaction extends TapToPayEvent {
  /// Lenient parse of the SDK's response payload (null when only an error
  /// arrived). The response struct is opaque (Codable with hidden fields), so
  /// treat [raw] as the source of truth for diagnostics.
  final XplorPayTransactionResult? result;

  /// Undecoded response payload from the SDK, if any.
  final Object? raw;

  /// SDK error type name (e.g. "gatewayDeclined"), when the sale failed.
  final String? error;

  const TapToPayTransaction({this.result, this.raw, this.error});

  bool get approved => result?.approved ?? false;
}

class TapToPayUnknown extends TapToPayEvent {
  final String name;
  const TapToPayUnknown(this.name);
}

/// Platform interface for Xplor Pay Tap to Pay on iPhone.
///
/// Implemented by [XplorPayTapToPayService] (real, iOS via
/// XplorPayTapToPayPlugin.swift) and [MockXplorPayTapToPayService] (simulator/
/// Android/tests). The SDK owns the whole payment UI; this interface only
/// checks support, pre-warms the reader session, and launches the flow.
abstract class XplorPayTapToPayPlatform {
  /// Payment flow feedback (transaction results, UI closed).
  Stream<TapToPayEvent> get events;

  /// Hardware-only check (equals the SDK's `isTapToPaySupported`).
  Future<bool> isSupported();

  /// Hardware + entitlement check. Call before checkout to show fallback UI.
  Future<TapToPaySupportResult> verifySupport();

  /// Configure the SDK (ClearentUIManager). Must be called before
  /// [prepare] / [presentPayment].
  Future<void> initialize({
    required String baseUrl,
    required String apiKey,
    String? publicKey,
    String? softwareType,
    String? softwareTypeVersion,
  });

  /// Pre-warm the Apple reader session. Safe to call repeatedly.
  Future<void> prepare({
    required double amount,
    bool forceRefreshToken = false,
    String? softwareType,
    String? softwareTypeVersion,
  });

  /// Whether the merchant accepted Apple's Tap to Pay terms.
  Future<bool> isAccountLinked();

  /// Present Apple's terms sheet. Keep outside the payment path (onboarding/
  /// settings), per the SDK docs.
  Future<void> linkAccount();

  /// Launch the full-screen SDK payment flow. The outcome arrives via
  /// [events] (`TapToPayTransaction` then `TapToPayClosed`).
  Future<void> presentPayment({
    required double amount,
    String? customerID,
    String? invoice,
    String? orderID,
    String? softwareType,
    String? softwareTypeVersion,
  });

  /// Cancel in-flight preparation and drop the cached reader JWT. Do not call
  /// after a successful sale.
  Future<void> invalidateSession();

  void dispose();
}

class XplorPayTapToPayException implements Exception {
  final String code;
  final String message;

  /// Native details map. For SDK errors it holds `type` (Clearent error type
  /// name) and `gateway` (the encoded ClearentError — the gateway's own
  /// errorMessage/resultCode when the SDK built the error from a response).
  final Map<Object?, Object?>? details;

  const XplorPayTapToPayException(this.code, this.message, {this.details});

  @override
  String toString() => 'XplorPayTapToPayException($code): $message';
}

/// Real implementation backed by MethodChannel "xplorpay/tap_to_pay" and
/// EventChannel "xplorpay/tap_to_pay/events" (XplorPayTapToPayPlugin.swift).
class XplorPayTapToPayService implements XplorPayTapToPayPlatform {
  static const _methodChannel = MethodChannel('xplorpay/tap_to_pay');
  static const _eventChannel = EventChannel('xplorpay/tap_to_pay/events');

  StreamController<TapToPayEvent>? _events;

  @override
  Stream<TapToPayEvent> get events {
    _events ??= _listen();
    return _events!.stream;
  }

  StreamController<TapToPayEvent> _listen() {
    final controller = StreamController<TapToPayEvent>.broadcast();
    controller.onListen = () {
      _eventChannel.receiveBroadcastStream().listen(
        (data) {
          if (data is Map) {
            controller.add(TapToPayEvent.fromMap(Map<Object?, Object?>.from(data)));
          }
        },
        onError: (Object error) {
          controller.add(TapToPayUnknown(error.toString()));
        },
        cancelOnError: false,
      );
    };
    return controller;
  }

  Future<T> _invoke<T>(String method, [Map<String, Object?>? args]) async {
    if (!Platform.isIOS) {
      throw const XplorPayTapToPayException(
        'UNSUPPORTED_PLATFORM',
        'Tap to Pay on iPhone requires iOS.',
      );
    }
    try {
      final result = await _methodChannel.invokeMethod<T>(method, args);
      return result as T;
    } on PlatformException catch (e) {
      final gateway = _gatewayDetails(e.details);
      final extra = gateway == null
          ? ''
          : ' — gateway: ${gateway['errorMessage'] ?? 'no error message'}'
              ' (resultCode: ${gateway['resultCode'] ?? '-'})';
      throw XplorPayTapToPayException(
        e.code,
        '${e.message ?? e.code}$extra',
        details: e.details is Map
            ? Map<Object?, Object?>.from(e.details as Map)
            : null,
      );
    }
  }

  /// Extracts the encoded ClearentError from PlatformException.details (see
  /// the native flutterError mapper — the gateway's own error fields are the
  /// only hint of WHY a Tap to Pay session token came back missing).
  static Map<Object?, Object?>? _gatewayDetails(Object? details) {
    if (details is! Map) return null;
    final gateway = details['gateway'];
    if (gateway is! Map) return null;
    return Map<Object?, Object?>.from(gateway);
  }

  @override
  Future<bool> isSupported() async {
    if (!Platform.isIOS) return false;
    return _invoke<bool>('isSupported');
  }

  @override
  Future<TapToPaySupportResult> verifySupport() async {
    if (!Platform.isIOS) {
      return const TapToPaySupportResult(
        isSupported: false,
        errorMessage: 'Tap to Pay on iPhone requires iOS.',
      );
    }
    final map = await _invoke<Map<Object?, Object?>>('verifySupport');
    return TapToPaySupportResult.fromMap(map);
  }

  @override
  Future<void> initialize({
    required String baseUrl,
    required String apiKey,
    String? publicKey,
    String? softwareType,
    String? softwareTypeVersion,
  }) {
    return _invoke<void>('initialize', {
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'publicKey': ?publicKey,
      'softwareType': ?softwareType,
      'softwareTypeVersion': ?softwareTypeVersion,
    });
  }

  @override
  Future<void> prepare({
    required double amount,
    bool forceRefreshToken = false,
    String? softwareType,
    String? softwareTypeVersion,
  }) {
    return _invoke<void>('prepare', {
      'amount': amount,
      'forceRefreshToken': forceRefreshToken,
      'softwareType': ?softwareType,
      'softwareTypeVersion': ?softwareTypeVersion,
    });
  }

  @override
  Future<bool> isAccountLinked() async {
    if (!Platform.isIOS) return false;
    return _invoke<bool>('isAccountLinked');
  }

  @override
  Future<void> linkAccount() => _invoke<void>('linkAccount');

  @override
  Future<void> presentPayment({
    required double amount,
    String? customerID,
    String? invoice,
    String? orderID,
    String? softwareType,
    String? softwareTypeVersion,
  }) {
    return _invoke<void>('presentPayment', {
      'amount': amount,
      'customerID': ?customerID,
      'invoice': ?invoice,
      'orderID': ?orderID,
      'softwareType': ?softwareType,
      'softwareTypeVersion': ?softwareTypeVersion,
    });
  }

  @override
  Future<void> invalidateSession() => _invoke<void>('invalidateSession');

  @override
  void dispose() {
    _events?.close();
    _events = null;
  }
}

/// Hardware-free mock with the same contract (simulator, Android, tests).
/// Runs a scripted prepare -> tap -> approved -> closed sequence per sale.
class MockXplorPayTapToPayService implements XplorPayTapToPayPlatform {
  final StreamController<TapToPayEvent> _events =
      StreamController<TapToPayEvent>.broadcast();
  final List<Timer> _timers = [];

  @override
  Stream<TapToPayEvent> get events => _events.stream;

  void _emit(TapToPayEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<TapToPaySupportResult> verifySupport() async {
    return const TapToPaySupportResult(isSupported: true);
  }

  @override
  Future<void> initialize({
    required String baseUrl,
    required String apiKey,
    String? publicKey,
    String? softwareType,
    String? softwareTypeVersion,
  }) async {
    debugPrint('MockXplorPayTapToPayService.initialize(baseUrl: $baseUrl)');
  }

  @override
  Future<void> prepare({
    required double amount,
    bool forceRefreshToken = false,
    String? softwareType,
    String? softwareTypeVersion,
  }) async {
    _later(const Duration(milliseconds: 300));
  }

  @override
  Future<bool> isAccountLinked() async => true;

  @override
  Future<void> linkAccount() async {
    _later(const Duration(milliseconds: 300));
  }

  @override
  Future<void> presentPayment({
    required double amount,
    String? customerID,
    String? invoice,
    String? orderID,
    String? softwareType,
    String? softwareTypeVersion,
  }) async {
    _later(const Duration(milliseconds: 400), () {
      _emit(const TapToPayTransaction(
        result: XplorPayTransactionResult(
          id: 'mock-taptopay-txn',
          result: 'APPROVED',
          resultCode: '00',
          displayMessage: 'MOCK: Tap to Pay sale approved',
          lastFour: '1111',
          cardType: 'VISA',
        ),
      ));
      _emit(const TapToPayClosed());
    });
  }

  @override
  Future<void> invalidateSession() async {
    _timers
      ..forEach((t) {
        if (t.isActive) t.cancel();
      })
      ..clear();
  }

  void _later(Duration delay, [void Function()? action]) {
    _timers.add(Timer(delay, action ?? () {}));
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _events.close();
  }
}
