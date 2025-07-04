import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/my_buttons.dart';

import '../../../components/global-widgets/general_text_field.dart';
import '../controllers/invoice_controller.dart';

class PaymentByCashView extends GetView<InvoiceController> {
  const PaymentByCashView({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment by Cash'),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
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
              //             Text('Email Receipt'),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 32.sp),
              Text(
                'Invoice Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.sp),
              _buildInvoiceSummary(),
              SizedBox(height: 32.sp),
              Text(
                'Billing Info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.sp),
              Text('Cash On Delivery'),
              SizedBox(height: 8.sp),
              Divider(height: 1, color: Colors.grey),
              SizedBox(height: 32.sp),

              Row(
                children: [
                  Text("Total Amount"),
                  Spacer(),
                  Text("\$ ${controller.total.value}"),
                ],
              ),
              SizedBox(height: 8.sp),
              Row(
                children: [
                  Text("Deposit Amount"),
                  Spacer(),
                  Text("- \$ ${controller.depositAmount.value}"),
                ],
              ),

              SizedBox(height: 8.sp),
              Row(
                children: [
                  Text('Payable Amount'),
                  Spacer(),
                  Row(
                    children: [
                      Text("\$"),
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
                              controller.cashAmtTextController,
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
                          if (controller.cashAmtTextController.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please enter the amount to pay.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          } else if (double.parse(
                                  controller.cashAmtTextController.text) <=
                              0) {
                            Get.snackbar(
                              'Error',
                              'Amount must be greater than zero.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          controller.checkNumberTextController.clear();
                          controller.checkNameTextController.clear();
                          await controller.makePayment("CASH");
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
    );
  }

  Widget _buildInvoiceSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${controller.type.value}: ${controller.invoiceNumber}"),
            SizedBox(height: 10.sp),
            Row(
              children: [
                Text('Customer Name'),
                Spacer(),
                Text(controller.customerName),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Address'),
                Spacer(),
                Text(controller.address),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Type'),
                Spacer(),
                Text(controller.type.value),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Total Amount'),
                Spacer(),
                Text(
                    '\$${double.parse(controller.total.value).toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Date'),
                Spacer(),
                Text(controller.showingDate.value),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
