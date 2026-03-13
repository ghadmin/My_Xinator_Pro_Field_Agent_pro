// import 'package:hive/hive.dart';

// part 'appointment_model.g.dart';

// @HiveType(typeId: 0)
// class Appointments {
//   @HiveField(0)
//   String? _companyID;
//   @HiveField(1)
//   dynamic _apptID;
//   @HiveField(2)
//   String? _appoinmentUId;
//   @HiveField(3)
//   dynamic _customerID;
//   @HiveField(4)
//   String? _serviceTypeId;
//   @HiveField(5)
//   dynamic _resourceID;
//   @HiveField(6)
//   dynamic _timeSlotId;
//   @HiveField(7)
//   String? _apptDateTime;
//   @HiveField(8)
//   String? _startDateTime;
//   @HiveField(9)
//   String? _endDateTime;
//   @HiveField(10)
//   String? _timeSlot;
//   @HiveField(11)
//   String? _note;
//   @HiveField(12)
//   String? _statusId;
//   @HiveField(13)
//   String? _ticketStatusId;
//   @HiveField(14)
//   String? _createdDateTime;
//   @HiveField(15)
//   bool? _markDownloaded;
//   @HiveField(16)
//   String? _promoCode;
//   @HiveField(17)
//   String? _createdBy;
//   @HiveField(18)
//   String? _userID;
//   @HiveField(19)
//   Resource? _resource;
//   @HiveField(20)
//   Customer? _customer;
//   @HiveField(21)
//   Status? _status;
//   @HiveField(22)
//   TicketStatus? _ticketStatus;
//   @HiveField(23)
//   ServiceType? _serviceType;
//   @HiveField(24)
//   List<Invoices>? _invoices;

//   Appointments({
//     String? companyID,
//     dynamic apptID,
//     String? appoinmentUId,
//     dynamic customerID,
//     String? serviceTypeId,
//     dynamic resourceID,
//     dynamic timeSlotId,
//     String? apptDateTime,
//     String? startDateTime,
//     String? endDateTime,
//     String? timeSlot,
//     String? note,
//     String? statusId,
//     String? ticketStatusId,
//     String? createdDateTime,
//     bool? markDownloaded,
//     String? promoCode,
//     String? createdBy,
//     String? userID,
//     Resource? resource,
//     Customer? customer,
//     Status? status,
//     TicketStatus? ticketStatus,
//     ServiceType? serviceType,
//     List<Invoices>? invoices,
//   }) {
//     _companyID = companyID;
//     _apptID = apptID;
//     _appoinmentUId = appoinmentUId;
//     _customerID = customerID;
//     _serviceTypeId = serviceTypeId;
//     _resourceID = resourceID;
//     _timeSlotId = timeSlotId;
//     _apptDateTime = apptDateTime;
//     _startDateTime = startDateTime;
//     _endDateTime = endDateTime;
//     _timeSlot = timeSlot;
//     _note = note;
//     _statusId = statusId;
//     _ticketStatusId = ticketStatusId;
//     _createdDateTime = createdDateTime;
//     _markDownloaded = markDownloaded;
//     _promoCode = promoCode;
//     _createdBy = createdBy;
//     _userID = userID;
//     _resource = resource;
//     _customer = customer;
//     _status = status;
//     _ticketStatus = ticketStatus;
//     _serviceType = serviceType;
//     _invoices = invoices;
//   }

//   Appointments.fromJson(dynamic json) {
//     _companyID = json['CompanyID'];
//     _apptID = json['ApptID'];
//     _appoinmentUId = json['AppoinmentUId'];
//     _customerID = json['CustomerID'];
//     _serviceTypeId = json['ServiceTypeId'];
//     _resourceID = json['ResourceID'];
//     _timeSlotId = json['TimeSlotId'];
//     _apptDateTime = json['ApptDateTime'];
//     _startDateTime = json['StartDateTime'];
//     _endDateTime = json['EndDateTime'];
//     _timeSlot = json['TimeSlot'];
//     _note = json['Note'];
//     _statusId = json['StatusId'];
//     _ticketStatusId = json['TicketStatusId'];
//     _createdDateTime = json['CreatedDateTime'];
//     _markDownloaded = json['MarkDownloaded'];
//     _promoCode = json['PromoCode'];
//     _createdBy = json['CreatedBy'];
//     _userID = json['UserID'];
//     _resource =
//         json['Resource'] != null ? Resource.fromJson(json['Resource']) : null;
//     _customer =
//         json['Customer'] != null ? Customer.fromJson(json['Customer']) : null;
//     _status = json['Status'] != null ? Status.fromJson(json['Status']) : null;
//     _ticketStatus = json['TicketStatus'] != null
//         ? TicketStatus.fromJson(json['TicketStatus'])
//         : null;
//     _serviceType = json['ServiceType'] != null
//         ? ServiceType.fromJson(json['ServiceType'])
//         : null;
//     if (json['Invoices'] != null) {
//       _invoices = [];
//       json['Invoices'].forEach((v) {
//         _invoices?.add(Invoices.fromJson(v));
//       });
//     }
//   }

//   Appointments copyWith({
//     String? companyID,
//     dynamic apptID,
//     String? appoinmentUId,
//     dynamic customerID,
//     String? serviceTypeId,
//     dynamic resourceID,
//     dynamic timeSlotId,
//     String? apptDateTime,
//     String? startDateTime,
//     String? endDateTime,
//     String? timeSlot,
//     String? note,
//     String? statusId,
//     String? ticketStatusId,
//     String? createdDateTime,
//     bool? markDownloaded,
//     String? promoCode,
//     String? createdBy,
//     String? userID,
//     Resource? resource,
//     Customer? customer,
//     Status? status,
//     TicketStatus? ticketStatus,
//     ServiceType? serviceType,
//     List<Invoices>? invoices,
//   }) =>
//       Appointments(
//         companyID: companyID ?? _companyID,
//         apptID: apptID ?? _apptID,
//         appoinmentUId: appoinmentUId ?? _appoinmentUId,
//         customerID: customerID ?? _customerID,
//         serviceTypeId: serviceTypeId ?? _serviceTypeId,
//         resourceID: resourceID ?? _resourceID,
//         timeSlotId: timeSlotId ?? _timeSlotId,
//         apptDateTime: apptDateTime ?? _apptDateTime,
//         startDateTime: startDateTime ?? _startDateTime,
//         endDateTime: endDateTime ?? _endDateTime,
//         timeSlot: timeSlot ?? _timeSlot,
//         note: note ?? _note,
//         statusId: statusId ?? _statusId,
//         ticketStatusId: ticketStatusId ?? _ticketStatusId,
//         createdDateTime: createdDateTime ?? _createdDateTime,
//         markDownloaded: markDownloaded ?? _markDownloaded,
//         promoCode: promoCode ?? _promoCode,
//         createdBy: createdBy ?? _createdBy,
//         userID: userID ?? _userID,
//         resource: resource ?? _resource,
//         customer: customer ?? _customer,
//         status: status ?? _status,
//         ticketStatus: ticketStatus ?? _ticketStatus,
//         serviceType: serviceType ?? _serviceType,
//         invoices: invoices ?? _invoices,
//       );

//   String? get companyID => _companyID;
//   dynamic get apptID => _apptID;
//   String? get appoinmentUId => _appoinmentUId;
//   dynamic get customerID => _customerID;
//   String? get serviceTypeId => _serviceTypeId;
//   dynamic get resourceID => _resourceID;
//   dynamic get timeSlotId => _timeSlotId;
//   String? get apptDateTime => _apptDateTime;
//   String? get startDateTime => _startDateTime;
//   String? get endDateTime => _endDateTime;
//   String? get timeSlot => _timeSlot;
//   String? get note => _note;
//   String? get statusId => _statusId;
//   String? get ticketStatusId => _ticketStatusId;
//   String? get createdDateTime => _createdDateTime;
//   bool? get markDownloaded => _markDownloaded;
//   String? get promoCode => _promoCode;
//   String? get createdBy => _createdBy;
//   String? get userID => _userID;
//   Resource? get resource => _resource;
//   Customer? get customer => _customer;
//   Status? get status => _status;
//   TicketStatus? get ticketStatus => _ticketStatus;
//   ServiceType? get serviceType => _serviceType;
//   List<Invoices>? get invoices => _invoices;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['CompanyID'] = _companyID;
//     map['ApptID'] = _apptID;
//     map['AppoinmentUId'] = _appoinmentUId;
//     map['CustomerID'] = _customerID;
//     map['ServiceTypeId'] = _serviceTypeId;
//     map['ResourceID'] = _resourceID;
//     map['TimeSlotId'] = _timeSlotId;
//     map['ApptDateTime'] = _apptDateTime;
//     map['StartDateTime'] = _startDateTime;
//     map['EndDateTime'] = _endDateTime;
//     map['TimeSlot'] = _timeSlot;
//     map['Note'] = _note;
//     map['StatusId'] = _statusId;
//     map['TicketStatusId'] = _ticketStatusId;
//     map['CreatedDateTime'] = _createdDateTime;
//     map['MarkDownloaded'] = _markDownloaded;
//     map['PromoCode'] = _promoCode;
//     map['CreatedBy'] = _createdBy;
//     map['UserID'] = _userID;
//     if (_resource != null) {
//       map['Resource'] = _resource?.toJson();
//     }
//     if (_customer != null) {
//       map['Customer'] = _customer?.toJson();
//     }
//     if (_status != null) {
//       map['Status'] = _status?.toJson();
//     }
//     if (_ticketStatus != null) {
//       map['TicketStatus'] = _ticketStatus?.toJson();
//     }
//     if (_serviceType != null) {
//       map['ServiceType'] = _serviceType?.toJson();
//     }
//     if (_invoices != null) {
//       map['Invoices'] = _invoices?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
// }

// @HiveType(typeId: 1)
// class Invoices {
//   @HiveField(0)
//   String? _invoiceID;
//   @HiveField(1)
//   String? _customerGuid;
//   @HiveField(2)
//   String? _fullName;
//   @HiveField(3)
//   String? _qBOCustomerId;
//   @HiveField(4)
//   String? _customerId;
//   @HiveField(5)
//   double? _depositAmount;
//   @HiveField(6)
//   String? _city;
//   @HiveField(7)
//   String? _qBOId;
//   @HiveField(8)
//   String? _number;
//   @HiveField(9)
//   String? _invoiceDate;
//   @HiveField(10)
//   double? _subtotal;
//   @HiveField(11)
//   double? _amountCollect;
//   @HiveField(12)
//   double? _discount;
//   @HiveField(13)
//   double? _total;
//   @HiveField(14)
//   double? _tax;
//   @HiveField(15)
//   String? _status;
//   @HiveField(16)
//   String? _type;
//   @HiveField(17)
//   String? _note;
//   @HiveField(18)
//   String? _due;
//   @HiveField(19)
//   bool? _isConverted;
//   @HiveField(20)
//   String? _convertedInvoiceID;
//   @HiveField(21)
//   dynamic _surcharge;
//   @HiveField(22)
//   List<Items>? _items;
//   @HiveField(23)
//   String? _discountOption;
//   @HiveField(24)
//   String? _taxType;
//   @HiveField(25)
//   List<Payment>? _paymentList;

//   Invoices({
//     String? invoiceID,
//     String? customerGuid,
//     String? fullName,
//     String? qBOCustomerId,
//     String? customerId,
//     double? depositAmount,
//     String? city,
//     String? qBOId,
//     String? number,
//     String? invoiceDate,
//     double? subtotal,
//     double? amountCollect,
//     double? discount,
//     double? total,
//     double? tax,
//     String? status,
//     String? type,
//     String? note,
//     String? due,
//     bool? isConverted,
//     String? convertedInvoiceID,
//     dynamic surcharge,
//     List<Items>? items,
//     String? discountOption,
//     String? taxType,
//     List<Payment>? paymentList,
//   }) {
//     _invoiceID = invoiceID;
//     _customerGuid = customerGuid;
//     _fullName = fullName;
//     _qBOCustomerId = qBOCustomerId;
//     _customerId = customerId;
//     _depositAmount = depositAmount;
//     _city = city;
//     _qBOId = qBOId;
//     _number = number;
//     _invoiceDate = invoiceDate;
//     _subtotal = subtotal;
//     _amountCollect = amountCollect;
//     _discount = discount;
//     _total = total;
//     _tax = tax;
//     _status = status;
//     _type = type;
//     _note = note;
//     _due = due;
//     _isConverted = isConverted;
//     _convertedInvoiceID = convertedInvoiceID;
//     _surcharge = surcharge;
//     _items = items;

//     _discountOption = discountOption;
//     _taxType = taxType;
//     _paymentList = paymentList;
//   }

//   Invoices.fromJson(dynamic json) {
//     _invoiceID = json['InvoiceID'];
//     _customerGuid = json['CustomerGuid'];
//     _fullName = json['FullName'];
//     _qBOCustomerId = json['QBOCustomerId'];
//     _customerId = json['CustomerId'];
//     _depositAmount = json['DepositAmount'];
//     _city = json['City'];
//     _qBOId = json['QBOId'];
//     _number = json['Number'];
//     _invoiceDate = json['InvoiceDate'];
//     _subtotal = json['Subtotal'];
//     _amountCollect = json['AmountCollect'];
//     _discount = json['Discount'];
//     _total = json['Total'];
//     _tax = json['Tax'];
//     _status = json['Status'];
//     _type = json['Type'];
//     _note = json['Note'];
//     _due = json['Due'];
//     _isConverted = json['IsConverted'];
//     _convertedInvoiceID = json['ConvertedInvoiceID'];
//     _surcharge = json['Surcharge'];
//     if (json['items'] != null) {
//       _items = [];
//       json['items'].forEach((v) {
//         _items?.add(Items.fromJson(v));
//       });
//     }
//     _discountOption = json['DiscountOption'];
//     _taxType = json['TaxType'];
//     if (json['PaymentList'] != null) {
//       _paymentList = [];
//       json['PaymentList'].forEach((v) {
//         _paymentList?.add(Payment.fromJson(v));
//       });
//     }
//   }

//   Invoices copyWith({
//     String? invoiceID,
//     String? customerGuid,
//     String? fullName,
//     String? qBOCustomerId,
//     String? customerId,
//     double? depositAmount,
//     String? city,
//     String? qBOId,
//     String? number,
//     String? invoiceDate,
//     double? subtotal,
//     double? amountCollect,
//     double? discount,
//     double? total,
//     double? tax,
//     String? status,
//     String? type,
//     String? note,
//     String? due,
//     bool? isConverted,
//     String? convertedInvoiceID,
//     dynamic surcharge,
//     List<Items>? items,
//     String? discountOption,
//     String? taxType,
//     List<Payment>? paymentList,
//   }) =>
//       Invoices(
//         invoiceID: invoiceID ?? _invoiceID,
//         customerGuid: customerGuid ?? _customerGuid,
//         fullName: fullName ?? _fullName,
//         qBOCustomerId: qBOCustomerId ?? _qBOCustomerId,
//         customerId: customerId ?? _customerId,
//         depositAmount: depositAmount ?? _depositAmount,
//         city: city ?? _city,
//         qBOId: qBOId ?? _qBOId,
//         number: number ?? _number,
//         invoiceDate: invoiceDate ?? _invoiceDate,
//         subtotal: subtotal ?? _subtotal,
//         amountCollect: amountCollect ?? _amountCollect,
//         discount: discount ?? _discount,
//         total: total ?? _total,
//         tax: tax ?? _tax,
//         status: status ?? _status,
//         type: type ?? _type,
//         note: note ?? _note,
//         due: due ?? _due,
//         isConverted: isConverted ?? _isConverted,
//         convertedInvoiceID: convertedInvoiceID ?? _convertedInvoiceID,
//         surcharge: surcharge ?? _surcharge,
//         items: items ?? _items,
//         discountOption: discountOption ?? _discountOption,
//         taxType: taxType ?? _taxType,
//         paymentList: paymentList ?? _paymentList,
//       );

//   String? get invoiceID => _invoiceID;
//   String? get customerGuid => _customerGuid;
//   String? get fullName => _fullName;
//   String? get qBOCustomerId => _qBOCustomerId;
//   String? get customerId => _customerId;
//   double? get depositAmount => _depositAmount;
//   String? get city => _city;
//   String? get qBOId => _qBOId;
//   String? get number => _number;
//   String? get invoiceDate => _invoiceDate;
//   double? get subtotal => _subtotal;
//   double? get amountCollect => _amountCollect;
//   double? get discount => _discount;
//   double? get total => _total;
//   double? get tax => _tax;
//   String? get status => _status;
//   String? get type => _type;
//   String? get note => _note;
//   String? get due => _due;
//   bool? get isConverted => _isConverted;
//   String? get convertedInvoiceID => _convertedInvoiceID;
//   dynamic get surcharge => _surcharge;
//   List<Items>? get items => _items;
//   String? get discountOption => _discountOption;
//   String? get taxType => _taxType;
//   List<Payment>? get paymentList => _paymentList;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['InvoiceID'] = _invoiceID;
//     map['CustomerGuid'] = _customerGuid;
//     map['FullName'] = _fullName;
//     map['QBOCustomerId'] = _qBOCustomerId;
//     map['CustomerId'] = _customerId;
//     map['DepositAmount'] = _depositAmount;
//     map['City'] = _city;
//     map['QBOId'] = _qBOId;
//     map['Number'] = _number;
//     map['InvoiceDate'] = _invoiceDate;
//     map['Subtotal'] = _subtotal;
//     map['AmountCollect'] = _amountCollect;
//     map['Discount'] = _discount;
//     map['Total'] = _total;
//     map['Tax'] = _tax;
//     map['Status'] = _status;
//     map['Type'] = _type;
//     map['Note'] = _note;
//     map['Due'] = _due;
//     map['IsConverted'] = _isConverted;
//     map['ConvertedInvoiceID'] = _convertedInvoiceID;
//     map['Surcharge'] = _surcharge;
//     if (_items != null) {
//       map['items'] = _items?.map((v) => v.toJson()).toList();
//     }
//     map['DiscountOption'] = _discountOption;
//     map['TaxType'] = _taxType;
//     if (_paymentList != null) {
//       map['PaymentList'] = _paymentList?.map((v) => v.toJson()).toList();
//     }

//     return map;
//   }
// }

// @HiveType(typeId: 2)
// class Items {
//   @HiveField(0)
//   String? _itemId;
//   @HiveField(1)
//   String? _name;
//   @HiveField(2)
//   String? _description;
//   @HiveField(3)
//   String? _quantity;
//   @HiveField(4)
//   String? _unitPrice;
//   @HiveField(5)
//   String? _totalPrice;
//   @HiveField(6)
//   String? _isTaxable;
//   @HiveField(7)
//   String? _itemTyId;

//   Items({
//     String? itemId,
//     String? name,
//     String? description,
//     String? quantity,
//     String? unitPrice,
//     String? totalPrice,
//     String? isTaxable,
//     String? itemTyId,
//   }) {
//     _itemId = itemId;
//     _name = name;
//     _description = description;
//     _quantity = quantity;
//     _unitPrice = unitPrice;
//     _totalPrice = totalPrice;
//     _isTaxable = isTaxable;
//     _itemTyId = itemTyId;
//   }

//   Items.fromJson(dynamic json) {
//     _itemId = json['ItemId'];
//     _name = json['Name'];
//     _description = json['Description'];
//     _quantity = json['Quantity'];
//     _unitPrice = json['UnitPrice'];
//     _totalPrice = json['TotalPrice'];
//     _isTaxable = json['IsTaxable'];
//     _itemTyId = json['ItemTyId'];
//   }

//   Items copyWith({
//     String? itemId,
//     String? name,
//     String? description,
//     String? quantity,
//     String? unitPrice,
//     String? totalPrice,
//     String? isTaxable,
//     String? itemTyId,
//   }) =>
//       Items(
//         itemId: itemId ?? _itemId,
//         name: name ?? _name,
//         description: description ?? _description,
//         quantity: quantity ?? _quantity,
//         unitPrice: unitPrice ?? _unitPrice,
//         totalPrice: totalPrice ?? _totalPrice,
//         isTaxable: isTaxable ?? _isTaxable,
//         itemTyId: itemTyId ?? _itemTyId,
//       );

//   String? get itemId => _itemId;
//   String? get name => _name;
//   String? get description => _description;
//   String? get quantity => _quantity;
//   String? get unitPrice => _unitPrice;
//   String? get totalPrice => _totalPrice;
//   String? get isTaxable => _isTaxable;
//   String? get itemTyId => _itemTyId;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['ItemId'] = _itemId;
//     map['Name'] = _name;
//     map['Description'] = _description;
//     map['Quantity'] = _quantity;
//     map['UnitPrice'] = _unitPrice;
//     map['TotalPrice'] = _totalPrice;
//     map['IsTaxable'] = _isTaxable;
//     map['ItemTyId'] = _itemTyId;
//     return map;
//   }
// }

// @HiveType(typeId: 3)
// class ServiceType {
//   @HiveField(0)
//   dynamic _companyID;
//   @HiveField(1)
//   dynamic _serviceTypeID;
//   @HiveField(2)
//   dynamic _resource;
//   @HiveField(3)
//   String? _serviceName;
//   @HiveField(4)
//   dynamic _createdDateTime;
//   @HiveField(5)
//   dynamic _hour;
//   @HiveField(6)
//   dynamic _minute;
//   @HiveField(7)
//   dynamic _calenderColor;
//   @HiveField(8)
//   dynamic _reminderID;
//   @HiveField(9)
//   bool? _isInternalUse;

//   ServiceType({
//     dynamic companyID,
//     dynamic serviceTypeID,
//     dynamic resource,
//     String? serviceName,
//     dynamic createdDateTime,
//     dynamic hour,
//     dynamic minute,
//     dynamic calenderColor,
//     dynamic reminderID,
//     bool? isInternalUse,
//   }) {
//     _companyID = companyID;
//     _serviceTypeID = serviceTypeID;
//     _resource = resource;
//     _serviceName = serviceName;
//     _createdDateTime = createdDateTime;
//     _hour = hour;
//     _minute = minute;
//     _calenderColor = calenderColor;
//     _reminderID = reminderID;
//     _isInternalUse = isInternalUse;
//   }

//   ServiceType.fromJson(dynamic json) {
//     _companyID = json['CompanyID'];
//     _serviceTypeID = json['ServiceTypeID'];
//     _resource = json['Resource'];
//     _serviceName = json['ServiceName'];
//     _createdDateTime = json['CreatedDateTime'];
//     _hour = json['Hour'];
//     _minute = json['Minute'];
//     _calenderColor = json['CalenderColor'];
//     _reminderID = json['ReminderID'];
//     _isInternalUse = json['IsInternalUse'];
//   }

//   ServiceType copyWith({
//     dynamic companyID,
//     dynamic serviceTypeID,
//     dynamic resource,
//     String? serviceName,
//     dynamic createdDateTime,
//     dynamic hour,
//     dynamic minute,
//     dynamic calenderColor,
//     dynamic reminderID,
//     bool? isInternalUse,
//   }) =>
//       ServiceType(
//         companyID: companyID ?? _companyID,
//         serviceTypeID: serviceTypeID ?? _serviceTypeID,
//         resource: resource ?? _resource,
//         serviceName: serviceName ?? _serviceName,
//         createdDateTime: createdDateTime ?? _createdDateTime,
//         hour: hour ?? _hour,
//         minute: minute ?? _minute,
//         calenderColor: calenderColor ?? _calenderColor,
//         reminderID: reminderID ?? _reminderID,
//         isInternalUse: isInternalUse ?? _isInternalUse,
//       );

//   dynamic get companyID => _companyID;
//   dynamic get serviceTypeID => _serviceTypeID;
//   dynamic get resource => _resource;
//   String? get serviceName => _serviceName;
//   dynamic get createdDateTime => _createdDateTime;
//   dynamic get hour => _hour;
//   dynamic get minute => _minute;
//   dynamic get calenderColor => _calenderColor;
//   dynamic get reminderID => _reminderID;
//   bool? get isInternalUse => _isInternalUse;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['CompanyID'] = _companyID;
//     map['ServiceTypeID'] = _serviceTypeID;
//     map['Resource'] = _resource;
//     map['ServiceName'] = _serviceName;
//     map['CreatedDateTime'] = _createdDateTime;
//     map['Hour'] = _hour;
//     map['Minute'] = _minute;
//     map['CalenderColor'] = _calenderColor;
//     map['ReminderID'] = _reminderID;
//     map['IsInternalUse'] = _isInternalUse;
//     return map;
//   }
// }

// @HiveType(typeId: 4)
// class TicketStatus {
//   @HiveField(0)
//   dynamic _statusId;
//   @HiveField(1)
//   String? _statusName;
//   @HiveField(2)
//   String? _companyId;

//   TicketStatus({
//     dynamic statusId,
//     String? statusName,
//     String? companyId,
//   }) {
//     _statusId = statusId;
//     _statusName = statusName;
//     _companyId = companyId;
//   }

//   TicketStatus.fromJson(dynamic json) {
//     _statusId = json['StatusId'];
//     _statusName = json['StatusName'];
//     _companyId = json['CompanyId'];
//   }

//   TicketStatus copyWith({
//     dynamic statusId,
//     String? statusName,
//     String? companyId,
//   }) =>
//       TicketStatus(
//         statusId: statusId ?? _statusId,
//         statusName: statusName ?? _statusName,
//         companyId: companyId ?? _companyId,
//       );

//   dynamic get statusId => _statusId;
//   String? get statusName => _statusName;
//   String? get companyId => _companyId;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['StatusId'] = _statusId;
//     map['StatusName'] = _statusName;
//     map['CompanyId'] = _companyId;
//     return map;
//   }
// }

// @HiveType(typeId: 5)
// class Status {
//   @HiveField(0)
//   dynamic _statusId;
//   @HiveField(1)
//   String? _statusName;
//   @HiveField(2)
//   dynamic _companyId;

//   Status({
//     dynamic statusId,
//     String? statusName,
//     dynamic companyId,
//   }) {
//     _statusId = statusId;
//     _statusName = statusName;
//     _companyId = companyId;
//   }

//   Status.fromJson(dynamic json) {
//     _statusId = json['StatusId'];
//     _statusName = json['StatusName'];
//     _companyId = json['CompanyId'];
//   }

//   Status copyWith({
//     dynamic statusId,
//     String? statusName,
//     dynamic companyId,
//   }) =>
//       Status(
//         statusId: statusId ?? _statusId,
//         statusName: statusName ?? _statusName,
//         companyId: companyId ?? _companyId,
//       );

//   dynamic get statusId => _statusId;
//   String? get statusName => _statusName;
//   dynamic get companyId => _companyId;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['StatusId'] = _statusId;
//     map['StatusName'] = _statusName;
//     map['CompanyId'] = _companyId;
//     return map;
//   }
// }

// @HiveType(typeId: 6)
// class Customer {
//   @HiveField(0)
//   String? _companyID;
//   @HiveField(1)
//   String? _createdCompanyID;
//   @HiveField(2)
//   dynamic _tagID;
//   @HiveField(3)
//   String? _customerID;
//   @HiveField(4)
//   String? _aMCustomerID;
//   @HiveField(5)
//   String? _customerGuid;
//   @HiveField(6)
//   String? _title;
//   @HiveField(7)
//   dynamic _title2;
//   @HiveField(8)
//   String? _firstName;
//   @HiveField(9)
//   dynamic _firstName2;
//   @HiveField(10)
//   String? _lastName;
//   @HiveField(11)
//   dynamic _lastName2;
//   @HiveField(12)
//   String? _jobTitle;
//   @HiveField(13)
//   dynamic _jobTitle2;
//   @HiveField(14)
//   String? _address1;
//   @HiveField(15)
//   String? _address2;
//   @HiveField(16)
//   String? _city;
//   @HiveField(17)
//   String? _state;
//   @HiveField(18)
//   String? _zipCode;
//   @HiveField(19)
//   String? _phone;
//   @HiveField(20)
//   String? _mobile;
//   @HiveField(21)
//   String? _email;
//   @HiveField(22)
//   String? _notes;
//   @HiveField(23)
//   String? _createdDateTime;
//   @HiveField(24)
//   bool? _callPopUploaded;
//   @HiveField(25)
//   dynamic _qboId;
//   @HiveField(26)
//   dynamic _callPopAppId;
//   @HiveField(27)
//   bool? _isPrimaryContact;
//   @HiveField(28)
//   dynamic _businessID;
//   @HiveField(29)
//   dynamic _syncToken;
//   @HiveField(30)
//   String? _businessName;
//   @HiveField(31)
//   bool? _isBusinessContact;
//   @HiveField(32)
//   String? _companyName;
//   @HiveField(33)
//   dynamic _companyName2;
//   @HiveField(34)
//   String? _dealerID;
//   @HiveField(35)
//   bool? _isDealer;
//   @HiveField(36)
//   dynamic _customerCode;
//   @HiveField(37)
//   dynamic _updateDate;

//   Customer({
//     String? companyID,
//     String? createdCompanyID,
//     dynamic tagID,
//     String? customerID,
//     String? aMCustomerID,
//     String? customerGuid,
//     String? title,
//     dynamic title2,
//     String? firstName,
//     dynamic firstName2,
//     String? lastName,
//     dynamic lastName2,
//     String? jobTitle,
//     dynamic jobTitle2,
//     String? address1,
//     String? address2,
//     String? city,
//     String? state,
//     String? zipCode,
//     String? phone,
//     String? mobile,
//     String? email,
//     String? notes,
//     String? createdDateTime,
//     bool? callPopUploaded,
//     dynamic qboId,
//     dynamic callPopAppId,
//     bool? isPrimaryContact,
//     dynamic businessID,
//     dynamic syncToken,
//     String? businessName,
//     bool? isBusinessContact,
//     String? companyName,
//     dynamic companyName2,
//     String? dealerID,
//     bool? isDealer,
//     dynamic customerCode,
//     dynamic updateDate,
//   }) {
//     _companyID = companyID;
//     _createdCompanyID = createdCompanyID;
//     _tagID = tagID;
//     _customerID = customerID;
//     _aMCustomerID = aMCustomerID;
//     _customerGuid = customerGuid;
//     _title = title;
//     _title2 = title2;
//     _firstName = firstName;
//     _firstName2 = firstName2;
//     _lastName = lastName;
//     _lastName2 = lastName2;
//     _jobTitle = jobTitle;
//     _jobTitle2 = jobTitle2;
//     _address1 = address1;
//     _address2 = address2;
//     _city = city;
//     _state = state;
//     _zipCode = zipCode;
//     _phone = phone;
//     _mobile = mobile;
//     _email = email;
//     _notes = notes;
//     _createdDateTime = createdDateTime;
//     _callPopUploaded = callPopUploaded;
//     _qboId = qboId;
//     _callPopAppId = callPopAppId;
//     _isPrimaryContact = isPrimaryContact;
//     _businessID = businessID;
//     _syncToken = syncToken;
//     _businessName = businessName;
//     _isBusinessContact = isBusinessContact;
//     _companyName = companyName;
//     _companyName2 = companyName2;
//     _dealerID = dealerID;
//     _isDealer = isDealer;
//     _customerCode = customerCode;
//     _updateDate = updateDate;
//   }

//   Customer.fromJson(dynamic json) {
//     _companyID = json['CompanyID'];
//     _createdCompanyID = json['CreatedCompanyID'];
//     _tagID = json['TagID'];
//     _customerID = json['CustomerID'];
//     _aMCustomerID = json['AMCustomerID'];
//     _customerGuid = json['CustomerGuid'];
//     _title = json['Title'];
//     _title2 = json['Title2'];
//     _firstName = json['FirstName'];
//     _firstName2 = json['FirstName2'];
//     _lastName = json['LastName'];
//     _lastName2 = json['LastName2'];
//     _jobTitle = json['JobTitle'];
//     _jobTitle2 = json['JobTitle2'];
//     _address1 = json['Address1'];
//     _address2 = json['Address2'];
//     _city = json['City'];
//     _state = json['State'];
//     _zipCode = json['ZipCode'];
//     _phone = json['Phone'];
//     _mobile = json['Mobile'];
//     _email = json['Email'];
//     _notes = json['Notes'];
//     _createdDateTime = json['CreatedDateTime'];
//     _callPopUploaded = json['CallPopUploaded'];
//     _qboId = json['QboId'];
//     _callPopAppId = json['CallPopAppId'];
//     _isPrimaryContact = json['IsPrimaryContact'];
//     _businessID = json['BusinessID'];
//     _syncToken = json['SyncToken'];
//     _businessName = json['BusinessName'];
//     _isBusinessContact = json['IsBusinessContact'];
//     _companyName = json['CompanyName'];
//     _companyName2 = json['CompanyName2'];
//     _dealerID = json['DealerID'];
//     _isDealer = json['IsDealer'];
//     _customerCode = json['CustomerCode'];
//     _updateDate = json['UpdateDate'];
//   }

//   Customer copyWith({
//     String? companyID,
//     String? createdCompanyID,
//     dynamic tagID,
//     String? customerID,
//     String? aMCustomerID,
//     String? customerGuid,
//     String? title,
//     dynamic title2,
//     String? firstName,
//     dynamic firstName2,
//     String? lastName,
//     dynamic lastName2,
//     String? jobTitle,
//     dynamic jobTitle2,
//     String? address1,
//     String? address2,
//     String? city,
//     String? state,
//     String? zipCode,
//     String? phone,
//     String? mobile,
//     String? email,
//     String? notes,
//     String? createdDateTime,
//     bool? callPopUploaded,
//     dynamic qboId,
//     dynamic callPopAppId,
//     bool? isPrimaryContact,
//     dynamic businessID,
//     dynamic syncToken,
//     String? businessName,
//     bool? isBusinessContact,
//     String? companyName,
//     dynamic companyName2,
//     String? dealerID,
//     bool? isDealer,
//     dynamic customerCode,
//     dynamic updateDate,
//   }) =>
//       Customer(
//         companyID: companyID ?? _companyID,
//         createdCompanyID: createdCompanyID ?? _createdCompanyID,
//         tagID: tagID ?? _tagID,
//         customerID: customerID ?? _customerID,
//         aMCustomerID: aMCustomerID ?? _aMCustomerID,
//         customerGuid: customerGuid ?? _customerGuid,
//         title: title ?? _title,
//         title2: title2 ?? _title2,
//         firstName: firstName ?? _firstName,
//         firstName2: firstName2 ?? _firstName2,
//         lastName: lastName ?? _lastName,
//         lastName2: lastName2 ?? _lastName2,
//         jobTitle: jobTitle ?? _jobTitle,
//         jobTitle2: jobTitle2 ?? _jobTitle2,
//         address1: address1 ?? _address1,
//         address2: address2 ?? _address2,
//         city: city ?? _city,
//         state: state ?? _state,
//         zipCode: zipCode ?? _zipCode,
//         phone: phone ?? _phone,
//         mobile: mobile ?? _mobile,
//         email: email ?? _email,
//         notes: notes ?? _notes,
//         createdDateTime: createdDateTime ?? _createdDateTime,
//         callPopUploaded: callPopUploaded ?? _callPopUploaded,
//         qboId: qboId ?? _qboId,
//         callPopAppId: callPopAppId ?? _callPopAppId,
//         isPrimaryContact: isPrimaryContact ?? _isPrimaryContact,
//         businessID: businessID ?? _businessID,
//         syncToken: syncToken ?? _syncToken,
//         businessName: businessName ?? _businessName,
//         isBusinessContact: isBusinessContact ?? _isBusinessContact,
//         companyName: companyName ?? _companyName,
//         companyName2: companyName2 ?? _companyName2,
//         dealerID: dealerID ?? _dealerID,
//         isDealer: isDealer ?? _isDealer,
//         customerCode: customerCode ?? _customerCode,
//         updateDate: updateDate ?? _updateDate,
//       );

//   String? get companyID => _companyID;
//   String? get createdCompanyID => _createdCompanyID;
//   dynamic get tagID => _tagID;
//   String? get customerID => _customerID;
//   String? get aMCustomerID => _aMCustomerID;
//   String? get customerGuid => _customerGuid;
//   String? get title => _title;
//   dynamic get title2 => _title2;
//   String? get firstName => _firstName;
//   dynamic get firstName2 => _firstName2;
//   String? get lastName => _lastName;
//   dynamic get lastName2 => _lastName2;
//   String? get jobTitle => _jobTitle;
//   dynamic get jobTitle2 => _jobTitle2;
//   String? get address1 => _address1;
//   String? get address2 => _address2;
//   String? get city => _city;
//   String? get state => _state;
//   String? get zipCode => _zipCode;
//   String? get phone => _phone;
//   String? get mobile => _mobile;
//   String? get email => _email;
//   String? get notes => _notes;
//   String? get createdDateTime => _createdDateTime;
//   bool? get callPopUploaded => _callPopUploaded;
//   dynamic get qboId => _qboId;
//   dynamic get callPopAppId => _callPopAppId;
//   bool? get isPrimaryContact => _isPrimaryContact;
//   dynamic get businessID => _businessID;
//   dynamic get syncToken => _syncToken;
//   String? get businessName => _businessName;
//   bool? get isBusinessContact => _isBusinessContact;
//   String? get companyName => _companyName;
//   dynamic get companyName2 => _companyName2;
//   String? get dealerID => _dealerID;
//   bool? get isDealer => _isDealer;
//   dynamic get customerCode => _customerCode;
//   dynamic get updateDate => _updateDate;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['CompanyID'] = _companyID;
//     map['CreatedCompanyID'] = _createdCompanyID;
//     map['TagID'] = _tagID;
//     map['CustomerID'] = _customerID;
//     map['AMCustomerID'] = _aMCustomerID;
//     map['CustomerGuid'] = _customerGuid;
//     map['Title'] = _title;
//     map['Title2'] = _title2;
//     map['FirstName'] = _firstName;
//     map['FirstName2'] = _firstName2;
//     map['LastName'] = _lastName;
//     map['LastName2'] = _lastName2;
//     map['JobTitle'] = _jobTitle;
//     map['JobTitle2'] = _jobTitle2;
//     map['Address1'] = _address1;
//     map['Address2'] = _address2;
//     map['City'] = _city;
//     map['State'] = _state;
//     map['ZipCode'] = _zipCode;
//     map['Phone'] = _phone;
//     map['Mobile'] = _mobile;
//     map['Email'] = _email;
//     map['Notes'] = _notes;
//     map['CreatedDateTime'] = _createdDateTime;
//     map['CallPopUploaded'] = _callPopUploaded;
//     map['QboId'] = _qboId;
//     map['CallPopAppId'] = _callPopAppId;
//     map['IsPrimaryContact'] = _isPrimaryContact;
//     map['BusinessID'] = _businessID;
//     map['SyncToken'] = _syncToken;
//     map['BusinessName'] = _businessName;
//     map['IsBusinessContact'] = _isBusinessContact;
//     map['CompanyName'] = _companyName;
//     map['CompanyName2'] = _companyName2;
//     map['DealerID'] = _dealerID;
//     map['IsDealer'] = _isDealer;
//     map['CustomerCode'] = _customerCode;
//     map['UpdateDate'] = _updateDate;
//     return map;
//   }
// }

// @HiveType(typeId: 7)
// class Resource {
//   @HiveField(0)
//   dynamic _id;
//   @HiveField(1)
//   dynamic _companyID;
//   @HiveField(2)
//   String? _name;
//   @HiveField(3)
//   dynamic _description;
//   @HiveField(4)
//   dynamic _workingHour;
//   @HiveField(5)
//   bool? _saterDay;
//   @HiveField(6)
//   bool? _sunday;
//   @HiveField(7)
//   bool? _monday;
//   @HiveField(8)
//   bool? _tuesday;
//   @HiveField(9)
//   bool? _wednesday;
//   @HiveField(10)
//   bool? _thursday;
//   @HiveField(11)
//   bool? _friday;
//   @HiveField(12)
//   dynamic _mobile;
//   @HiveField(13)
//   dynamic _email;

//   Resource({
//     dynamic id,
//     dynamic companyID,
//     String? name,
//     dynamic description,
//     dynamic workingHour,
//     bool? saterDay,
//     bool? sunday,
//     bool? monday,
//     bool? tuesday,
//     bool? wednesday,
//     bool? thursday,
//     bool? friday,
//     dynamic mobile,
//     dynamic email,
//   }) {
//     _id = id;
//     _companyID = companyID;
//     _name = name;
//     _description = description;
//     _workingHour = workingHour;
//     _saterDay = saterDay;
//     _sunday = sunday;
//     _monday = monday;
//     _tuesday = tuesday;
//     _wednesday = wednesday;
//     _thursday = thursday;
//     _friday = friday;
//     _mobile = mobile;
//     _email = email;
//   }

//   Resource.fromJson(dynamic json) {
//     _id = json['Id'];
//     _companyID = json['CompanyID'];
//     _name = json['Name'];
//     _description = json['Description'];
//     _workingHour = json['WorkingHour'];
//     _saterDay = json['SaterDay'];
//     _sunday = json['Sunday'];
//     _monday = json['Monday'];
//     _tuesday = json['Tuesday'];
//     _wednesday = json['Wednesday'];
//     _thursday = json['Thursday'];
//     _friday = json['Friday'];
//     _mobile = json['Mobile'];
//     _email = json['Email'];
//   }

//   Resource copyWith({
//     dynamic id,
//     dynamic companyID,
//     String? name,
//     dynamic description,
//     dynamic workingHour,
//     bool? saterDay,
//     bool? sunday,
//     bool? monday,
//     bool? tuesday,
//     bool? wednesday,
//     bool? thursday,
//     bool? friday,
//     dynamic mobile,
//     dynamic email,
//   }) =>
//       Resource(
//         id: id ?? _id,
//         companyID: companyID ?? _companyID,
//         name: name ?? _name,
//         description: description ?? _description,
//         workingHour: workingHour ?? _workingHour,
//         saterDay: saterDay ?? _saterDay,
//         sunday: sunday ?? _sunday,
//         monday: monday ?? _monday,
//         tuesday: tuesday ?? _tuesday,
//         wednesday: wednesday ?? _wednesday,
//         thursday: thursday ?? _thursday,
//         friday: friday ?? _friday,
//         mobile: mobile ?? _mobile,
//         email: email ?? _email,
//       );

//   dynamic get id => _id;
//   dynamic get companyID => _companyID;
//   String? get name => _name;
//   dynamic get description => _description;
//   dynamic get workingHour => _workingHour;
//   bool? get saterDay => _saterDay;
//   bool? get sunday => _sunday;
//   bool? get monday => _monday;
//   bool? get tuesday => _tuesday;
//   bool? get wednesday => _wednesday;
//   bool? get thursday => _thursday;
//   bool? get friday => _friday;
//   dynamic get mobile => _mobile;
//   dynamic get email => _email;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['Id'] = _id;
//     map['CompanyID'] = _companyID;
//     map['Name'] = _name;
//     map['Description'] = _description;
//     map['WorkingHour'] = _workingHour;
//     map['SaterDay'] = _saterDay;
//     map['Sunday'] = _sunday;
//     map['Monday'] = _monday;
//     map['Tuesday'] = _tuesday;
//     map['Wednesday'] = _wednesday;
//     map['Thursday'] = _thursday;
//     map['Friday'] = _friday;
//     map['Mobile'] = _mobile;
//     map['Email'] = _email;
//     return map;
//   }
// }

// @HiveType(typeId: 8)
// class Payment {
//   @HiveField(0)
//   dynamic _id;
//   @HiveField(1)
//   String? _companyId;
//   @HiveField(2)
//   String? _invocieId;
//   @HiveField(3)
//   double? _amount;
//   @HiveField(4)
//   String? _checkName;
//   @HiveField(5)
//   String? _checkNumber;
//   @HiveField(6)
//   String? _type;
//   @HiveField(7)
//   bool? _isDeposit;
//   @HiveField(8)
//   String? _source;
//   @HiveField(9)
//   String? _createdDate;
//   @HiveField(10)
//   dynamic _qboId;
//   @HiveField(11)
//   String? _paymentRefNum;
//   @HiveField(12)
//   dynamic _rmPaymentId;

//   Payment({
//     dynamic id,
//     String? companyId,
//     String? invocieId,
//     dynamic amount,
//     String? checkName,
//     String? checkNumber,
//     String? type,
//     bool? isDeposit,
//     String? source,
//     String? createdDate,
//     dynamic qboId,
//     String? paymentRefNum,
//     dynamic rmPaymentId,
//   }) {
//     _id = id;
//     _companyId = companyId;
//     _invocieId = invocieId;
//     _amount = amount;
//     _checkName = checkName;
//     _checkNumber = checkNumber;
//     _type = type;
//     _isDeposit = isDeposit;
//     _source = source;
//     _createdDate = createdDate;
//     _qboId = qboId;
//     _paymentRefNum = paymentRefNum;
//     _rmPaymentId = rmPaymentId;
//   }

//   Payment.fromJson(dynamic json) {
//     _id = json['Id'];
//     _companyId = json['CompanyId'];
//     _invocieId = json['InvocieId'];
//     _amount = json['Amount'];
//     _checkName = json['CheckName'];
//     _checkNumber = json['CheckNumber'];
//     _type = json['Type'];
//     _isDeposit = json['IsDeposit'];
//     _source = json['Source'];
//     _createdDate = json['CreatedDate'];
//     _qboId = json['QboId'];
//     _paymentRefNum = json['PaymentRefNum'];
//     _rmPaymentId = json['RMPaymentId'];
//   }

//   Payment copyWith({
//     dynamic id,
//     String? companyId,
//     String? invocieId,
//     dynamic amount,
//     String? checkName,
//     String? checkNumber,
//     String? type,
//     bool? isDeposit,
//     String? source,
//     String? createdDate,
//     dynamic qboId,
//     String? paymentRefNum,
//     dynamic rmPaymentId,
//   }) =>
//       Payment(
//         id: id ?? _id,
//         companyId: companyId ?? _companyId,
//         invocieId: invocieId ?? _invocieId,
//         amount: amount ?? _amount,
//         checkName: checkName ?? _checkName,
//         checkNumber: checkNumber ?? _checkNumber,
//         type: type ?? _type,
//         isDeposit: isDeposit ?? _isDeposit,
//         source: source ?? _source,
//         createdDate: createdDate ?? _createdDate,
//         qboId: qboId ?? _qboId,
//         paymentRefNum: paymentRefNum ?? _paymentRefNum,
//         rmPaymentId: rmPaymentId ?? _rmPaymentId,
//       );

//   dynamic get id => _id;
//   String? get companyId => _companyId;
//   String? get invocieId => _invocieId;
//   dynamic get amount => _amount;
//   String? get checkName => _checkName;
//   String? get checkNumber => _checkNumber;
//   String? get type => _type;
//   bool? get isDeposit => _isDeposit;
//   String? get source => _source;
//   String? get createdDate => _createdDate;
//   dynamic get qboId => _qboId;
//   String? get paymentRefNum => _paymentRefNum;
//   dynamic get rmPaymentId => _rmPaymentId;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['Id'] = _id;
//     map['CompanyId'] = _companyId;
//     map['InvocieId'] = _invocieId;
//     map['Amount'] = _amount;
//     map['CheckName'] = _checkName;
//     map['CheckNumber'] = _checkNumber;
//     map['Type'] = _type;
//     map['IsDeposit'] = _isDeposit;
//     map['Source'] = _source;
//     map['CreatedDate'] = _createdDate;
//     map['QboId'] = _qboId;
//     map['PaymentRefNum'] = _paymentRefNum;
//     map['RMPaymentId'] = _rmPaymentId;
//     return map;
//   }
// }
import 'package:hive/hive.dart';

part 'appointment_model.g.dart';

@HiveType(typeId: 0)
class Appointments {
  @HiveField(0)
  String? _companyID;
  @HiveField(1)
  dynamic _apptID;
  @HiveField(2)
  String? _appoinmentUId;
  @HiveField(3)
  dynamic _customerID;
  @HiveField(4)
  String? _serviceTypeId;
  @HiveField(5)
  dynamic _resourceID;
  @HiveField(6)
  dynamic _timeSlotId;
  @HiveField(7)
  String? _apptDateTime;
  @HiveField(8)
  String? _startDateTime;
  @HiveField(9)
  String? _endDateTime;
  @HiveField(10)
  String? _timeSlot;
  @HiveField(11)
  String? _note;
  @HiveField(12)
  String? _statusId;
  @HiveField(13)
  String? _ticketStatusId;
  @HiveField(14)
  String? _createdDateTime;
  @HiveField(15)
  bool? _markDownloaded;
  @HiveField(16)
  String? _promoCode;
  @HiveField(17)
  String? _createdBy;
  @HiveField(18)
  String? _userID;
  @HiveField(25)
  dynamic _customFieldId;
  @HiveField(26)
  List<dynamic>? _customFeilds;
  @HiveField(27)
  String? _siteID;
  @HiveField(19)
  Resource? _resource;
  @HiveField(20)
  Customer? _customer;
  @HiveField(21)
  Status? _status;
  @HiveField(22)
  TicketStatus? _ticketStatus;
  @HiveField(23)
  ServiceType? _serviceType;
  @HiveField(24)
  List<Invoices>? _invoices;

  Appointments({
    String? companyID,
    dynamic apptID,
    String? appoinmentUId,
    dynamic customerID,
    String? serviceTypeId,
    dynamic resourceID,
    dynamic timeSlotId,
    String? apptDateTime,
    String? startDateTime,
    String? endDateTime,
    String? timeSlot,
    String? note,
    String? statusId,
    String? ticketStatusId,
    String? createdDateTime,
    bool? markDownloaded,
    String? promoCode,
    String? createdBy,
    String? userID,
    dynamic customFieldId,
    List<dynamic>? customFeilds,
    String? siteID,
    Resource? resource,
    Customer? customer,
    Status? status,
    TicketStatus? ticketStatus,
    ServiceType? serviceType,
    List<Invoices>? invoices,
  }) {
    _companyID = companyID;
    _apptID = apptID;
    _appoinmentUId = appoinmentUId;
    _customerID = customerID;
    _serviceTypeId = serviceTypeId;
    _resourceID = resourceID;
    _timeSlotId = timeSlotId;
    _apptDateTime = apptDateTime;
    _startDateTime = startDateTime;
    _endDateTime = endDateTime;
    _timeSlot = timeSlot;
    _note = note;
    _statusId = statusId;
    _ticketStatusId = ticketStatusId;
    _createdDateTime = createdDateTime;
    _markDownloaded = markDownloaded;
    _promoCode = promoCode;
    _createdBy = createdBy;
    _userID = userID;
    _customFieldId = customFieldId;
    _customFeilds = customFeilds;
    _siteID = siteID;
    _resource = resource;
    _customer = customer;
    _status = status;
    _ticketStatus = ticketStatus;
    _serviceType = serviceType;
    _invoices = invoices;
  }

  Appointments.fromJson(dynamic json) {
    _companyID = json['CompanyID'];
    _apptID = json['ApptID'];
    _appoinmentUId = json['AppoinmentUId'];
    _customerID = json['CustomerID'];
    _serviceTypeId = json['ServiceTypeId'];
    _resourceID = json['ResourceID'];
    _timeSlotId = json['TimeSlotId'];
    _apptDateTime = json['ApptDateTime'];
    _startDateTime = json['StartDateTime'];
    _endDateTime = json['EndDateTime'];
    _timeSlot = json['TimeSlot'];
    _note = json['Note'];
    _statusId = json['StatusId'];
    _ticketStatusId = json['TicketStatusId'];
    _createdDateTime = json['CreatedDateTime'];
    _markDownloaded = json['MarkDownloaded'];
    _promoCode = json['PromoCode'];
    _createdBy = json['CreatedBy'];
    _userID = json['UserID'];
    _customFieldId = json['CustomFieldId'];
    _customFeilds = json['CustomFeilds'];
    _siteID = json['SiteID'];
    _resource =
        json['Resource'] != null ? Resource.fromJson(json['Resource']) : null;
    _customer =
        json['Customer'] != null ? Customer.fromJson(json['Customer']) : null;
    _status = json['Status'] != null ? Status.fromJson(json['Status']) : null;
    _ticketStatus = json['TicketStatus'] != null
        ? TicketStatus.fromJson(json['TicketStatus'])
        : null;
    _serviceType = json['ServiceType'] != null
        ? ServiceType.fromJson(json['ServiceType'])
        : null;
    if (json['Invoices'] != null) {
      _invoices = [];
      json['Invoices'].forEach((v) {
        _invoices?.add(Invoices.fromJson(v));
      });
    }
  }

  Appointments copyWith({
    String? companyID,
    dynamic apptID,
    String? appoinmentUId,
    dynamic customerID,
    String? serviceTypeId,
    dynamic resourceID,
    dynamic timeSlotId,
    String? apptDateTime,
    String? startDateTime,
    String? endDateTime,
    String? timeSlot,
    String? note,
    String? statusId,
    String? ticketStatusId,
    String? createdDateTime,
    bool? markDownloaded,
    String? promoCode,
    String? createdBy,
    String? userID,
    dynamic customFieldId,
    List<dynamic>? customFeilds,
    String? siteID,
    Resource? resource,
    Customer? customer,
    Status? status,
    TicketStatus? ticketStatus,
    ServiceType? serviceType,
    List<Invoices>? invoices,
  }) =>
      Appointments(
        companyID: companyID ?? _companyID,
        apptID: apptID ?? _apptID,
        appoinmentUId: appoinmentUId ?? _appoinmentUId,
        customerID: customerID ?? _customerID,
        serviceTypeId: serviceTypeId ?? _serviceTypeId,
        resourceID: resourceID ?? _resourceID,
        timeSlotId: timeSlotId ?? _timeSlotId,
        apptDateTime: apptDateTime ?? _apptDateTime,
        startDateTime: startDateTime ?? _startDateTime,
        endDateTime: endDateTime ?? _endDateTime,
        timeSlot: timeSlot ?? _timeSlot,
        note: note ?? _note,
        statusId: statusId ?? _statusId,
        ticketStatusId: ticketStatusId ?? _ticketStatusId,
        createdDateTime: createdDateTime ?? _createdDateTime,
        markDownloaded: markDownloaded ?? _markDownloaded,
        promoCode: promoCode ?? _promoCode,
        createdBy: createdBy ?? _createdBy,
        userID: userID ?? _userID,
        customFieldId: customFieldId ?? _customFieldId,
        customFeilds: customFeilds ?? _customFeilds,
        siteID: siteID ?? _siteID,
        resource: resource ?? _resource,
        customer: customer ?? _customer,
        status: status ?? _status,
        ticketStatus: ticketStatus ?? _ticketStatus,
        serviceType: serviceType ?? _serviceType,
        invoices: invoices ?? _invoices,
      );

  String? get companyID => _companyID;
  dynamic get apptID => _apptID;
  String? get appoinmentUId => _appoinmentUId;
  dynamic get customerID => _customerID;
  String? get serviceTypeId => _serviceTypeId;
  dynamic get resourceID => _resourceID;
  dynamic get timeSlotId => _timeSlotId;
  String? get apptDateTime => _apptDateTime;
  String? get startDateTime => _startDateTime;
  String? get endDateTime => _endDateTime;
  String? get timeSlot => _timeSlot;
  String? get note => _note;
  String? get statusId => _statusId;
  String? get ticketStatusId => _ticketStatusId;
  String? get createdDateTime => _createdDateTime;
  bool? get markDownloaded => _markDownloaded;
  String? get promoCode => _promoCode;
  String? get createdBy => _createdBy;
  String? get userID => _userID;
  dynamic get customFieldId => _customFieldId;
  List<dynamic>? get customFeilds => _customFeilds;
  String? get siteID => _siteID;
  Resource? get resource => _resource;
  Customer? get customer => _customer;
  Status? get status => _status;
  TicketStatus? get ticketStatus => _ticketStatus;
  ServiceType? get serviceType => _serviceType;
  List<Invoices>? get invoices => _invoices;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = _companyID;
    map['ApptID'] = _apptID;
    map['AppoinmentUId'] = _appoinmentUId;
    map['CustomerID'] = _customerID;
    map['ServiceTypeId'] = _serviceTypeId;
    map['ResourceID'] = _resourceID;
    map['TimeSlotId'] = _timeSlotId;
    map['ApptDateTime'] = _apptDateTime;
    map['StartDateTime'] = _startDateTime;
    map['EndDateTime'] = _endDateTime;
    map['TimeSlot'] = _timeSlot;
    map['Note'] = _note;
    map['StatusId'] = _statusId;
    map['TicketStatusId'] = _ticketStatusId;
    map['CreatedDateTime'] = _createdDateTime;
    map['MarkDownloaded'] = _markDownloaded;
    map['PromoCode'] = _promoCode;
    map['CreatedBy'] = _createdBy;
    map['UserID'] = _userID;
    map['CustomFieldId'] = _customFieldId;
    map['CustomFeilds'] = _customFeilds;
    map['SiteID'] = _siteID;
    if (_resource != null) {
      map['Resource'] = _resource?.toJson();
    }
    if (_customer != null) {
      map['Customer'] = _customer?.toJson();
    }
    if (_status != null) {
      map['Status'] = _status?.toJson();
    }
    if (_ticketStatus != null) {
      map['TicketStatus'] = _ticketStatus?.toJson();
    }
    if (_serviceType != null) {
      map['ServiceType'] = _serviceType?.toJson();
    }
    if (_invoices != null) {
      map['Invoices'] = _invoices?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

@HiveType(typeId: 1)
class Invoices {
  @HiveField(0)
  String? _invoiceID;
  @HiveField(1)
  String? _customerGuid;
  @HiveField(2)
  String? _fullName;
  @HiveField(3)
  String? _qBOCustomerId;
  @HiveField(4)
  String? _customerId;
  @HiveField(5)
  double? _depositAmount;
  @HiveField(6)
  String? _city;
  @HiveField(7)
  String? _qBOId;
  @HiveField(8)
  String? _number;
  @HiveField(9)
  String? _invoiceDate;
  @HiveField(10)
  double? _subtotal;
  @HiveField(11)
  double? _amountCollect;
  @HiveField(12)
  double? _discount;
  @HiveField(13)
  double? _total;
  @HiveField(14)
  double? _tax;
  @HiveField(15)
  String? _status;
  @HiveField(16)
  String? _type;
  @HiveField(17)
  String? _note;
  @HiveField(18)
  String? _due;
  @HiveField(19)
  bool? _isConverted;
  @HiveField(20)
  String? _convertedInvoiceID;
  @HiveField(21)
  dynamic _surcharge;
  @HiveField(22)
  List<Items>? _items;
  @HiveField(23)
  String? _discountOption;
  @HiveField(24)
  String? _taxType;
  @HiveField(25)
  String? _requestedDepositAmount;
  @HiveField(26)
  String? _requestedDepositPercentage;
  @HiveField(27)
  dynamic _requestedAmountType;
  @HiveField(28)
  List<Payment>? _paymentList;
  @HiveField(29)
  String? _qboClassId;
// "QboClassId": null,
  @HiveField(30)
  String? _qboLocationId;
// "QboLocationId": null,

  Invoices({
    String? invoiceID,
    String? customerGuid,
    String? fullName,
    String? qBOCustomerId,
    String? customerId,
    double? depositAmount,
    String? city,
    String? qBOId,
    String? number,
    String? invoiceDate,
    double? subtotal,
    double? amountCollect,
    double? discount,
    double? total,
    double? tax,
    String? status,
    String? type,
    String? note,
    String? due,
    bool? isConverted,
    String? convertedInvoiceID,
    dynamic surcharge,
    List<Items>? items,
    String? discountOption,
    String? taxType,
    String? requestedDepositAmount,
    String? requestedDepositPercentage,
    dynamic requestedAmountType,
    String? qboClassId,
    String? qboLocationId,
    List<Payment>? paymentList,
  }) {
    _invoiceID = invoiceID;
    _customerGuid = customerGuid;
    _fullName = fullName;
    _qBOCustomerId = qBOCustomerId;
    _customerId = customerId;
    _depositAmount = depositAmount;
    _city = city;
    _qBOId = qBOId;
    _qboClassId = qboClassId;
    _qboLocationId = qboLocationId;
    _number = number;
    _invoiceDate = invoiceDate;
    _subtotal = subtotal;
    _amountCollect = amountCollect;
    _discount = discount;
    _total = total;
    _tax = tax;
    _status = status;
    _type = type;
    _note = note;
    _due = due;
    _isConverted = isConverted;
    _convertedInvoiceID = convertedInvoiceID;
    _surcharge = surcharge;
    _items = items;
    _discountOption = discountOption;
    _taxType = taxType;
    _requestedDepositAmount = requestedDepositAmount;
    _requestedDepositPercentage = requestedDepositPercentage;
    _requestedAmountType = requestedAmountType;
    _paymentList = paymentList;
  }

  Invoices.fromJson(dynamic json) {
    _invoiceID = json['InvoiceID'];
    _customerGuid = json['CustomerGuid'];
    _fullName = json['FullName'];
    _qBOCustomerId = json['QBOCustomerId'];
    _customerId = json['CustomerId'];
    _depositAmount = json['DepositAmount'];
    _city = json['City'];
    _qBOId = json['QBOId'];
    _number = json['Number'];
    _invoiceDate = json['InvoiceDate'];
    _subtotal = json['Subtotal'];
    _amountCollect = json['AmountCollect'];
    _discount = json['Discount'];
    _total = json['Total'];
    _tax = json['Tax'];
    _status = json['Status'];
    _qboClassId = json['QboClassId']?.toString();
    _qboLocationId = json['QboLocationId']?.toString();
    _type = json['Type'];
    _note = json['Note'];
    _due = json['Due'];
    _isConverted = json['IsConverted'];
    _convertedInvoiceID = json['ConvertedInvoiceID'];
    _surcharge = json['Surcharge'];
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(Items.fromJson(v));
      });
    }
    _discountOption = json['DiscountOption'];
    _taxType = json['TaxType'];
    _requestedDepositAmount = json['RequestedDepositAmount'];
    _requestedDepositPercentage = json['RequestedDepositPercentage'];
    _requestedAmountType = json['RequestedAmountType'];
    if (json['PaymentList'] != null) {
      _paymentList = [];
      json['PaymentList'].forEach((v) {
        _paymentList?.add(Payment.fromJson(v));
      });
    }
  }

  Invoices copyWith({
    String? invoiceID,
    String? customerGuid,
    String? fullName,
    String? qBOCustomerId,
    String? customerId,
    double? depositAmount,
    String? city,
    String? qBOId,
    String? number,
    String? invoiceDate,
    double? subtotal,
    double? amountCollect,
    double? discount,
    double? total,
    double? tax,
    String? status,
    String? type,
    String? note,
    String? due,
    bool? isConverted,
    String? convertedInvoiceID,
    dynamic surcharge,
    String? qboClassId,
    String? qboLocationId,
    List<Items>? items,
    String? discountOption,
    String? taxType,
    String? requestedDepositAmount,
    String? requestedDepositPercentage,
    dynamic requestedAmountType,
    List<Payment>? paymentList,
  }) =>
      Invoices(
        invoiceID: invoiceID ?? _invoiceID,
        customerGuid: customerGuid ?? _customerGuid,
        fullName: fullName ?? _fullName,
        qBOCustomerId: qBOCustomerId ?? _qBOCustomerId,
        customerId: customerId ?? _customerId,
        depositAmount: depositAmount ?? _depositAmount,
        city: city ?? _city,
        qBOId: qBOId ?? _qBOId,
        number: number ?? _number,
        invoiceDate: invoiceDate ?? _invoiceDate,
        subtotal: subtotal ?? _subtotal,
        amountCollect: amountCollect ?? _amountCollect,
        discount: discount ?? _discount,
        total: total ?? _total,
        tax: tax ?? _tax,
        qboClassId: qboClassId ?? _qboClassId,
        qboLocationId: qboLocationId ?? _qboLocationId,
        status: status ?? _status,
        type: type ?? _type,
        note: note ?? _note,
        due: due ?? _due,
        isConverted: isConverted ?? _isConverted,
        convertedInvoiceID: convertedInvoiceID ?? _convertedInvoiceID,
        surcharge: surcharge ?? _surcharge,
        items: items ?? _items,
        discountOption: discountOption ?? _discountOption,
        taxType: taxType ?? _taxType,
        requestedDepositAmount:
            requestedDepositAmount ?? _requestedDepositAmount,
        requestedDepositPercentage:
            requestedDepositPercentage ?? _requestedDepositPercentage,
        requestedAmountType: requestedAmountType ?? _requestedAmountType,
        paymentList: paymentList ?? _paymentList,
      );

  String? get invoiceID => _invoiceID;
  String? get customerGuid => _customerGuid;
  String? get fullName => _fullName;
  String? get qBOCustomerId => _qBOCustomerId;
  String? get customerId => _customerId;
  double? get depositAmount => _depositAmount;
  String? get city => _city;
  String? get qBOId => _qBOId;
  String? get number => _number;
  String? get invoiceDate => _invoiceDate;
  double? get subtotal => _subtotal;
  double? get amountCollect => _amountCollect;
  double? get discount => _discount;
  double? get total => _total;
  double? get tax => _tax;
  String? get status => _status;
  String? get type => _type;
  String? get note => _note;
  String? get due => _due;
  String? get qboClassId => _qboClassId;
  String? get qboLocationId => _qboLocationId;
  bool? get isConverted => _isConverted;
  String? get convertedInvoiceID => _convertedInvoiceID;
  dynamic get surcharge => _surcharge;
  List<Items>? get items => _items;
  String? get discountOption => _discountOption;
  String? get taxType => _taxType;
  String? get requestedDepositAmount => _requestedDepositAmount;
  String? get requestedDepositPercentage => _requestedDepositPercentage;
  dynamic get requestedAmountType => _requestedAmountType;
  List<Payment>? get paymentList => _paymentList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InvoiceID'] = _invoiceID;
    map['CustomerGuid'] = _customerGuid;
    map['FullName'] = _fullName;
    map['QBOCustomerId'] = _qBOCustomerId;
    map['CustomerId'] = _customerId;
    map['DepositAmount'] = _depositAmount;
    map['City'] = _city;
    map['QBOId'] = _qBOId;
    map['Number'] = _number;
    map['QboClassId'] = _qboClassId;
    map['QboLocationId'] = _qboLocationId;
    map['InvoiceDate'] = _invoiceDate;
    map['Subtotal'] = _subtotal;
    map['AmountCollect'] = _amountCollect;
    map['Discount'] = _discount;
    map['Total'] = _total;
    map['Tax'] = _tax;
    map['Status'] = _status;
    map['Type'] = _type;
    map['Note'] = _note;
    map['Due'] = _due;
    map['IsConverted'] = _isConverted;
    map['ConvertedInvoiceID'] = _convertedInvoiceID;
    map['Surcharge'] = _surcharge;
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    map['DiscountOption'] = _discountOption;
    map['TaxType'] = _taxType;
    map['RequestedDepositAmount'] = _requestedDepositAmount;
    map['RequestedDepositPercentage'] = _requestedDepositPercentage;
    map['RequestedAmountType'] = _requestedAmountType;
    if (_paymentList != null) {
      map['PaymentList'] = _paymentList?.map((v) => v.toJson()).toList();
    }

    return map;
  }
}

@HiveType(typeId: 2)
class Items {
  @HiveField(0)
  String? _itemId;
  @HiveField(1)
  String? _name;
  @HiveField(2)
  String? _description;
  @HiveField(3)
  String? _quantity;
  @HiveField(4)
  String? _unitPrice;
  @HiveField(5)
  String? _totalPrice;
  @HiveField(6)
  String? _isTaxable;
  @HiveField(7)
  String? _itemTyId;

  Items({
    String? itemId,
    String? name,
    String? description,
    String? quantity,
    String? unitPrice,
    String? totalPrice,
    String? isTaxable,
    String? itemTyId,
  }) {
    _itemId = itemId;
    _name = name;
    _description = description;
    _quantity = quantity;
    _unitPrice = unitPrice;
    _totalPrice = totalPrice;
    _isTaxable = isTaxable;
    _itemTyId = itemTyId;
  }

  Items.fromJson(dynamic json) {
    _itemId = json['ItemId'];
    _name = json['Name'];
    _description = json['Description'];
    _quantity = json['Quantity'];
    _unitPrice = json['UnitPrice'];
    _totalPrice = json['TotalPrice'];
    _isTaxable = json['IsTaxable'];
    _itemTyId = json['ItemTyId'];
  }

  Items copyWith({
    String? itemId,
    String? name,
    String? description,
    String? quantity,
    String? unitPrice,
    String? totalPrice,
    String? isTaxable,
    String? itemTyId,
  }) =>
      Items(
        itemId: itemId ?? _itemId,
        name: name ?? _name,
        description: description ?? _description,
        quantity: quantity ?? _quantity,
        unitPrice: unitPrice ?? _unitPrice,
        totalPrice: totalPrice ?? _totalPrice,
        isTaxable: isTaxable ?? _isTaxable,
        itemTyId: itemTyId ?? _itemTyId,
      );

  String? get itemId => _itemId;
  String? get name => _name;
  String? get description => _description;
  String? get quantity => _quantity;
  String? get unitPrice => _unitPrice;
  String? get totalPrice => _totalPrice;
  String? get isTaxable => _isTaxable;
  String? get itemTyId => _itemTyId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ItemId'] = _itemId;
    map['Name'] = _name;
    map['Description'] = _description;
    map['Quantity'] = _quantity;
    map['UnitPrice'] = _unitPrice;
    map['TotalPrice'] = _totalPrice;
    map['IsTaxable'] = _isTaxable;
    map['ItemTyId'] = _itemTyId;
    return map;
  }
}

@HiveType(typeId: 3)
class ServiceType {
  @HiveField(0)
  dynamic _companyID;
  @HiveField(1)
  dynamic _serviceTypeID;
  @HiveField(2)
  dynamic _resource;
  @HiveField(3)
  String? _serviceName;
  @HiveField(4)
  dynamic _createdDateTime;
  @HiveField(5)
  dynamic _hour;
  @HiveField(6)
  dynamic _minute;
  @HiveField(7)
  dynamic _calenderColor;
  @HiveField(8)
  dynamic _reminderID;
  @HiveField(9)
  bool? _isInternalUse;

  ServiceType({
    dynamic companyID,
    dynamic serviceTypeID,
    dynamic resource,
    String? serviceName,
    dynamic createdDateTime,
    dynamic hour,
    dynamic minute,
    dynamic calenderColor,
    dynamic reminderID,
    bool? isInternalUse,
  }) {
    _companyID = companyID;
    _serviceTypeID = serviceTypeID;
    _resource = resource;
    _serviceName = serviceName;
    _createdDateTime = createdDateTime;
    _hour = hour;
    _minute = minute;
    _calenderColor = calenderColor;
    _reminderID = reminderID;
    _isInternalUse = isInternalUse;
  }

  ServiceType.fromJson(dynamic json) {
    _companyID = json['CompanyID'];
    _serviceTypeID = json['ServiceTypeID'];
    _resource = json['Resource'];
    _serviceName = json['ServiceName'];
    _createdDateTime = json['CreatedDateTime'];
    _hour = json['Hour'];
    _minute = json['Minute'];
    _calenderColor = json['CalenderColor'];
    _reminderID = json['ReminderID'];
    _isInternalUse = json['IsInternalUse'];
  }

  ServiceType copyWith({
    dynamic companyID,
    dynamic serviceTypeID,
    dynamic resource,
    String? serviceName,
    dynamic createdDateTime,
    dynamic hour,
    dynamic minute,
    dynamic calenderColor,
    dynamic reminderID,
    bool? isInternalUse,
  }) =>
      ServiceType(
        companyID: companyID ?? _companyID,
        serviceTypeID: serviceTypeID ?? _serviceTypeID,
        resource: resource ?? _resource,
        serviceName: serviceName ?? _serviceName,
        createdDateTime: createdDateTime ?? _createdDateTime,
        hour: hour ?? _hour,
        minute: minute ?? _minute,
        calenderColor: calenderColor ?? _calenderColor,
        reminderID: reminderID ?? _reminderID,
        isInternalUse: isInternalUse ?? _isInternalUse,
      );

  dynamic get companyID => _companyID;
  dynamic get serviceTypeID => _serviceTypeID;
  dynamic get resource => _resource;
  String? get serviceName => _serviceName;
  dynamic get createdDateTime => _createdDateTime;
  dynamic get hour => _hour;
  dynamic get minute => _minute;
  dynamic get calenderColor => _calenderColor;
  dynamic get reminderID => _reminderID;
  bool? get isInternalUse => _isInternalUse;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = _companyID;
    map['ServiceTypeID'] = _serviceTypeID;
    map['Resource'] = _resource;
    map['ServiceName'] = _serviceName;
    map['CreatedDateTime'] = _createdDateTime;
    map['Hour'] = _hour;
    map['Minute'] = _minute;
    map['CalenderColor'] = _calenderColor;
    map['ReminderID'] = _reminderID;
    map['IsInternalUse'] = _isInternalUse;
    return map;
  }
}

@HiveType(typeId: 4)
class TicketStatus {
  @HiveField(0)
  dynamic _statusId;
  @HiveField(1)
  String? _statusName;
  @HiveField(2)
  String? _companyId;

  TicketStatus({
    dynamic statusId,
    String? statusName,
    String? companyId,
  }) {
    _statusId = statusId;
    _statusName = statusName;
    _companyId = companyId;
  }

  TicketStatus.fromJson(dynamic json) {
    _statusId = json['StatusId'];
    _statusName = json['StatusName'];
    _companyId = json['CompanyId'];
  }

  TicketStatus copyWith({
    dynamic statusId,
    String? statusName,
    String? companyId,
  }) =>
      TicketStatus(
        statusId: statusId ?? _statusId,
        statusName: statusName ?? _statusName,
        companyId: companyId ?? _companyId,
      );

  dynamic get statusId => _statusId;
  String? get statusName => _statusName;
  String? get companyId => _companyId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['StatusId'] = _statusId;
    map['StatusName'] = _statusName;
    map['CompanyId'] = _companyId;
    return map;
  }
}

@HiveType(typeId: 5)
class Status {
  @HiveField(0)
  dynamic _statusId;
  @HiveField(1)
  String? _statusName;
  @HiveField(2)
  dynamic _companyId;

  Status({
    dynamic statusId,
    String? statusName,
    dynamic companyId,
  }) {
    _statusId = statusId;
    _statusName = statusName;
    _companyId = companyId;
  }

  Status.fromJson(dynamic json) {
    _statusId = json['StatusId'];
    _statusName = json['StatusName'];
    _companyId = json['CompanyId'];
  }

  Status copyWith({
    dynamic statusId,
    String? statusName,
    dynamic companyId,
  }) =>
      Status(
        statusId: statusId ?? _statusId,
        statusName: statusName ?? _statusName,
        companyId: companyId ?? _companyId,
      );

  dynamic get statusId => _statusId;
  String? get statusName => _statusName;
  dynamic get companyId => _companyId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['StatusId'] = _statusId;
    map['StatusName'] = _statusName;
    map['CompanyId'] = _companyId;
    return map;
  }
}

@HiveType(typeId: 6)
class Customer {
  @HiveField(0)
  String? _companyID;
  @HiveField(1)
  String? _createdCompanyID;
  @HiveField(2)
  dynamic _tagID;
  @HiveField(3)
  String? _customerID;
  @HiveField(4)
  String? _aMCustomerID;
  @HiveField(5)
  String? _customerGuid;
  @HiveField(6)
  String? _title;
  @HiveField(7)
  dynamic _title2;
  @HiveField(8)
  String? _firstName;
  @HiveField(9)
  dynamic _firstName2;
  @HiveField(10)
  String? _lastName;
  @HiveField(11)
  dynamic _lastName2;
  @HiveField(12)
  String? _jobTitle;
  @HiveField(13)
  dynamic _jobTitle2;
  @HiveField(14)
  String? _address1;
  @HiveField(15)
  String? _address2;
  @HiveField(16)
  String? _city;
  @HiveField(17)
  String? _state;
  @HiveField(18)
  String? _zipCode;
  @HiveField(19)
  String? _phone;
  @HiveField(20)
  String? _mobile;
  @HiveField(21)
  String? _email;
  @HiveField(22)
  String? _notes;
  @HiveField(23)
  String? _createdDateTime;
  @HiveField(24)
  bool? _callPopUploaded;
  @HiveField(25)
  dynamic _qboId;
  @HiveField(26)
  dynamic _callPopAppId;
  @HiveField(27)
  bool? _isPrimaryContact;
  @HiveField(28)
  dynamic _businessID;
  @HiveField(29)
  dynamic _syncToken;
  @HiveField(30)
  String? _businessName;
  @HiveField(31)
  bool? _isBusinessContact;
  @HiveField(32)
  String? _companyName;
  @HiveField(33)
  dynamic _companyName2;
  @HiveField(34)
  String? _dealerID;
  @HiveField(35)
  bool? _isDealer;
  @HiveField(36)
  dynamic _customerCode;
  @HiveField(37)
  dynamic _updateDate;

  Customer({
    String? companyID,
    String? createdCompanyID,
    dynamic tagID,
    String? customerID,
    String? aMCustomerID,
    String? customerGuid,
    String? title,
    dynamic title2,
    String? firstName,
    dynamic firstName2,
    String? lastName,
    dynamic lastName2,
    String? jobTitle,
    dynamic jobTitle2,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zipCode,
    String? phone,
    String? mobile,
    String? email,
    String? notes,
    String? createdDateTime,
    bool? callPopUploaded,
    dynamic qboId,
    dynamic callPopAppId,
    bool? isPrimaryContact,
    dynamic businessID,
    dynamic syncToken,
    String? businessName,
    bool? isBusinessContact,
    String? companyName,
    dynamic companyName2,
    String? dealerID,
    bool? isDealer,
    dynamic customerCode,
    dynamic updateDate,
  }) {
    _companyID = companyID;
    _createdCompanyID = createdCompanyID;
    _tagID = tagID;
    _customerID = customerID;
    _aMCustomerID = aMCustomerID;
    _customerGuid = customerGuid;
    _title = title;
    _title2 = title2;
    _firstName = firstName;
    _firstName2 = firstName2;
    _lastName = lastName;
    _lastName2 = lastName2;
    _jobTitle = jobTitle;
    _jobTitle2 = jobTitle2;
    _address1 = address1;
    _address2 = address2;
    _city = city;
    _state = state;
    _zipCode = zipCode;
    _phone = phone;
    _mobile = mobile;
    _email = email;
    _notes = notes;
    _createdDateTime = createdDateTime;
    _callPopUploaded = callPopUploaded;
    _qboId = qboId;
    _callPopAppId = callPopAppId;
    _isPrimaryContact = isPrimaryContact;
    _businessID = businessID;
    _syncToken = syncToken;
    _businessName = businessName;
    _isBusinessContact = isBusinessContact;
    _companyName = companyName;
    _companyName2 = companyName2;
    _dealerID = dealerID;
    _isDealer = isDealer;
    _customerCode = customerCode;
    _updateDate = updateDate;
  }

  Customer.fromJson(dynamic json) {
    _companyID = json['CompanyID'];
    _createdCompanyID = json['CreatedCompanyID'];
    _tagID = json['TagID'];
    _customerID = json['CustomerID'];
    _aMCustomerID = json['AMCustomerID'];
    _customerGuid = json['CustomerGuid'];
    _title = json['Title'];
    _title2 = json['Title2'];
    _firstName = json['FirstName'];
    _firstName2 = json['FirstName2'];
    _lastName = json['LastName'];
    _lastName2 = json['LastName2'];
    _jobTitle = json['JobTitle'];
    _jobTitle2 = json['JobTitle2'];
    _address1 = json['Address1'];
    _address2 = json['Address2'];
    _city = json['City'];
    _state = json['State'];
    _zipCode = json['ZipCode'];
    _phone = json['Phone'];
    _mobile = json['Mobile'];
    _email = json['Email'];
    _notes = json['Notes'];
    _createdDateTime = json['CreatedDateTime'];
    _callPopUploaded = json['CallPopUploaded'];
    _qboId = json['QboId'];
    _callPopAppId = json['CallPopAppId'];
    _isPrimaryContact = json['IsPrimaryContact'];
    _businessID = json['BusinessID'];
    _syncToken = json['SyncToken'];
    _businessName = json['BusinessName'];
    _isBusinessContact = json['IsBusinessContact'];
    _companyName = json['CompanyName'];
    _companyName2 = json['CompanyName2'];
    _dealerID = json['DealerID'];
    _isDealer = json['IsDealer'];
    _customerCode = json['CustomerCode'];
    _updateDate = json['UpdateDate'];
  }

  Customer copyWith({
    String? companyID,
    String? createdCompanyID,
    dynamic tagID,
    String? customerID,
    String? aMCustomerID,
    String? customerGuid,
    String? title,
    dynamic title2,
    String? firstName,
    dynamic firstName2,
    String? lastName,
    dynamic lastName2,
    String? jobTitle,
    dynamic jobTitle2,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zipCode,
    String? phone,
    String? mobile,
    String? email,
    String? notes,
    String? createdDateTime,
    bool? callPopUploaded,
    dynamic qboId,
    dynamic callPopAppId,
    bool? isPrimaryContact,
    dynamic businessID,
    dynamic syncToken,
    String? businessName,
    bool? isBusinessContact,
    String? companyName,
    dynamic companyName2,
    String? dealerID,
    bool? isDealer,
    dynamic customerCode,
    dynamic updateDate,
  }) =>
      Customer(
        companyID: companyID ?? _companyID,
        createdCompanyID: createdCompanyID ?? _createdCompanyID,
        tagID: tagID ?? _tagID,
        customerID: customerID ?? _customerID,
        aMCustomerID: aMCustomerID ?? _aMCustomerID,
        customerGuid: customerGuid ?? _customerGuid,
        title: title ?? _title,
        title2: title2 ?? _title2,
        firstName: firstName ?? _firstName,
        firstName2: firstName2 ?? _firstName2,
        lastName: lastName ?? _lastName,
        lastName2: lastName2 ?? _lastName2,
        jobTitle: jobTitle ?? _jobTitle,
        jobTitle2: jobTitle2 ?? _jobTitle2,
        address1: address1 ?? _address1,
        address2: address2 ?? _address2,
        city: city ?? _city,
        state: state ?? _state,
        zipCode: zipCode ?? _zipCode,
        phone: phone ?? _phone,
        mobile: mobile ?? _mobile,
        email: email ?? _email,
        notes: notes ?? _notes,
        createdDateTime: createdDateTime ?? _createdDateTime,
        callPopUploaded: callPopUploaded ?? _callPopUploaded,
        qboId: qboId ?? _qboId,
        callPopAppId: callPopAppId ?? _callPopAppId,
        isPrimaryContact: isPrimaryContact ?? _isPrimaryContact,
        businessID: businessID ?? _businessID,
        syncToken: syncToken ?? _syncToken,
        businessName: businessName ?? _businessName,
        isBusinessContact: isBusinessContact ?? _isBusinessContact,
        companyName: companyName ?? _companyName,
        companyName2: companyName2 ?? _companyName2,
        dealerID: dealerID ?? _dealerID,
        isDealer: isDealer ?? _isDealer,
        customerCode: customerCode ?? _customerCode,
        updateDate: updateDate ?? _updateDate,
      );

  String? get companyID => _companyID;
  String? get createdCompanyID => _createdCompanyID;
  dynamic get tagID => _tagID;
  String? get customerID => _customerID;
  String? get aMCustomerID => _aMCustomerID;
  String? get customerGuid => _customerGuid;
  String? get title => _title;
  dynamic get title2 => _title2;
  String? get firstName => _firstName;
  dynamic get firstName2 => _firstName2;
  String? get lastName => _lastName;
  dynamic get lastName2 => _lastName2;
  String? get jobTitle => _jobTitle;
  dynamic get jobTitle2 => _jobTitle2;
  String? get address1 => _address1;
  String? get address2 => _address2;
  String? get city => _city;
  String? get state => _state;
  String? get zipCode => _zipCode;
  String? get phone => _phone;
  String? get mobile => _mobile;
  String? get email => _email;
  String? get notes => _notes;
  String? get createdDateTime => _createdDateTime;
  bool? get callPopUploaded => _callPopUploaded;
  dynamic get qboId => _qboId;
  dynamic get callPopAppId => _callPopAppId;
  bool? get isPrimaryContact => _isPrimaryContact;
  dynamic get businessID => _businessID;
  dynamic get syncToken => _syncToken;
  String? get businessName => _businessName;
  bool? get isBusinessContact => _isBusinessContact;
  String? get companyName => _companyName;
  dynamic get companyName2 => _companyName2;
  String? get dealerID => _dealerID;
  bool? get isDealer => _isDealer;
  dynamic get customerCode => _customerCode;
  dynamic get updateDate => _updateDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = _companyID;
    map['CreatedCompanyID'] = _createdCompanyID;
    map['TagID'] = _tagID;
    map['CustomerID'] = _customerID;
    map['AMCustomerID'] = _aMCustomerID;
    map['CustomerGuid'] = _customerGuid;
    map['Title'] = _title;
    map['Title2'] = _title2;
    map['FirstName'] = _firstName;
    map['FirstName2'] = _firstName2;
    map['LastName'] = _lastName;
    map['LastName2'] = _lastName2;
    map['JobTitle'] = _jobTitle;
    map['JobTitle2'] = _jobTitle2;
    map['Address1'] = _address1;
    map['Address2'] = _address2;
    map['City'] = _city;
    map['State'] = _state;
    map['ZipCode'] = _zipCode;
    map['Phone'] = _phone;
    map['Mobile'] = _mobile;
    map['Email'] = _email;
    map['Notes'] = _notes;
    map['CreatedDateTime'] = _createdDateTime;
    map['CallPopUploaded'] = _callPopUploaded;
    map['QboId'] = _qboId;
    map['CallPopAppId'] = _callPopAppId;
    map['IsPrimaryContact'] = _isPrimaryContact;
    map['BusinessID'] = _businessID;
    map['SyncToken'] = _syncToken;
    map['BusinessName'] = _businessName;
    map['IsBusinessContact'] = _isBusinessContact;
    map['CompanyName'] = _companyName;
    map['CompanyName2'] = _companyName2;
    map['DealerID'] = _dealerID;
    map['IsDealer'] = _isDealer;
    map['CustomerCode'] = _customerCode;
    map['UpdateDate'] = _updateDate;
    return map;
  }
}

@HiveType(typeId: 7)
class Resource {
  @HiveField(0)
  dynamic _id;
  @HiveField(1)
  dynamic _companyID;
  @HiveField(2)
  String? _name;
  @HiveField(3)
  dynamic _description;
  @HiveField(4)
  dynamic _workingHour;
  @HiveField(5)
  bool? _saterDay;
  @HiveField(6)
  bool? _sunday;
  @HiveField(7)
  bool? _monday;
  @HiveField(8)
  bool? _tuesday;
  @HiveField(9)
  bool? _wednesday;
  @HiveField(10)
  bool? _thursday;
  @HiveField(11)
  bool? _friday;
  @HiveField(12)
  dynamic _mobile;
  @HiveField(13)
  dynamic _email;

  Resource({
    dynamic id,
    dynamic companyID,
    String? name,
    dynamic description,
    dynamic workingHour,
    bool? saterDay,
    bool? sunday,
    bool? monday,
    bool? tuesday,
    bool? wednesday,
    bool? thursday,
    bool? friday,
    dynamic mobile,
    dynamic email,
  }) {
    _id = id;
    _companyID = companyID;
    _name = name;
    _description = description;
    _workingHour = workingHour;
    _saterDay = saterDay;
    _sunday = sunday;
    _monday = monday;
    _tuesday = tuesday;
    _wednesday = wednesday;
    _thursday = thursday;
    _friday = friday;
    _mobile = mobile;
    _email = email;
  }

  Resource.fromJson(dynamic json) {
    _id = json['Id'];
    _companyID = json['CompanyID'];
    _name = json['Name'];
    _description = json['Description'];
    _workingHour = json['WorkingHour'];
    _saterDay = json['SaterDay'];
    _sunday = json['Sunday'];
    _monday = json['Monday'];
    _tuesday = json['Tuesday'];
    _wednesday = json['Wednesday'];
    _thursday = json['Thursday'];
    _friday = json['Friday'];
    _mobile = json['Mobile'];
    _email = json['Email'];
  }

  Resource copyWith({
    dynamic id,
    dynamic companyID,
    String? name,
    dynamic description,
    dynamic workingHour,
    bool? saterDay,
    bool? sunday,
    bool? monday,
    bool? tuesday,
    bool? wednesday,
    bool? thursday,
    bool? friday,
    dynamic mobile,
    dynamic email,
  }) =>
      Resource(
        id: id ?? _id,
        companyID: companyID ?? _companyID,
        name: name ?? _name,
        description: description ?? _description,
        workingHour: workingHour ?? _workingHour,
        saterDay: saterDay ?? _saterDay,
        sunday: sunday ?? _sunday,
        monday: monday ?? _monday,
        tuesday: tuesday ?? _tuesday,
        wednesday: wednesday ?? _wednesday,
        thursday: thursday ?? _thursday,
        friday: friday ?? _friday,
        mobile: mobile ?? _mobile,
        email: email ?? _email,
      );

  dynamic get id => _id;
  dynamic get companyID => _companyID;
  String? get name => _name;
  dynamic get description => _description;
  dynamic get workingHour => _workingHour;
  bool? get saterDay => _saterDay;
  bool? get sunday => _sunday;
  bool? get monday => _monday;
  bool? get tuesday => _tuesday;
  bool? get wednesday => _wednesday;
  bool? get thursday => _thursday;
  bool? get friday => _friday;
  dynamic get mobile => _mobile;
  dynamic get email => _email;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Id'] = _id;
    map['CompanyID'] = _companyID;
    map['Name'] = _name;
    map['Description'] = _description;
    map['WorkingHour'] = _workingHour;
    map['SaterDay'] = _saterDay;
    map['Sunday'] = _sunday;
    map['Monday'] = _monday;
    map['Tuesday'] = _tuesday;
    map['Wednesday'] = _wednesday;
    map['Thursday'] = _thursday;
    map['Friday'] = _friday;
    map['Mobile'] = _mobile;
    map['Email'] = _email;
    return map;
  }
}

@HiveType(typeId: 8)
class Payment {
  @HiveField(0)
  dynamic _id;
  @HiveField(1)
  String? _companyId;
  @HiveField(2)
  String? _invocieId;
  @HiveField(3)
  double? _amount;
  @HiveField(4)
  String? _checkName;
  @HiveField(5)
  String? _checkNumber;
  @HiveField(6)
  String? _type;
  @HiveField(7)
  bool? _isDeposit;
  @HiveField(8)
  String? _source;
  @HiveField(9)
  String? _createdDate;
  @HiveField(10)
  dynamic _qboId;
  @HiveField(11)
  String? _paymentRefNum;
  @HiveField(12)
  dynamic _rmPaymentId;

  Payment({
    dynamic id,
    String? companyId,
    String? invocieId,
    dynamic amount,
    String? checkName,
    String? checkNumber,
    String? type,
    bool? isDeposit,
    String? source,
    String? createdDate,
    dynamic qboId,
    String? paymentRefNum,
    dynamic rmPaymentId,
  }) {
    _id = id;
    _companyId = companyId;
    _invocieId = invocieId;
    _amount = amount;
    _checkName = checkName;
    _checkNumber = checkNumber;
    _type = type;
    _isDeposit = isDeposit;
    _source = source;
    _createdDate = createdDate;
    _qboId = qboId;
    _paymentRefNum = paymentRefNum;
    _rmPaymentId = rmPaymentId;
  }

  Payment.fromJson(dynamic json) {
    _id = json['Id'];
    _companyId = json['CompanyId'];
    _invocieId = json['InvocieId'];
    _amount = json['Amount'];
    _checkName = json['CheckName'];
    _checkNumber = json['CheckNumber'];
    _type = json['Type'];
    _isDeposit = json['IsDeposit'];
    _source = json['Source'];
    _createdDate = json['CreatedDate'];
    _qboId = json['QboId'];
    _paymentRefNum = json['PaymentRefNum'];
    _rmPaymentId = json['RMPaymentId'];
  }

  Payment copyWith({
    dynamic id,
    String? companyId,
    String? invocieId,
    dynamic amount,
    String? checkName,
    String? checkNumber,
    String? type,
    bool? isDeposit,
    String? source,
    String? createdDate,
    dynamic qboId,
    String? paymentRefNum,
    dynamic rmPaymentId,
  }) =>
      Payment(
        id: id ?? _id,
        companyId: companyId ?? _companyId,
        invocieId: invocieId ?? _invocieId,
        amount: amount ?? _amount,
        checkName: checkName ?? _checkName,
        checkNumber: checkNumber ?? _checkNumber,
        type: type ?? _type,
        isDeposit: isDeposit ?? _isDeposit,
        source: source ?? _source,
        createdDate: createdDate ?? _createdDate,
        qboId: qboId ?? _qboId,
        paymentRefNum: paymentRefNum ?? _paymentRefNum,
        rmPaymentId: rmPaymentId ?? _rmPaymentId,
      );

  dynamic get id => _id;
  String? get companyId => _companyId;
  String? get invocieId => _invocieId;
  dynamic get amount => _amount;
  String? get checkName => _checkName;
  String? get checkNumber => _checkNumber;
  String? get type => _type;
  bool? get isDeposit => _isDeposit;
  String? get source => _source;
  String? get createdDate => _createdDate;
  dynamic get qboId => _qboId;
  String? get paymentRefNum => _paymentRefNum;
  dynamic get rmPaymentId => _rmPaymentId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Id'] = _id;
    map['CompanyId'] = _companyId;
    map['InvocieId'] = _invocieId;
    map['Amount'] = _amount;
    map['CheckName'] = _checkName;
    map['CheckNumber'] = _checkNumber;
    map['Type'] = _type;
    map['IsDeposit'] = _isDeposit;
    map['Source'] = _source;
    map['CreatedDate'] = _createdDate;
    map['QboId'] = _qboId;
    map['PaymentRefNum'] = _paymentRefNum;
    map['RMPaymentId'] = _rmPaymentId;
    return map;
  }
}
