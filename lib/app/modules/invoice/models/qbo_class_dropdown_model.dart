class QboClassModel {
  final int id;
  final String name;
  final int qboClassId;
  final String companyId;

  QboClassModel({
    required this.id,
    required this.name,
    required this.qboClassId,
    required this.companyId,
  });

  factory QboClassModel.fromJson(Map<String, dynamic> json) {
    return QboClassModel(
      id: json['ID'] as int,
      name: json['Name'] as String,
      qboClassId: json['QboClassId'] as int,
      companyId: json['CompanyId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Name': name,
      'QboClassId': qboClassId,
      'CompanyId': companyId,
    };
  }
}
