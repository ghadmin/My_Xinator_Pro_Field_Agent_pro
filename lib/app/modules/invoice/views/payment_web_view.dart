import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart';
import 'package:xinator_fsm_pro/app/modules/invoice/controllers/invoice_controller.dart';

class XPayLinkScreen extends GetView<InvoiceController> {
  const XPayLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TextWidget(text: "Payment")),
      body: controller.isWebControllerInitialized
          ? WebViewWidget(
              controller: controller.webController,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
