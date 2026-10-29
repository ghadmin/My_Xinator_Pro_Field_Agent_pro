import 'package:get/get.dart';

import '../invoice/controllers/invoice_controller.dart';

/// Records an approved Xplor Pay card sale against the invoice the payment
/// flow started from, giving card payments the same post-payment behaviour as
/// cash/check (refresh + navigate back to the refreshed invoice detail).
///
/// Guards make this a no-op for standalone terminal use (no invoice context,
/// no registered [InvoiceController], or a mismatched invoice id) so the
/// Xplor Pay screens stay usable outside the invoice flow.
class InvoicePaymentRecorder {
  /// [invoiceId] is the invoice the flow was launched with; [amount] is the
  /// charged (gateway-approved) amount.
  static Future<bool> recordApprovedCardPayment({
    required double amount,
    String? invoiceId,
  }) async {
    if (invoiceId == null || invoiceId.isEmpty) return false;
    if (!Get.isRegistered<InvoiceController>()) return false;
    final invoice = Get.find<InvoiceController>();
    if (invoice.invoiceID.value != invoiceId) return false;

    final amountStr = amount.toStringAsFixed(2);
    if (invoice.depositRequestPay.value) {
      // Deposit flow: record the amount the merchant requested/collected.
      await invoice.makeDepositPay(amountStr, 'CARD');
    } else {
      invoice.finalCollectionAmount.value = amountStr;
      await invoice.makePayment('CARD');
    }

    // makePayment/makeDepositPay already refreshed appointments + invoice
    // lists; unwind past this screen and the payment-method selection back to
    // the refreshed invoice detail.
    Get.back<void>();
    Get.back<void>();
    return true;
  }
}
