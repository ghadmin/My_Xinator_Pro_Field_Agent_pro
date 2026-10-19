import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/xplorpay/xplorpay_api_client.dart';
import '../../../services/xplorpay/xplorpay_credentials.dart';
import '../../../services/xplorpay/xplorpay_models.dart';
import '../../../services/xplorpay/xplorpay_tap_to_pay_service.dart';
import 'xplorpay_terminal_controller.dart' show XplorPayEnv;
import '../invoice_payment_recorder.dart';

/// Reader/SDK states for the Tap to Pay screen.
enum XplorPayTapToPayState { unsupported, idle, ready, approved, error }

/// GetX controller for the Tap to Pay on iPhone screen.
class XplorPayTapToPayController extends GetxController {
  static const _prefPrefix = 'xplorpay_';

  late final XplorPayTapToPayPlatform _impl;
  StreamSubscription<TapToPayEvent>? _sub;

  /// Invoice context when launched from the payment method selection screen.
  String? invoiceId;

  /// Amount passed to the last [pay] call — the total a successful sale is
  /// recorded for against the invoice.
  double? _lastChargeAmount;

  // ---- configuration (credentials are static; env stays user-selectable) ----
  final env = XplorPayEnv.production.obs;
  final publicKey = XplorPayCredentials.publicKey.obs;
  final apiKey = XplorPayCredentials.apiKey.obs;

  final support = Rxn<TapToPaySupportResult>();
  final prepared = false.obs;
  final accountLinked = false.obs;
  final busy = false.obs;
  final statusMessage = ''.obs;
  final lastResult = Rxn<XplorPayTransactionResult>();
  final lastError = ''.obs;
  final txnState = XplorPayTapToPayState.idle.obs;

  XplorPayTapToPayPlatform _createImpl() {
    if (Platform.isIOS) return XplorPayTapToPayService();
    return MockXplorPayTapToPayService();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      invoiceId = args['invoiceId']?.toString();
    }
    _impl = _createImpl();
    _sub = _impl.events.listen(_onEvent);
    _loadConfig();
  }

  @override
  void onClose() {
    _sub?.cancel();
    _impl.dispose();
    super.onClose();
  }

  /// Credentials are static (XplorPayCredentials); only the environment
  /// preference persists.
  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final envName = prefs.getString('${_prefPrefix}env');
    if (envName != null) {
      env.value = XplorPayEnv.values
          .firstWhere((e) => e.name == envName, orElse: () => XplorPayEnv.production);
    }
    _checkSupport();
  }

  /// Persists the selected gateway environment.
  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefPrefix}env', env.value.name);
  }

  Future<void> _checkSupport() async {
    try {
      final result = await _impl.verifySupport();
      support.value = result;
      if (!result.isSupported) {
        statusMessage.value =
            result.errorMessage ?? 'Tap to Pay is not supported on this device';
      }
      // Account-linked status is NOT refreshed here: before SDK
      // initialization (and before Apple approves the entitlement) that
      // call can trap inside the SDK. It runs in link()/prepare() after
      // initialize instead.
    } on XplorPayTapToPayException catch (e) {
      support.value = TapToPaySupportResult(
        isSupported: false,
        errorMessage: '${e.code}: ${e.message}',
      );
    }
  }

  Future<void> recheckSupport() => _checkSupport();

  Future<void> _refreshAccountLinked() async {
    try {
      accountLinked.value = await _impl.isAccountLinked();
    } on XplorPayTapToPayException {
      accountLinked.value = false;
    }
  }

  Future<XplorPayTapToPayException?> _ensureInitialized() async {
    try {
      final identity = await XplorPayApiClient.softwareIdentity();
      await _impl.initialize(
        baseUrl: env.value.baseUrl,
        apiKey: apiKey.value,
        publicKey: publicKey.value.isEmpty ? null : publicKey.value,
        softwareType: identity.$1,
        softwareTypeVersion: identity.$2,
      );
      return null;
    } on XplorPayTapToPayException catch (e) {
      return e;
    }
  }

  Future<void> prepare() async {
    if (busy.value) return;
    busy.value = true;
    try {
      final problem = await _ensureInitialized();
      if (problem != null) {
        statusMessage.value = '${problem.code}: ${problem.message}';
        return;
      }
      final identity = await XplorPayApiClient.softwareIdentity();
      await _impl.prepare(amount: 1.0, softwareType: identity.$1, softwareTypeVersion: identity.$2);
      prepared.value = true;
      statusMessage.value = 'Reader session prepared';
    } on XplorPayTapToPayException catch (e) {
      statusMessage.value = '${e.code}: ${e.message}';
    } finally {
      busy.value = false;
    }
  }

  Future<void> link() async {
    if (busy.value) return;
    busy.value = true;
    try {
      final problem = await _ensureInitialized();
      if (problem != null) {
        statusMessage.value = '${problem.code}: ${problem.message}';
        return;
      }
      await _impl.linkAccount();
      await _refreshAccountLinked();
      statusMessage.value =
          accountLinked.value ? 'Apple terms accepted' : 'Terms not accepted yet';
    } on XplorPayTapToPayException catch (e) {
      // e.g. the Proximity Reader entitlement is missing until Apple approves
      // it — surface the SDK reason on screen instead of crashing upward.
      statusMessage.value = '${e.code}: ${e.message}';
    } finally {
      busy.value = false;
    }
  }

  Future<void> pay(double amount) async {
    if (busy.value) return;
    if (support.value?.isSupported != true) {
      statusMessage.value = 'Tap to Pay is not supported on this device';
      return;
    }
    if (amount <= 0) {
      statusMessage.value = 'Enter a valid amount';
      return;
    }
    _lastChargeAmount = amount;
    busy.value = true;
    lastResult.value = null;
    lastError.value = '';
    try {
      final problem = await _ensureInitialized();
      if (problem != null) {
        statusMessage.value = '${problem.code}: ${problem.message}';
        return;
      }
      final identity = await XplorPayApiClient.softwareIdentity();
      await _impl.presentPayment(
        amount: amount,
        invoice: invoiceId,
        orderID: null,
        customerID: null,
        softwareType: identity.$1,
        softwareTypeVersion: identity.$2,
      );
      txnState.value = XplorPayTapToPayState.ready;
      statusMessage.value = 'Hold the card near the top edge of the iPhone';
    } on XplorPayTapToPayException catch (e) {
      txnState.value = XplorPayTapToPayState.error;
      statusMessage.value = '${e.code}: ${e.message}';
    } finally {
      busy.value = false;
    }
  }

  /// Cancels in-flight preparation and drops the cached reader JWT (docs: do
  /// not call after a successful sale).
  Future<void> invalidateSession() async {
    try {
      await _impl.invalidateSession();
      prepared.value = false;
      if (txnState.value == XplorPayTapToPayState.ready) {
        txnState.value = XplorPayTapToPayState.idle;
        statusMessage.value = 'Session cancelled';
      }
    } on XplorPayTapToPayException catch (e) {
      statusMessage.value = '${e.code}: ${e.message}';
    }
  }

  void _onEvent(TapToPayEvent event) {
    switch (event) {
      case TapToPayTransaction t:
        lastResult.value = t.result;
        lastError.value = t.error ?? '';
        txnState.value = t.approved
            ? XplorPayTapToPayState.approved
            : ((t.error != null || t.result?.result?.toUpperCase() == 'DECLINED')
                ? XplorPayTapToPayState.error
                : XplorPayTapToPayState.ready);
        if (t.approved) {
          unawaited(_recordInvoicePayment());
        }
        break;
      case TapToPayClosed c:
        if (c.error != null) {
          lastError.value = c.error!;
          txnState.value = XplorPayTapToPayState.error;
        } else if (txnState.value == XplorPayTapToPayState.ready) {
          txnState.value = XplorPayTapToPayState.idle;
        }
        statusMessage.value = 'Tap to Pay closed';
        break;
      case TapToPayUnknown u:
        lastError.value = u.name;
        txnState.value = XplorPayTapToPayState.error;
        break;
    }
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
    } catch (each) {
      statusMessage.value = 'Approved — recording payment failed: $each';
    } finally {
      busy.value = false;
    }
  }

  void resetResult() {
    lastResult.value = null;
    lastError.value = '';
    txnState.value = XplorPayTapToPayState.idle;
    statusMessage.value = '';
  }
}
