import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:xinator_fsm_pro/app/modules/invoice/controllers/invoice_controller.dart';
import 'package:xinator_fsm_pro/app/routes/app_pages.dart';
import 'package:xinator_fsm_pro/config/theme/light_theme_colors.dart';

import '../../../../utils/date_converter.dart';

class PaymentMethodSelectionView extends GetView<InvoiceController> {
  const PaymentMethodSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your preferred method',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: LightThemeColors.bodyTextSecondaryColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16.sp),
            Container(
              height: 180.sp,
              color: Colors.transparent,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 180.sp,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF021B79),
                          Color(0xFF0A62A2),
                          Color(0xFF84C4E1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '\$${double.parse(controller.total.value).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6.sp),
                        Text(
                          'Deposit Amount',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '\$${double.parse(controller.depositAmount.value).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3.sp),
                        Text(
                          'Due by ${dateTimeConverter(inputTime: DateTime.now().toString(), outputFormat: "MM/dd/yyyy")}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // Positioned(
                  //   bottom: 10.sp,
                  //   right: 20,
                  //   child: SizedBox(
                  //     height: 42.sp,
                  //     width: 120.sp,
                  //     child: SecondaryButton(
                  //       onPressed: () {},
                  //       title: 'View Invoice',
                  //       inactive: false,
                  //
                  //       // style: ElevatedButton.styleFrom(
                  //       //   primary: Colors.blue.shade300,
                  //       //   onPrimary: Colors.white,
                  //       // ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
            SizedBox(height: 32.sp),
            PaymentOption(
              icon: Remix.cash_line,
              label: 'Pay by Cash',
              onTap: () {
                controller.finalCollectionAmount.value =
                    (double.parse(controller.total.value) -
                            double.parse(controller.depositAmount.value))
                        .toStringAsFixed(2);
                controller.cashAmtTextController.text =
                    controller.finalCollectionAmount.value;
                Get.toNamed(Routes.PAYMENT_BY_CASH);
              },
            ),
            SizedBox(height: 8.sp),
            PaymentOption(
              icon: Remix.currency_line,
              label: 'Pay by Check',
              onTap: () {
                controller.finalCollectionAmount.value =
                    (double.parse(controller.total.value) -
                            double.parse(controller.depositAmount.value))
                        .toStringAsFixed(2);
                controller.checkAmtTextController.text =
                    controller.finalCollectionAmount.value;
                Get.toNamed(Routes.PAYMENT_BY_CHECK);
              },
            ),
            SizedBox(height: 8.sp),
            PaymentOption(
                icon: Remix.bank_card_2_fill,
                label: 'Credit/Debit Card',
                onTap: () async {
                  controller.finalCollectionAmount.value =
                      (double.parse(controller.total.value) -
                              double.parse(controller.depositAmount.value))
                          .toStringAsFixed(2);
                  await controller.initializeWebController();
                  Get.toNamed(Routes.MANUAL_PAYMENT);
                }),
            // SizedBox(height: 8.sp),
            // PaymentOption(
            //   icon: Remix.bank_card_2_fill,
            //   label: 'Pay by Card',
            //   onTap: () => null,
            // ),
            // SizedBox(height: 8.sp),
            // PaymentOption(
            //   icon: Icons.account_balance,
            //   label: 'Payment By Bank Transfer (ACH)',
            //   onTap: () => Get.toNamed(Routes.PAYMENT_BY_BANK_TRANSFER),
            // ),
            // SizedBox(height: 8.sp),
            // PaymentOption(
            //   icon: Remix.wallet_2_line,
            //   label: 'BNPL (By Now Pay Later)',
            //   onTap: () => null,
            // ),
          ],
        ),
      ),
    );
  }
}

class PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const PaymentOption(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(width: 1, color: LightThemeColors.buttonBorderColor),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
