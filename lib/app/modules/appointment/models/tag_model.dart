class TagModel {
  final int id;
  final String name;
  final String description;
  final String companyId;
  final String createdAt; // keep as String because of invalid "00" month

  TagModel({
    required this.id,
    required this.name,
    required this.description,
    required this.companyId,
    required this.createdAt,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['Id'] as int,
      name: json['Name'] as String,
      description: json['Description'] as String,
      companyId: json['CompanyId'] as String,
      createdAt: json['CreatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Description': description,
      'CompanyId': companyId,
      'CreatedAt': createdAt,
    };
  }
}
