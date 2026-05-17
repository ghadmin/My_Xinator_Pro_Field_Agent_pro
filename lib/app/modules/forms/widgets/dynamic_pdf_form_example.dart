import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/form_field_model.dart';
import 'dynamic_pdf_form_widget.dart';

class DynamicPdfFormExample extends StatefulWidget {
  const DynamicPdfFormExample({super.key});

  @override
  State<DynamicPdfFormExample> createState() => _DynamicPdfFormExampleState();
}

class _DynamicPdfFormExampleState extends State<DynamicPdfFormExample> {
  late FormTemplateModel _sampleTemplate;
  late MemoryPdfPageRenderer _pdfRenderer;

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _sampleTemplate = FormTemplateModel(
      pdfPath: 'sample_form.pdf',
      totalPages: 2,
      fields: [
        FormFieldModel(
          id: 'customer_name',
          type: 'text',
          header: 'Customer Name',
          position: FieldPosition(xPct: 10, yPct: 15, wPct: 35, hPct: 8),
          page: 1,
        ),
        FormFieldModel(
          id: 'service_address',
          type: 'textarea',
          header: 'Service Address',
          position: FieldPosition(xPct: 10, yPct: 25, wPct: 45, hPct: 12),
          page: 1,
        ),
        FormFieldModel(
          id: 'service_type',
          type: 'dropdown',
          header: 'Service Type',
          position: FieldPosition(xPct: 10, yPct: 40, wPct: 30, hPct: 8),
          page: 1,
          dropdownOptions: [
            'Installation',
            'Maintenance',
            'Repair',
            'Inspection',
            'Consultation',
          ],
        ),
        FormFieldModel(
          id: 'technician_name',
          type: 'smartfield',
          header: 'Technician',
          position: FieldPosition(xPct: 55, yPct: 15, wPct: 30, hPct: 8),
          page: 1,
          smartFieldSource: 'technician_name',
        ),
        FormFieldModel(
          id: 'technician_id',
          type: 'smartfield',
          header: 'Technician ID',
          position: FieldPosition(xPct: 55, yPct: 25, wPct: 30, hPct: 8),
          page: 1,
          smartFieldSource: 'technician_id',
        ),
        FormFieldModel(
          id: 'customer_signature',
          type: 'signature',
          header: 'Customer Signature',
          position: FieldPosition(xPct: 10, yPct: 70, wPct: 35, hPct: 15),
          page: 1,
        ),
        FormFieldModel(
          id: 'terms_accepted',
          type: 'checkbox',
          header: 'I accept the terms and conditions',
          position: FieldPosition(xPct: 10, yPct: 88, wPct: 50, hPct: 8),
          page: 1,
        ),
        FormFieldModel(
          id: 'parts_used',
          type: 'partstable',
          header: 'Parts Used',
          position: FieldPosition(xPct: 10, yPct: 20, wPct: 80, hPct: 50),
          page: 2,
          maxRows: 10,
        ),
      ],
    );

    _pdfRenderer = MemoryPdfPageRenderer(
      pageImages: {
        1: Uint8List(0),
        2: Uint8List(0),
      },
      aspectRatios: {
        1: 8.5 / 11,
        2: 8.5 / 11,
      },
    );
  }

  final Map<String, dynamic> _smartFieldValues = {
    'technician_name': 'John Doe',
    'technician_id': 'TECH-2024-001',
    'date': '2025-01-15',
    'company': 'Xinator Pro Services',
  };

  final Map<String, dynamic> _formData = {};

  void _handleFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData.clear();
      _formData.addAll(data);
    });
  }

  void _handleSubmit(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Submitted'),
        content: SingleChildScrollView(
          child: Text(
            data.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic PDF Form Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sample Dynamic Form',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This is a demonstration of the dynamic PDF form system. '
                  'In production, you would integrate with a PDF rendering library.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text('${_sampleTemplate.fields.length} Fields'),
                      backgroundColor: Colors.white,
                    ),
                    Chip(
                      label: Text('${_sampleTemplate.totalPages} Pages'),
                      backgroundColor: Colors.white,
                    ),
                    Chip(
                      label: Text('${_formData.length} Filled'),
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: DynamicPdfFormWidget(
              template: _sampleTemplate,
              smartFieldValues: _smartFieldValues,
              pdfRenderer: _pdfRenderer,
              initialFormData: _formData,
              onFormChanged: _handleFormChanged,
              onSubmit: _handleSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
