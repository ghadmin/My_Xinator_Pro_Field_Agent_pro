class FormFieldModel {
  final String id;
  final String type;
  final String? header;
  final FieldPosition position;
  final int page;
  final String? smartFieldSource;
  final List<String>? dropdownOptions;
  final int? maxRows;
  final dynamic defaultValue;

  FormFieldModel({
    required this.id,
    required this.type,
    this.header,
    required this.position,
    required this.page,
    this.smartFieldSource,
    this.dropdownOptions,
    this.maxRows,
    this.defaultValue,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      id: json['id'] ?? json['fieldId'] ?? '',
      type: json['type'] ?? 'text',
      header: json['header'],
      position: FieldPosition.fromJson(json['position'] ?? {}),
      page: json['page'] ?? json['pageIndex'] ?? 0,
      smartFieldSource: json['smartFieldSource'],
      dropdownOptions: json['dropdownOptions'] != null
          ? List<String>.from(json['dropdownOptions'])
          : null,
      maxRows: json['maxRows'],
      defaultValue: json['defaultValue'],
    );
  }
}

class FieldPosition {
  final double xPct;
  final double yPct;
  final double wPct;
  final double hPct;

  FieldPosition({
    required this.xPct,
    required this.yPct,
    required this.wPct,
    required this.hPct,
  });

  factory FieldPosition.fromJson(Map<String, dynamic> json) {
    return FieldPosition(
      xPct: (json['xPct'] ?? 0.0).toDouble(),
      yPct: (json['yPct'] ?? 0.0).toDouble(),
      wPct: (json['wPct'] ?? 100.0).toDouble(),
      hPct: (json['hPct'] ?? 10.0).toDouble(),
    );
  }
}

class FormTemplateModel {
  final String pdfPath;
  final int totalPages;
  final List<FormFieldModel> fields;

  FormTemplateModel({
    required this.pdfPath,
    required this.totalPages,
    required this.fields,
  });

  factory FormTemplateModel.fromJson(Map<String, dynamic> json) {
    var fieldsList = <FormFieldModel>[];
    if (json['fields'] != null) {
      fieldsList = (json['fields'] as List)
          .map((field) => FormFieldModel.fromJson(field))
          .toList();
    }

    return FormTemplateModel(
      pdfPath: json['pdfPath'] ?? '',
      totalPages: json['totalPages'] ?? json['pageCount'] ?? 1,
      fields: fieldsList,
    );
  }

  List<FormFieldModel> getFieldsForPage(int pageNum) {
    return fields.where((field) => field.page == pageNum).toList();
  }
}

class PartsTableRow {
  String qty;
  String description;

  PartsTableRow({
    this.qty = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'qty': qty,
      'description': description,
    };
  }

  factory PartsTableRow.fromJson(Map<String, dynamic> json) {
    return PartsTableRow(
      qty: json['qty']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}
