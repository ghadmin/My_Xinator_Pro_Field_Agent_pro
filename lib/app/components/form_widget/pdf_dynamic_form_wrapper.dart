import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pdf_dynamic_form.dart';

class PdfDynamicFormWrapper extends StatefulWidget {
  const PdfDynamicFormWrapper({super.key});

  @override
  State<PdfDynamicFormWrapper> createState() => _PdfDynamicFormWrapperState();
}

class _PdfDynamicFormWrapperState extends State<PdfDynamicFormWrapper> {
  late final Map<String, dynamic>? _config;

  @override
  void initState() {
    super.initState();
    _config = Get.arguments as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    return _config == null
        ? Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('No form configuration provided'),
                ],
              ),
            ),
          )
        : PdfDynamicForm(config: _config);
  }
}
