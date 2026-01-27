import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../components/global-widgets/my_buttons.dart';
import '../controllers/invoice_controller.dart';

class XPayPaymentView extends GetView<InvoiceController> {
  const XPayPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('XPay Payment'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 500.sp,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Obx(
                    () => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.sp),
                          child: WebViewWidget(
                            controller: controller.webController2,
                          ),
                        ),
                        if (controller.isLoading2.value)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50.sp),
              _backButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBack() {
    Get.back();
  }

  SizedBox _backButton() {
    return SizedBox(
      height: 40.sp,
      width: 245.sp,
      child: PrimaryButton(
        title: "Back",
        onPressed: () {
          Get.back();
        },
        inactive: false,
      ),
    );
  }
}
