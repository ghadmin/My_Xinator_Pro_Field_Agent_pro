import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/form_field_model.dart';
import '../widgets/dynamic_pdf_form_widget.dart';
import '../helpers/pdf_integration_helper.dart';

class DynamicFormFillingView extends StatefulWidget {
  final String formId;
  final String formTitle;
  final String? formDescription;
  final FormTemplateModel template;
  final Map<String, dynamic> smartFieldValues;
  final Map<String, dynamic> initialFormData;
  final bool readOnly;
  final Uint8List? pdfBytes;

  const DynamicFormFillingView({
    super.key,
    required this.formId,
    required this.formTitle,
    this.formDescription,
    required this.template,
    required this.smartFieldValues,
    this.initialFormData = const {},
    this.readOnly = false,
    this.pdfBytes,
  });

  @override
  State<DynamicFormFillingView> createState() => _DynamicFormFillingViewState();
}

class _DynamicFormFillingViewState extends State<DynamicFormFillingView> {
  late Map<String, dynamic> _formData;
  late MemoryPdfPageRenderer _pdfRenderer;
  bool _isLoading = true;
  bool _isSaving = false;
  final List<String> _validationErrors = [];

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.initialFormData);
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    try {
      if (widget.pdfBytes != null) {
        _pdfRenderer = await PdfIntegrationHelper.createRendererFromPdfBytes(
          widget.pdfBytes!,
          dpi: 200,
          backgroundColor: '#FFFFFF',
        );
      } else {
        _pdfRenderer = MemoryPdfPageRenderer(pageImages: {}, aspectRatios: {});
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing form: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading form: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
  }

  List<String> _validateForm() {
    final errors = <String>[];

    for (final field in widget.template.fields) {
      final value = _formData[field.id];

      if (field.header?.toLowerCase().contains('required') == true) {
        if (value == null || value.toString().isEmpty) {
          errors.add('${field.header} is required');
        }
      }

      if (field.type == 'signature' &&
          (value == null || value.toString().isEmpty)) {
        errors.add('Signature is required');
      }

      if (field.type == 'partstable') {
        final tableData = value as List?;
        if (tableData == null || tableData.isEmpty) {
          errors.add('${field.header} must have at least one row');
        }
      }
    }

    return errors;
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      Navigator.pop(context, _formData);
    }
  }

  Future<void> _handleSubmit() async {
    final errors = _validateForm();

    if (errors.isNotEmpty) {
      setState(() {
        _validationErrors.clear();
        _validationErrors.addAll(errors);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix validation errors'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      Navigator.pop(context, {
        ..._formData,
        'submitted_at': DateTime.now().toIso8601String(),
        'form_id': widget.formId,
      });
    }
  }

  double _calculateCompletionPercentage() {
    if (widget.template.fields.isEmpty) return 0;

    int filledFields = 0;
    for (final field in widget.template.fields) {
      final value = _formData[field.id];
      if (value != null && value.toString().isNotEmpty) {
        filledFields++;
      }
    }

    return (filledFields / widget.template.fields.length * 100).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completionPercentage = _calculateCompletionPercentage();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.formTitle, style: const TextStyle(fontSize: 18)),
            if (widget.formDescription != null)
              Text(
                widget.formDescription!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (!widget.readOnly)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${completionPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: completionPercentage == 100
                        ? Colors.green
                        : theme.primaryColor,
                  ),
                ),
              ),
            ),
        ],
        bottom: _isLoading || _isSaving
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          if (_validationErrors.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Validation Errors',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._validationErrors.map(
                    (error) => Padding(
                      padding: const EdgeInsets.only(left: 32, bottom: 4),
                      child: Text(
                        '• $error',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Loading form template...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : DynamicPdfFormWidget(
                    key: ValueKey(widget.formId),
                    template: widget.template,
                    smartFieldValues: widget.smartFieldValues,
                    pdfRenderer: _pdfRenderer,
                    initialFormData: _formData,
                    readOnly: widget.readOnly,
                    onFormChanged: _handleFormChanged,
                  ),
          ),
        ],
      ),
      bottomNavigationBar: !widget.readOnly
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1.toDouble()),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSaving ? null : _handleSave,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Draft'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _handleSubmit,
                        icon: const Icon(Icons.check),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: completionPercentage == 100
                              ? Colors.green
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class FormProgressIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int completedFields;
  final int totalFields;

  const FormProgressIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.completedFields,
    required this.totalFields,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalFields > 0 ? completedFields / totalFields : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05.toDouble()),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Form Progress',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '$completedFields/$totalFields fields',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 8,
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Page $currentPage of $totalPages',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
