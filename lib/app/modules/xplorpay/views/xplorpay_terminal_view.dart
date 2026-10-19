import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/xplorpay_terminal_controller.dart';

/// Demo terminal screen: connect to the VP3300 over Bluetooth, run a sale,
/// watch reader feedback, and submit the JWT to the Xplor Pay gateway.
class XplorPayTerminalView extends StatefulWidget {
  const XplorPayTerminalView({super.key});

  @override
  State<XplorPayTerminalView> createState() => _XplorPayTerminalViewState();
}

class _XplorPayTerminalViewState extends State<XplorPayTerminalView> {
  final controller = Get.put(XplorPayTerminalController());
  final amountController = TextEditingController(text: '1.00');

  @override
  void initState() {
    super.initState();
    // Prefill the amount when launched from the invoice payment flow.
    final args = Get.arguments;
    if (args is Map && args['amount'] != null) {
      final a = double.tryParse(args['amount'].toString());
      if (a != null && a > 0) {
        amountController.text = a.toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !controller.busy.value,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Card Reader Terminal'),
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
                  _configSection(),
                  16.verticalSpace,
                  _readerSection(),
                  16.verticalSpace,
                  _saleSection(),
                  16.verticalSpace,
                  _manualEntrySection(),
                  16.verticalSpace,
                  _feedbackSection(),
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

  // ---------------- configuration ----------------

  Widget _configSection() {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gateway configuration',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              8.verticalSpace,
              SegmentedButton<XplorPayEnv>(
                segments: XplorPayEnv.values
                    .map((e) => ButtonSegment(value: e, label: Text(e.label)))
                    .toList(),
                selected: {controller.env.value},
                onSelectionChanged: (selection) {
                  controller.env.value = selection.first;
                  controller.saveConfig();
                },
              ),
              8.verticalSpace,
              Text('Credentials are built into the app',
                  style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- reader ----------------

  Widget _readerSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Obx(() {
                  final state = controller.readerState.value;
                  final color = switch (state) {
                    XplorPayReaderState.connected => Colors.green,
                    XplorPayReaderState.searching => Colors.orange,
                    XplorPayReaderState.disconnected => Colors.red,
                  };
                  final label = switch (state) {
                    XplorPayReaderState.connected => 'Connected',
                    XplorPayReaderState.searching => 'Searching...',
                    XplorPayReaderState.disconnected => 'Disconnected',
                  };
                  return Row(
                    children: [
                      Icon(Icons.circle, size: 10.sp, color: color),
                      6.horizontalSpace,
                      Text(label, style: TextStyle(fontSize: 13.sp)),
                    ],
                  );
                }),
                const Spacer(),
                FilledButton.tonal(
                  onPressed:
                      controller.busy.value ? null : () => controller.connect(),
                  child: const Text('Connect reader'),
                ),
              ],
            ),
            if (controller.readerState.value == XplorPayReaderState.connected)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: TextButton.icon(
                  onPressed: controller.disconnect,
                  icon: const Icon(Icons.link_off),
                  label: const Text('Disconnect'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- sale ----------------

  Widget _saleSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New sale', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            8.verticalSpace,
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            8.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controller.busy.value
                        ? null
                        : () {
                            final amount =
                                double.tryParse(amountController.text) ?? 0;
                            controller.charge(amount);
                          },
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Charge card'),
                  ),
                ),
                8.horizontalSpace,
                Obx(() {
                  final waiting =
                      controller.txnState.value == XplorPayTxnState.waitingForCard;
                  return OutlinedButton(
                    onPressed: waiting ? controller.cancel : null,
                    child: const Text('Cancel'),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- manual entry fallback ----------------

  Widget _manualEntrySection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manual entry (fallback)',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            8.verticalSpace,
            TextField(
              controller: controller.manualCard,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Card number',
                border: OutlineInputBorder(),
              ),
            ),
            8.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.manualExp,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Expiry MMYY',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: TextField(
                    controller: controller.manualCsc,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'CSC',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            8.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.busy.value
                    ? null
                    : controller.submitManualEntry,
                icon: const Icon(Icons.edit),
                label: const Text('Tokenize manually entered card'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- feedback + result ----------------

  Widget _feedbackSection() {
    return Obx(
      () => Card(
        color: Colors.blueGrey.shade50,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reader feedback',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                4.verticalSpace,
                Text(
                  controller.feedback.value.isEmpty
                      ? '—'
                      : controller.feedback.value,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontStyle: controller.feedback.value.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal),
                ),
                if (controller.statusMessage.value.isNotEmpty) ...[
                  4.verticalSpace,
                  Text(
                    controller.statusMessage.value,
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.blueGrey.shade700),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultSection() {
    return Obx(() {
      final result = controller.lastResult.value;
      final card = controller.lastCard.value;
      if (result == null && card == null) return const SizedBox.shrink();

      final color = switch (controller.txnState.value) {
        XplorPayTxnState.approved => Colors.green.shade700,
        XplorPayTxnState.declined => Colors.red.shade700,
        XplorPayTxnState.error => Colors.orange.shade800,
        _ => Colors.blueGrey,
      };

      return Card(
        shape: BeveledRectangleBorder(
            side: BorderSide(color: color, width: 2)),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    switch (controller.txnState.value) {
                      XplorPayTxnState.approved => 'APPROVED',
                      XplorPayTxnState.declined => 'DECLINED',
                      XplorPayTxnState.error => 'ERROR',
                      XplorPayTxnState.submitting => 'SUBMITTING...',
                      _ => 'IN PROGRESS',
                    },
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold, color: color),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.resetResult,
                    child: const Text('New sale'),
                  ),
                ],
              ),
              8.verticalSpace,
              if (card != null)
                Text('Card: ${card.cardType} •••• ${card.lastFour}',
                    style: TextStyle(fontSize: 13.sp)),
              if (result != null) ...[
                4.verticalSpace,
                Text(result.displayMessage ?? '',
                    style: TextStyle(fontSize: 13.sp)),
                if ((result.authorizationCode ?? '').isNotEmpty)
                  Text('Auth code: ${result.authorizationCode}',
                      style: TextStyle(fontSize: 13.sp)),
                if ((result.id ?? '').isNotEmpty)
                  Text('Transaction ID: ${result.id}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
              ],
            ],
          ),
        ),
      );
    });
  }
}
