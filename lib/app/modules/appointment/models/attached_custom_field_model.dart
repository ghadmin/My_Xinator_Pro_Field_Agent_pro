import 'dart:convert';

class AttachedCustomFieldModel {
  int? appointmentID;
  int? fieldID;
  String? fieldValue;
  String? lastUpdated;

  AttachedCustomFieldModel({
    this.appointmentID,
    this.fieldID,
    this.fieldValue,
    this.lastUpdated,
  });

  factory AttachedCustomFieldModel.fromJson(Map<String, dynamic> json) {
    return AttachedCustomFieldModel(
      appointmentID: json['AppointmentID'],
      fieldID: json['FieldID'],
      fieldValue: json['FieldValue'],
      lastUpdated: json['LastUpdated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AppointmentID': appointmentID,
      'FieldID': fieldID,
      'FieldValue': fieldValue,
      'LastUpdated': lastUpdated,
    };
  }

  /// Parse the field value as a list (for checklist fields)
  /// Returns a list of strings if the value is a JSON array string
  /// Returns a list with the single string value otherwise
  List<String> getFieldValueAsList() {
    if (fieldValue == null || fieldValue!.isEmpty) {
      return [];
    }

    try {
      // Try to parse as JSON array
      final parsed = jsonDecode(fieldValue!);
      if (parsed is List) {
        return parsed.map((e) => e.toString()).toList();
      }
    } catch (e) {
      // If parsing fails, treat as single string value
    }

    // Return as single item list if not a valid JSON array
    return [fieldValue!];
  }

  /// Check if this is a checklist field (value is a JSON array)
  bool get isChecklist {
    if (fieldValue == null || fieldValue!.isEmpty) {
      return false;
    }
    try {
      final parsed = jsonDecode(fieldValue!);
      return parsed is List;
    } catch (e) {
      return false;
    }
  }

  /// Get the field value as a single string (for non-checklist fields)
  String getFieldValueAsString() {
    if (fieldValue == null || fieldValue!.isEmpty) {
      return '';
    }

    // If it's a checklist (JSON array), return comma-separated values
    if (isChecklist) {
      final list = getFieldValueAsList();
      return list.join(', ');
    }

    return fieldValue!;
  }
}
