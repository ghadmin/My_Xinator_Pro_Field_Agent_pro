class SiteModel {
  int? id;
  String? customerID;
  String? customerGuid;
  String? siteName;
  String? address;
  String? contact;
  String? email;
  String? phoneNumber;
  String? note;
  bool? isActive;
  String? createdDateTime;
  String? firstName;
  String? lastName;
  String? country;
  String? state;
  String? zip;

  SiteModel({
    this.id,
    this.customerID,
    this.customerGuid,
    this.siteName,
    this.address,
    this.contact,
    this.email,
    this.phoneNumber,
    this.note,
    this.isActive,
    this.createdDateTime,
    this.firstName,
    this.lastName,
    this.country,
    this.state,
    this.zip,
  });

  SiteModel.fromJson(dynamic json) {
    id = json['Id'];
    customerID = json['CustomerID']?.toString();
    customerGuid = json['CustomerGuid'];
    siteName = json['SiteName'];
    address = json['Address'];
    contact = json['Contact'];
    email = json['Email'];
    phoneNumber = json['PhoneNumber'];
    note = json['Note'];
    isActive = json['IsActive'];
    createdDateTime = json['CreatedDateTime'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    country = json['Country'];
    state = json['State'];
    zip = json['Zip'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Id'] = id;
    map['CustomerID'] = customerID;
    map['CustomerGuid'] = customerGuid;
    map['SiteName'] = siteName;
    map['Address'] = address;
    map['Contact'] = contact;
    map['Email'] = email;
    map['PhoneNumber'] = phoneNumber;
    map['Note'] = note;
    map['IsActive'] = isActive;
    map['CreatedDateTime'] = createdDateTime;
    map['FirstName'] = firstName;
    map['LastName'] = lastName;
    map['Country'] = country;
    map['State'] = state;
    map['Zip'] = zip;
    return map;
  }
}
