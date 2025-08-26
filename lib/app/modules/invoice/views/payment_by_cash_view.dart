import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/global-widgets/general_text_field.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../controllers/invoice_controller.dart';

class PaymentByCashView extends GetView<InvoiceController> {
  const PaymentByCashView({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: Get.size.width <= 440
          ? AppBar(
              title: Text('Payment by Cash'),
              centerTitle: false,
            )
          : PreferredSize(
              preferredSize: Size.fromHeight(40.sp),
              child: Padding(
                padding: EdgeInsets.only(top: 15.sp),
                child: AppBar(
                  title: Text('Payment by Cash'),
                  centerTitle: false,
                ),
              ),
            ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  Text("Paid Amount"),
                  Spacer(),
                  Text("- \$ ${controller.depositAmount.value}"),
                ],
              ),
              SizedBox(height: 8.sp),
              controller.depositRequestPay.value
                  ? Row(
                      children: [
                        Text('Due Amount'),
                        Spacer(),
                        Text(
                          "\$ ${controller.finalCollectionAmount.value}",
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Text('Payable Amount'),
                        Spacer(),
                        Row(
                          children: [
                            Text("\$"),
                            SizedBox(width: 8.sp),
                            SizedBox(
                              // height: 35.sp,
                              width: 100.sp,
                              child: GeneralTextField(
                                hint: '',
                                textInputType: TextInputType.numberWithOptions(
                                    decimal: true),
                                theme: theme,
                                textAlignment: TextAlign.end,
                                textEditingController:
                                    controller.cashAmtTextController,
                                onChanged: (value) {
                                  controller.finalCollectionAmount.value =
                                      value;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              controller.depositRequestPay.value
                  ? Container(
                      margin: EdgeInsets.only(top: 8.sp),
                      width: double.infinity,
                      height: 40.sp,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: theme.primaryColor, width: 1.sp),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Payment Requested   ",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$${controller.requestedDepositAmountEditTextController.text.isEmpty ? "0.00" : controller.requestedDepositAmountEditTextController.text}",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.primaryColor,
                                fontSize: 18.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
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
                  controller.depositRequestPay.value
                      ? Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 42.sp,
                            child: PrimaryButton(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              onPressed: () async {
                                bool confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Confirm Payment'),
                                        content: Text(
                                            'Are you sure you want to proceed with the payment?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: Text('Confirm'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;

                                if (confirmed) {
                                  await controller.makeDepositPay(
                                    controller
                                        .requestedDepositAmountEditTextController
                                        .text,
                                    "CASH",
                                  );
                                  controller.depositRequestPay.value = false;
                                }
                              },
                              title: controller.type.value == "Invoice"
                                  ? "Pay Invoice"
                                  : "Pay Deposit",
                              inactive: false,
                            ),
                          ),
                        )
                      : Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 42.sp,
                            child: PrimaryButton(
                              onPressed: () async {
                                if (controller
                                    .cashAmtTextController.text.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Please enter the amount to pay.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                } else if (double.parse(controller
                                        .cashAmtTextController.text) <=
                                    0) {
                                  Get.snackbar(
                                    'Error',
                                    'Amount must be greater than zero.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }
                                bool confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Confirm Payment'),
                                        content: Text(
                                            'Are you sure you want to proceed with the payment?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: Text('Confirm'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;

                                if (confirmed) {
                                  controller.checkNumberTextController.clear();
                                  controller.checkNameTextController.clear();
                                  await controller.makePayment("CASH");
                                }
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
