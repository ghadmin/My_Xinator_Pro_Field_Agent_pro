import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/invoice_controller.dart';

class PaymentByACHView extends GetView<InvoiceController> {
  const PaymentByACHView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment by ACH'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
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
                        Text('Email Receipt'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Text(
                'Invoice Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildInvoiceSummary(),
              SizedBox(height: 32),
              Text(
                'Bank Account',
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
                          child: Text(value),
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
                  Text('Collection Amount'),
                  Spacer(),
                  Text('\$150.00'),
                ],
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Cancel'),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Confirm'),
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
            Text('Invoice Number: Inv-7369-100243'),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Customer Name'),
                Spacer(),
                Text('AdamApple'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Address'),
                Spacer(),
                Text('123 Main St. Anywhere\nPA 10000'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Type'),
                Spacer(),
                Text('Invoice'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Total Amount'),
                Spacer(),
                Text('\$150.00'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Date'),
                Spacer(),
                Text('04/20/2025'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
