import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Flutter-side bridge for Xplor Pay "Tap to Pay on iPhone" (Apple
/// ProximityReader). Native handlers live in
/// `ios/Runner/XplorPayTapToPayPlugin.swift`; channel names must stay identical
/// to the standalone `xplor_pay_tap_to_pay` package.
class XplorPayTapToPayService {
  static const _methodChannel =
      MethodChannel('com.xceleran.tapToPay/tap_to_pay');
  static const _eventChannel =
      EventChannel('com.xceleran.tapToPay/tap_to_pay/events');

  StreamController<XplorPayTapToPayEvent>? _events;

  bool get isPlatformSupported => !kIsWeb && Platform.isIOS;

  /// Lifecycle + transaction events from the native SDK.
  Stream<XplorPayTapToPayEvent> get events {
    _events ??= _listen();
    return _events!.stream;
  }

  StreamController<XplorPayTapToPayEvent> _listen() {
    final controller = StreamController<XplorPayTapToPayEvent>.broadcast();
    controller.onListen = () {
      if (!isPlatformSupported) return;
      _eventChannel.receiveBroadcastStream().listen(
        (data) {
          if (data is Map) {
            controller.add(
                XplorPayTapToPayEvent.fromMap(Map<Object?, Object?>.from(data)));
          }
        },
        onError: (Object error) {
          controller.add(XplorPayTapToPayUnknownEvent(
              name: 'stream_error', payload: {'error': error.toString()}));
        },
        cancelOnError: false,
      );
    };
    return controller;
  }

  Future<T> _invoke<T>(String method, [Map<String, Object?>? args]) async {
    if (!isPlatformSupported) {
      throw const XplorPayTapToPayException(
        code: 'UNSUPPORTED_PLATFORM',
        message: 'Tap to Pay on iPhone is only available on iOS devices.',
      );
    }
    try {
      final result = await _methodChannel.invokeMethod<T>(method, args);
      return result as T;
    } on PlatformException catch (e) {
      throw XplorPayTapToPayException(
        code: e.code,
        message: e.message ?? e.code,
        details: e.details,
      );
    }
  }

  /// Hardware-only check (safe to call before initialize).
  Future<bool> isSupported() async {
    if (!isPlatformSupported) return false;
    try {
      return await _invoke<bool>('isSupported');
    } on XplorPayTapToPayException {
      return false;
    }
  }

  /// Hardware + entitlement check. Call after initialize — the SDK traps if
  /// the completion variant runs before initialization (see plugin notes).
  Future<XplorPayTapToPaySupport> verifySupport() async {
    if (!isPlatformSupported) {
      return const XplorPayTapToPaySupport(
          isSupported: false, errorMessage: 'Tap to Pay on iPhone requires iOS.');
    }
    final map = await _invoke<Map<Object?, Object?>>('verifySupport');
    return XplorPayTapToPaySupport(
      isSupported: map['isSupported'] == true,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  Future<void> initialize({
    required String apiKey,
    required bool isSandbox,
    String? publicKey,
    String? baseUrl,
  }) async {
    final effectiveBaseUrl = baseUrl ??
        (isSandbox
            ? 'https://gateway-int.clearent.net'
            : 'https://gateway.clearent.net');
    await _invoke<bool>('initialize', {
      'apiKey': apiKey,
      'baseUrl': effectiveBaseUrl,
      'publicKey': publicKey,
      'softwareType': 'XinatorBMSFieldAgentPro',
      'softwareTypeVersion': '1.0.0',
    });
  }

  /// Presents Apple's tap sheet and processes the sale. Resolves exactly once
  /// with the verdict (approved/declined/cancelled/error/unknown) after the
  /// SDK UI is dismissed — the completion alone never indicates sale success.
  Future<XplorPayTapToPayResult> processPayment({
    required double amount,
    String currencyCode = 'USD',
    String? invoiceNumber,
    String? orderId,
    String? customerId,
  }) async {
    final raw = await _invoke<Map<Object?, Object?>>('processPayment', {
      'amount': amount,
      'currencyCode': currencyCode,
      'invoice': invoiceNumber,
      'orderId': orderId,
      'customerId': customerId,
    });
    return XplorPayTapToPayResult.fromMap(raw);
  }

  /// Pre-warms the reader session. Safe to call repeatedly; pass
  /// [forceRefreshToken] only after a terminal-profile change.
  Future<void> prepare({
    required double amount,
    bool forceRefreshToken = false,
  }) {
    return _invoke<bool>('prepare', {
      'amount': amount,
      'forceRefreshToken': forceRefreshToken,
    });
  }

  Future<bool> isAccountLinked() async {
    if (!isPlatformSupported) return false;
    return _invoke<bool>('isAccountLinked');
  }

  Future<void> linkAccount() => _invoke<bool>('linkAccount');

  /// Cancels in-flight preparation and clears the cached JWT. Never call after
  /// a successful sale.
  Future<void> invalidateSession() => _invoke<bool>('invalidateSession');

  void dispose() {
    _events?.close();
    _events = null;
  }
}

// ---------------- models ----------------

/// Hardware + entitlement verification result.
class XplorPayTapToPaySupport {
  final bool isSupported;
  final String? errorMessage;

  const XplorPayTapToPaySupport({required this.isSupported, this.errorMessage});
}

enum XplorPayTapToPayStatus { approved, declined, cancelled, error }

XplorPayTapToPayStatus _statusFrom(String? status) {
  switch (status?.toLowerCase()) {
    case 'approved':
    case 'success':
      return XplorPayTapToPayStatus.approved;
    case 'declined':
      return XplorPayTapToPayStatus.declined;
    case 'cancelled':
    case 'canceled':
      return XplorPayTapToPayStatus.cancelled;
    default:
      // 'unknown' is an ambiguous SDK outcome: reconcile with the gateway,
      // never retry blindly.
      return XplorPayTapToPayStatus.error;
  }
}

/// Verdict of a Tap to Pay sale (from processPayment or the event stream).
class XplorPayTapToPayResult {
  final XplorPayTapToPayStatus status;
  final String? transactionId;
  final String? authCode;
  final String? errorMessage;
  final Map<String, dynamic>? rawResponse;

  const XplorPayTapToPayResult({
    required this.status,
    this.transactionId,
    this.authCode,
    this.errorMessage,
    this.rawResponse,
  });

  bool get isApproved => status == XplorPayTapToPayStatus.approved;
  bool get isDeclined => status == XplorPayTapToPayStatus.declined;
  bool get isCancelled => status == XplorPayTapToPayStatus.cancelled;

  factory XplorPayTapToPayResult.fromMap(Map<Object?, Object?> map) {
    final statusStr = map['status']?.toString() ?? 'error';
    final raw = map['rawResponse'];
    return XplorPayTapToPayResult(
      status: _statusFrom(statusStr),
      transactionId: map['transactionId'] as String? ??
          map['id'] as String? ??
          map['transaction-id'] as String?,
      authCode: map['authCode'] as String? ??
          map['authorization-code'] as String? ??
          map['auth-code'] as String?,
      errorMessage: map['errorMessage'] as String? ??
          map['display-message'] as String?,
      rawResponse: raw is Map ? Map<String, dynamic>.from(raw) : null,
    );
  }
}

// ---------------- events ----------------

sealed class XplorPayTapToPayEvent {
  const XplorPayTapToPayEvent();

  factory XplorPayTapToPayEvent.fromMap(Map<Object?, Object?> map) {
    switch (map['event']?.toString()) {
      case 'closed':
        return XplorPayTapToPayClosed(error: map['error'] as String?);
      case 'transaction':
        final result = map['result'] is Map
            ? XplorPayTapToPayResult.fromMap(
                Map<Object?, Object?>.from(map['result'] as Map))
            : null;
        return XplorPayTapToPayTransaction(result: result);
      default:
        return XplorPayTapToPayUnknownEvent(
            name: map['event']?.toString() ?? 'unknown', payload: map);
    }
  }
}

/// Apple's tap sheet was dismissed (Done or Cancel). Never a sale verdict.
class XplorPayTapToPayClosed extends XplorPayTapToPayEvent {
  final String? error;
  const XplorPayTapToPayClosed({this.error});
}

/// A transaction verdict arrived from the SDK delegate.
class XplorPayTapToPayTransaction extends XplorPayTapToPayEvent {
  final XplorPayTapToPayResult? result;
  const XplorPayTapToPayTransaction({this.result});

  bool get isApproved => result?.isApproved ?? false;
}

class XplorPayTapToPayUnknownEvent extends XplorPayTapToPayEvent {
  final String name;
  final Map<Object?, Object?> payload;
  const XplorPayTapToPayUnknownEvent({required this.name, required this.payload});
}

// ---------------- exception ----------------

class XplorPayTapToPayException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  const XplorPayTapToPayException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() {
    // The native plugin encodes the underlying ClearentError into
    // details["gateway"]; surface it — the raw code alone is too generic
    // (e.g. missingData = the gateway session-token call returned no token).
    final gateway = details is Map ? details['gateway'] : null;
    if (gateway is String && gateway.isNotEmpty) {
      return '$message — gateway: $gateway';
    }
    return message;
  }
}
