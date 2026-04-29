import 'package:intl/intl.dart';

/// Model class for Equipment
/// Used for storing equipment information in appointments
class EquipmentModel {
  // Primary fields
  final String? id;
  final String? companyId;
  final String? customerId;
  final String? customerGuid;
  final int? siteId;
  final String serialNumber;
  final String? equipmentTypeId; // ID from EquipmentTypeModel
  final String? make;
  final String? model;
  final String? barcode;
  final String? sku;
  final String? notes;

  // Date fields (stored as ISO strings, API sends MM/dd/yyyy format)
  final String? warrantyStart;
  final String? warrantyEnd;
  final String? laborWarrantyStart;
  final String? laborWarrantyEnd;
  final String? installDate;
  final String? createdAt;
  final String? updatedAt;

  // Computed type name (not from API, used for display)
  final String type;

  EquipmentModel({
    this.id,
    this.companyId,
    this.customerId,
    this.customerGuid,
    this.siteId,
    required this.serialNumber,
    this.equipmentTypeId,
    this.type = '',
    this.make,
    this.model,
    this.barcode,
    this.sku,
    this.notes,
    this.warrantyStart,
    this.warrantyEnd,
    this.laborWarrantyStart,
    this.laborWarrantyEnd,
    this.installDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Parse date from API format (MM/dd/yyyy) to ISO format
  static String? _parseApiDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    if (dateStr == '01/01/1900') return null; // Treat as null/default
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final month = parts[0].padLeft(2, '0');
        final day = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day'; // Convert to ISO-like format
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  /// Format ISO date to API format (MM/dd/yyyy)
  static String? _formatApiDate(String? isoDateStr) {
    if (isoDateStr == null || isoDateStr.isEmpty) return '01/01/1900';
    try {
      final date = DateTime.parse(isoDateStr);
      return DateFormat('MM/dd/yyyy').format(date);
    } catch (e) {
      return '01/01/1900';
    }
  }

  /// Create EquipmentModel from JSON (snake_case - local storage)
  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] as String?,
      companyId: json['company_id'] as String?,
      customerId: json['customer_id'] as String?,
      customerGuid: json['customer_guid'] as String?,
      siteId: json['site_id'] as int?,
      serialNumber: json['serial_number'] as String? ?? '',
      equipmentTypeId: json['equipment_type_id'] as String?,
      type: json['type'] as String? ?? '',
      make: json['make'] as String?,
      model: json['model'] as String?,
      barcode: json['barcode'] as String?,
      sku: json['sku'] as String?,
      notes: json['notes'] as String?,
      warrantyStart: json['warranty_start'] as String?,
      warrantyEnd: json['warranty_end'] as String?,
      laborWarrantyStart: json['labor_warranty_start'] as String?,
      laborWarrantyEnd: json['labor_warranty_end'] as String?,
      installDate: json['install_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Create EquipmentModel from server JSON (PascalCase)
  factory EquipmentModel.fromJsonServer(Map<String, dynamic> json) {
    final serialNumber = json['SerialNumber'] as String? ?? '';
    final make = json['Make'] as String?;
    final model = json['Model'] as String?;
    final barcode = json['Barcode'] as String?;
    final notes = json['Notes'] as String?;

    return EquipmentModel(
      id: json['Id']?.toString(),
      companyId: json['CompanyID'] as String?,
      customerId: json['CustomerID']?.toString(),
      customerGuid: json['CustomerGuid'] as String?,
      siteId: json['SiteId'] as int?,
      serialNumber: serialNumber.isNotEmpty ? serialNumber : 'N/A',
      equipmentTypeId: json['EquipmentTypeID']?.toString(),
      make: make?.isNotEmpty == true ? make : null,
      model: model?.isNotEmpty == true ? model : null,
      barcode: barcode?.isNotEmpty == true ? barcode : null,
      sku: barcode?.isNotEmpty == true ? barcode : null, // API doesn't have SKU, using Barcode
      notes: notes?.isNotEmpty == true ? notes : null,
      warrantyStart: _parseApiDate(json['WarrantyStart'] as String?),
      warrantyEnd: _parseApiDate(json['WarrantyEnd'] as String?),
      laborWarrantyStart: _parseApiDate(json['LaborWarrantyStart'] as String?),
      laborWarrantyEnd: _parseApiDate(json['LaborWarrantyEnd'] as String?),
      installDate: _parseApiDate(json['InstallDate'] as String?),
      createdAt: _parseApiDate(json['CreatedDateTime'] as String?),
      updatedAt: _parseApiDate(json['UpdatedDateTime'] as String?),
      type: json['EquipmentType'] as String? ?? '', // Use EquipmentType from API response
    );
  }

  /// Convert EquipmentModel to JSON (snake_case - local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'customer_id': customerId,
      'customer_guid': customerGuid,
      'site_id': siteId,
      'serial_number': serialNumber,
      'equipment_type_id': equipmentTypeId,
      'type': type,
      'make': make,
      'model': model,
      'barcode': barcode,
      'sku': sku,
      'notes': notes,
      'warranty_start': warrantyStart,
      'warranty_end': warrantyEnd,
      'labor_warranty_start': laborWarrantyStart,
      'labor_warranty_end': laborWarrantyEnd,
      'install_date': installDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convert to server JSON format (PascalCase)
  Map<String, dynamic> toJsonServer() {
    return {
      'Id': id ?? '',
      'CompanyID': companyId ?? '',
      'CustomerID': customerId ?? '',
      'CustomerGuid': customerGuid ?? '',
      'SiteId': siteId ?? 0,
      'Model': model ?? '',
      'Make': make ?? '',
      'SerialNumber': serialNumber,
      'Barcode': barcode ?? '',
      'EquipmentTypeID': equipmentTypeId ?? '',
      'EquipmentTypeDesc': type, // This might not be used by API
      'Notes': notes ?? '',
      'WarrantyStart': _formatApiDate(warrantyStart),
      'WarrantyEnd': _formatApiDate(warrantyEnd),
      'LaborWarrantyStart': _formatApiDate(laborWarrantyStart),
      'LaborWarrantyEnd': _formatApiDate(laborWarrantyEnd),
      'InstallDate': _formatApiDate(installDate),
      'CreatedDateTime': _formatApiDate(createdAt) ?? DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now()),
    };
  }

  /// Create a copy of this EquipmentModel with some fields replaced
  EquipmentModel copyWith({
    String? id,
    String? companyId,
    String? customerId,
    String? customerGuid,
    int? siteId,
    String? serialNumber,
    String? equipmentTypeId,
    String? type,
    String? make,
    String? model,
    String? barcode,
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
      companyId: companyId ?? this.companyId,
      customerId: customerId ?? this.customerId,
      customerGuid: customerGuid ?? this.customerGuid,
      siteId: siteId ?? this.siteId,
      serialNumber: serialNumber ?? this.serialNumber,
      equipmentTypeId: equipmentTypeId ?? this.equipmentTypeId,
      type: type ?? this.type,
      make: make ?? this.make,
      model: model ?? this.model,
      barcode: barcode ?? this.barcode,
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
