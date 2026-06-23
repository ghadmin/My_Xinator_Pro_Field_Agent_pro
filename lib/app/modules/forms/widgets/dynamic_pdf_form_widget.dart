import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Build a PDF page with proper view hierarchy
  ///
  /// Following the recommended pattern from PDF Implementation Details:
  /// - ScrollContainer (SingleChildScrollView) - handles scrolling
  /// └── PageContainer (Container) - sized to match rendered bitmap
  ///     ├── PageBitmap (Image.memory) - the rendered PDF page
  ///     └── Overlay (Stack) - same size as page, holds field boxes
  ///         ├── FieldBox 1 (Positioned) - positioned by percentage
  ///         ├── FieldBox 2
  ///         └── ...
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
        child: _buildPageContainer(pageImage, pageFields, aspectRatio),
      ),
    );
  }

  /// Build the page container with proper layering
  ///
  /// This creates the PageContainer from the PDF implementation guide.
  /// The PageContainer is the parent that holds both the bitmap and overlay.
  Widget _buildPageContainer(
    Uint8List? pageImage,
    List<FormFieldModel> pageFields,
    double aspectRatio,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The page container size (in pixels) matches the rendered bitmap size
        final pageWidth = constraints.maxWidth;
        final pageHeight = pageWidth / aspectRatio;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // PageBitmap layer - the rendered PDF page
            _buildPageBitmap(pageImage),

            // Overlay layer - position:absolute, same size as page container
            // Field boxes are children of this overlay, not the scrollview
            _buildFieldOverlayLayer(
              pageFields: pageFields,
              pageWidth: pageWidth,
              pageHeight: pageHeight,
            ),
          ],
        );
      },
    );
  }

  /// Build the page bitmap layer
  ///
  /// This is the PageBitmap from the PDF implementation guide.
  /// It displays the rendered PDF page image.
  Widget _buildPageBitmap(Uint8List? pageImage) {
    return Positioned.fill(
      child: _buildPdfBackground(pageImage),
    );
  }

  /// Build the overlay layer for field boxes
  ///
  /// This is the Overlay from the PDF implementation guide.
  /// It's an absolute-positioned layer that sits on top of the bitmap.
  /// Field boxes are positioned as children of this overlay.
  Widget _buildFieldOverlayLayer({
    required List<FormFieldModel> pageFields,
    required double pageWidth,
    required double pageHeight,
  }) {
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: pageFields.map((field) {
          return _buildFieldBox(
            field: field,
            pageWidth: pageWidth,
            pageHeight: pageHeight,
          );
        }).toList(),
      ),
    );
  }

  /// Build a single field box
  ///
  /// Field placement math from PDF implementation guide:
  /// boxLeftPx = pageContainer.width * field.position.xPct
  /// boxTopPx = pageContainer.height * field.position.yPct
  /// boxWidthPx = pageContainer.width * field.position.wPct
  /// boxHeightPx = pageContainer.height * field.position.hPct
  Widget _buildFieldBox({
    required FormFieldModel field,
    required double pageWidth,
    required double pageHeight,
  }) {
    // Position is stored as fractions (xPct, yPct, wPct, hPct)
    // Convert to pixels at render time
    final boxLeftPx = pageWidth * (field.position.xPct / 100);
    final boxTopPx = pageHeight * (field.position.yPct / 100);
    final boxWidthPx = pageWidth * (field.position.wPct / 100);
    final boxHeightPx = pageHeight * (field.position.hPct / 100);

    return Positioned(
      left: boxLeftPx,
      top: boxTopPx,
      width: boxWidthPx,
      height: boxHeightPx,
      child: _buildFieldWidget(field),
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
      case 'text area':
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
      case 'check':
        return CheckboxFieldWidget(
          id: field.id,
          label: field.header ?? '',
          value: fieldValue == true || fieldValue == 'true',
          onChanged: (value) => _updateFieldValue(field.id, value),
          readOnly: widget.readOnly,
        );

      case 'checkboxes':
        final List<String> selectedValues = fieldValue is List
            ? List<String>.from(fieldValue)
            : (fieldValue?.toString().isNotEmpty == true ? [fieldValue.toString()] : []);
        return CheckboxesFieldWidget(
          id: field.id,
          header: field.header,
          options: field.dropdownOptions ?? [],
          selectedValues: selectedValues,
          onChanged: (values) => _updateFieldValue(field.id, values),
          readOnly: widget.readOnly,
        );

      case 'radio':
      case 'radio buttons':
      case 'radiobuttons':
        final String? selectedValue = fieldValue?.toString();
        return RadioButtonsFieldWidget(
          id: field.id,
          header: field.header,
          options: field.dropdownOptions ?? [],
          selectedValue: selectedValue,
          onChanged: (value) => _updateFieldValue(field.id, value),
          readOnly: widget.readOnly,
        );

      case 'number':
        return TextFieldWidget(
          id: field.id,
          header: field.header,
          value: fieldValue?.toString() ?? '',
          onChanged: (value) => _updateFieldValue(field.id, value),
          readOnly: widget.readOnly,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );

      case 'date':
        return DateFieldWidget(
          id: field.id,
          header: field.header,
          value: fieldValue?.toString(),
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
      case 'smart field':
        // Look up smart field value by field.id (e.g., "pdf_1776450913261_56q93m")
        // NOT by smartFieldSource (e.g., "system.CompanyName")
        // See: Smart Field Issue Solution PDF
        final smartValue = widget.smartFieldValues[field.id] ??
            fieldValue?.toString() ??
            '';
        return SmartFieldWidget(
          id: field.id,
          header: field.header,
          value: smartValue,
        );

      case 'partstable':
      case 'parts table':
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
