import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/form_field_model.dart';
import 'form_field_widgets.dart';
import 'signature_pad_widget.dart';

abstract class PdfPageRenderer {
  Future<Uint8List?> renderPage(int pageNumber);
  double? getAspectRatio(int pageNumber);
}

class MemoryPdfPageRenderer implements PdfPageRenderer {
  final Map<int, Uint8List> pageImages;
  final Map<int, double> aspectRatios;

  MemoryPdfPageRenderer({
    required this.pageImages,
    required this.aspectRatios,
  });

  @override
  Future<Uint8List?> renderPage(int pageNumber) async {
    return pageImages[pageNumber];
  }

  @override
  double? getAspectRatio(int pageNumber) {
    return aspectRatios[pageNumber];
  }
}

class DynamicPdfFormWidget extends StatefulWidget {
  final FormTemplateModel template;
  final Map<String, dynamic> smartFieldValues;
  final Map<String, dynamic> initialFormData;
  final PdfPageRenderer pdfRenderer;
  final bool readOnly;
  final void Function(Map<String, dynamic>)? onSubmit;
  final void Function(Map<String, dynamic>)? onFormChanged;

  const DynamicPdfFormWidget({
    super.key,
    required this.template,
    required this.smartFieldValues,
    required this.pdfRenderer,
    this.initialFormData = const {},
    this.readOnly = false,
    this.onSubmit,
    this.onFormChanged,
  });

  @override
  State<DynamicPdfFormWidget> createState() => _DynamicPdfFormWidgetState();
}

class _DynamicPdfFormWidgetState extends State<DynamicPdfFormWidget> {
  late Map<String, dynamic> _formData;
  final Map<int, Uint8List> _pdfPageImages = {};
  final Map<int, double> _pageAspectRatios = {};
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.initialFormData);
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    try {
      for (int i = 1; i <= widget.template.totalPages; i++) {
        try {
          final pageImage = await widget.pdfRenderer.renderPage(i);
          final aspectRatio = widget.pdfRenderer.getAspectRatio(i);

          if (pageImage != null) {
            _pdfPageImages[i] = pageImage;
            if (aspectRatio != null) {
              _pageAspectRatios[i] = aspectRatio;
            }
          }
        } catch (e) {
          debugPrint('Error rendering page $i: $e');
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading PDF: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateFieldValue(String fieldId, dynamic value) {
    setState(() {
      _formData[fieldId] = value;
    });
    widget.onFormChanged?.call(_formData);
  }

  Future<void> _openSignaturePad(String fieldId) async {
    final currentSignature = _formData[fieldId] as String?;

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => SignaturePadWidget(
          initialSignature: currentSignature,
        ),
      ),
    );

    if (result != null) {
      _updateFieldValue(fieldId, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading form...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Form'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!widget.readOnly && widget.onSubmit != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () => widget.onSubmit!(_formData),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            for (int pageNum = 1; pageNum <= widget.template.totalPages; pageNum++)
              _buildPdfPage(pageNum),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfPage(int pageNum) {
    final pageFields = widget.template.getFieldsForPage(pageNum);
    final pageImage = _pdfPageImages[pageNum];
    final aspectRatio = _pageAspectRatios[pageNum] ?? 8.5 / 11;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          children: [
            _buildPdfBackground(pageImage),
            ...pageFields.map((field) => _buildFieldOverlay(field, aspectRatio)),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfBackground(Uint8List? pageImage) {
    if (pageImage != null) {
      return Positioned.fill(
        child: Image.memory(
          pageImage,
          fit: BoxFit.contain,
        ),
      );
    }

    return Positioned.fill(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'PDF Page Not Available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldOverlay(FormFieldModel field, double pageAspectRatio) {
    final screenWidth = MediaQuery.of(context).size.width - 32;
    final screenHeight = screenWidth / pageAspectRatio;

    return Positioned(
      left: (field.position.xPct / 100) * screenWidth,
      top: (field.position.yPct / 100) * screenHeight,
      width: (field.position.wPct / 100) * screenWidth,
      height: (field.position.hPct / 100) * screenHeight,
      child: _buildFieldWidget(field),
    );
  }

  Widget _buildFieldWidget(FormFieldModel field) {
    final fieldValue = _formData[field.id] ?? field.defaultValue;

    switch (field.type.toLowerCase()) {
      case 'text':
      case 'textfield':
        return TextFieldWidget(
          id: field.id,
          header: field.header,
          value: fieldValue?.toString() ?? '',
          onChanged: (value) => _updateFieldValue(field.id, value),
          readOnly: widget.readOnly,
        );

      case 'textarea':
        return TextFieldWidget(
          id: field.id,
          header: field.header,
          value: fieldValue?.toString() ?? '',
          onChanged: (value) => _updateFieldValue(field.id, value),
          maxLines: null,
          readOnly: widget.readOnly,
        );

      case 'dropdown':
        return DropdownFieldWidget(
          id: field.id,
          header: field.header,
          value: fieldValue?.toString(),
          options: field.dropdownOptions ?? [],
          onChanged: (value) => _updateFieldValue(field.id, value),
          readOnly: widget.readOnly,
        );

      case 'checkbox':
        return CheckboxFieldWidget(
          id: field.id,
          label: field.header ?? '',
          value: fieldValue == true || fieldValue == 'true',
          onChanged: (value) => _updateFieldValue(field.id, value),
          readOnly: widget.readOnly,
        );

      case 'signature':
        return SignatureFieldWidget(
          id: field.id,
          header: field.header,
          signatureData: fieldValue?.toString(),
          onSign: () => _openSignaturePad(field.id),
          readOnly: widget.readOnly,
        );

      case 'smartfield':
        final smartValue = widget.smartFieldValues[field.smartFieldSource] ??
            fieldValue?.toString() ??
            '';
        return SmartFieldWidget(
          id: field.id,
          header: field.header,
          value: smartValue,
        );

      case 'partstable':
        final tableData = fieldValue is List
            ? List<Map<String, String>>.from(
                fieldValue.map((row) => Map<String, String>.from(row)))
            : <Map<String, String>>[];
        return PartsTableWidget(
          id: field.id,
          header: field.header,
          rows: tableData,
          maxRows: field.maxRows ?? 10,
          onChanged: (value) => _updateFieldValue(field.id, value),
          readOnly: widget.readOnly,
        );

      default:
        return TextFieldWidget(
          id: field.id,
          header: field.header,
          value: fieldValue?.toString() ?? '',
          onChanged: (value) => _updateFieldValue(field.id, value),
          readOnly: widget.readOnly,
        );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
