class Equipment {
  final int id;
  final int siteId;
  final String customerGuid;
  final String customerId;
  final String customerName;
  final String? make;
  final String? model;
  final String? notes;
  final String? barcode;
  final String? serialNumber;
  final int? equipmentTypeId;
  final String? equipmentType;
  final String createdDateTime;
  final String? warrantyStart;
  final String? warrantyEnd;
  final String? laborWarrantyStart;
  final String? laborWarrantyEnd;
  final String? installDate;

  Equipment({
    required this.id,
    required this.siteId,
    required this.customerGuid,
    required this.customerId,
    required this.customerName,
    this.make,
    this.model,
    this.notes,
    this.barcode,
    this.serialNumber,
    this.equipmentTypeId,
    this.equipmentType,
    required this.createdDateTime,
    this.warrantyStart,
    this.warrantyEnd,
    this.laborWarrantyStart,
    this.laborWarrantyEnd,
    this.installDate,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as int,
      siteId: json['siteId'] as int,
      customerGuid: json['customerGuid'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      make: json['make'] as String?,
      model: json['model'] as String?,
      notes: json['notes'] as String?,
      barcode: json['barcode'] as String?,
      serialNumber: json['serialNumber'] as String?,
      equipmentTypeId: json['equipmentTypeId'] as int?,
      equipmentType: json['equipmentType'] as String?,
      createdDateTime: json['createdDateTime'] as String,
      warrantyStart: json['warrantyStart'] as String?,
      warrantyEnd: json['warrantyEnd'] as String?,
      laborWarrantyStart: json['laborWarrantyStart'] as String?,
      laborWarrantyEnd: json['laborWarrantyEnd'] as String?,
      installDate: json['installDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'customerGuid': customerGuid,
      'customerId': customerId,
      'customerName': customerName,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (notes != null) 'notes': notes,
      if (barcode != null) 'barcode': barcode,
      if (serialNumber != null) 'serialNumber': serialNumber,
      if (equipmentTypeId != null) 'equipmentTypeId': equipmentTypeId,
      if (equipmentType != null) 'equipmentType': equipmentType,
      'createdDateTime': createdDateTime,
      if (warrantyStart != null) 'warrantyStart': warrantyStart,
      if (warrantyEnd != null) 'warrantyEnd': warrantyEnd,
      if (laborWarrantyStart != null) 'laborWarrantyStart': laborWarrantyStart,
      if (laborWarrantyEnd != null) 'laborWarrantyEnd': laborWarrantyEnd,
      if (installDate != null) 'installDate': installDate,
    };
  }
}

class EquipmentType {
  final String id;
  final String typeName;
  final String createdBy;
  final String updatedBy;
  final String createdDateTime;
  final String updateDateTime;

  EquipmentType({
    required this.id,
    required this.typeName,
    required this.createdBy,
    required this.updatedBy,
    required this.createdDateTime,
    required this.updateDateTime,
  });

  factory EquipmentType.fromJson(Map<String, dynamic> json) {
    return EquipmentType(
      id: json['id'].toString(),
      typeName: json['typeName'] as String,
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String,
      createdDateTime: json['createdDateTime'] as String,
      updateDateTime: json['updateDateTime'] as String,
    );
  }
}
