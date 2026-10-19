import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/xplorpay/xplorpay_api_client.dart';
import '../../../services/xplorpay/xplorpay_credentials.dart';
import '../../../services/xplorpay/xplorpay_event.dart';
import '../../../services/xplorpay/xplorpay_models.dart';
import '../../../services/xplorpay/xplorpay_service.dart';
import '../invoice_payment_recorder.dart';

/// Gateway environments (docs.xplorpay.com):
/// prod https://gateway.clearent.net / sandbox https://gateway-int.clearent.net
enum XplorPayEnv {
  production('https://gateway.clearent.net', 'Production'),
  sandbox('https://gateway-int.clearent.net', 'Sandbox (INT)');

  const XplorPayEnv(this.baseUrl, this.label);
  final String baseUrl;
  final String label;
}

/// Reader connection state on the terminal screen.
enum XplorPayReaderState { disconnected, searching, connected }

/// End-to-end transaction states.
enum XplorPayTxnState {
  idle,
  waitingForCard,
  processing,
  submitting,
  approved,
  declined,
  error,
}

/// GetX controller for the Xplor Pay card-reader terminal screen.
///
/// SECURITY: credentials are loaded from runtime config (SharedPreferences),
/// never hardcoded. The JWT is forwarded once and never logged.
class XplorPayTerminalController extends GetxController {
  static const _prefPrefix = 'xplorpay_';

  late XplorPayPlatform _reader;
  StreamSubscription<XplorPayEvent>? _sub;

  // ---- configuration (credentials are static; env stays user-selectable) ----
  final env = XplorPayEnv.production.obs;
  final publicKey = XplorPayCredentials.publicKey.obs;
  final apiKey = XplorPayCredentials.apiKey.obs;

  // ---- live state ----
  final readerState = XplorPayReaderState.disconnected.obs;
  final txnState = XplorPayTxnState.idle.obs;
  final feedback = ''.obs;
  final statusMessage = ''.obs;
  final lastResult = Rxn<XplorPayTransactionResult>();
  final lastCard = Rxn<XplorPayToken>();
  final busy = false.obs;

  // ---- editable gateway config (seeded from prefs in _loadConfig) ----
  // Credentials are static now; no on-screen entry, no input controllers.

  // ---- manual entry form ----
  final manualCard = TextEditingController();
  final manualCsc = TextEditingController();
  final manualExp = TextEditingController();

  /// JWT from the last successful card read, awaiting gateway submission.
  String? _pendingJwt;

  /// Invoice context when launched from the payment method selection screen;
  /// sent as the gateway `invoice` field.
  String? invoiceId;

  /// Amount of the transaction currently running (gateway needs the same
  /// total the reader captured).
  double? _lastChargeAmount;

  /// Rebuild the platform implementation: mock everywhere except real iOS.
  XplorPayPlatform _createReader() {
    if (Platform.isIOS) return XplorPayService();
    return MockXplorPayService();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      invoiceId = args['invoiceId']?.toString();
    }
    _reader = _createReader();
    _sub = _reader.events.listen(_onEvent);
    _loadConfig();
  }

  @override
  void onClose() {
    _sub?.cancel();
    _reader.dispose();
    manualCard.dispose();
    manualCsc.dispose();
    manualExp.dispose();
    super.onClose();
  }

  // ---- configuration ----

  /// Credentials are static (XplorPayCredentials); only the environment
  /// preference persists.
  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final envName = prefs.getString('${_prefPrefix}env');
    if (envName != null) {
      env.value = XplorPayEnv.values
          .firstWhere((e) => e.name == envName, orElse: () => XplorPayEnv.production);
    }
  }

  /// Persists the selected gateway environment.
  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefPrefix}env', env.value.name);
  }

  // ---- event handling ----

  void _onEvent(XplorPayEvent event) {
    switch (event) {
      case XplorPayConnected():
        readerState.value = XplorPayReaderState.connected;
        statusMessage.value = 'Reader connected';
        break;
      case XplorPayDisconnected():
        readerState.value = XplorPayReaderState.disconnected;
        if (txnState.value == XplorPayTxnState.waitingForCard) {
          txnState.value = XplorPayTxnState.idle;
          statusMessage.value = 'Reader disconnected mid-transaction';
        }
        break;
      case XplorPayFeedback f:
        feedback.value = f.message;
        break;
      case XplorPayToken t:
        _pendingJwt = t.jwt;
        lastCard.value = t;
        txnState.value = XplorPayTxnState.submitting;
        _submitPendingJwt();
        break;
      case XplorPayBluetoothDevices():
        break; // diagnostics only
      case XplorPayError e:
        txnState.value = XplorPayTxnState.error;
        statusMessage.value = e.message;
        break;
    }
  }

  // ---- actions ----

  /// initialize + connectReader, guarded against double-taps.
  Future<void> connect() async {
    if (busy.value) return;
    busy.value = true;
    readerState.value = XplorPayReaderState.searching;
    statusMessage.value = 'Searching for reader...';
    try {
      await _reader.initialize(publicKey: publicKey.value, baseUrl: env.value.baseUrl);
      await _reader.connectReader();
      // deviceConnected event flips readerState; timeout guard below.
      Timer(const Duration(seconds: 20), () {
        if (readerState.value == XplorPayReaderState.searching) {
          readerState.value = XplorPayReaderState.disconnected;
          statusMessage.value = 'No reader found within 20s. Is Bluetooth on and the reader powered?';
        }
      });
    } on XplorPayException catch (e) {
      readerState.value = XplorPayReaderState.disconnected;
      statusMessage.value = '${e.code}: ${e.message}';
    } finally {
      busy.value = false;
    }
  }

  /// Starts the card read. The gateway call happens automatically once the
  /// reader returns the JWT (token event → _submitPendingJwt).
  Future<void> charge(double amount) async {
    if (busy.value) return;
    if (readerState.value != XplorPayReaderState.connected) {
      statusMessage.value = 'Connect the reader first';
      return;
    }
    busy.value = true;
    lastResult.value = null;
    lastCard.value = null;
    _pendingJwt = null;
    _lastChargeAmount = amount;
    txnState.value = XplorPayTxnState.waitingForCard;
    statusMessage.value = 'Insert, tap or swipe the card';
    try {
      await _reader.startTransaction(amount: amount);
    } on XplorPayException catch (e) {
      txnState.value = XplorPayTxnState.error;
      statusMessage.value = '${e.code}: ${e.message}';
    } finally {
      busy.value = false;
    }
  }

  Future<void> cancel() async {
    try {
      await _reader.cancelTransaction();
    } on XplorPayException catch (e) {
      statusMessage.value = '${e.code}: ${e.message}';
    }
    if (txnState.value == XplorPayTxnState.waitingForCard) {
      txnState.value = XplorPayTxnState.idle;
      statusMessage.value = 'Transaction cancelled';
    }
  }

  Future<void> disconnect() async {
    try {
      await _reader.disconnectReader();
    } on XplorPayException catch (e) {
      statusMessage.value = '${e.code}: ${e.message}';
    }
  }

  /// Manual entry fallback: tokenize a typed card number.
  Future<void> submitManualEntry() async {
    final card = manualCard.text.replaceAll(' ', '');
    final csc = manualCsc.text.trim();
    final exp = manualExp.text.trim();
    if (card.length < 12 || csc.length < 3 || exp.length != 4) {
      statusMessage.value = 'Card number, CSC and MMYY expiration are required';
      return;
    }
    busy.value = true;
    try {
      final identity = await XplorPayApiClient.softwareIdentity();
      await _reader.startManualEntry(
        card: card,
        csc: csc,
        expirationDateMMYY: exp,
        softwareType: identity.$1,
        softwareTypeVersion: identity.$2,
      );
      txnState.value = XplorPayTxnState.waitingForCard;
      statusMessage.value = 'Tokenizing manually entered card...';
    } on XplorPayException catch (e) {
      txnState.value = XplorPayTxnState.error;
      statusMessage.value = '${e.code}: ${e.message}';
    } finally {
      busy.value = false;
    }
  }

  /// Submits the reader JWT to the gateway (or a backend that proxies it).
  Future<void> _submitPendingJwt() async {
    final jwt = _pendingJwt;
    if (jwt == null) return;
    _pendingJwt = null;
    try {
      final identity = await XplorPayApiClient.softwareIdentity();
      final request = MobileSaleRequest(
        amount: _formatAmount(),
        softwareType: identity.$1,
        softwareTypeVersion: identity.$2,
        invoice: invoiceId,
      );
      final client = XplorPayApiClient();
      final result = await client.submitSaleJwt(
        baseUrl: env.value.baseUrl,
        apiKey: apiKey.value,
        mobileJwt: jwt,
        request: request,
      );
      lastResult.value = result;
      txnState.value = result.approved
          ? XplorPayTxnState.approved
          : (result.result?.toUpperCase() == 'DECLINED'
              ? XplorPayTxnState.declined
              : XplorPayTxnState.error);
      statusMessage.value = result.displayMessage ?? result.result ?? 'Done';
      if (result.approved) {
        await _recordInvoicePayment();
      }
    } on XplorPayApiException catch (e) {
      txnState.value = XplorPayTxnState.error;
      statusMessage.value = e.message;
    } catch (e) {
      txnState.value = XplorPayTxnState.error;
      statusMessage.value = 'Gateway submission failed: $e';
    }
  }

  String _formatAmount() {
    // The reader transaction amount is in the lastResult flow; the gateway
    // expects the same total as a string ("10.00").
    final v = _lastChargeAmount;
    if (v == null) return '0.00';
    return v.toStringAsFixed(2);
  }

  /// Records an approved sale against the invoice context (parity with the
  /// cash/check flow). On success this navigates back to the refreshed
  /// invoice detail, which disposes this screen; on failure the result stays
  /// on screen with the reason.
  Future<void> _recordInvoicePayment() async {
    try {
      await recordApprovedCardPayment(
        invoiceId: invoiceId,
        amount: _lastChargeAmount ?? 0.0,
      );
    } catch (e) {
      statusMessage.value = 'Approved — recording payment failed: $e';
    }
  }

  /// Resets the result view for the next sale.
  void resetResult() {
    lastResult.value = null;
    lastCard.value = null;
    _pendingJwt = null;
    txnState.value = XplorPayTxnState.idle;
    statusMessage.value = '';
    feedback.value = '';
  }
}
