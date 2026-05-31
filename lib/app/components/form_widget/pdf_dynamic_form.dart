import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';
import 'package:myxinator_pro_field_agent_pro/app/models/forms/forms_models.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/forms/controllers/forms_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/signature/signature_dialog.dart';
import 'package:image_picker/image_picker.dart';

/// ============================================
/// PDF Dynamic Form - Main Widget
/// ============================================
/// Supports two modes:
/// 1. BUILDER - Create/edit form templates with drag-drop fields
/// 2. VIEWER - Fill and submit existing forms
///
/// Coordinate System:
/// - Origin: TOP-LEFT of the page
/// - xPct, yPct: 0.0-1.0 - Position as fraction of page dimensions
/// - wPct, hPct: 0.0-1.0 - Size as fraction of page dimensions
/// - Y grows downward
/// - Page index: 0-based for multi-page PDFs
///
/// PDF Template Dimensions (A4 @ 300 DPI):
/// - Width: 2480 pixels (210mm)
/// - Height: 3508 pixels (297mm)
/// ============================================

enum PdfFormMode { builder, viewer }

class PdfDynamicForm extends StatefulWidget {
  final Map<String, dynamic> config;
  final PdfFormMode mode;

  const PdfDynamicForm({
    super.key,
    required this.config,
    this.mode = PdfFormMode.viewer,
  });

  @override
  State<PdfDynamicForm> createState() => _PdfDynamicFormState();
}

class _PdfDynamicFormState extends State<PdfDynamicForm> {
  @override
  Widget build(BuildContext context) {
    switch (widget.mode) {
      case PdfFormMode.builder:
        return PdfFormBuilder(config: widget.config);
      case PdfFormMode.viewer:
        return PdfFormViewer(config: widget.config);
    }
  }
}

/// ============================================
/// PDF FORM BUILDER - Create/Edit Templates
/// ============================================

class PdfFormBuilder extends StatefulWidget {
  final Map<String, dynamic> config;

  const PdfFormBuilder({super.key, required this.config});

  @override
  State<PdfFormBuilder> createState() => _PdfFormBuilderState();
}

class _PdfFormBuilderState extends State<PdfFormBuilder> {
  // late InAppWebViewController _webViewController;
  String? _pdfBase64;
  List<Map<String, dynamic>> _fields = [];
  Map<String, dynamic>? _selectedField;
  int _currentPage = 0;
  bool _isDirty = false;
  final String _templateName = 'Untitled Template';

  // Field types available in toolbox
  final List<FieldType> _fieldTypes = [
    FieldType(type: 'text', label: 'Text', icon: Icons.text_fields),
    FieldType(type: 'number', label: 'Number', icon: Icons.numbers),
    FieldType(type: 'textarea', label: 'Text Area', icon: Icons.notes),
    FieldType(type: 'date', label: 'Date', icon: Icons.calendar_today),
    FieldType(type: 'checkbox', label: 'Checkbox', icon: Icons.check_box),
    FieldType(
      type: 'radio',
      label: 'Radio Group',
      icon: Icons.radio_button_unchecked,
    ),
    FieldType(type: 'dropdown', label: 'Dropdown', icon: Icons.arrow_drop_down),
    FieldType(type: 'signature', label: 'Signature', icon: Icons.draw),
    FieldType(type: 'image', label: 'Image', icon: Icons.image),
    FieldType(type: 'file', label: 'File Upload', icon: Icons.upload_file),
    FieldType(
      type: 'smartfield',
      label: 'Smart Field',
      icon: Icons.auto_awesome,
    ),
    FieldType(
      type: 'partstable',
      label: 'Parts Table',
      icon: Icons.table_chart,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pdfBase64 = widget.config['pdfBase64'] as String?;
    _loadExistingFields();
  }

  void _loadExistingFields() {
    if (widget.config.containsKey('form')) {
      final form = widget.config['form'] as Map<String, dynamic>;
      if (form.containsKey('fields')) {
        _fields = List<Map<String, dynamic>>.from(
          form['fields'].map((f) => Map<String, dynamic>.from(f)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: Row(
              children: [
                _buildToolbox(),
                Expanded(child: _buildCanvas()),
                _buildPropertiesPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PDF Form Builder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            _templateName,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          tooltip: 'Undo',
          onPressed: _undo,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          tooltip: 'Redo',
          onPressed: _redo,
        ),
        IconButton(
          icon: const Icon(Icons.save),
          tooltip: 'Save Template',
          onPressed: _saveTemplate,
        ),
        IconButton(
          icon: const Icon(Icons.preview),
          tooltip: 'Preview Form',
          onPressed: _previewForm,
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: 'Help',
          onPressed: _showHelp,
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'Page $_currentPage of ${_getTotalPages()}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_left),
            onPressed: _currentPage > 0
                ? () => _changePage(_currentPage - 1)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_right),
            onPressed: _currentPage < _getTotalPages() - 1
                ? () => _changePage(_currentPage + 1)
                : null,
          ),
          const Spacer(),
          if (_isDirty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Unsaved changes',
                style: TextStyle(color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolbox() {
    return Container(
      width: 120,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: const Text(
              'TOOLBOX',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _fieldTypes.length,
              itemBuilder: (context, index) {
                final fieldType = _fieldTypes[index];
                return Draggable<FieldType>(
                  data: fieldType,
                  feedback: Container(
                    width: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(fieldType.icon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          fieldType.label,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  child: DragTarget<FieldType>(
                    onAcceptWithDetails: (details) {
                      // Field dropped on toolbox (ignored)
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(fieldType.icon, color: Colors.blue.shade700),
                            const SizedBox(height: 4),
                            Text(
                              fieldType.label,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Container(color: Colors.grey.shade200, child: _buildPdfCanvas());
  }

  Widget _buildPdfCanvas() {
    if (_pdfBase64 == null || _pdfBase64!.isEmpty) {
      return const Center(child: Text('No PDF loaded'));
    }

    final fieldsJson = _escapeJson(_fields);
    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PDF Form Builder</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; font-family: -apple-system, sans-serif; background: #e0e0e0; }
        #pdf-container { position: relative; width: 100%; min-height: 100vh; padding: 20px; }
        .pdf-page { position: relative; margin: 0 auto; background: white; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
        .field-overlay { position: absolute; border: 2px dashed #2196F3; background: rgba(33, 150, 243, 0.1); cursor: move; z-index: 1000; }
        .field-overlay.selected { border: 2px solid #2196F3; background: rgba(33, 150, 243, 0.2); box-shadow: 0 0 0 4px rgba(33, 150, 243, 0.3); }
        .field-overlay .resize-handle { position: absolute; width: 10px; height: 10px; background: #2196F3; border-radius: 50%; }
        .field-overlay .resize-handle.se { bottom: -5px; right: -5px; cursor: se-resize; }
        .field-overlay .field-label { position: absolute; top: -20px; left: 0; font-size: 10px; color: #2196F3; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        #loading { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.95); display: flex; align-items: center; justify-content: center; z-index: 9999; flex-direction: column; gap: 16px; }
        .spinner { width: 40px; height: 40px; border: 3px solid #f3f3f3; border-top: 3px solid #2196F3; border-radius: 50%; animation: spin 1s linear infinite; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    </style>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
    <script>
        const PDF_URL = 'data:application/pdf;base64,$_pdfBase64';
        const FIELDS = $fieldsJson;
        const CURRENT_PAGE = $_currentPage;

        let pdfDoc = null;
        let scale = 1.0;
        let selectedField = null;
        let isDragging = false;
        let isResizing = false;
        let dragOffset = { x: 0, y: 0 };

        document.addEventListener('DOMContentLoaded', init);

        async function init() {
            await loadPDF();
            setupDragAndDrop();
        }

        async function loadPDF() {
            const loadingEl = document.getElementById('loading');
            const container = document.getElementById('pdf-container');

            try {
                pdfDoc = await pdfjsLib.getDocument({ url: PDF_URL }).promise;

                for (let pageNum = 1; pageNum <= pdfDoc.numPages; pageNum++) {
                    const page = await pdfDoc.getPage(pageNum);
                    const viewport = page.getViewport({ scale: scale });

                    const pageContainer = document.createElement('div');
                    pageContainer.className = 'pdf-page';
                    pageContainer.style.width = viewport.width + 'px';
                    pageContainer.style.height = viewport.height + 'px';
                    pageContainer.dataset.pageNum = pageNum - 1;

                    const canvas = document.createElement('canvas');
                    canvas.width = viewport.width;
                    canvas.height = viewport.height;
                    await page.render({ canvasContext: canvas.getContext('2d'), viewport }).promise;

                    pageContainer.appendChild(canvas);
                    addFieldOverlays(pageContainer, pageNum - 1, viewport.width, viewport.height);
                    container.appendChild(pageContainer);
                }

                loadingEl.classList.add('hidden');

            } catch (error) {
                loadingEl.classList.add('hidden');
                container.innerHTML = '<div style="padding: 20px; text-align: center; color: red;">Error: ' + error.message + '</div>';
            }
        }

        function addFieldOverlays(pageContainer, pageIndex, pageWidth, pageHeight) {
            const pageFields = FIELDS.filter(f => f.position && f.position.page === pageIndex);

            pageFields.forEach(field => {
                const overlay = createFieldOverlay(field, pageWidth, pageHeight);
                pageContainer.appendChild(overlay);
            });
        }

        function createFieldOverlay(field, pageWidth, pageHeight) {
            const pos = field.position;
            const overlay = document.createElement('div');
            overlay.className = 'field-overlay';
            overlay.dataset.fieldId = field.id;

            overlay.style.left = (pos.xPct * 100) + '%';
            overlay.style.top = (pos.yPct * 100) + '%';
            overlay.style.width = (pos.wPct * 100) + '%';
            overlay.style.height = (pos.hPct * 100) + '%';

            const label = document.createElement('div');
            label.className = 'field-label';
            let labelText = field.label || field.id;
            if (field.type === 'smartfield' && field.smartFieldSource) {
                labelText += ' [' + field.smartFieldSource + ']';
            }
            label.textContent = labelText;
            overlay.appendChild(label);

            const resizeHandle = document.createElement('div');
            resizeHandle.className = 'resize-handle se';
            overlay.appendChild(resizeHandle);

            overlay.addEventListener('mousedown', (e) => startDrag(e, overlay, field));
            resizeHandle.addEventListener('mousedown', (e) => startResize(e, overlay, field));
            overlay.addEventListener('click', (e) => { e.stopPropagation(); selectField(field, overlay); });

            return overlay;
        }

        function startDrag(e, overlay, field) {
            if (e.target.classList.contains('resize-handle')) return;
            isDragging = true;
            const rect = overlay.getBoundingClientRect();
            dragOffset.x = e.clientX - rect.left;
            dragOffset.y = e.clientY - rect.top;
        }

        function startResize(e, overlay, field) {
            e.stopPropagation();
            isResizing = true;
        }

        function selectField(field, overlay) {
            document.querySelectorAll('.field-overlay').forEach(el => el.classList.remove('selected'));
            overlay.classList.add('selected');
            selectedField = field;
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('onFieldSelected', field);
            }
        }

        document.addEventListener('mousemove', (e) => {
            if (!isDragging && !isResizing) return;
            // Handle drag/resize logic
        });

        document.addEventListener('mouseup', () => {
            isDragging = false;
            isResizing = false;
        });

        function updateFieldPosition(fieldId, xPct, yPct) {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('onFieldMoved', fieldId, xPct, yPct);
            }
        }

        function updateFieldSize(fieldId, wPct, hPct) {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('onFieldResized', fieldId, wPct, hPct);
            }
        }
    </script>
</head>
<body>
    <div id="loading"><div class="spinner"></div><div>Loading PDF...</div></div>
    <div id="pdf-container"></div>
</body>
</html>
    ''';

    return InAppWebView(
      initialData: InAppWebViewInitialData(data: html),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        supportZoom: true,
        builtInZoomControls: false,
      ),
      onWebViewCreated: (controller) {
        // _webViewController = controller;
        _setupBuilderHandlers(controller);
      },
      onConsoleMessage: (controller, consoleMessage) {
        kLog('Builder Console: ${consoleMessage.message}');
      },
    );
  }

  Widget _buildPropertiesPanel() {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const Row(
              children: [
                Icon(Icons.settings, size: 18),
                SizedBox(width: 8),
                Text(
                  'PROPERTIES',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedField != null
                ? _buildFieldProperties()
                : _buildNoSelection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldProperties() {
    final field = _selectedField!;
    final pos = field['position'] as Map<String, dynamic>? ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPropField('Field ID', field['id']?.toString() ?? ''),
        _buildPropField('Type', field['type']?.toString() ?? ''),
        const SizedBox(height: 16),
        const Text(
          'Position (Percentage)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildNumberInput(
                'X%',
                (pos['xPct'] as num?)?.toDouble() ?? 0.0,
                (v) => _updateFieldPos('xPct', v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildNumberInput(
                'Y%',
                (pos['yPct'] as num?)?.toDouble() ?? 0.0,
                (v) => _updateFieldPos('yPct', v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildNumberInput(
                'Width%',
                (pos['wPct'] as num?)?.toDouble() ?? 0.1,
                (v) => _updateFieldPos('wPct', v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildNumberInput(
                'Height%',
                (pos['hPct'] as num?)?.toDouble() ?? 0.05,
                (v) => _updateFieldPos('hPct', v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Label',
          field['label'] ?? '',
          (v) => _updateField('label', v),
        ),
        _buildTextField(
          'Placeholder',
          field['placeholder'] ?? '',
          (v) => _updateField('placeholder', v),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Required', style: TextStyle(fontSize: 14)),
          value: field['required'] ?? false,
          onChanged: (v) => _updateField('required', v),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Delete Field',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: _deleteSelectedField,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Select a field to edit properties',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPropField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    final controller = TextEditingController(text: value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: const TextStyle(fontSize: 13),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNumberInput(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    final controller = TextEditingController(text: value.toStringAsFixed(2));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          style: const TextStyle(fontSize: 12),
          onChanged: (v) => onChanged(double.tryParse(v) ?? value),
        ),
      ],
    );
  }

  void _setupBuilderHandlers(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'onFieldSelected',
      callback: (args) {
        if (args.isNotEmpty) {
          setState(() {
            _selectedField = Map<String, dynamic>.from(args[0]);
          });
        }
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'onFieldMoved',
      callback: (args) {
        if (args.length >= 3) {
          final fieldId = args[0] as String;
          final xPct = args[1] as double;
          final yPct = args[2] as double;
          _updateFieldPositionInList(fieldId, xPct: xPct, yPct: yPct);
        }
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'onFieldResized',
      callback: (args) {
        if (args.length >= 3) {
          final fieldId = args[0] as String;
          final wPct = args[1] as double;
          final hPct = args[2] as double;
          _updateFieldPositionInList(fieldId, wPct: wPct, hPct: hPct);
        }
      },
    );
  }

  void _updateFieldPositionInList(
    String fieldId, {
    double? xPct,
    double? yPct,
    double? wPct,
    double? hPct,
  }) {
    final index = _fields.indexWhere((f) => f['id'] == fieldId);
    if (index != -1) {
      setState(() {
        final pos = _fields[index]['position'] as Map<String, dynamic>;
        if (xPct != null) pos['xPct'] = xPct;
        if (yPct != null) pos['yPct'] = yPct;
        if (wPct != null) pos['wPct'] = wPct;
        if (hPct != null) pos['hPct'] = hPct;
        _fields[index]['position'] = pos;
        _isDirty = true;
      });
    }
  }

  void _updateField(String key, dynamic value) {
    if (_selectedField != null) {
      setState(() {
        _selectedField![key] = value;
        final index = _fields.indexWhere(
          (f) => f['id'] == _selectedField!['id'],
        );
        if (index != -1) {
          _fields[index][key] = value;
        }
        _isDirty = true;
      });
    }
  }

  void _updateFieldPos(String key, double value) {
    if (_selectedField != null) {
      final pos = _selectedField!['position'] as Map<String, dynamic>? ?? {};
      pos[key] = value;
      _updateField('position', pos);
    }
  }

  void _deleteSelectedField() {
    if (_selectedField != null) {
      setState(() {
        _fields.removeWhere((f) => f['id'] == _selectedField!['id']);
        _selectedField = null;
        _isDirty = true;
      });
    }
  }

  void _changePage(int page) {
    setState(() => _currentPage = page);
  }

  int _getTotalPages() => 1;

  void _undo() {
    // TODO: Implement undo
  }

  void _redo() {
    // TODO: Implement redo
  }

  void _saveTemplate() {
    final template = {
      'name': _templateName,
      'pdfBase64': _pdfBase64,
      'fields': _fields,
      'createdAt': DateTime.now().toIso8601String(),
    };
    kLog('Template saved: ${template.keys}');
    setState(() => _isDirty = false);
  }

  void _previewForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfFormViewer(
          config: {
            'form': {'fields': _fields},
            'pdfBase64': _pdfBase64,
          },
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('PDF Form Builder Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Drag fields from the toolbox onto the PDF canvas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('2. Click on a field to select it'),
              SizedBox(height: 8),
              Text('3. Drag fields to reposition them'),
              SizedBox(height: 8),
              Text('4. Use the resize handle (bottom-right) to resize'),
              SizedBox(height: 8),
              Text('5. Edit properties in the right panel'),
              SizedBox(height: 8),
              Text('6. Save your template when done'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _escapeJson(dynamic json) {
    final str = jsonEncode(json);
    return str.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
  }
}

class FieldType {
  final String type;
  final String label;
  final IconData icon;

  FieldType({required this.type, required this.label, required this.icon});
}

/// ============================================
/// PDF FORM VIEWER - Fill Existing Forms
/// ============================================

class PdfFormViewer extends StatefulWidget {
  final Map<String, dynamic> config;

  const PdfFormViewer({super.key, required this.config});

  @override
  State<PdfFormViewer> createState() => _PdfFormViewerState();
}

class _PdfFormViewerState extends State<PdfFormViewer> {
  final Map<String, dynamic> formValues = {};
  final ImagePicker _imagePicker = ImagePicker();
  InAppWebViewController? _webViewController;

  Map<String, dynamic>? _formData;
  List? _fields;
  String? _pdfBase64;
  Map<String, dynamic>? _smartFieldValues;
  double _currentZoom = 0.75;

  @override
  void initState() {
    super.initState();
    _pdfBase64 = widget.config['pdfBase64'] as String?;
    _smartFieldValues =
        widget.config['smartFieldValues'] as Map<String, dynamic>?;

    // Load saved form progress from Hive
    _loadSavedFormProgress();
  }

  /// Load saved form progress from Hive
  Future<void> _loadSavedFormProgress() async {
    try {
      final formInstanceId = widget.config['formInstanceId'] as int?;
      final appointmentId = widget.config['appointmentId'] as String?;

      kLog('🔍 Looking for saved form progress:');
      kLog('  formInstanceId: $formInstanceId');
      kLog('  appointmentId: $appointmentId');

      if (formInstanceId == null || appointmentId == null) {
        kLog('⚠️ formInstanceId or appointmentId is null, skipping load');
        return;
      }

      // Check if FormsController is registered
      if (!Get.isRegistered<FormsController>()) {
        kLog('⚠️ FormsController not registered, skipping form progress load');
        // Try to register it if not available
        try {
          Get.put(FormsController());
          kLog('✅ Registered FormsController');
        } catch (e) {
          kLog('❌ Could not register FormsController: $e');
          return;
        }
      }

      final formsController = Get.find<FormsController>();
      final savedProgress = formsController.getFormProgress(
        formInstanceId,
        appointmentId: appointmentId,
      );

      kLog('📦 Saved progress found: ${savedProgress.isNotEmpty} (${savedProgress.length} fields)');

      if (savedProgress.isNotEmpty) {
        setState(() {
          formValues.addAll(savedProgress);
        });
        kLog(
          '✅ Loaded ${savedProgress.length} saved field values for appointmentId=$appointmentId, formInstanceId=$formInstanceId',
        );
        kLog('📋 Saved fields: ${savedProgress.keys.toList()}');

        // After loading saved data, update the web view
        WidgetsBinding.instance.addPostFrameCallback((_) {
          kLog('🔄 Restoring saved fields to web view...');
          _restoreSavedFieldsToWebView(savedProgress);
        });
      } else {
        kLog('⚠️ No saved progress found for appointmentId=$appointmentId, formInstanceId=$formInstanceId');
      }
    } catch (e) {
      kLog('❌ Error loading form progress: $e');
    }
  }

  /// Restore saved field values to the web view
  Future<void> _restoreSavedFieldsToWebView(
    Map<String, dynamic> savedValues,
  ) async {
    try {
      kLog('🔄 _restoreSavedFieldsToWebView called with ${savedValues.length} values');

      if (_webViewController == null) {
        kLog('⚠️ Web view controller is null, waiting...');
        // Wait for web view to be created
        await Future.delayed(const Duration(milliseconds: 1000));
        if (_webViewController == null) {
          kLog('❌ Web view controller still null after delay, giving up');
          return;
        }
      }

      int restoredCount = 0;

      // Restore each saved field value to the web view
      for (final entry in savedValues.entries) {
        final fieldId = entry.key;
        final value = entry.value;

        if (value == null || value.toString().isEmpty) {
          kLog('⏭️ Skipping empty field: $fieldId');
          continue;
        }

        kLog('🔧 Restoring field: $fieldId (value length: ${value.toString().length})');
        await _updateWebViewField(fieldId, value);
        restoredCount++;
      }

      kLog('✅ Restored $restoredCount/${savedValues.length} field values to web view');
    } catch (e) {
      kLog('❌ Error restoring fields to web view: $e');
    }
  }

  /// Update a single field in the web view
  Future<void> _updateWebViewField(String fieldId, dynamic value) async {
    try {
      if (_webViewController == null) {
        kLog('❌ Web view controller is null in _updateWebViewField');
        return;
      }

      // Check if this is a parts table (List of Maps)
      if (value is List && value.isNotEmpty && value.first is Map) {
        kLog('🔧 Restoring parts table: $fieldId (${value.length} rows)');
        // Convert to JSON for JavaScript
        final partsDataJson = jsonEncode(value);
        await _webViewController!.evaluateJavascript(
          source: "restorePartsTableData('$fieldId', $partsDataJson);",
        );
        kLog('✅ Parts table restored: $fieldId');
        return;
      }

      final valueString = value.toString();
      kLog('🔧 _updateWebViewField: $fieldId (isSignature: ${valueString.length > 1000})');

      // Check if this is a signature (base64 image data)
      final isSignature =
          valueString.contains('data:image') ||
          valueString.startsWith('iVBORw0KGgo') ||
          valueString.length > 1000;

      // Use window object to avoid escaping issues for large data
      await _webViewController!.evaluateJavascript(
        source: "window.__tempFieldValue = `${valueString.replaceAll('`', '\\`')}`;",
      );

      // Call JavaScript to update the field
      await _webViewController!.evaluateJavascript(
        source:
            '''
        (function() {
          const fieldId = '$fieldId';
          const value = window.__tempFieldValue;
          delete window.__tempFieldValue;

          console.log('Restoring field:', fieldId, 'value length:', value ? value.length : 0);

          // Find the field container
          const fieldElement = document.querySelector('[data-field-id="' + fieldId + '"]');
          if (!fieldElement) {
            console.log('❌ Field not found: ' + fieldId);
            return;
          }

          // Get the field container (might be the signature area div)
          const container = fieldElement.closest('.field-overlay');
          if (!container) {
            console.log('❌ Container not found for: ' + fieldId);
            return;
          }

          $isSignature
            ? _restoreSignatureField(container, fieldId, value)
            : _restoreRegularField(fieldElement, value);

          function _restoreSignatureField(container, fieldId, base64Data) {
            console.log('🖼️ Restoring signature for:', fieldId);

            // Check if base64 data URL or raw base64
            let dataUrl = base64Data;
            if (!dataUrl.startsWith('data:image')) {
              // It's raw base64, add the data URL prefix
              dataUrl = 'data:image/png;base64,' + base64Data;
            }

            // Clear container and create new image
            container.innerHTML = '';

            const img = document.createElement('img');
            img.src = dataUrl;
            img.style.width = '100%';
            img.style.height = '100%';
            img.style.objectFit = 'contain';
            img.style.cursor = 'pointer';

            // Add click handler to reopen signature dialog
            img.addEventListener('click', function(e) {
              e.preventDefault();
              e.stopPropagation();
              openSignature(fieldId);
            });

            container.appendChild(img);
            console.log('✅ Signature restored for: ' + fieldId);
          }

          function _restoreRegularField(field, value) {
            console.log('📝 Restoring regular field:', field.tagName, 'value:', value);

            if (field.tagName === 'INPUT') {
              const inputType = field.type.toLowerCase();
              if (inputType === 'checkbox' || inputType === 'radio') {
                field.checked = (value === true || value === 'true');
              } else {
                field.value = value;
              }
            } else if (field.tagName === 'TEXTAREA') {
              field.value = value;
            } else if (field.tagName === 'SELECT') {
              field.value = value;
            }
          }
        })();
      ''',
      );

      kLog('✅ JavaScript executed for field: $fieldId');
    } catch (e) {
      kLog('❌ Error updating field $fieldId: $e');
    }
  }

  /// Save form progress to Hive
  ///
  /// Auto-saves current form field values to Hive storage
  /// This allows restoring user input when the form is opened again
  Future<void> _saveFormProgress() async {
    try {
      final formInstanceId = widget.config['formInstanceId'] as int?;
      final appointmentId = widget.config['appointmentId'] as String?;

      if (formInstanceId == null || appointmentId == null) {
        kLog('⚠️ formInstanceId or appointmentId is null, skipping save');
        return;
      }

      // Check if FormsController is registered
      if (!Get.isRegistered<FormsController>()) {
        kLog('⚠️ FormsController not registered, skipping form progress save');
        // Try to register it if not available
        try {
          Get.put(FormsController());
          kLog('✅ Registered FormsController');
        } catch (e) {
          kLog('❌ Could not register FormsController: $e');
          return;
        }
      }

      final formsController = Get.find<FormsController>();

      // Create a copy of current form values
      final currentValues = Map<String, dynamic>.from(formValues);

      // Save to Hive with appointmentId
      await formsController.saveFormProgress(
        formInstanceId,
        currentValues,
        appointmentId: appointmentId,
      );
      kLog('✅ Auto-saved form progress for appointmentId=$appointmentId, formInstanceId=$formInstanceId (${currentValues.length} fields)');
    } catch (e) {
      kLog('❌ Error saving form progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData = widget.config.containsKey('form')
        ? widget.config['form'] as Map<String, dynamic>
        : widget.config;
    final fields = formData['fields'] as List? ?? [];
    _formData = formData;
    _fields = fields;

    return Scaffold(
      backgroundColor: WarmOrganicBlueTheme.warmGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: WarmOrganicBlueTheme.deepNavy),
        title: Text('PDF Form', style: WarmOrganicBlueTheme.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: _currentZoom > 0.5 ? () => _zoom(-0.25) : null,
          ),
          Text(
            '${(_currentZoom * 100).toInt()}%',
            style: WarmOrganicBlueTheme.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: _currentZoom < 3.0 ? () => _zoom(0.25) : null,
          ),
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(
              Icons.save,
              color: WarmOrganicBlueTheme.primaryBlue,
            ),
          ),
        ],
      ),
      body: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    if (_pdfBase64 == null || _pdfBase64!.isEmpty) {
      return const Center(child: Text('Error: PDF data not available'));
    }

    final fieldsJson = _escapeJson(_fields ?? []);
    final smartFieldValuesJson = _escapeJson(_smartFieldValues ?? {});
    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PDF Dynamic Form</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; font-family: -apple-system, sans-serif; background: #f5f5f5; }
        #pdf-container { position: relative; width: 100%; min-height: 100vh; padding: 10px; }
        .pdf-page { position: relative; margin: 20px auto; background: white; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .field-overlay { position: absolute; z-index: 1000; }
        .field-overlay input, .field-overlay textarea, .field-overlay select { width: 100%; height: 100%; border: 1px solid #2196F3; border-radius: 4px; padding: 4px; font-size: 12px; }
        .field-overlay input:focus, .field-overlay textarea:focus, .field-overlay select:focus { outline: none; box-shadow: 0 0 0 2px rgba(33, 150, 243, 0.2); }
        .field-overlay .smartfield { width: 100%; height: 100%; background: rgba(33, 150, 243, 0.05); padding: 4px; font-size: 11px; display: flex; align-items: center; font-weight: bold; }
        .field-overlay .signature-area { width: 100%; height: 100%; border: 1px dashed #2196F3; background: rgba(255, 255, 255, 0.5); display: flex; align-items: center; justify-content: center; cursor: pointer; }
        .field-overlay .radio-group, .field-overlay .checkbox-group { width: 100%; height: 100%; overflow-y: auto; padding: 4px; display: flex; flex-direction: column; gap: 2px; }
        .field-overlay .radio-item, .field-overlay .checkbox-item { display: flex; align-items: center; gap: 4px; font-size: 11px; }
        .field-overlay .radio-item input, .field-overlay .checkbox-item input { width: auto; height: auto; margin: 0; }
        .field-overlay .radio-item label, .field-overlay .checkbox-item label { flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .field-overlay .image-area { width: 100%; height: 100%; border: 1px dashed #2196F3; background: rgba(255, 255, 255, 0.5); display: flex; flex-direction: column; align-items: center; justify-content: center; cursor: pointer; position: relative; }
        .field-overlay .image-area img { width: 100%; height: 100%; object-fit: contain; }
        .field-overlay .image-area .placeholder { font-size: 10px; color: #2196F3; text-align: center; padding: 4px; }
        .field-overlay .file-area { width: 100%; height: 100%; border: 1px dashed #2196F3; background: rgba(255, 255, 255, 0.5); display: flex; flex-direction: column; align-items: center; justify-content: center; cursor: pointer; }
        .field-overlay .file-area .file-name { font-size: 10px; color: #2196F3; text-align: center; padding: 4px; word-break: break-all; }
        .field-overlay .parts-table { width: 100%; height: 100%; border: 1px solid #2196F3; background: white; display: flex; flex-direction: column; font-size: 10px; overflow: hidden; }
        .field-overlay .parts-table .table-header { display: flex; background: #f0f0f0; border-bottom: 1px solid #2196F3; font-weight: 600; flex-shrink: 0; }
        .field-overlay .parts-table .table-header .header-cell { padding: 4px; text-align: center; border-right: 1px solid #ddd; }
        .field-overlay .parts-table .table-header .header-cell:last-child { border-right: none; }
        .field-overlay .parts-table .table-body { flex: 1; overflow-y: auto; }
        .field-overlay .parts-table .table-row { display: flex; border-bottom: 1px solid #eee; }
        .field-overlay .parts-table .table-row:last-child { border-bottom: none; }
        .field-overlay .parts-table .table-row .row-cell { padding: 2px; border-right: 1px solid #eee; }
        .field-overlay .parts-table .table-row .row-cell:last-child { border-right: none; }
        .field-overlay .parts-table .table-row .cell-qty { width: 40px; flex-shrink: 0; }
        .field-overlay .parts-table .table-row .cell-desc { flex: 1; }
        .field-overlay .parts-table .table-row .cell-action { width: 24px; flex-shrink: 0; }
        .field-overlay .parts-table .table-row input { width: 100%; height: 100%; border: none; font-size: 10px; padding: 2px; box-sizing: border-box; }
        .field-overlay .parts-table .table-row input:focus { outline: none; background: #f9f9f9; }
        .field-overlay .parts-table .table-row .btn-delete { width: 100%; height: 100%; border: none; background: none; color: #ef5350; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 12px; }
        .field-overlay .parts-table .table-row .btn-delete:disabled { color: #ccc; cursor: not-allowed; }
        .field-overlay .parts-table .table-footer { display: flex; border-top: 1px solid #2196F3; padding: 4px; flex-shrink: 0; }
        .field-overlay .parts-table .btn-add { flex: 1; padding: 4px 8px; background: #2196F3; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 10px; display: flex; align-items: center; justify-content: center; gap: 4px; }
        .field-overlay .parts-table .btn-add:disabled { background: #ccc; cursor: not-allowed; }
        .required-field::before { content: '*'; color: red; margin-right: 2px; }
    </style>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
    <script>
        const PDF_URL = 'data:application/pdf;base64,$_pdfBase64';
        const FIELDS = $fieldsJson;
        const SMART_FIELD_VALUES = $smartFieldValuesJson;
        let pdfDoc = null;
        let scale = 1.5;

        document.addEventListener('DOMContentLoaded', async () => {
            pdfDoc = await pdfjsLib.getDocument({ url: PDF_URL }).promise;
            await renderPdf();
        });

        async function renderPdf() {
            const container = document.getElementById('pdf-container');
            if (!container) return;

            container.innerHTML = ''; // Clear existing content

            for (let pageNum = 1; pageNum <= pdfDoc.numPages; pageNum++) {
                const page = await pdfDoc.getPage(pageNum);
                const viewport = page.getViewport({ scale: scale });
                const pageContainer = document.createElement('div');
                pageContainer.className = 'pdf-page';
                pageContainer.style.width = viewport.width + 'px';
                pageContainer.style.height = viewport.height + 'px';

                const canvas = document.createElement('canvas');
                canvas.width = viewport.width;
                canvas.height = viewport.height;
                await page.render({ canvasContext: canvas.getContext('2d'), viewport }).promise;
                pageContainer.appendChild(canvas);
                addFieldOverlays(pageContainer, pageNum - 1, viewport.width, viewport.height);
                container.appendChild(pageContainer);
            }
        }

        function addFieldOverlays(pageContainer, pageIndex, pageWidth, pageHeight) {
            const pageFields = FIELDS.filter(f => f.position && f.position.page === pageIndex);
            pageFields.forEach(field => {
                const overlay = document.createElement('div');
                overlay.className = 'field-overlay';
                overlay.style.left = (field.position.xPct * 100) + '%';
                overlay.style.top = (field.position.yPct * 100) + '%';
                overlay.style.width = (field.position.wPct * 100) + '%';
                overlay.style.height = (field.position.hPct * 100) + '%';

                const content = createFieldContent(field);
                overlay.appendChild(content);
                pageContainer.appendChild(overlay);
            });
        }

        function createFieldContent(field) {
            const wrapper = document.createElement('div');
            wrapper.style.width = '100%';
            wrapper.style.height = '100%';
            if (field.required) wrapper.classList.add('required-field');

            switch (field.type) {
                case 'text': {
                    const input = document.createElement('input');
                    input.type = 'text';
                    input.placeholder = field.placeholder || '';
                    input.dataset.fieldId = field.id;
                    input.onchange = function() { updateFieldValue(field.id, this.value); };
                    wrapper.appendChild(input);
                    break;
                }
                case 'number': {
                    const input = document.createElement('input');
                    input.type = 'number';
                    input.placeholder = field.placeholder || '';
                    input.dataset.fieldId = field.id;
                    input.onchange = function() { updateFieldValue(field.id, this.value); };
                    wrapper.appendChild(input);
                    break;
                }
                case 'textarea': {
                    const textarea = document.createElement('textarea');
                    textarea.placeholder = field.placeholder || '';
                    textarea.dataset.fieldId = field.id;
                    textarea.onchange = function() { updateFieldValue(field.id, this.value); };
                    wrapper.appendChild(textarea);
                    break;
                }
                case 'date': {
                    const input = document.createElement('input');
                    input.type = 'date';
                    input.dataset.fieldId = field.id;
                    input.onchange = function() { updateFieldValue(field.id, this.value); };
                    wrapper.appendChild(input);
                    break;
                }
                case 'checkbox': {
                    const input = document.createElement('input');
                    input.type = 'checkbox';
                    input.dataset.fieldId = field.id;
                    input.onchange = function() { updateFieldValue(field.id, this.checked); };
                    wrapper.appendChild(input);
                    break;
                }
                case 'check': {
                    const checkContainer = document.createElement('div');
                    checkContainer.className = 'checkbox-item';
                    checkContainer.style.display = 'flex';
                    checkContainer.style.alignItems = 'center';
                    checkContainer.style.gap = '8px';
                    checkContainer.style.height = '100%';

                    const input = document.createElement('input');
                    input.type = 'checkbox';
                    input.id = 'check_' + field.id;
                    input.dataset.fieldId = field.id;
                    input.style.width = 'auto';
                    input.style.height = 'auto';
                    input.style.margin = '0';

                    const label = document.createElement('label');
                    label.htmlFor = 'check_' + field.id;
                    label.textContent = field.header || field.label || field.placeholder || '';
                    label.style.flex = '1';
                    label.style.cursor = 'pointer';
                    label.style.fontSize = '12px';
                    label.style.whiteSpace = 'nowrap';
                    label.style.overflow = 'hidden';
                    label.style.textOverflow = 'ellipsis';

                    input.onchange = function() {
                        const value = this.checked ? 'true' : 'false';
                        updateFieldValue(field.id, value);
                    };

                    checkContainer.appendChild(input);
                    checkContainer.appendChild(label);
                    wrapper.appendChild(checkContainer);

                    // Set initial value to false
                    updateFieldValue(field.id, 'false');
                    break;
                }
                case 'radio': {
                    const radioGroup = document.createElement('div');
                    radioGroup.className = 'radio-group';
                    const options = field.options || [];
                    options.forEach((option, index) => {
                        const radioItem = document.createElement('div');
                        radioItem.className = 'radio-item';

                        const radio = document.createElement('input');
                        radio.type = 'radio';
                        radio.name = field.id;
                        radio.value = option;
                        radio.dataset.fieldId = field.id;
                        if (index === 0) radio.checked = true;

                        const label = document.createElement('label');
                        label.textContent = option;

                        radioItem.appendChild(radio);
                        radioItem.appendChild(label);
                        radioGroup.appendChild(radioItem);

                        radio.onchange = function() {
                            const selected = document.querySelector('input[name="' + field.id + '"]:checked');
                            updateFieldValue(field.id, selected ? selected.value : '');
                        };
                    });

                    wrapper.appendChild(radioGroup);

                    // Set initial value
                    const firstRadio = radioGroup.querySelector('input[type="radio"]');
                    if (firstRadio) {
                        updateFieldValue(field.id, firstRadio.value);
                    }
                    break;
                }
                case 'dropdown': {
                    const select = document.createElement('select');
                    const options = field.options || [];
                    const placeholder = field.placeholder || 'Select...';

                    const defaultOption = document.createElement('option');
                    defaultOption.value = '';
                    defaultOption.textContent = placeholder;
                    defaultOption.disabled = true;
                    defaultOption.selected = true;
                    select.appendChild(defaultOption);

                    options.forEach(option => {
                        const opt = document.createElement('option');
                        opt.value = option;
                        opt.textContent = option;
                        select.appendChild(opt);
                    });

                    select.dataset.fieldId = field.id;
                    select.onchange = function() { updateFieldValue(field.id, this.value); };
                    wrapper.appendChild(select);
                    break;
                }
                case 'image': {
                    const imageArea = document.createElement('div');
                    imageArea.className = 'image-area';
                    imageArea.dataset.fieldId = field.id;
                    imageArea.innerHTML = '<div class="placeholder">' + (field.placeholder || 'Tap to add image') + '</div>';
                    imageArea.onclick = function() { openImagePicker(field.id); };
                    wrapper.appendChild(imageArea);
                    break;
                }
                case 'file': {
                    const fileArea = document.createElement('div');
                    fileArea.className = 'file-area';
                    fileArea.dataset.fieldId = field.id;
                    fileArea.innerHTML = '<div class="file-name">' + (field.placeholder || 'Tap to upload file') + '</div>';
                    fileArea.onclick = function() { openFilePicker(field.id); };
                    wrapper.appendChild(fileArea);
                    break;
                }
                case 'signature': {
                    const div = document.createElement('div');
                    div.className = 'signature-area';
                    div.dataset.fieldId = field.id;
                    div.textContent = field.placeholder || 'Tap to Sign';
                    div.onclick = function() { openSignature(field.id); };
                    wrapper.appendChild(div);
                    break;
                }
                case 'smartfield': {
                    const div = document.createElement('div');
                    div.className = 'smartfield';
                    div.dataset.fieldId = field.id;
                    div.textContent = field.placeholder || 'Loading...';
                    wrapper.appendChild(div);

                    // Load the actual value asynchronously
                    getSmartFieldValue(field).then(value => {
                        div.textContent = value;
                        updateFieldValue(field.id, value);
                    });
                    break;
                }
                case 'partstable': {
                    const maxRows = field.maxRows || 10;
                    const table = document.createElement('div');
                    table.className = 'parts-table';
                    table.dataset.fieldId = field.id;
                    table.id = 'partsTable_' + field.id;

                    // Create table header
                    const header = document.createElement('div');
                    header.className = 'table-header';
                    header.innerHTML = `
                        <div class="header-cell cell-qty">Qty</div>
                        <div class="header-cell cell-desc">Description</div>
                        <div class="header-cell cell-action"></div>
                    `;
                    table.appendChild(header);

                    // Create table body
                    const body = document.createElement('div');
                    body.className = 'table-body';
                    body.id = 'partsTableBody_' + field.id;
                    table.appendChild(body);

                    // Create table footer with add button
                    const footer = document.createElement('div');
                    footer.className = 'table-footer';
                    const addButton = document.createElement('button');
                    addButton.className = 'btn-add';
                    addButton.type = 'button';
                    addButton.innerHTML = '<span>+</span> Add Row';
                    addButton.onclick = function() { addPartsTableRow(field.id, maxRows); };
                    footer.appendChild(addButton);
                    table.appendChild(footer);

                    // Add initial empty row
                    addPartsTableRow(field.id, maxRows);

                    wrapper.appendChild(table);
                    break;
                }
            }
            return wrapper;
        }

        // Add a new row to the parts table
        function addPartsTableRow(fieldId, maxRows) {
            const body = document.getElementById('partsTableBody_' + fieldId);
            if (!body) return;

            const currentRows = body.querySelectorAll('.table-row').length;
            if (currentRows >= maxRows) return;

            const rowIndex = currentRows;
            const row = document.createElement('div');
            row.className = 'table-row';
            row.dataset.rowIndex = rowIndex;

            const qtyCell = document.createElement('div');
            qtyCell.className = 'row-cell cell-qty';
            const qtyInput = document.createElement('input');
            qtyInput.type = 'number';
            qtyInput.className = 'input-qty';
            qtyInput.placeholder = '0';
            qtyInput.onchange = function() { updatePartsTableCell(fieldId, rowIndex, 'qty', this.value); };
            qtyCell.appendChild(qtyInput);
            row.appendChild(qtyCell);

            const descCell = document.createElement('div');
            descCell.className = 'row-cell cell-desc';
            const descInput = document.createElement('input');
            descInput.type = 'text';
            descInput.className = 'input-desc';
            descInput.placeholder = 'Item description';
            descInput.onchange = function() { updatePartsTableCell(fieldId, rowIndex, 'description', this.value); };
            descCell.appendChild(descInput);
            row.appendChild(descCell);

            const actionCell = document.createElement('div');
            actionCell.className = 'row-cell cell-action';
            const deleteBtn = document.createElement('button');
            deleteBtn.className = 'btn-delete';
            deleteBtn.type = 'button';
            deleteBtn.textContent = '×';
            deleteBtn.disabled = (currentRows === 0);
            deleteBtn.onclick = function() { removePartsTableRow(fieldId, rowIndex); };
            actionCell.appendChild(deleteBtn);
            row.appendChild(actionCell);

            body.appendChild(row);

            // Update the data
            if (!window.partsTableData) {
                window.partsTableData = {};
            }
            if (!window.partsTableData[fieldId]) {
                window.partsTableData[fieldId] = [];
            }
            window.partsTableData[fieldId].push({qty: '', description: ''});
            updateFieldValue(fieldId, window.partsTableData[fieldId]);
        }

        // Remove a row from the parts table
        function removePartsTableRow(fieldId, rowIndex) {
            const body = document.getElementById('partsTableBody_' + fieldId);
            if (!body) return;

            const rows = body.querySelectorAll('.table-row');
            if (rows.length <= 1) return; // Keep at least one row

            var rowToRemove = null;
            rows.forEach(function(row) {
                if (row.dataset.rowIndex == rowIndex) {
                    rowToRemove = row;
                }
            });

            if (rowToRemove) {
                rowToRemove.remove();
            }

            // Reindex remaining rows
            var remainingRows = body.querySelectorAll('.table-row');
            remainingRows.forEach(function(row, index) {
                row.dataset.rowIndex = index;
                var deleteBtn = row.querySelector('.btn-delete');
                if (deleteBtn) {
                    deleteBtn.disabled = (index == 0);
                    deleteBtn.onclick = function() { removePartsTableRow(fieldId, index); };
                }
                var qtyInput = row.querySelector('.input-qty');
                if (qtyInput) {
                    qtyInput.onchange = function() { updatePartsTableCell(fieldId, index, 'qty', this.value); };
                }
                var descInput = row.querySelector('.input-desc');
                if (descInput) {
                    descInput.onchange = function() { updatePartsTableCell(fieldId, index, 'description', this.value); };
                }
            });

            // Update the data
            if (window.partsTableData && window.partsTableData[fieldId]) {
                window.partsTableData[fieldId].splice(rowIndex, 1);
                updateFieldValue(fieldId, window.partsTableData[fieldId]);
            }
        }

        // Update a cell value in the parts table
        function updatePartsTableCell(fieldId, rowIndex, key, value) {
            if (!window.partsTableData) {
                window.partsTableData = {};
            }
            if (!window.partsTableData[fieldId]) {
                window.partsTableData[fieldId] = [];
            }
            if (!window.partsTableData[fieldId][rowIndex]) {
                window.partsTableData[fieldId][rowIndex] = {qty: '', description: ''};
            }
            window.partsTableData[fieldId][rowIndex][key] = value;
            updateFieldValue(fieldId, window.partsTableData[fieldId]);
        }

        // Restore parts table data from saved form progress
        function restorePartsTableData(fieldId, data) {
            if (!Array.isArray(data) || data.length == 0) {
                // Add default empty row if no data
                addPartsTableRow(fieldId, 10);
                return;
            }

            var body = document.getElementById('partsTableBody_' + fieldId);
            if (!body) {
                // Table not yet created, wait for it
                setTimeout(function() { restorePartsTableData(fieldId, data); }, 100);
                return;
            }

            // Clear existing rows
            body.innerHTML = '';

            // Initialize data storage
            if (!window.partsTableData) {
                window.partsTableData = {};
            }
            window.partsTableData[fieldId] = [];

            // Add rows from saved data
            data.forEach(function(rowData, index) {
                var qty = rowData.qty || '';
                var description = rowData.description || '';

                var row = document.createElement('div');
                row.className = 'table-row';
                row.dataset.rowIndex = index;

                var qtyCell = document.createElement('div');
                qtyCell.className = 'row-cell cell-qty';
                var qtyInput = document.createElement('input');
                qtyInput.type = 'number';
                qtyInput.className = 'input-qty';
                qtyInput.placeholder = '0';
                qtyInput.value = qty;
                qtyInput.onchange = function() { updatePartsTableCell(fieldId, index, 'qty', this.value); };
                qtyCell.appendChild(qtyInput);
                row.appendChild(qtyCell);

                var descCell = document.createElement('div');
                descCell.className = 'row-cell cell-desc';
                var descInput = document.createElement('input');
                descInput.type = 'text';
                descInput.className = 'input-desc';
                descInput.placeholder = 'Item description';
                descInput.value = description;
                descInput.onchange = function() { updatePartsTableCell(fieldId, index, 'description', this.value); };
                descCell.appendChild(descInput);
                row.appendChild(descCell);

                var actionCell = document.createElement('div');
                actionCell.className = 'row-cell cell-action';
                var deleteBtn = document.createElement('button');
                deleteBtn.className = 'btn-delete';
                deleteBtn.type = 'button';
                deleteBtn.textContent = '×';
                deleteBtn.disabled = (index == 0);
                deleteBtn.onclick = function() { removePartsTableRow(fieldId, index); };
                actionCell.appendChild(deleteBtn);
                row.appendChild(actionCell);

                body.appendChild(row);
                window.partsTableData[fieldId].push({qty: qty, description: description});
            });

            updateFieldValue(fieldId, window.partsTableData[fieldId]);
        }

        async function getSmartFieldValue(field) {
            // First check if there's a pre-resolved value from smartFieldData
            if (SMART_FIELD_VALUES && SMART_FIELD_VALUES[field.id]) {
                const value = SMART_FIELD_VALUES[field.id];
                // Store the value in formValues
                updateFieldValue(field.id, value);
                return value;
            }

            // Fall back to dynamic resolution for system values
            const source = field.smartFieldSource || '';

            // Handle system values
            if (source === 'system.TodaysDate') {
                return new Date().toLocaleDateString();
            }
            if (source === 'system.CurrentTime') {
                return new Date().toLocaleTimeString();
            }
            if (source === 'system.CurrentDateTime') {
                return new Date().toLocaleString();
            }
            if (source === 'system.Timestamp') {
                return Date.now().toString();
            }

            // For other sources, call Flutter handler
            if (window.flutter_inappwebview) {
                try {
                    const result = await window.flutter_inappwebview.callHandler('getSmartFieldValue', source, field.id);
                    return result || field.placeholder || '';
                } catch (e) {
                    console.error('Error getting smart field value:', e);
                    return field.placeholder || '';
                }
            }

            return field.placeholder || '';
        }

        function setPdfScale(newScale) {
            scale = newScale;
            renderPdf();
        }

        function updateFieldValue(fieldId, value) {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('updateFormField', fieldId, value);
            }
        }

        function openSignature(fieldId) {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('openSignatureDialog', fieldId);
            }
        }

        function openImagePicker(fieldId) {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('openImagePicker', fieldId);
            }
        }

        function openFilePicker(fieldId) {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('openFilePicker', fieldId);
            }
        }

        function updateSignatureImage(fieldId, imageDataUrl) {
            console.log('updateSignatureImage called for:', fieldId);

            // Try to find the signature area or any element with this fieldId
            let container = document.querySelector('.signature-area[data-field-id="' + fieldId + '"]');

            // If not found, try to find any element with the fieldId and get its container
            if (!container) {
                const field = document.querySelector('[data-field-id="' + fieldId + '"]');
                if (field) {
                    container = field.closest('.field-overlay');
                }
            }

            if (container) {
                console.log('Found container for:', fieldId);

                // Remove all existing content
                while (container.firstChild) {
                    container.removeChild(container.firstChild);
                }

                // Create new image
                const img = document.createElement('img');
                img.src = imageDataUrl;
                img.style.width = '100%';
                img.style.height = '100%';
                img.style.objectFit = 'contain';
                img.style.cursor = 'pointer';
                img.style.display = 'block';

                // Add click handler to reopen signature dialog
                img.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    openSignature(fieldId);
                });

                container.appendChild(img);

                // Update the data-field-id on the container for next time
                container.setAttribute('data-field-id', fieldId);

                console.log('✅ Signature image updated for:', fieldId, 'image src length:', img.src.length);
            } else {
                console.log('❌ Container not found for:', fieldId);
            }
        }

        function updateImageField(fieldId, imageDataUrl) {
            const field = document.querySelector('.image-area[data-field-id="' + fieldId + '"]');
            if (field) {
                const img = document.createElement('img');
                img.src = imageDataUrl;
                img.style.width = '100%';
                img.style.height = '100%';
                img.style.objectFit = 'contain';
                field.innerHTML = '';
                field.appendChild(img);
                field.onclick = null; // Remove click handler after image is added
            }
        }

        function updateFileField(fieldId, fileName) {
            const field = document.querySelector('.file-area[data-field-id="' + fieldId + '"]');
            if (field) {
                field.innerHTML = '<div class="file-name">📎 ' + fileName + '</div>';
                field.onclick = null; // Remove click handler after file is added
            }
        }
    </script>
</head>
<body><div id="pdf-container"></div></body>
</html>
    ''';

    return InAppWebView(
      initialData: InAppWebViewInitialData(data: html),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        supportZoom: true,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _setupViewerHandlers(controller);
      },
      onConsoleMessage: (controller, consoleMessage) {
        kLog('Viewer Console: ${consoleMessage.message}');
      },
    );
  }

  void _setupViewerHandlers(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'updateFormField',
      callback: (args) {
        if (args.length >= 2) {
          final fieldId = args[0] as String;
          final value = args[1];
          setState(() => formValues[fieldId] = value);
          kLog('Field updated: $fieldId = $value');

          // Auto-save form progress to Hive
          _saveFormProgress();
        }
        return true;
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'openSignatureDialog',
      callback: (args) async {
        if (args.isNotEmpty) {
          final fieldId = args[0] as String;

          kLog('Opening signature dialog for field: $fieldId');

          // Variable to capture signature data from callback
          String? capturedSignatureData;

          // Show signature dialog
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => SignatureDialogModal(
              title: 'Signature',
              onSignatureSaved: (signatureBase64, fullName) {
                kLog(
                  'Signature captured via callback: length=${signatureBase64.length}, name=$fullName',
                );
                capturedSignatureData = signatureBase64;
              },
            ),
          );

          kLog(
            'Dialog result: $result, has data: ${capturedSignatureData != null && capturedSignatureData!.isNotEmpty}',
          );

          if (result == true &&
              capturedSignatureData != null &&
              capturedSignatureData!.isNotEmpty) {
            kLog('🔄 UPDATING signature on PDF: $fieldId');

            // Update formValues immediately WITHOUT setState to avoid rebuild
            formValues[fieldId] = capturedSignatureData;

            // Use window object to pass large base64 string without escaping issues
            await controller.evaluateJavascript(
              source: "window.__tempSignature = `$capturedSignatureData`;",
            );

            // Update the UI using the window object
            await controller.evaluateJavascript(
              source: "if (typeof updateSignatureImage === 'function') { updateSignatureImage('$fieldId', window.__tempSignature); } delete window.__tempSignature;",
            );

            kLog('✅ Signature updated successfully');

            // Auto-save form progress to Hive
            await _saveFormProgress();

            return capturedSignatureData;
          } else {
            kLog('⚠️ No signature data or dialog cancelled');
          }
        }
        return null;
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'getSmartFieldValue',
      callback: (args) async {
        if (args.isEmpty) return '';
        final source = args[0] as String;
        final fieldId = args.length > 1 ? args[1] as String : '';

        // Handle different smart field sources
        return _resolveSmartFieldValue(source, fieldId);
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'openImagePicker',
      callback: (args) async {
        if (args.isNotEmpty) {
          final fieldId = args[0] as String;
          final imageData = await _pickImage();
          if (imageData != null) {
            final base64Image = base64Encode(imageData);
            final dataUrl = 'data:image/jpeg;base64,$base64Image';

            // Update the UI
            controller.evaluateJavascript(
              source: "updateImageField('$fieldId', '$dataUrl')",
            );

            // Store the value
            setState(() => formValues[fieldId] = dataUrl);
            kLog('Image updated: $fieldId');

            // Auto-save form progress to Hive
            _saveFormProgress();

            return dataUrl;
          }
        }
        return null;
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'openFilePicker',
      callback: (args) async {
        if (args.isNotEmpty) {
          final fieldId = args[0] as String;
          final fileData = await _pickFile();
          if (fileData != null) {
            final fileName = fileData['name'] as String;
            final base64File = base64Encode(fileData['bytes'] as List<int>);

            // Update the UI
            controller.evaluateJavascript(
              source: "updateFileField('$fieldId', '$fileName')",
            );

            // Store the value
            setState(
              () => formValues[fieldId] = {
                'name': fileName,
                'data': 'data:application/octet-stream;base64,$base64File',
              },
            );
            kLog('File updated: $fieldId = $fileName');

            // Auto-save form progress to Hive
            _saveFormProgress();

            return fileName;
          }
        }
        return null;
      },
    );
  }

  String _resolveSmartFieldValue(String source, String fieldId) {
    // Handle config-based sources (e.g., config.customerName, config.appointmentDate)
    if (source.startsWith('config.')) {
      final key = source.substring(7); // Remove 'config.' prefix
      final keys = key.split('.');

      dynamic value = widget.config;
      for (final k in keys) {
        if (value is Map) {
          value = value[k];
        } else {
          return '';
        }
      }

      if (value != null) {
        return value.toString();
      }
    }

    // Handle field references (e.g., field.firstName)
    if (source.startsWith('field.')) {
      final referencedFieldId = source.substring(6); // Remove 'field.' prefix
      final value = formValues[referencedFieldId];
      if (value != null) {
        return value.toString();
      }
    }

    // Handle form data sources (e.g., form.customer.name)
    if (source.startsWith('form.')) {
      final path = source.substring(5); // Remove 'form.' prefix
      final keys = path.split('.');

      dynamic value = _formData;
      for (final k in keys) {
        if (value is Map) {
          value = value[k];
        } else {
          return '';
        }
      }

      if (value != null) {
        return value.toString();
      }
    }

    // Return empty string if source not found
    return '';
  }

  Future<Uint8List?> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        return await image.readAsBytes();
      }
    } catch (e) {
      kLog('Error picking image: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _pickFile() async {
    try {
      final result = await showDialog<Map<String, dynamic>?>(
        context: context,
        builder: (_) => const FilePickerDialog(),
      );
      return result;
    } catch (e) {
      kLog('Error picking file: $e');
    }
    return null;
  }

  void _submitForm() async {
    if (formValues.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No data to submit')));
      return;
    }

    kLog('Form submitted with values: $formValues');

    // Get form data from config
    final formData = widget.config['form'] as Map<String, dynamic>?;
    if (formData == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Form data not found')));
      return;
    }

    // Check if we have form instance info for submission
    final formInstanceId = widget.config['formInstanceId'] as int?;
    final templateId = widget.config['templateId'] as int?;
    final appointmentId = widget.config['appointmentId'] as String?;
    final customerId = widget.config['customerId'] as String?;
    final queueId = widget.config['queueId'] as int?;

    if (formInstanceId == null || templateId == null || appointmentId == null) {
      // Form is opened in preview mode without submission capability
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted (preview mode)')),
      );
      kLog('Form submitted in preview mode - no submission data');
      return;
    }

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get the FormsController
      if (!Get.isRegistered<FormsController>()) {
        Get.put(FormsController());
        kLog('✅ Registered FormsController for form submission');
      }
      final formsController = Get.find<FormsController>();

      // Build a FormQueueItem-like object for submission
      final formItem = FormQueueItem(
        queueId: queueId ?? 0,
        formInstanceId: formInstanceId,
        appointmentId: appointmentId,
        templateId: templateId,
        customerId: customerId ?? '',
        action: 'Push',
        createdDateTime: DateTime.now(),
        instanceStatus: 'Pending',
        sendToCustomerOnSubmit: false,
        template: FormTemplate(
          id: templateId,
          name: widget.config['formName'] as String? ?? 'Form',
          description: '',
          structure: jsonEncode(formData),
          requireSignature: false,
          requireTip: false,
        ),
        smartFieldData: '{}',
      );

      // Submit the form
      final success = await formsController.submitDynamicForm(
        form: formItem,
        fieldValues: formValues,
      );

      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully')),
        );

        // ✅ Keep saved form progress after submission
        // The form data remains in Hive for future reference
        kLog('✅ Form submitted - saved progress retained in Hive');

        // Navigate back
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to submit form')));
      }
    } catch (e) {
      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting form: $e')));
      kLog('Error submitting form: $e');
    }
  }

  void _zoom(double delta) {
    setState(() {
      _currentZoom = (_currentZoom + delta).clamp(0.5, 3.0);
      _updatePdfZoom();
    });
  }

  void _updatePdfZoom() {
    _webViewController?.evaluateJavascript(
      source: 'setPdfScale($_currentZoom);',
    );
  }

  String _escapeJson(dynamic json) {
    final str = jsonEncode(json);
    return str.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
  }
}

/// ============================================
/// FILE PICKER DIALOG
/// ============================================

class FilePickerDialog extends StatefulWidget {
  const FilePickerDialog({super.key});

  @override
  State<FilePickerDialog> createState() => _FilePickerDialogState();
}

class _FilePickerDialogState extends State<FilePickerDialog> {
  final List<Map<String, String>> _sampleFiles = [
    {'name': 'document.pdf', 'type': 'application/pdf', 'size': '125 KB'},
    {'name': 'report.docx', 'type': 'application/docx', 'size': '45 KB'},
    {'name': 'data.xlsx', 'type': 'application/xlsx', 'size': '32 KB'},
    {'name': 'image.png', 'type': 'image/png', 'size': '256 KB'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Select File"),
      content: SizedBox(
        width: 400,
        height: 300,
        child: ListView.builder(
          itemCount: _sampleFiles.length,
          itemBuilder: (context, index) {
            final file = _sampleFiles[index];
            return ListTile(
              leading: Icon(_getFileIcon(file['name']!)),
              title: Text(file['name']!),
              subtitle: Text('${file['type']} • ${file['size']}'),
              onTap: () => _selectFile(file['name']!),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return Icons.description;
    }
    if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      return Icons.table_chart;
    }
    if (fileName.endsWith('.png') ||
        fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg')) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }

  Future<void> _selectFile(String fileName) async {
    // For demo purposes, create a simple text file
    // In production, you would use file_picker package
    final bytes = utf8.encode('Sample file content for $fileName');

    if (mounted) {
      Navigator.pop(context, {'name': fileName, 'bytes': bytes});
    }
  }
}

/// ============================================
/// PDF GENERATOR - Export Filled Forms
/// ============================================
/// TODO: Implement PDF generation using syncfusion_flutter_pdf or similar
/// This will allow generating filled PDFs from form submissions
///
/// Example usage:
/// final file = await PdfGenerator.generateFilledPdf(
///   templateBase64: pdfBase64,
///   fieldValues: formValues,
///   fields: fields,
/// );
