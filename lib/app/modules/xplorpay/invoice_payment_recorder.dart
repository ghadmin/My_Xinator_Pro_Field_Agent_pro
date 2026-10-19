import 'package:get/get.dart';

import '../invoice/controllers/invoice_controller.dart';

/// Records an approved Xplor Pay card sale against the invoice the terminal
/// screen was launched for, mirroring the cash/check flow:
///
/// - Deposit-request mode charges the requested deposit -> [InvoiceController.makeDepositPay].
/// - Full payment charges the remaining balance -> [InvoiceController.makePayment]
///   (which also refreshes appointment/invoice state and pops back to the
///   invoice detail, same as the cash/check screens).
///
/// No-ops when the terminal screen was opened outside the invoice flow
/// (standalone testing) or the invoice context has gone stale, so a sale is
/// never recorded against the wrong invoice.
Future<void> recordApprovedCardPayment({
  required String? invoiceId,
  required double amount,
}) async {
  if (invoiceId == null || invoiceId.isEmpty) return;
  if (!Get.isRegistered<InvoiceController>()) return;
  final invoice = Get.find<InvoiceController>();
  if (invoice.invoiceID.value.toString() != invoiceId) return;

  final formatted = amount.toStringAsFixed(2);
  // Deposit vs. full payment must mirror the amount decision made at
  // navigation time (payment_method_selection_view): a deposit charge only
  // when deposit-request mode is active AND a requested amount was entered.
  final isDepositCharge = invoice.depositRequestPay.value &&
      invoice.requestedDepositAmountEditTextController.text.isNotEmpty;
  if (isDepositCharge) {
    // "CARD" — assumed to be accepted by ApiUrl.makePayment like CASH/CHECK;
    // adjust here if the backend expects a different Type string.
    await invoice.makeDepositPay(formatted, 'CARD');
  } else {
    invoice.finalCollectionAmount.value = formatted;
    await invoice.makePayment('CARD');
  }
}
