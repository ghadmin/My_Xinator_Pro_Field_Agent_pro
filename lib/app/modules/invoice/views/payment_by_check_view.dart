import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart'
    show TextWidget;

import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../controllers/invoice_controller.dart';

class PaymentByCheckView extends GetView<InvoiceController> {
  const PaymentByCheckView({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(text: 'Payment by Check'),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  TextWidget(text:
                //   'Thank you for selecting the payment method. Please add your billing info to continue.',
                //   style: TextStyle(fontSize: 16),
                // ),
                // SizedBox(height: 16),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     SizedBox(
                //       width: 170.sp,
                //       child: ElevatedButton(
                //         onPressed: () {},
                //         style: ButtonStyle(
                //           backgroundColor:
                //               WidgetStateProperty.all(Color(0xff0CBC8B)),
                //         ),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Icon(Icons.email),
                //             SizedBox(width: 8.sp),
                //              TextWidget(text:'Email Receipt'),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(height: 32.sp),
                TextWidget(
                  text: 'Invoice Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.sp),
                _buildInvoiceSummary(),
                SizedBox(height: 32.sp),
                TextWidget(
                  text: 'Billing Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.sp),
                TextWidget(text: 'Payment by Check'),
                SizedBox(height: 8.sp),
                Divider(height: 1, color: Colors.grey),
                SizedBox(height: 32.sp),
                TextWidget(text: 'Check Name'), SizedBox(height: 8.sp),
                SizedBox(
                  height: 42.sp,
                  width: double.infinity,
                  child: GeneralTextField(
                    hint: "Enter Check Name",
                    textInputType: TextInputType.text,
                    theme: theme,
                    textAlignment: TextAlign.start,
                    textEditingController: controller.checkNameTextController,
                  ),
                ),
                SizedBox(height: 8.sp),
                TextWidget(text: 'Check Number'), SizedBox(height: 8.sp),
                SizedBox(
                  height: 42.sp,
                  width: double.infinity,
                  child: GeneralTextField(
                    hint: "Enter Check Number",
                    textInputType: TextInputType.number,
                    theme: theme,
                    textAlignment: TextAlign.start,
                    textEditingController: controller.checkNumberTextController,
                  ),
                ),
                SizedBox(height: 25.sp),
                Row(
                  children: [
                    TextWidget(text: "Total Amount"),
                    Spacer(),
                    TextWidget(text: "\$ ${controller.total.value}"),
                  ],
                ),
                SizedBox(height: 8.sp),
                Row(
                  children: [
                    TextWidget(text: "Deposit Amount"),
                    Spacer(),
                    TextWidget(text: "- \$ ${controller.depositAmount.value}"),
                  ],
                ),

                SizedBox(height: 8.sp),
                Row(
                  children: [
                    TextWidget(text: 'Payable Amount'),
                    Spacer(),
                    Row(
                      children: [
                        TextWidget(text: "\$"),
                        SizedBox(width: 8.sp),
                        SizedBox(
                          height: 35.sp,
                          width: 100.sp,
                          child: GeneralTextField(
                            hint: '',
                            textInputType:
                                TextInputType.numberWithOptions(decimal: true),
                            theme: theme,
                            textAlignment: TextAlign.end,
                            textEditingController:
                                controller.checkAmtTextController,
                            onChanged: (value) {
                              controller.finalCollectionAmount.value = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42.sp,
                        child: SecondaryButton(
                          onPressed: () {
                            Get.back();
                          },
                          title: 'Cancel',
                          inactive: false,
                        ),
                      ),
                    ),
                    SizedBox(width: 30.sp),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 42.sp,
                        child: PrimaryButton(
                          onPressed: () async {
                            if (controller
                                .checkNameTextController.text.isEmpty) {
                              Get.snackbar(
                                  snackPosition: SnackPosition.BOTTOM,
                                  "Error",
                                  "Please enter check name");
                              return;
                            } else if (controller
                                .checkNumberTextController.text.isEmpty) {
                              Get.snackbar(
                                  snackPosition: SnackPosition.BOTTOM,
                                  "Error",
                                  "Please enter check number");
                              return;
                            } else if (controller
                                .checkAmtTextController.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please enter the amount to pay.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            } else if (double.parse(
                                    controller.checkAmtTextController.text) <=
                                0) {
                              Get.snackbar(
                                'Error',
                                'Amount must be greater than zero.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            await controller.makePayment("CHECK");
                          },
                          title: 'Pay',
                          inactive: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
                text: "${controller.type.value}: ${controller.invoiceNumber}"),
            SizedBox(height: 10.sp),
            Row(
              children: [
                TextWidget(text: 'Customer Name'),
                Spacer(),
                TextWidget(text: controller.customerName),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                TextWidget(text: 'Address'),
                Spacer(),
                TextWidget(text: controller.address),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                TextWidget(text: 'Type'),
                Spacer(),
                TextWidget(text: controller.type.value),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                TextWidget(text: 'Total Amount'),
                Spacer(),
                TextWidget(
                    text:
                        '\$${double.parse(controller.total.value).toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                TextWidget(text: 'Date'),
                Spacer(),
                TextWidget(text: controller.showingDate.value),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
