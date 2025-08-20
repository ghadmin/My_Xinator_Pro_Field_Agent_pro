import 'package:flutter/material.dart';
import 'package:xinator_fsm_pro/app/clearant_service.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ClearentService _service = ClearentService();
  final TextEditingController _amountController = TextEditingController(text: "1.00");
  String _log = "Waiting...";

  @override
  void initState() {
    super.initState();
    _service.onEvent.listen((event) {
      setState(() {
        if (event.type == 'ready') {
          _log = "✅ Reader is ready!";
        } else if (event.type == 'success') {
          final token = event.data?['transactionToken'];
          final last4 = event.data?['last4'];
          _log = "💳 Success!\nToken: $token\nLast 4: $last4";
        } else if (event.type == 'error') {
          _log = "❌ Error: ${event.data?['message']}";
        } else if (event.type == 'message') {
          _log = "ℹ️ ${event.data?['text']}";
        } else if (event.type == 'info') {
          _log = "💡 ${event.data?['text']}";
        }
      });
    });
  }

  @override
  void dispose() {
    _service.dispose(); // Clean up
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("IDTech Reader")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount (\$)"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _service.connectReader,
              child: Text("🔌 Connect Reader"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 1.00;
                _service.startTransaction(amount);
              },
              child: Text("💳 Start Transaction"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    _log,
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}