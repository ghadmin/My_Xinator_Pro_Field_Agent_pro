import 'dart:convert';

class CustomFieldModel {
  int? fieldID;
  String? fieldName;
  String? fieldType;
  String? fieldOptions;
  bool? isActive;
  List<String>? options; // For dropdown or checklist

  String? appliesTo;
  String? createdDateTime;
  String? companyId;
  String? selectedValue; // For dropdown
  List<String>? selectedOptions = []; // For checklist

  // Added to store field values
  String? textValue; // For text field
  String? numberValue; // For number field

  CustomFieldModel(
      {this.fieldID,
      this.fieldName,
      this.fieldType,
      this.fieldOptions,
      this.isActive,
      this.options,
      this.appliesTo,
      this.createdDateTime,
      this.companyId});

  CustomFieldModel.fromJson(Map<String, dynamic> json) {
    fieldID = json['FieldID'];
    fieldName = json['FieldName'];
    fieldType = json['FieldType'];
    fieldOptions = json['FieldOptions'];
    isActive = json['IsActive'];
    appliesTo = json['AppliesTo'];
    createdDateTime = json['CreatedDateTime'];
    companyId = json['CompanyId'];
    options = fieldOptions != null
        ? List<String>.from(jsonDecode(fieldOptions!))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FieldID'] = fieldID;
    data['FieldName'] = fieldName;
    data['FieldType'] = fieldType;
    data['FieldOptions'] = fieldOptions;
    data['IsActive'] = isActive;
    data['AppliesTo'] = appliesTo;
    data['CreatedDateTime'] = createdDateTime;
    data['CompanyId'] = companyId;
    return data;
  }

  /// Get the value of the custom field as a string
  String? getFieldValue() {
    switch (fieldType) {
      case 'dropdown':
        return selectedValue;
      case 'checklist':
        return selectedOptions?.join(', ');
      case 'text':
        return textValue;
      case 'number':
        return numberValue;
      default:
        return null;
    }
  }

  /// Get a map of field name to value
  Map<String, dynamic> toFieldMap() {
    return {
      fieldName!: getFieldValue(),
    };
  }

  List<CustomFieldModel> parseCustomFields(String jsonResponse) {
    final List<dynamic> decodedJson = json.decode(jsonResponse);
    return decodedJson.map((field) {
      return CustomFieldModel(
        fieldID: field['FieldID'],
        fieldName: field['FieldName'],
        fieldType: field['FieldType'],
        options: field['FieldOptions'] != null
            ? List<String>.from(json.decode(field['FieldOptions']))
            : null,
        isActive: field['IsActive'],
        appliesTo: field['AppliesTo'],
        createdDateTime: DateTime.fromMillisecondsSinceEpoch(
          int.parse(field['CreatedDateTime'].replaceAll(RegExp(r'[^0-9]'), '')),
        ).toString(),
        companyId: field['CompanyId'],
      );
    }).toList();
  }
}
