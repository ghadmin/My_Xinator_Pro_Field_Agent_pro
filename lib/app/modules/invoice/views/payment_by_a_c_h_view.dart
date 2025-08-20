import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart';

import '../controllers/invoice_controller.dart';

class PaymentByACHView extends GetView<InvoiceController> {
  const PaymentByACHView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(text: 'Payment by ACH'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text:
                    'Thank you for selecting the payment method. Please select your desired credit or add a new',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Icon(Icons.email),
                        SizedBox(width: 8),
                        TextWidget(text: 'Email Receipt'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              TextWidget(
                text: 'Invoice Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildInvoiceSummary(),
              SizedBox(height: 32),
              TextWidget(
                text: 'Bank Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(labelText: 'Account Name'),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Account Number'),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Type'),
                      items: ['Checking', 'Savings'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: TextWidget(text: value),
                        );
                      }).toList(),
                      onChanged: (String? value) {},
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Routing Number'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  TextWidget(text: 'Collection Amount'),
                  Spacer(),
                  TextWidget(text: '\$150.00'),
                ],
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: TextWidget(text: 'Cancel'),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: TextWidget(text: 'Confirm'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextWidget(text: 'Invoice Number: Inv-7369-100243'),
            SizedBox(height: 8),
            Row(
              children: [
                TextWidget(text: 'Customer Name'),
                Spacer(),
                TextWidget(text: 'AdamApple'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                TextWidget(text: 'Address'),
                Spacer(),
                TextWidget(text: '123 Main St. Anywhere\nPA 10000'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                TextWidget(text: 'Type'),
                Spacer(),
                TextWidget(text: 'Invoice'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                TextWidget(text: 'Total Amount'),
                Spacer(),
                TextWidget(text: '\$150.00'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                TextWidget(text: 'Date'),
                Spacer(),
                TextWidget(text: '04/20/2025'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
