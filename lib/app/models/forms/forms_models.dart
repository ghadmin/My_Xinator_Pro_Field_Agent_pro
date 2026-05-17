import 'dart:convert';

// ============== POLL RESPONSE MODELS ==============

/// Response from the poll endpoint
class FormsPollResponse {
  final bool success;
  final int count;
  final List<FormQueueItem> items;

  FormsPollResponse({
    required this.success,
    required this.count,
    required this.items,
  });

  factory FormsPollResponse.fromJson(Map<String, dynamic> json) {
    return FormsPollResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((item) => FormQueueItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// A form queue item from the poll response
class FormQueueItem {
  final int queueId;
  final int formInstanceId;
  final String appointmentId;
  final int templateId;
  final int? resourceId;
  final String action; // "Push" or "Cancel"
  final int? triggerId;
  final DateTime createdDateTime;
  final String customerId;
  final String instanceStatus;
  final bool sendToCustomerOnSubmit;
  final FormTemplate template;
  final String smartFieldData; // JSON string

  FormQueueItem({
    required this.queueId,
    required this.formInstanceId,
    required this.appointmentId,
    required this.templateId,
    this.resourceId,
    required this.action,
    this.triggerId,
    required this.createdDateTime,
    required this.customerId,
    required this.instanceStatus,
    required this.sendToCustomerOnSubmit,
    required this.template,
    required this.smartFieldData,
  });

  factory FormQueueItem.fromJson(Map<String, dynamic> json) {
    return FormQueueItem(
      queueId: json['queueId'] ?? 0,
      formInstanceId: json['formInstanceId'] ?? 0,
      appointmentId: json['appointmentId']?.toString() ?? '',
      templateId: json['templateId'] ?? 0,
      resourceId: json['resourceId'],
      action: json['action'] ?? '',
      triggerId: json['triggerId'],
      createdDateTime: DateTime.parse(
        json['createdDateTime'] ?? DateTime.now().toIso8601String(),
      ),
      customerId: json['customerId']?.toString() ?? '',
      instanceStatus: json['instanceStatus'] ?? '',
      sendToCustomerOnSubmit: json['sendToCustomerOnSubmit'] ?? false,
      template: FormTemplate.fromJson(
        Map<String, dynamic>.from(json['template'] as Map? ?? {}),
      ),
      smartFieldData: json['smartFieldData'] ?? '{}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'queueId': queueId,
      'formInstanceId': formInstanceId,
      'appointmentId': appointmentId,
      'templateId': templateId,
      'resourceId': resourceId,
      'action': action,
      'triggerId': triggerId,
      'createdDateTime': createdDateTime.toIso8601String(),
      'customerId': customerId,
      'instanceStatus': instanceStatus,
      'sendToCustomerOnSubmit': sendToCustomerOnSubmit,
      'template': template.toJson(),
      'smartFieldData': smartFieldData,
    };
  }
}

/// Form template from the poll response
class FormTemplate {
  final int id;
  final String name;
  final String description;
  final String structure; // JSON string
  final bool requireSignature;
  final bool requireTip;

  FormTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.structure,
    required this.requireSignature,
    required this.requireTip,
  });

  factory FormTemplate.fromJson(Map<String, dynamic> json) {
    return FormTemplate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      structure: json['structure'] ?? '{}',
      requireSignature: json['requireSignature'] ?? false,
      requireTip: json['requireTip'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'structure': structure,
      'requireSignature': requireSignature,
      'requireTip': requireTip,
    };
  }

  /// Get the PDF file name from the structure JSON
  /// Returns the PDF file name if available, otherwise returns the template name
  String get pdfFileName {
    try {
      if (structure.isEmpty) return name;

      // Parse the structure JSON
      final structureJson = _parseJson(structure);
      if (structureJson.isEmpty) return name;

      // Extract pdfFile.name
      final pdfFile = structureJson['pdfFile'] as Map<String, dynamic>?;
      if (pdfFile != null && pdfFile['name'] != null) {
        final fileName = pdfFile['name'] as String;
        if (fileName.isNotEmpty) {
          return fileName;
        }
      }

      return name;
    } catch (e) {
      // Fallback to template name if parsing fails
      return name;
    }
  }

  /// Simple JSON parser
  static Map<String, dynamic> _parseJson(String jsonString) {
    try {
      if (jsonString.startsWith('{')) {
        final decoded = jsonDecode(jsonString);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return <String, dynamic>{};
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}

// ============== ACK REQUEST/RESPONSE MODELS ==============

/// Request body for the ack endpoint
class AckRequest {
  final String companyId;
  final List<int> queueIds;
  final String? deviceInfo;

  AckRequest({
    required this.companyId,
    required this.queueIds,
    this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'queueIds': queueIds,
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
    };
  }
}

/// Response from the ack endpoint
class AckResponse {
  final bool success;
  final List<int> acked;
  final int requested;

  AckResponse({
    required this.success,
    required this.acked,
    required this.requested,
  });

  factory AckResponse.fromJson(Map<String, dynamic> json) {
    return AckResponse(
      success: json['success'] ?? false,
      acked: (json['acked'] as List? ?? []).map((e) => e as int).toList(),
      requested: json['requested'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'acked': acked,
      'requested': requested,
    };
  }
}

// ============== SUBMIT REQUEST/RESPONSE MODELS ==============

/// Request body for the submit endpoint
class SubmitRequest {
  final String companyId;
  final int formInstanceId;
  final int? queueId;
  final int templateId;
  final String appointmentId;
  final String? customerId;
  final String? deviceInfo;
  final List<FieldResponse> responses;

  SubmitRequest({
    required this.companyId,
    required this.formInstanceId,
    this.queueId,
    required this.templateId,
    required this.appointmentId,
    this.customerId,
    this.deviceInfo,
    required this.responses,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'formInstanceId': formInstanceId,
      if (queueId != null) 'queueId': queueId,
      'templateId': templateId,
      'appointmentId': appointmentId,
      if (customerId != null) 'customerId': customerId,
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
      'responses': responses.map((r) => r.toJson()).toList(),
    };
  }
}

/// A single field response in the submit request
class FieldResponse {
  final String fieldId;
  final String label;
  final String type;
  final String value;
  final FieldPosition? position;

  FieldResponse({
    required this.fieldId,
    required this.label,
    required this.type,
    required this.value,
    this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'label': label,
      'type': type,
      'value': value,
      if (position != null) 'position': position!.toJson(),
    };
  }

  /// Create a text field response
  factory FieldResponse.text({
    required String fieldId,
    required String label,
    required String value,
    FieldPosition? position,
  }) =>
      FieldResponse(
        fieldId: fieldId,
        label: label,
        type: 'text',
        value: value,
        position: position,
      );

  /// Create a textarea field response
  factory FieldResponse.textarea({
    required String fieldId,
    required String label,
    required String value,
    FieldPosition? position,
  }) =>
      FieldResponse(
        fieldId: fieldId,
        label: label,
        type: 'textarea',
        value: value,
        position: position,
      );

  /// Create a signature field response
  factory FieldResponse.signature({
    required String fieldId,
    required String label,
    required String base64DataUrl, // "data:image/png;base64,..."
    FieldPosition? position,
  }) =>
      FieldResponse(
        fieldId: fieldId,
        label: label,
        type: 'signature',
        value: base64DataUrl,
        position: position,
      );

  /// Create a parts table field response
  factory FieldResponse.partsTable({
    required String fieldId,
    required String label,
    required PartsTableData data,
    FieldPosition? position,
  }) =>
      FieldResponse(
        fieldId: fieldId,
        label: label,
        type: 'partstable',
        value: data.toJsonString(),
        position: position,
      );

  /// Create a number field response
  factory FieldResponse.number({
    required String fieldId,
    required String label,
    required num value,
    FieldPosition? position,
  }) =>
      FieldResponse(
        fieldId: fieldId,
        label: label,
        type: 'number',
        value: value.toString(),
        position: position,
      );

  /// Create a date field response
  factory FieldResponse.date({
    required String fieldId,
    required String label,
    required DateTime value,
    FieldPosition? position,
  }) =>
      FieldResponse(
        fieldId: fieldId,
        label: label,
        type: 'date',
        value: value.toIso8601String().split('T')[0], // YYYY-MM-DD
        position: position,
      );

  /// Create a checkbox field response
  factory FieldResponse.checkbox({
    required String fieldId,
    required String label,
    required List<String> selectedValues,
    FieldPosition? position,
  }) =>
      FieldResponse(
        fieldId: fieldId,
        label: label,
        type: 'checkbox',
        value: selectedValues.join(','),
        position: position,
      );

  /// Create a check (yes/no) field response
  factory FieldResponse.check({
    required String fieldId,
    required String label,
    required bool value,
    FieldPosition? position,
  }) =>
      FieldResponse(
        fieldId: fieldId,
        label: label,
        type: 'check',
        value: value ? 'true' : 'false',
        position: position,
      );
}

/// Position of a field on a PDF page
class FieldPosition {
  final int page;
  final double xPct;
  final double yPct;
  final double wPct;
  final double hPct;

  FieldPosition({
    required this.page,
    required this.xPct,
    required this.yPct,
    required this.wPct,
    required this.hPct,
  });

  factory FieldPosition.fromJson(Map<String, dynamic> json) {
    return FieldPosition(
      page: json['page'] ?? 0,
      xPct: (json['xPct'] ?? 0).toDouble(),
      yPct: (json['yPct'] ?? 0).toDouble(),
      wPct: (json['wPct'] ?? 0).toDouble(),
      hPct: (json['hPct'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'xPct': xPct,
      'yPct': yPct,
      'wPct': wPct,
      'hPct': hPct,
    };
  }
}

/// Response from the submit endpoint
class SubmitResponse {
  final bool success;
  final int formResponseId;
  final int instancesUpdated;
  final String? stampedPdfUrl;
  final String? stampError;
  final String? emailStatus;
  final String? emailError;

  SubmitResponse({
    required this.success,
    required this.formResponseId,
    required this.instancesUpdated,
    this.stampedPdfUrl,
    this.stampError,
    this.emailStatus,
    this.emailError,
  });

  factory SubmitResponse.fromJson(Map<String, dynamic> json) {
    return SubmitResponse(
      success: json['success'] ?? false,
      formResponseId: json['formResponseId'] ?? 0,
      instancesUpdated: json['instancesUpdated'] ?? 0,
      stampedPdfUrl: json['stampedPdfUrl'],
      stampError: json['stampError'],
      emailStatus: json['emailStatus'],
      emailError: json['emailError'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'formResponseId': formResponseId,
      'instancesUpdated': instancesUpdated,
      'stampedPdfUrl': stampedPdfUrl,
      'stampError': stampError,
      'emailStatus': emailStatus,
      'emailError': emailError,
    };
  }
}

// ============== PARTS TABLE MODELS ==============

/// Data for a parts table field
class PartsTableData {
  final String variant; // "used" or "toOrder"
  final List<PartRow> rows;

  PartsTableData({
    required this.variant,
    required this.rows,
  });

  /// Convert to JSON string for the API
  String toJsonString() {
    final jsonData = {
      'variant': variant,
      'rows': rows.map((r) => r.toJson()).toList(),
    };
    // Use dart:convert to encode properly
    return _jsonEncode(data: jsonData);
  }

  Map<String, dynamic> toJson() {
    return {
      'variant': variant,
      'rows': rows.map((r) => r.toJson()).toList(),
    };
  }

  static String _jsonEncode({required Map<String, dynamic> data}) {
    // Simple JSON encoding for parts table
    final buffer = StringBuffer('{');
    buffer.write('"variant":"${data['variant']}",');
    buffer.write('"rows":[');
    final rows = data['rows'] as List;
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) buffer.write(',');
      final row = rows[i] as Map<String, dynamic>;
      buffer.write('{');
      buffer.write('"itemId":${row['itemId'] == null ? 'null' : '"${row['itemId']}"'},');
      buffer.write('"name":"${row['name']}",');
      buffer.write('"description":"${row['description']}",');
      buffer.write('"qty":${row['qty']},');
      buffer.write('"price":${row['price'] == null ? 'null' : row['price']},');
      buffer.write('"partNumber":${row['partNumber'] == null ? 'null' : '"${row['partNumber']}"'}');
      buffer.write('}');
    }
    buffer.write(']}');
    return buffer.toString();
  }
}

/// A single row in a parts table
class PartRow {
  final String? itemId; // Pricebook GUID or null
  final String name;
  final String description;
  final int qty;
  final double? price;
  final String? partNumber;

  PartRow({
    this.itemId,
    required this.name,
    required this.description,
    required this.qty,
    this.price,
    this.partNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'description': description,
      'qty': qty,
      'price': price,
      'partNumber': partNumber,
    };
  }
}

// ============== TEMPLATE STRUCTURE MODELS ==============

/// Parsed form template structure
class FormTemplateStructure {
  final String version;
  final String mode; // "web" or "pdf"
  final List<FormSection>? sections; // For web mode
  final PdfFileInfo? pdfFile; // For PDF mode
  final List<FormField>? fields; // For PDF mode

  FormTemplateStructure({
    required this.version,
    required this.mode,
    this.sections,
    this.pdfFile,
    this.fields,
  });

  /// Parse from JSON string
  static FormTemplateStructure? tryParse(String jsonString) {
    try {
      // Would use dart:convert in real implementation
      // For now, return null to indicate parsing not implemented
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// PDF file info for template
class PdfFileInfo {
  final String path;
  final String name;
  final int pageCount;

  PdfFileInfo({
    required this.path,
    required this.name,
    required this.pageCount,
  });

  factory PdfFileInfo.fromJson(Map<String, dynamic> json) {
    return PdfFileInfo(
      path: json['path'] ?? '',
      name: json['name'] ?? '',
      pageCount: json['pageCount'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'pageCount': pageCount,
    };
  }
}

/// A form field definition
class FormField {
  final String id;
  final String? header; // For PDF mode
  final String? label; // For web mode
  final String type;
  final String? smartFieldSource;
  final bool required;
  final FieldPosition? position;

  FormField({
    required this.id,
    this.header,
    this.label,
    required this.type,
    this.smartFieldSource,
    required this.required,
    this.position,
  });

  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      id: json['id'] ?? '',
      header: json['header'],
      label: json['label'],
      type: json['type'] ?? '',
      smartFieldSource: json['smartFieldSource'],
      required: json['required'] ?? false,
      position: json['position'] != null
          ? FieldPosition.fromJson(json['position'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'header': header,
      'label': label,
      'type': type,
      'smartFieldSource': smartFieldSource,
      'required': required,
      'position': position?.toJson(),
    };
  }

  /// Get the display name (header for PDF, label for web)
  String get displayName => header ?? label ?? 'Untitled';
}

/// A form section (web mode)
class FormSection {
  final String id;
  final String title;
  final List<FormRow> rows;

  FormSection({
    required this.id,
    required this.title,
    required this.rows,
  });

  factory FormSection.fromJson(Map<String, dynamic> json) {
    return FormSection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      rows: (json['rows'] as List? ?? []).map((r) => FormRow.fromJson(r)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rows': rows.map((r) => r.toJson()).toList(),
    };
  }
}

/// A row in a form section
class FormRow {
  final String id;
  final List<FormField> fields;

  FormRow({
    required this.id,
    required this.fields,
  });

  factory FormRow.fromJson(Map<String, dynamic> json) {
    return FormRow(
      id: json['id'] ?? '',
      fields: (json['fields'] as List? ?? [])
          .map((f) => FormField.fromJson(f))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fields': fields.map((f) => f.toJson()).toList(),
    };
  }
}
