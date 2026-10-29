import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/xplorpay_tap_to_pay_controller.dart';

/// Tap to Pay on iPhone screen: verifies device + entitlement support, links
/// Apple's terms once, pre-warms the reader, and runs contactless sales.
class XplorPayTapToPayView extends StatefulWidget {
  const XplorPayTapToPayView({super.key});

  @override
  State<XplorPayTapToPayView> createState() => _XplorPayTapToPayViewState();
}

class _XplorPayTapToPayViewState extends State<XplorPayTapToPayView> {
  final controller = Get.put(XplorPayTapToPayController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !controller.busy.value,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Tap to Pay on iPhone'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _readinessSection(),
                  16.verticalSpace,
                  _saleSection(),
                  16.verticalSpace,
                  _resultSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- readiness ----------------

  Widget _readinessSection() {
    final stage = controller.stage.value;
    final checking = controller.busy.value &&
        (stage == XplorPayTapToPayStage.checking ||
            stage == XplorPayTapToPayStage.preparing);

    IconData icon;
    Color color;
    String label;
    switch (stage) {
      case XplorPayTapToPayStage.checking:
      case XplorPayTapToPayStage.preparing:
        icon = Icons.sync;
        color = Colors.blue;
        label = stage == XplorPayTapToPayStage.checking
            ? 'Checking device support...'
            : 'Preparing reader session...';
        break;
      case XplorPayTapToPayStage.unsupported:
        icon = Icons.error_outline;
        color = Colors.red;
        label = 'Tap to Pay unavailable';
        break;
      case XplorPayTapToPayStage.ready:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        label = 'Ready to accept contactless payments';
        break;
    }

    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                checking
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(icon, color: color, size: 20),
                8.horizontalSpace,
                Expanded(child: Text(label, style: TextStyle(fontSize: 14.sp))),
              ],
            ),
            if (controller.supportMessage.value.isNotEmpty) ...[
              8.verticalSpace,
              Text(
                controller.supportMessage.value,
                style: TextStyle(fontSize: 12.sp, color: Colors.black54),
              ),
            ],
            if (controller.termsPending.value) ...[
              8.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: controller.busy.value ? null : controller.linkAccount,
                  child: const Text('Review & accept Apple terms'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- sale ----------------

  Widget _saleSection() {
    final ready = controller.stage.value == XplorPayTapToPayStage.ready;
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Charge',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            8.verticalSpace,
            TextField(
              controller: controller.amountInput,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            12.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: ready && !controller.busy.value ? controller.pay : null,
                icon: const Icon(Icons.contactless),
                label: Text(controller.busy.value &&
                        controller.txnState.value ==
                            XplorPayTapToPayTxnState.processing
                    ? 'Waiting for card...'
                    : 'Charge'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- result ----------------

  Widget _resultSection() {
    final txn = controller.txnState.value;
    if (txn == XplorPayTapToPayTxnState.idle) return const SizedBox.shrink();

    Color color;
    IconData icon;
    switch (txn) {
      case XplorPayTapToPayTxnState.approved:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case XplorPayTapToPayTxnState.declined:
      case XplorPayTapToPayTxnState.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case XplorPayTapToPayTxnState.cancelled:
        color = Colors.orange;
        icon = Icons.cancel_outlined;
        break;
      case XplorPayTapToPayTxnState.processing:
        color = Colors.blue;
        icon = Icons.contactless;
        break;
      case XplorPayTapToPayTxnState.idle:
        return const SizedBox.shrink();
    }

    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                8.horizontalSpace,
                Expanded(
                  child: Text(controller.statusMessage.value,
                      style: TextStyle(fontSize: 14.sp)),
                ),
              ],
            ),
            8.verticalSpace,
            TextButton(
              onPressed: controller.resetResult,
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}
