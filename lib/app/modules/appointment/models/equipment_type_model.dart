/// Equipment Type Model
/// Used for equipment type dropdown
class EquipmentTypeModel {
  final String equipmentTypeId;
  final String equipmentTypeDesc;

  EquipmentTypeModel({
    required this.equipmentTypeId,
    required this.equipmentTypeDesc,
  });

  /// Create EquipmentTypeModel from JSON
  factory EquipmentTypeModel.fromJson(Map<String, dynamic> json) {
    return EquipmentTypeModel(
      equipmentTypeId: json['EquipmentTypeID']?.toString() ?? '',
      equipmentTypeDesc: json['EquipmentTypeDesc']?.toString() ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'EquipmentTypeID': equipmentTypeId,
      'EquipmentTypeDesc': equipmentTypeDesc,
    };
  }

  @override
  String toString() => equipmentTypeDesc;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentTypeModel &&
          runtimeType == other.runtimeType &&
          equipmentTypeId == other.equipmentTypeId;

  @override
  int get hashCode => equipmentTypeId.hashCode;
}
