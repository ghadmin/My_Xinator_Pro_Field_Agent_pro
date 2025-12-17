import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../components/global-widgets/my_buttons.dart';
import '../controllers/invoice_controller.dart';

class ManualPaymentView extends GetView<InvoiceController> {
  const ManualPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Manual Payment'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              _amount(theme),
              SizedBox(
                height: 350.sp,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Obx(
                    () => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.sp),
                          child: WebViewWidget(
                            controller: controller.webController,
                          ),
                        ),
                        if (controller.isLoading.value)
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

  Container _amount(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(12.sp),
      width: double.infinity,
      height: 40.sp,
      decoration: BoxDecoration(
        border: Border.all(color: theme.primaryColor, width: 1.sp),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Center(
        child: controller.depositRequestPay.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Amount to be collected: "),
                  Text(
                    "\$${controller.requestedDepositAmountEditTextController.text}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Amount to be collected: "),
                  Text(
                    "\$${controller.finalCollectionAmount.value}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
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
