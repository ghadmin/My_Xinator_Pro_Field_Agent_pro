/// Model class for Equipment
/// Used for storing equipment information in appointments
class EquipmentModel {
  final String? id;
  final String serialNumber;
  final String type;
  final String? make;
  final String? model;
  final String? sku;
  final String? warrantyStart;
  final String? warrantyEnd;
  final String? laborWarrantyStart;
  final String? laborWarrantyEnd;
  final String? installDate;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  EquipmentModel({
    this.id,
    required this.serialNumber,
    required this.type,
    this.make,
    this.model,
    this.sku,
    this.warrantyStart,
    this.warrantyEnd,
    this.laborWarrantyStart,
    this.laborWarrantyEnd,
    this.installDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Create EquipmentModel from JSON (snake_case - local storage)
  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] as String?,
      serialNumber: json['serial_number'] as String? ?? '',
      type: json['type'] as String? ?? '',
      make: json['make'] as String?,
      model: json['model'] as String?,
      sku: json['sku'] as String?,
      warrantyStart: json['warranty_start'] as String?,
      warrantyEnd: json['warranty_end'] as String?,
      laborWarrantyStart: json['labor_warranty_start'] as String?,
      laborWarrantyEnd: json['labor_warranty_end'] as String?,
      installDate: json['install_date'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Create EquipmentModel from server JSON (PascalCase)
  factory EquipmentModel.fromJsonServer(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['Id']?.toString(),
      serialNumber: json['SerialNumber'] as String? ?? '',
      type: json['EquipmentType'] as String? ?? '',
      make: json['Make'] as String?,
      model: json['Model'] as String?,
      sku: json['Barcode'] as String?,
      warrantyStart: json['WarrantyStart'] as String?,
      warrantyEnd: json['WarrantyEnd'] as String?,
      laborWarrantyStart: json['LaborWarrantyStart'] as String?,
      laborWarrantyEnd: json['LaborWarrantyEnd'] as String?,
      installDate: json['InstallDate'] as String?,
      notes: json['Notes'] as String?,
      createdAt: json['CreatedDateTime'] as String?,
      updatedAt: json['UpdatedDateTime'] as String?,
    );
  }

  /// Convert EquipmentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial_number': serialNumber,
      'type': type,
      'make': make,
      'model': model,
      'sku': sku,
      'warranty_start': warrantyStart,
      'warranty_end': warrantyEnd,
      'labor_warranty_start': laborWarrantyStart,
      'labor_warranty_end': laborWarrantyEnd,
      'install_date': installDate,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Create a copy of this EquipmentModel with some fields replaced
  EquipmentModel copyWith({
    String? id,
    String? serialNumber,
    String? type,
    String? make,
    String? model,
    String? sku,
    String? warrantyStart,
    String? warrantyEnd,
    String? laborWarrantyStart,
    String? laborWarrantyEnd,
    String? installDate,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return EquipmentModel(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      type: type ?? this.type,
      make: make ?? this.make,
      model: model ?? this.model,
      sku: sku ?? this.sku,
      warrantyStart: warrantyStart ?? this.warrantyStart,
      warrantyEnd: warrantyEnd ?? this.warrantyEnd,
      laborWarrantyStart: laborWarrantyStart ?? this.laborWarrantyStart,
      laborWarrantyEnd: laborWarrantyEnd ?? this.laborWarrantyEnd,
      installDate: installDate ?? this.installDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display title for the equipment
  String get displayTitle {
    if (make != null && model != null) {
      return '$make $model ($serialNumber)';
    } else if (type.isNotEmpty) {
      return '$type - $serialNumber';
    }
    return serialNumber;
  }

  /// Check if warranty is still valid
  bool get isWarrantyValid {
    if (warrantyEnd == null || warrantyEnd!.isEmpty) return false;
    try {
      final endDate = DateTime.parse(warrantyEnd!);
      return DateTime.now().isBefore(endDate);
    } catch (e) {
      return false;
    }
  }

  /// Check if labor warranty is still valid
  bool get isLaborWarrantyValid {
    if (laborWarrantyEnd == null || laborWarrantyEnd!.isEmpty) return false;
    try {
      final endDate = DateTime.parse(laborWarrantyEnd!);
      return DateTime.now().isBefore(endDate);
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
    return 'EquipmentModel(id: $id, serialNumber: $serialNumber, type: $type, make: $make, model: $model)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EquipmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Form data class for Equipment form
/// Used to manage the form state for creating/editing equipment
class EquipmentFormData {
  final String serialNumber;
  final String type;
  final String make;
  final String model;
  final String sku;
  final DateTime? warrantyStart;
  final DateTime? warrantyEnd;
  final DateTime? laborWarrantyStart;
  final DateTime? laborWarrantyEnd;
  final DateTime? installDate;
  final String notes;

  EquipmentFormData({
    this.serialNumber = '',
    this.type = '',
    this.make = '',
    this.model = '',
    this.sku = '',
    this.warrantyStart,
    this.warrantyEnd,
    this.laborWarrantyStart,
    this.laborWarrantyEnd,
    this.installDate,
    this.notes = '',
  });

  /// Create form data from EquipmentModel
  factory EquipmentFormData.fromModel(EquipmentModel model) {
    return EquipmentFormData(
      serialNumber: model.serialNumber,
      type: model.type,
      make: model.make ?? '',
      model: model.model ?? '',
      sku: model.sku ?? '',
      warrantyStart: _parseDateString(model.warrantyStart),
      warrantyEnd: _parseDateString(model.warrantyEnd),
      laborWarrantyStart: _parseDateString(model.laborWarrantyStart),
      laborWarrantyEnd: _parseDateString(model.laborWarrantyEnd),
      installDate: _parseDateString(model.installDate),
      notes: model.notes ?? '',
    );
  }

  /// Helper to parse date string to DateTime
  static DateTime? _parseDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// Convert form data to EquipmentModel
  EquipmentModel toModel({String? id}) {
    return EquipmentModel(
      id: id,
      serialNumber: serialNumber,
      type: type,
      make: make.isEmpty ? null : make,
      model: model.isEmpty ? null : model,
      sku: sku.isEmpty ? null : sku,
      warrantyStart: _formatDate(warrantyStart),
      warrantyEnd: _formatDate(warrantyEnd),
      laborWarrantyStart: _formatDate(laborWarrantyStart),
      laborWarrantyEnd: _formatDate(laborWarrantyEnd),
      installDate: _formatDate(installDate),
      notes: notes.isEmpty ? null : notes,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Helper to format DateTime to ISO string
  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return date.toIso8601String();
  }

  /// Validate required fields
  bool get isValid => serialNumber.isNotEmpty && type.isNotEmpty;

  /// Get validation errors
  Map<String, String?> get validationErrors {
    final errors = <String, String?>{};
    if (serialNumber.isEmpty) {
      errors['serialNumber'] = 'Serial number is required';
    }
    if (type.isEmpty) {
      errors['type'] = 'Type is required';
    }
    return errors;
  }

  EquipmentFormData copyWith({
    String? serialNumber,
    String? type,
    String? make,
    String? model,
    String? sku,
    DateTime? warrantyStart,
    DateTime? warrantyEnd,
    DateTime? laborWarrantyStart,
    DateTime? laborWarrantyEnd,
    DateTime? installDate,
    String? notes,
  }) {
    return EquipmentFormData(
      serialNumber: serialNumber ?? this.serialNumber,
      type: type ?? this.type,
      make: make ?? this.make,
      model: model ?? this.model,
      sku: sku ?? this.sku,
      warrantyStart: warrantyStart ?? this.warrantyStart,
      warrantyEnd: warrantyEnd ?? this.warrantyEnd,
      laborWarrantyStart: laborWarrantyStart ?? this.laborWarrantyStart,
      laborWarrantyEnd: laborWarrantyEnd ?? this.laborWarrantyEnd,
      installDate: installDate ?? this.installDate,
      notes: notes ?? this.notes,
    );
  }
}
