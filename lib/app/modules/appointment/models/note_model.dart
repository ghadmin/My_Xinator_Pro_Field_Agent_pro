class NoteModel {
  final int? id;
  final String? description;
  final String? createdAt;
  final int? cslId;
  final int? customerId;
  final int? appointmentId;
  final String? companyId;
  final String? userId;
  final int? tagId;
  final String? userName;

  NoteModel({
    this.id,
    this.description,
    this.createdAt,
    this.cslId,
    this.customerId,
    this.appointmentId,
    this.companyId,
    this.userId,
    this.tagId,
    this.userName,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['Id'],
      description: json['Description'],
      createdAt: json['CreatedAt'],
      cslId: json['CSLId'],
      customerId: json['CustomerId'],
      appointmentId: json['AppointmentId'],
      companyId: json['CompanyId'],
      userId: json['UserId'],
      tagId: json['TagId'],
      userName: json['UserName'],
    );
  }

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Description": description,
        "CreatedAt": createdAt,
        "CSLId": cslId,
        "CustomerId": customerId,
        "AppointmentId": appointmentId,
        "CompanyId": companyId,
        "UserId": userId,
        "TagId": tagId,
        "UserName": userName,
      };
}
