import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'xplorpay_event.dart';

/// Platform interface for the Xplor Pay (Clearent) mobile EMV flow.
///
/// Implemented by [XplorPayService] (real, iOS via XplorPayPlugin.m) and
/// [MockXplorPayService] (no hardware; used on simulators, Android and tests).
abstract class XplorPayPlatform {
  /// Reader + transaction feedback and results.
  Stream<XplorPayEvent> get events;

  /// True when this device/platform can talk to the reader.
  bool get isSupported;

  /// Configure the SDK. Must be called before connecting.
  ///
  /// [publicKey] is the Xplor Pay public key, [baseUrl] the gateway
  /// environment (e.g. https://gateway.clearent.net).
  Future<void> initialize({required String publicKey, required String baseUrl});

  /// Start a Bluetooth scan and connect to the first reader found.
  Future<void> connectReader();

  /// Start a card-present sale. The token arrives via [events] once the card
  /// has been read and secured.
  Future<void> startTransaction({
    required double amount,
    int timeoutSeconds = 10,
  });

  /// Cancel a pending card read.
  Future<void> cancelTransaction();

  /// Drop the Bluetooth connection.
  Future<void> disconnectReader();

  /// Tokenize a manually typed card (fallback when the reader cannot read).
  Future<void> startManualEntry({
    required String card,
    required String csc,
    required String expirationDateMMYY,
    String? softwareType,
    String? softwareTypeVersion,
  });

  void dispose();
}

class XplorPayException implements Exception {
  final String code;
  final String message;

  const XplorPayException(this.code, this.message);

  @override
  String toString() => 'XplorPayException($code): $message';
}

/// Real implementation backed by MethodChannel "xplorpay/methods" and
/// EventChannel "xplorpay/events" (native handlers in XplorPayPlugin.m).
class XplorPayService implements XplorPayPlatform {
  static const _methodChannel = MethodChannel('xplorpay/methods');
  static const _eventChannel = EventChannel('xplorpay/events');

  StreamController<XplorPayEvent>? _events;
  bool _initialized = false;

  @override
  bool get isSupported => Platform.isIOS;

  @override
  Stream<XplorPayEvent> get events {
    _events ??= _listen();
    return _events!.stream;
  }

  StreamController<XplorPayEvent> _listen() {
    final controller = StreamController<XplorPayEvent>.broadcast();
    controller.onListen = () {
      _eventChannel.receiveBroadcastStream().listen(
        (data) {
          if (data is Map) {
            controller.add(eventFromMap(Map<Object?, Object?>.from(data)));
          }
        },
        onError: (Object error) {
          controller.add(XplorPayError(error.toString()));
        },
        cancelOnError: false,
      );
    };
    return controller;
  }

  Future<T> _invoke<T>(String method, [Map<String, Object?>? args]) async {
    if (!isSupported) {
      throw const XplorPayException(
        'UNSUPPORTED_PLATFORM',
        'Xplor Pay card reader requires iOS. Android support is not implemented yet.',
      );
    }
    try {
      final result = await _methodChannel.invokeMethod<T>(method, args);
      return result as T;
    } on PlatformException catch (e) {
      throw XplorPayException(e.code, e.message ?? e.code);
    }
  }

  @override
  Future<void> initialize({
    required String publicKey,
    required String baseUrl,
  }) async {
    await _invoke<void>('initialize', {
      'publicKey': publicKey,
      'baseUrl': baseUrl,
    });
    _initialized = true;
  }

  @override
  Future<void> connectReader() async {
    if (!_initialized) {
      throw const XplorPayException(
        'NOT_INITIALIZED',
        'Call initialize() before connectReader()',
      );
    }
    await _invoke<void>('connectReader');
  }

  @override
  Future<void> startTransaction({
    required double amount,
    int timeoutSeconds = 10,
  }) async {
    if (!_initialized) {
      throw const XplorPayException(
        'NOT_INITIALIZED',
        'Call initialize() before startTransaction()',
      );
    }
    await _invoke<void>('startTransaction', {
      'amount': amount,
      'timeout': timeoutSeconds,
    });
  }

  @override
  Future<void> cancelTransaction() => _invoke<void>('cancelTransaction');

  @override
  Future<void> disconnectReader() => _invoke<void>('disconnectReader');

  @override
  Future<void> startManualEntry({
    required String card,
    required String csc,
    required String expirationDateMMYY,
    String? softwareType,
    String? softwareTypeVersion,
  }) {
    return _invoke<void>('startManualEntry', {
      'card': card,
      'csc': csc,
      'expirationDateMMYY': expirationDateMMYY,
      'softwareType': ?softwareType,
      'softwareTypeVersion': ?softwareTypeVersion,
    });
  }

  @override
  void dispose() {
    _events?.close();
    _events = null;
    _initialized = false;
  }
}

/// Hardware-free implementation with the same contract so the UI can be
/// developed on the simulator, on Android, and in tests. Runs a scripted
/// connect -> insert card -> secured -> token sequence per sale.
class MockXplorPayService implements XplorPayPlatform {
  final StreamController<XplorPayEvent> _events =
      StreamController<XplorPayEvent>.broadcast();
  final List<Timer> _timers = [];
  bool _transactionRunning = false;

  @override
  bool get isSupported => true; // mock supports every platform by design

  @override
  Stream<XplorPayEvent> get events => _events.stream;

  void _emit(XplorPayEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  void _later(Duration delay, void Function() action) {
    _timers.add(Timer(delay, action));
  }

  @override
  Future<void> initialize({
    required String publicKey,
    required String baseUrl,
  }) async {
    debugAssertMock(publicKey, baseUrl);
    _later(const Duration(milliseconds: 200),
        () => _emit(const XplorPayFeedback(message: 'MOCK: SDK initialized', feedbackType: XplorPayFeedbackType.info, returnCode: 0)));
  }

  @override
  Future<void> connectReader() async {
    _later(const Duration(milliseconds: 300), () {
      _emit(const XplorPayFeedback(
          message: 'SEARCHING FOR POWERED ON BLUETOOTH READERS',
          feedbackType: XplorPayFeedbackType.info,
          returnCode: 0));
    });
    _later(const Duration(milliseconds: 1500), () {
      _emit(const XplorPayConnected());
      _emit(const XplorPayBluetoothDevices([
        XplorPayBluetoothDevice(
            friendlyName: 'IDTECH-VP3300-MOCK',
            deviceId: 'AA:BB:CC:DD:EE:FF',
            connected: true),
      ]));
    });
  }

  @override
  Future<void> startTransaction({
    required double amount,
    int timeoutSeconds = 10,
  }) async {
    if (_transactionRunning) {
      throw const XplorPayException('TRANSACTION_IN_PROGRESS', 'A transaction is already running');
    }
    if (amount <= 0) {
      throw const XplorPayException('INVALID_ARGUMENTS', 'amount must be greater than zero');
    }
    _transactionRunning = true;
    _later(const Duration(milliseconds: 200), () {
      _emit(const XplorPayFeedback(
          message: 'TRANSACTION STARTED', feedbackType: XplorPayFeedbackType.info, returnCode: 0));
      _emit(const XplorPayFeedback(
          message: 'PLEASE SWIPE, TAP, OR INSERT', feedbackType: XplorPayFeedbackType.userAction, returnCode: 0));
    });
    _later(const Duration(milliseconds: 1200), () {
      _emit(const XplorPayFeedback(
          message: 'CARD INSERTED', feedbackType: XplorPayFeedbackType.userAction, returnCode: 0));
    });
    _later(const Duration(milliseconds: 2500), () {
      _emit(const XplorPayFeedback(
          message: 'CARD READ OK, REMOVE CARD', feedbackType: XplorPayFeedbackType.userAction, returnCode: 0));
      _emit(const XplorPayFeedback(
          message: 'CARD SECURED', feedbackType: XplorPayFeedbackType.info, returnCode: 0));
      _emit(const XplorPayToken(
        jwt: 'mock-jwt-not-a-real-token',
        cvm: 'OFC',
        lastFour: '1111',
        cardType: 'VISA',
      ));
      _transactionRunning = false;
    });
  }

  @override
  Future<void> cancelTransaction() async {
    _timers
      ..forEach((t) {
        if (t.isActive) t.cancel();
      })
      ..clear();
    _transactionRunning = false;
    _emit(const XplorPayFeedback(
        message: 'TRANSACTION TERMINATED', feedbackType: XplorPayFeedbackType.info, returnCode: 0));
  }

  @override
  Future<void> disconnectReader() async {
    _emit(const XplorPayDisconnected());
  }

  @override
  Future<void> startManualEntry({
    required String card,
    required String csc,
    required String expirationDateMMYY,
    String? softwareType,
    String? softwareTypeVersion,
  }) async {
    _later(const Duration(milliseconds: 800), () {
      _emit(XplorPayToken(
        jwt: 'mock-jwt-not-a-real-token',
        cvm: 'NON',
        lastFour: card.length >= 4 ? card.substring(card.length - 4) : '0000',
        cardType: 'VISA',
      ));
    });
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _events.close();
  }

  /// Kept so tests/dev runs can assert the operator supplied values instead of
  /// silently running against production credentials.
  static void debugAssertMock(String publicKey, String baseUrl) {
    assert(() {
      debugPrint('MockXplorPayService.initialize(baseUrl: $baseUrl, '
          'publicKey: ${publicKey.isEmpty ? '<empty>' : '<set>'})');
      return true;
    }());
  }
}
