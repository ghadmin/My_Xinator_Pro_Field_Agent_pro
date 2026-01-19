class QboLocationModel {
  final int id;
  final String name;
  final int qboLocationId;
  final String companyId;

  QboLocationModel({
    required this.id,
    required this.name,
    required this.qboLocationId,
    required this.companyId,
  });

  factory QboLocationModel.fromJson(Map<String, dynamic> json) {
    return QboLocationModel(
      id: json['ID'] as int,
      name: json['Name'] as String,
      qboLocationId: json['QboLocationID'] as int,
      companyId: json['CompanyId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Name': name,
      'QboLocationID': qboLocationId,
      'CompanyId': companyId,
    };
  }
}
