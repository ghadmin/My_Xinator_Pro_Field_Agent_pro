import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/xplorpay_tap_to_pay_controller.dart';
import '../controllers/xplorpay_terminal_controller.dart' show XplorPayEnv;

/// Tap to Pay on iPhone: the SDK owns the whole payment UI (Apple tap sheet,
/// success/error screens); this screen handles device support checks, Apple
/// terms linking, session preparation, and launching the flow.
class XplorPayTapToPayView extends StatefulWidget {
  const XplorPayTapToPayView({super.key});

  @override
  State<XplorPayTapToPayView> createState() => _XplorPayTapToPayViewState();
}

class _XplorPayTapToPayViewState extends State<XplorPayTapToPayView> {
  final controller = Get.put(XplorPayTapToPayController());
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
        appBar: AppBar(title: const Text('Tap to Pay'), centerTitle: true),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _supportSection(),
                  16.verticalSpace,
                  _configSection(),
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

  Widget _supportSection() {
    final s = controller.support.value;
    final supported = s?.isSupported == true;
    final checked = s != null;
    final color = !checked
        ? Colors.blueGrey
        : supported
            ? Colors.green
            : Colors.orange;
    final label = !checked
        ? 'Checking device...'
        : supported
            ? 'Tap to Pay available'
            : 'Tap to Pay unavailable';
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contactless, size: 20.sp, color: color),
                8.horizontalSpace,
                Text(label,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: controller.busy.value ? null : controller.recheckSupport,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Re-check support',
                ),
              ],
            ),
            if (!checked || !supported) ...[
              4.verticalSpace,
              Text(
                s?.errorMessage ??
                    'Requires a physical iPhone (XR or newer), iOS 15.4+, passcode and NFC on',
                style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

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

  Widget _saleSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('New sale',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: controller.busy.value ? null : controller.link,
                  icon: const Icon(Icons.link),
                  label: Text(controller.accountLinked.value
                      ? 'Apple terms accepted'
                      : 'Accept Apple terms'),
                ),
              ],
            ),
            8.verticalSpace,
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                            final amount = double.tryParse(amountController.text) ?? 0;
                            controller.pay(amount);
                          },
                    icon: const Icon(Icons.contactless),
                    label: const Text('Charge with Tap to Pay'),
                  ),
                ),
                8.horizontalSpace,
                Obx(() {
                  final preparing = controller.txnState.value ==
                      XplorPayTapToPayState.ready;
                  return OutlinedButton(
                    onPressed: preparing ? controller.invalidateSession : null,
                    child: const Text('Cancel'),
                  );
                }),
              ],
            ),
            8.verticalSpace,
            Text(
              controller.statusMessage.value.isEmpty
                  ? 'SDK handles the tap sheet, authorizing and result screens'
                  : controller.statusMessage.value,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontStyle: controller.statusMessage.value.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: Colors.blueGrey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultSection() {
    return Obx(() {
      final result = controller.lastResult.value;
      final error = controller.lastError.value;
      if (result == null && error.isEmpty) return const SizedBox.shrink();

      final state = controller.txnState.value;
      final color = switch (state) {
        XplorPayTapToPayState.approved => Colors.green.shade700,
        XplorPayTapToPayState.error => Colors.orange.shade800,
        _ => Colors.blueGrey,
      };

      return Card(
        shape: BeveledRectangleBorder(side: BorderSide(color: color, width: 2)),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    switch (state) {
                      XplorPayTapToPayState.approved => 'APPROVED',
                      XplorPayTapToPayState.error => 'ERROR',
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
              if ((result?.displayMessage ?? '').isNotEmpty)
                Text(result!.displayMessage!, style: TextStyle(fontSize: 13.sp)),
              if ((result?.lastFour ?? '').isNotEmpty)
                Text('${result!.cardType} ---- ${result.lastFour}',
                    style: TextStyle(fontSize: 13.sp)),
              if ((result?.id ?? '').isNotEmpty)
                Text('Transaction ID: ${result!.id}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
              if (error.isNotEmpty)
                Text('SDK error: $error',
                    style: TextStyle(fontSize: 12.sp, color: Colors.orange.shade800)),
            ],
          ),
        ),
      );
    });
  }
}
