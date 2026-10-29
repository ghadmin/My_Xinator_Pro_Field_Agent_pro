import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/xplorpay/xplorpay_credentials.dart';
import '../../../services/xplorpay/xplorpay_tap_to_pay_service.dart';
import '../invoice_payment_recorder.dart';

/// Stages of the Tap to Pay readiness flow on this screen.
enum XplorPayTapToPayStage {
  checking, // initialize/verify running
  unsupported, // hardware/OS/entitlement says no
  needsLink, // merchant has not accepted Apple's terms yet
  preparing, // pre-warming the reader session
  ready, // ready to accept a tap
}

/// End-to-end transaction states.
enum XplorPayTapToPayTxnState { idle, processing, approved, declined, cancelled, error }

/// GetX controller for the Tap to Pay on iPhone screen.
///
/// Credentials/environment are shared with the card-reader terminal screen
/// (same `xplorpay_*` SharedPreferences keys). SECURITY: the API key lives in
/// on-device prefs only; move to a backend-issued token before production.
class XplorPayTapToPayController extends GetxController {
  static const _prefPrefix = 'xplorpay_';

  final _service = XplorPayTapToPayService();
  StreamSubscription<XplorPayTapToPayEvent>? _sub;

  // ---- route context ----
  /// Invoice the payment flow started from (null/empty = standalone use).
  String? invoiceId;

  // ---- configuration ----
  // Credentials are compiled in (XplorPayCredentials — user decision
  // 2026-10-29, sandbox INT gateway); only the environment is selectable.
  final isSandbox = true.obs;
  String get apiKey => XplorPayCredentials.apiKey;

  // ---- live state ----
  final stage = XplorPayTapToPayStage.checking.obs;
  final txnState = XplorPayTapToPayTxnState.idle.obs;
  final statusMessage = ''.obs;
  final supportMessage = ''.obs;
  final amountInput = TextEditingController();
  final busy = false.obs;

  /// Amount of the sale in flight (the recorder needs the charged total).
  double? _lastChargeAmount;
  bool _saleApproved = false;

  double get amount => double.tryParse(amountInput.text.trim()) ?? 0.0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final a = args['amount'];
      final parsed = a is num ? a.toStringAsFixed(2) : double.tryParse('$a')?.toStringAsFixed(2);
      amountInput.text = parsed ?? '';
      final id = args['invoiceId'];
      invoiceId = (id == null || '$id'.isEmpty) ? null : '$id';
    }
    _sub = _service.events.listen(_onEvent);
    _loadConfigAndStart();
  }

  @override
  void onClose() {
    _sub?.cancel();
    // A stale warm session is only dropped when the flow did NOT end in an
    // approved sale (invalidateTapToPaySession must not run after a success).
    if (!_saleApproved) {
      _service.invalidateSession().catchError((_) {});
    }
    _service.dispose();
    amountInput.dispose();
    super.onClose();
  }

  // ---------------- setup ----------------

  /// Loads the persisted environment choice and starts the readiness flow.
  /// The API key always comes from [XplorPayCredentials] — nothing to type.
  Future<void> _loadConfigAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final envName = prefs.getString('${_prefPrefix}env');
    isSandbox.value = envName != 'production';

    if (!Platform.isIOS) {
      stage.value = XplorPayTapToPayStage.unsupported;
      supportMessage.value = 'Tap to Pay on iPhone is only available on iOS.';
      return;
    }
    await startFlow();
  }

  /// Persists the selected environment, then (re)starts the readiness flow.
  Future<void> saveEnv() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefPrefix}env', isSandbox.value ? 'sandbox' : 'production');
    await startFlow();
  }

  /// initialize → verify support → terms link → pre-warm, in that order:
  /// the completion-based support check crashes if run before initialize.
  Future<void> startFlow() async {
    if (busy.value) return;
    busy.value = true;
    stage.value = XplorPayTapToPayStage.checking;
    supportMessage.value = '';
    try {
      await _service.initialize(apiKey: apiKey, isSandbox: isSandbox.value);

      // Hardware-only check first so unsupported devices bail out fast.
      if (!await _service.isSupported()) {
        stage.value = XplorPayTapToPayStage.unsupported;
        supportMessage.value = 'Tap to Pay is not available on this device.';
        return;
      }
      final support = await _service.verifySupport();
      if (!support.isSupported) {
        stage.value = XplorPayTapToPayStage.unsupported;
        supportMessage.value =
            support.errorMessage ?? 'Tap to Pay is unavailable on this device.';
        return;
      }
      if (!await _service.isAccountLinked()) {
        stage.value = XplorPayTapToPayStage.needsLink;
        supportMessage.value = 'Accept Apple\'s Tap to Pay terms to continue.';
        return;
      }
      await _prepare();
    } on XplorPayTapToPayException catch (e) {
      stage.value = XplorPayTapToPayStage.unsupported;
      supportMessage.value = e.toString();
    } finally {
      busy.value = false;
    }
  }

  /// Presents Apple's terms sheet. Linking auto-starts reader preparation.
  Future<void> linkAccount() async {
    if (busy.value) return;
    busy.value = true;
    try {
      await _service.linkAccount();
      statusMessage.value = 'Terms accepted';
      await _prepare();
    } on XplorPayTapToPayException catch (e) {
      statusMessage.value = 'Account linking failed: $e';
    } finally {
      busy.value = false;
    }
  }

  Future<void> _prepare() async {
    stage.value = XplorPayTapToPayStage.preparing;
    statusMessage.value = 'Preparing Tap to Pay...';
    try {
      await _service.prepare(amount: amount <= 0 ? 1.00 : amount);
      stage.value = XplorPayTapToPayStage.ready;
      statusMessage.value = 'Ready — enter the amount and charge';
    } on XplorPayTapToPayException catch (e) {
      stage.value = XplorPayTapToPayStage.unsupported;
      supportMessage.value = 'Tap to Pay could not start: $e';
    }
  }

  // ---------------- sale ----------------

  /// Runs the contactless sale. The verdict resolves once the SDK UI closes;
  /// approved sales are recorded against the invoice and the flow unwinds.
  Future<void> pay() async {
    if (busy.value) return;
    if (stage.value != XplorPayTapToPayStage.ready) {
      statusMessage.value = 'Tap to Pay is not ready yet';
      return;
    }
    final charge = amount;
    if (charge <= 0) {
      statusMessage.value = 'Enter an amount greater than zero';
      return;
    }
    busy.value = true;
    _lastChargeAmount = charge;
    txnState.value = XplorPayTapToPayTxnState.processing;
    statusMessage.value = 'Hold the card near the top of the iPhone...';
    try {
      final result = await _service.processPayment(
        amount: charge,
        invoiceNumber: invoiceId,
        orderId: invoiceId,
      );
      switch (result.status) {
        case XplorPayTapToPayStatus.approved:
          _saleApproved = true;
          txnState.value = XplorPayTapToPayTxnState.approved;
          statusMessage.value =
              'Approved${result.authCode != null ? ' (auth ${result.authCode})' : ''}';
          await InvoicePaymentRecorder.recordApprovedCardPayment(
            amount: _lastChargeAmount ?? charge,
            invoiceId: invoiceId,
          );
          break;
        case XplorPayTapToPayStatus.declined:
          txnState.value = XplorPayTapToPayTxnState.declined;
          statusMessage.value = result.errorMessage ?? 'Payment declined';
          break;
        case XplorPayTapToPayStatus.cancelled:
          txnState.value = XplorPayTapToPayTxnState.cancelled;
          statusMessage.value = 'Payment cancelled';
          break;
        case XplorPayTapToPayStatus.error:
          txnState.value = XplorPayTapToPayTxnState.error;
          statusMessage.value = result.errorMessage ?? 'Payment failed';
          break;
      }
    } on XplorPayTapToPayException catch (e) {
      txnState.value = XplorPayTapToPayTxnState.error;
      statusMessage.value = e.toString();
    } finally {
      busy.value = false;
    }
  }

  void _onEvent(XplorPayTapToPayEvent event) {
    switch (event) {
      case XplorPayTapToPayTransaction t:
        // Live mirror of the verdict; the authoritative handling happens on
        // the processPayment future in pay().
        final status = t.result?.status;
        if (status != null && txnState.value == XplorPayTapToPayTxnState.processing) {
          statusMessage.value = t.result?.errorMessage ?? statusMessage.value;
        }
        break;
      case XplorPayTapToPayClosed():
        break; // UI dismissal — never a verdict
      case XplorPayTapToPayUnknownEvent():
        break;
    }
  }

  /// Resets the result view for the next sale.
  void resetResult() {
    txnState.value = XplorPayTapToPayTxnState.idle;
    statusMessage.value = stage.value == XplorPayTapToPayStage.ready
        ? 'Ready — enter the amount and charge'
        : '';
  }
}
