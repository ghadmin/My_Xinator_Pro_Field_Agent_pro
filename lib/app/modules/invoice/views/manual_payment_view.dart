import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/my_buttons.dart';
import 'package:xinator_fsm_pro/app/modules/invoice/controllers/invoice_controller.dart';

class ManualPaymentView extends GetView<InvoiceController> {
  const ManualPaymentView({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Manual Payment'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 350.sp,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(right: 25.sp),
                child: WebViewWidget(
                  controller: controller.webController,
                ),
              ),
            ),
            SizedBox(
              height: 40.sp,
              width: 245.sp,
              child: PrimaryButton(
                  title: "Back",
                  onPressed: () {
                    Get.back();
                    // await controller.paymentStatus();
                  },
                  inactive: false),
            ),
          ],
        ),
      ),
    );
  }
}
