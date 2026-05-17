class AppointmentApiModel {
  final String? companyID;
  final int? apptID;
  final String? appoinmentUId;
  final int? customerID;
  final String? serviceTypeId;
  final int? resourceID;
  final int? timeSlotId;
  final String? apptDateTime;
  final String? startDateTime;
  final String? endDateTime;
  final String? timeSlot;
  final String? note;
  final int? statusId;
  final int? ticketStatusId;
  final String? createdDateTime;
  final String? createdBy;
  final String? siteID;
  final Resource? resource;
  final Customer? customer;
  final Status? status;
  final TicketStatus? ticketStatus;
  final ServiceType? serviceType;
  final List<Invoice> invoices;

  AppointmentApiModel({
    this.companyID,
    this.apptID,
    this.appoinmentUId,
    this.customerID,
    this.serviceTypeId,
    this.resourceID,
    this.timeSlotId,
    this.apptDateTime,
    this.startDateTime,
    this.endDateTime,
    this.timeSlot,
    this.note,
    this.statusId,
    this.ticketStatusId,
    this.createdDateTime,
    this.createdBy,
    this.siteID,
    this.resource,
    this.customer,
    this.status,
    this.ticketStatus,
    this.serviceType,
    this.invoices = const [],
  });

  factory AppointmentApiModel.fromJson(Map<String, dynamic> json) {
    return AppointmentApiModel(
      companyID: json['CompanyID']?.toString(),
      apptID: json['ApptID'] as int?,
      appoinmentUId: json['AppoinmentUId']?.toString(),
      customerID: json['CustomerID'] as int?,
      serviceTypeId: json['ServiceTypeId']?.toString(),
      resourceID: json['ResourceID'] as int?,
      timeSlotId: json['TimeSlotId'] as int?,
      apptDateTime: json['ApptDateTime']?.toString(),
      startDateTime: json['StartDateTime']?.toString(),
      endDateTime: json['EndDateTime']?.toString(),
      timeSlot: json['TimeSlot']?.toString(),
      note: json['Note']?.toString(),
      statusId: json['StatusId'] as int?,
      ticketStatusId: json['TicketStatusId'] as int?,
      createdDateTime: json['CreatedDateTime']?.toString(),
      createdBy: json['CreatedBy']?.toString(),
      siteID: json['SiteID']?.toString(),
      resource: json['Resource'] != null
          ? Resource.fromJson(json['Resource'])
          : null,
      customer: json['Customer'] != null
          ? Customer.fromJson(json['Customer'])
          : null,
      status: json['Status'] != null
          ? Status.fromJson(json['Status'])
          : null,
      ticketStatus: json['TicketStatus'] != null
          ? TicketStatus.fromJson(json['TicketStatus'])
          : null,
      serviceType: json['ServiceType'] != null
          ? ServiceType.fromJson(json['ServiceType'])
          : null,
      invoices: json['Invoices'] != null
          ? (json['Invoices'] as List)
              .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CompanyID': companyID,
      'ApptID': apptID,
      'AppoinmentUId': appoinmentUId,
      'CustomerID': customerID,
      'ServiceTypeId': serviceTypeId,
      'ResourceID': resourceID,
      'TimeSlotId': timeSlotId,
      'ApptDateTime': apptDateTime,
      'StartDateTime': startDateTime,
      'EndDateTime': endDateTime,
      'TimeSlot': timeSlot,
      'Note': note,
      'StatusId': statusId,
      'TicketStatusId': ticketStatusId,
      'CreatedDateTime': createdDateTime,
      'CreatedBy': createdBy,
      'SiteID': siteID,
      'Resource': resource?.toJson(),
      'Customer': customer?.toJson(),
      'Status': status?.toJson(),
      'TicketStatus': ticketStatus?.toJson(),
      'ServiceType': serviceType?.toJson(),
      'Invoices': invoices.map((e) => e.toJson()).toList(),
    };
  }
}

class Resource {
  final int? id;
  final String? name;

  Resource({this.id, this.name});

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['Id'] as int?,
      name: json['Name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'Id': id, 'Name': name};
  }
}

class Customer {
  final String? customerID;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? mobile;
  final String? address1;
  final String? city;
  final String? state;
  final String? zipCode;

  Customer({
    this.customerID,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.mobile,
    this.address1,
    this.city,
    this.state,
    this.zipCode,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerID: json['CustomerID']?.toString(),
      firstName: json['FirstName']?.toString(),
      lastName: json['LastName']?.toString(),
      email: json['Email']?.toString(),
      phone: json['Phone']?.toString(),
      mobile: json['Mobile']?.toString(),
      address1: json['Address1']?.toString(),
      city: json['City']?.toString(),
      state: json['State']?.toString(),
      zipCode: json['ZipCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CustomerID': customerID,
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
      'Phone': phone,
      'Mobile': mobile,
      'Address1': address1,
      'City': city,
      'State': state,
      'ZipCode': zipCode,
    };
  }
}

class Status {
  final int? statusId;
  final String? statusName;

  Status({this.statusId, this.statusName});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      statusId: json['StatusId'] as int?,
      statusName: json['StatusName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'StatusId': statusId, 'StatusName': statusName};
  }
}

class TicketStatus {
  final int? statusId;
  final String? statusName;

  TicketStatus({this.statusId, this.statusName});

  factory TicketStatus.fromJson(Map<String, dynamic> json) {
    return TicketStatus(
      statusId: json['StatusId'] as int?,
      statusName: json['StatusName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'StatusId': statusId, 'StatusName': statusName};
  }
}

class ServiceType {
  final int? serviceTypeID;
  final String? serviceName;

  ServiceType({this.serviceTypeID, this.serviceName});

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      serviceTypeID: json['ServiceTypeID'] as int?,
      serviceName: json['ServiceName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'ServiceTypeID': serviceTypeID, 'ServiceName': serviceName};
  }
}

class Invoice {
  final String? invoiceID;
  final String? number;
  final double? total;
  final String? type;
  final String? status;

  Invoice({this.invoiceID, this.number, this.total, this.type, this.status});

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceID: json['InvoiceID']?.toString(),
      number: json['Number']?.toString(),
      total: (json['Total'] as num?)?.toDouble(),
      type: json['Type']?.toString(),
      status: json['Status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'InvoiceID': invoiceID,
      'Number': number,
      'Total': total,
      'Type': type,
      'Status': status,
    };
  }
}
