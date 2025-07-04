import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 13)
class CustomerModel extends HiveObject {
  @HiveField(0)
  String? companyID;
  @HiveField(1)
  String? createdCompanyID;
  @HiveField(2)
  int? tagID;
  @HiveField(3)
  String? customerID;
  @HiveField(4)
  String? aMCustomerID;
  @HiveField(5)
  String? customerGuid;
  @HiveField(6)
  String? title;
  @HiveField(7)
  dynamic title2;
  @HiveField(8)
  String? firstName;
  @HiveField(9)
  dynamic firstName2;
  @HiveField(10)
  String? lastName;
  @HiveField(11)
  dynamic lastName2;
  @HiveField(12)
  String? jobTitle;
  @HiveField(13)
  dynamic jobTitle2;
  @HiveField(14)
  String? address1;
  @HiveField(15)
  String? address2;
  @HiveField(16)
  String? city;
  @HiveField(17)
  String? state;
  @HiveField(18)
  String? zipCode;
  @HiveField(19)
  String? phone;
  @HiveField(20)
  String? mobile;
  @HiveField(21)
  String? email;
  @HiveField(22)
  String? notes;
  @HiveField(23)
  dynamic createdDateTime;
  @HiveField(24)
  bool? callPopUploaded;
  @HiveField(25)
  int? qboId;
  @HiveField(26)
  dynamic callPopAppId;
  @HiveField(27)
  bool? isPrimaryContact;
  @HiveField(28)
  int? businessID;
  @HiveField(29)
  int? syncToken;
  @HiveField(30)
  String? businessName;
  @HiveField(31)
  bool? isBusinessContact;
  @HiveField(32)
  String? companyName;
  @HiveField(33)
  dynamic companyName2;
  @HiveField(34)
  String? dealerID;
  @HiveField(35)
  bool? isDealer;
  @HiveField(36)
  String? customerCode;
  @HiveField(37)
  String? updateDate;

  CustomerModel({
    this.companyID,
    this.createdCompanyID,
    this.tagID,
    this.customerID,
    this.aMCustomerID,
    this.customerGuid,
    this.title,
    this.title2,
    this.firstName,
    this.firstName2,
    this.lastName,
    this.lastName2,
    this.jobTitle,
    this.jobTitle2,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zipCode,
    this.phone,
    this.mobile,
    this.email,
    this.notes,
    this.createdDateTime,
    this.callPopUploaded,
    this.qboId,
    this.callPopAppId,
    this.isPrimaryContact,
    this.businessID,
    this.syncToken,
    this.businessName,
    this.isBusinessContact,
    this.companyName,
    this.companyName2,
    this.dealerID,
    this.isDealer,
    this.customerCode,
    this.updateDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      companyID: json['CompanyID'],
      createdCompanyID: json['CreatedCompanyID'],
      tagID: json['TagID'],
      customerID: json['CustomerID'],
      aMCustomerID: json['AMCustomerID'],
      customerGuid: json['CustomerGuid'],
      title: json['Title'],
      title2: json['Title2'],
      firstName: json['FirstName'],
      firstName2: json['FirstName2'],
      lastName: json['LastName'],
      lastName2: json['LastName2'],
      jobTitle: json['JobTitle'],
      jobTitle2: json['JobTitle2'],
      address1: json['Address1'],
      address2: json['Address2'],
      city: json['City'],
      state: json['State'],
      zipCode: json['ZipCode'],
      phone: json['Phone'],
      mobile: json['Mobile'],
      email: json['Email'],
      notes: json['Notes'],
      createdDateTime: json['CreatedDateTime'],
      callPopUploaded: json['CallPopUploaded'],
      qboId: json['QboId'],
      callPopAppId: json['CallPopAppId'],
      isPrimaryContact: json['IsPrimaryContact'],
      businessID: json['BusinessID'],
      syncToken: json['SyncToken'],
      businessName: json['BusinessName'],
      isBusinessContact: json['IsBusinessContact'],
      companyName: json['CompanyName'],
      companyName2: json['CompanyName2'],
      dealerID: json['DealerID'],
      isDealer: json['IsDealer'],
      customerCode: json['CustomerCode'],
      updateDate: json['UpdateDate'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = companyID;
    map['CreatedCompanyID'] = createdCompanyID;
    map['TagID'] = tagID;
    map['CustomerID'] = customerID;
    map['AMCustomerID'] = aMCustomerID;
    map['CustomerGuid'] = customerGuid;
    map['Title'] = title;
    map['Title2'] = title2;
    map['FirstName'] = firstName;
    map['FirstName2'] = firstName2;
    map['LastName'] = lastName;
    map['LastName2'] = lastName2;
    map['JobTitle'] = jobTitle;
    map['JobTitle2'] = jobTitle2;
    map['Address1'] = address1;
    map['Address2'] = address2;
    map['City'] = city;
    map['State'] = state;
    map['ZipCode'] = zipCode;
    map['Phone'] = phone;
    map['Mobile'] = mobile;
    map['Email'] = email;
    map['Notes'] = notes;
    map['CreatedDateTime'] = createdDateTime;
    map['CallPopUploaded'] = callPopUploaded;
    map['QboId'] = qboId;
    map['CallPopAppId'] = callPopAppId;
    map['IsPrimaryContact'] = isPrimaryContact;
    map['BusinessID'] = businessID;
    map['SyncToken'] = syncToken;
    map['BusinessName'] = businessName;
    map['IsBusinessContact'] = isBusinessContact;
    map['CompanyName'] = companyName;
    map['CompanyName2'] = companyName2;
    map['DealerID'] = dealerID;
    map['IsDealer'] = isDealer;
    map['CustomerCode'] = customerCode;
    map['UpdateDate'] = updateDate;
    return map;
  }
}
