// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentsAdapter extends TypeAdapter<Appointments> {
  @override
  final int typeId = 0;

  @override
  Appointments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appointments()
      .._companyID = fields[0] as String?
      .._apptID = fields[1] as dynamic
      .._appoinmentUId = fields[2] as String?
      .._customerID = fields[3] as dynamic
      .._serviceTypeId = fields[4] as String?
      .._resourceID = fields[5] as dynamic
      .._timeSlotId = fields[6] as dynamic
      .._apptDateTime = fields[7] as String?
      .._startDateTime = fields[8] as String?
      .._endDateTime = fields[9] as String?
      .._timeSlot = fields[10] as String?
      .._note = fields[11] as String?
      .._statusId = fields[12] as String?
      .._ticketStatusId = fields[13] as String?
      .._createdDateTime = fields[14] as String?
      .._markDownloaded = fields[15] as bool?
      .._promoCode = fields[16] as String?
      .._createdBy = fields[17] as String?
      .._userID = fields[18] as String?
      .._resource = fields[19] as Resource?
      .._customer = fields[20] as Customer?
      .._status = fields[21] as Status?
      .._ticketStatus = fields[22] as TicketStatus?
      .._serviceType = fields[23] as ServiceType?
      .._invoices = (fields[24] as List?)?.cast<Invoices>();
  }

  @override
  void write(BinaryWriter writer, Appointments obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj._companyID)
      ..writeByte(1)
      ..write(obj._apptID)
      ..writeByte(2)
      ..write(obj._appoinmentUId)
      ..writeByte(3)
      ..write(obj._customerID)
      ..writeByte(4)
      ..write(obj._serviceTypeId)
      ..writeByte(5)
      ..write(obj._resourceID)
      ..writeByte(6)
      ..write(obj._timeSlotId)
      ..writeByte(7)
      ..write(obj._apptDateTime)
      ..writeByte(8)
      ..write(obj._startDateTime)
      ..writeByte(9)
      ..write(obj._endDateTime)
      ..writeByte(10)
      ..write(obj._timeSlot)
      ..writeByte(11)
      ..write(obj._note)
      ..writeByte(12)
      ..write(obj._statusId)
      ..writeByte(13)
      ..write(obj._ticketStatusId)
      ..writeByte(14)
      ..write(obj._createdDateTime)
      ..writeByte(15)
      ..write(obj._markDownloaded)
      ..writeByte(16)
      ..write(obj._promoCode)
      ..writeByte(17)
      ..write(obj._createdBy)
      ..writeByte(18)
      ..write(obj._userID)
      ..writeByte(19)
      ..write(obj._resource)
      ..writeByte(20)
      ..write(obj._customer)
      ..writeByte(21)
      ..write(obj._status)
      ..writeByte(22)
      ..write(obj._ticketStatus)
      ..writeByte(23)
      ..write(obj._serviceType)
      ..writeByte(24)
      ..write(obj._invoices);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoicesAdapter extends TypeAdapter<Invoices> {
  @override
  final int typeId = 1;

  @override
  Invoices read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Invoices()
      .._invoiceID = fields[0] as String?
      .._customerGuid = fields[1] as String?
      .._fullName = fields[2] as String?
      .._qBOCustomerId = fields[3] as String?
      .._customerId = fields[4] as String?
      .._depositAmount = fields[5] as double?
      .._city = fields[6] as String?
      .._qBOId = fields[7] as String?
      .._number = fields[8] as String?
      .._invoiceDate = fields[9] as String?
      .._subtotal = fields[10] as double?
      .._amountCollect = fields[11] as double?
      .._discount = fields[12] as double?
      .._total = fields[13] as double?
      .._tax = fields[14] as double?
      .._status = fields[15] as String?
      .._type = fields[16] as String?
      .._note = fields[17] as String?
      .._due = fields[18] as String?
      .._isConverted = fields[19] as bool?
      .._convertedInvoiceID = fields[20] as String?
      .._surcharge = fields[21] as dynamic
      .._items = (fields[22] as List?)?.cast<Items>()
      .._discountOption = fields[23] as String?
      .._taxType = fields[24] as String?
      .._paymentList = (fields[25] as List?)?.cast<Payment>();
  }

  @override
  void write(BinaryWriter writer, Invoices obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj._invoiceID)
      ..writeByte(1)
      ..write(obj._customerGuid)
      ..writeByte(2)
      ..write(obj._fullName)
      ..writeByte(3)
      ..write(obj._qBOCustomerId)
      ..writeByte(4)
      ..write(obj._customerId)
      ..writeByte(5)
      ..write(obj._depositAmount)
      ..writeByte(6)
      ..write(obj._city)
      ..writeByte(7)
      ..write(obj._qBOId)
      ..writeByte(8)
      ..write(obj._number)
      ..writeByte(9)
      ..write(obj._invoiceDate)
      ..writeByte(10)
      ..write(obj._subtotal)
      ..writeByte(11)
      ..write(obj._amountCollect)
      ..writeByte(12)
      ..write(obj._discount)
      ..writeByte(13)
      ..write(obj._total)
      ..writeByte(14)
      ..write(obj._tax)
      ..writeByte(15)
      ..write(obj._status)
      ..writeByte(16)
      ..write(obj._type)
      ..writeByte(17)
      ..write(obj._note)
      ..writeByte(18)
      ..write(obj._due)
      ..writeByte(19)
      ..write(obj._isConverted)
      ..writeByte(20)
      ..write(obj._convertedInvoiceID)
      ..writeByte(21)
      ..write(obj._surcharge)
      ..writeByte(22)
      ..write(obj._items)
      ..writeByte(23)
      ..write(obj._discountOption)
      ..writeByte(24)
      ..write(obj._taxType)
      ..writeByte(25)
      ..write(obj._paymentList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoicesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemsAdapter extends TypeAdapter<Items> {
  @override
  final int typeId = 2;

  @override
  Items read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Items()
      .._itemId = fields[0] as String?
      .._name = fields[1] as String?
      .._description = fields[2] as String?
      .._quantity = fields[3] as String?
      .._unitPrice = fields[4] as String?
      .._totalPrice = fields[5] as String?
      .._isTaxable = fields[6] as String?
      .._itemTyId = fields[7] as String?;
  }

  @override
  void write(BinaryWriter writer, Items obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj._itemId)
      ..writeByte(1)
      ..write(obj._name)
      ..writeByte(2)
      ..write(obj._description)
      ..writeByte(3)
      ..write(obj._quantity)
      ..writeByte(4)
      ..write(obj._unitPrice)
      ..writeByte(5)
      ..write(obj._totalPrice)
      ..writeByte(6)
      ..write(obj._isTaxable)
      ..writeByte(7)
      ..write(obj._itemTyId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServiceTypeAdapter extends TypeAdapter<ServiceType> {
  @override
  final int typeId = 3;

  @override
  ServiceType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceType()
      .._companyID = fields[0] as dynamic
      .._serviceTypeID = fields[1] as dynamic
      .._resource = fields[2] as dynamic
      .._serviceName = fields[3] as String?
      .._createdDateTime = fields[4] as dynamic
      .._hour = fields[5] as dynamic
      .._minute = fields[6] as dynamic
      .._calenderColor = fields[7] as dynamic
      .._reminderID = fields[8] as dynamic
      .._isInternalUse = fields[9] as bool?;
  }

  @override
  void write(BinaryWriter writer, ServiceType obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj._companyID)
      ..writeByte(1)
      ..write(obj._serviceTypeID)
      ..writeByte(2)
      ..write(obj._resource)
      ..writeByte(3)
      ..write(obj._serviceName)
      ..writeByte(4)
      ..write(obj._createdDateTime)
      ..writeByte(5)
      ..write(obj._hour)
      ..writeByte(6)
      ..write(obj._minute)
      ..writeByte(7)
      ..write(obj._calenderColor)
      ..writeByte(8)
      ..write(obj._reminderID)
      ..writeByte(9)
      ..write(obj._isInternalUse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TicketStatusAdapter extends TypeAdapter<TicketStatus> {
  @override
  final int typeId = 4;

  @override
  TicketStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TicketStatus()
      .._statusId = fields[0] as dynamic
      .._statusName = fields[1] as String?
      .._companyId = fields[2] as String?;
  }

  @override
  void write(BinaryWriter writer, TicketStatus obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj._statusId)
      ..writeByte(1)
      ..write(obj._statusName)
      ..writeByte(2)
      ..write(obj._companyId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatusAdapter extends TypeAdapter<Status> {
  @override
  final int typeId = 5;

  @override
  Status read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Status()
      .._statusId = fields[0] as dynamic
      .._statusName = fields[1] as String?
      .._companyId = fields[2] as dynamic;
  }

  @override
  void write(BinaryWriter writer, Status obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj._statusId)
      ..writeByte(1)
      ..write(obj._statusName)
      ..writeByte(2)
      ..write(obj._companyId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 6;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer()
      .._companyID = fields[0] as String?
      .._createdCompanyID = fields[1] as String?
      .._tagID = fields[2] as dynamic
      .._customerID = fields[3] as String?
      .._aMCustomerID = fields[4] as String?
      .._customerGuid = fields[5] as String?
      .._title = fields[6] as String?
      .._title2 = fields[7] as dynamic
      .._firstName = fields[8] as String?
      .._firstName2 = fields[9] as dynamic
      .._lastName = fields[10] as String?
      .._lastName2 = fields[11] as dynamic
      .._jobTitle = fields[12] as String?
      .._jobTitle2 = fields[13] as dynamic
      .._address1 = fields[14] as String?
      .._address2 = fields[15] as String?
      .._city = fields[16] as String?
      .._state = fields[17] as String?
      .._zipCode = fields[18] as String?
      .._phone = fields[19] as String?
      .._mobile = fields[20] as String?
      .._email = fields[21] as String?
      .._notes = fields[22] as String?
      .._createdDateTime = fields[23] as String?
      .._callPopUploaded = fields[24] as bool?
      .._qboId = fields[25] as dynamic
      .._callPopAppId = fields[26] as dynamic
      .._isPrimaryContact = fields[27] as bool?
      .._businessID = fields[28] as dynamic
      .._syncToken = fields[29] as dynamic
      .._businessName = fields[30] as String?
      .._isBusinessContact = fields[31] as bool?
      .._companyName = fields[32] as String?
      .._companyName2 = fields[33] as dynamic
      .._dealerID = fields[34] as String?
      .._isDealer = fields[35] as bool?
      .._customerCode = fields[36] as dynamic
      .._updateDate = fields[37] as dynamic;
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(38)
      ..writeByte(0)
      ..write(obj._companyID)
      ..writeByte(1)
      ..write(obj._createdCompanyID)
      ..writeByte(2)
      ..write(obj._tagID)
      ..writeByte(3)
      ..write(obj._customerID)
      ..writeByte(4)
      ..write(obj._aMCustomerID)
      ..writeByte(5)
      ..write(obj._customerGuid)
      ..writeByte(6)
      ..write(obj._title)
      ..writeByte(7)
      ..write(obj._title2)
      ..writeByte(8)
      ..write(obj._firstName)
      ..writeByte(9)
      ..write(obj._firstName2)
      ..writeByte(10)
      ..write(obj._lastName)
      ..writeByte(11)
      ..write(obj._lastName2)
      ..writeByte(12)
      ..write(obj._jobTitle)
      ..writeByte(13)
      ..write(obj._jobTitle2)
      ..writeByte(14)
      ..write(obj._address1)
      ..writeByte(15)
      ..write(obj._address2)
      ..writeByte(16)
      ..write(obj._city)
      ..writeByte(17)
      ..write(obj._state)
      ..writeByte(18)
      ..write(obj._zipCode)
      ..writeByte(19)
      ..write(obj._phone)
      ..writeByte(20)
      ..write(obj._mobile)
      ..writeByte(21)
      ..write(obj._email)
      ..writeByte(22)
      ..write(obj._notes)
      ..writeByte(23)
      ..write(obj._createdDateTime)
      ..writeByte(24)
      ..write(obj._callPopUploaded)
      ..writeByte(25)
      ..write(obj._qboId)
      ..writeByte(26)
      ..write(obj._callPopAppId)
      ..writeByte(27)
      ..write(obj._isPrimaryContact)
      ..writeByte(28)
      ..write(obj._businessID)
      ..writeByte(29)
      ..write(obj._syncToken)
      ..writeByte(30)
      ..write(obj._businessName)
      ..writeByte(31)
      ..write(obj._isBusinessContact)
      ..writeByte(32)
      ..write(obj._companyName)
      ..writeByte(33)
      ..write(obj._companyName2)
      ..writeByte(34)
      ..write(obj._dealerID)
      ..writeByte(35)
      ..write(obj._isDealer)
      ..writeByte(36)
      ..write(obj._customerCode)
      ..writeByte(37)
      ..write(obj._updateDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResourceAdapter extends TypeAdapter<Resource> {
  @override
  final int typeId = 7;

  @override
  Resource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Resource()
      .._id = fields[0] as dynamic
      .._companyID = fields[1] as dynamic
      .._name = fields[2] as String?
      .._description = fields[3] as dynamic
      .._workingHour = fields[4] as dynamic
      .._saterDay = fields[5] as bool?
      .._sunday = fields[6] as bool?
      .._monday = fields[7] as bool?
      .._tuesday = fields[8] as bool?
      .._wednesday = fields[9] as bool?
      .._thursday = fields[10] as bool?
      .._friday = fields[11] as bool?
      .._mobile = fields[12] as dynamic
      .._email = fields[13] as dynamic;
  }

  @override
  void write(BinaryWriter writer, Resource obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj._id)
      ..writeByte(1)
      ..write(obj._companyID)
      ..writeByte(2)
      ..write(obj._name)
      ..writeByte(3)
      ..write(obj._description)
      ..writeByte(4)
      ..write(obj._workingHour)
      ..writeByte(5)
      ..write(obj._saterDay)
      ..writeByte(6)
      ..write(obj._sunday)
      ..writeByte(7)
      ..write(obj._monday)
      ..writeByte(8)
      ..write(obj._tuesday)
      ..writeByte(9)
      ..write(obj._wednesday)
      ..writeByte(10)
      ..write(obj._thursday)
      ..writeByte(11)
      ..write(obj._friday)
      ..writeByte(12)
      ..write(obj._mobile)
      ..writeByte(13)
      ..write(obj._email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final int typeId = 8;

  @override
  Payment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Payment()
      .._id = fields[0] as dynamic
      .._companyId = fields[1] as String?
      .._invocieId = fields[2] as String?
      .._amount = fields[3] as double?
      .._checkName = fields[4] as String?
      .._checkNumber = fields[5] as String?
      .._type = fields[6] as String?
      .._isDeposit = fields[7] as bool?
      .._source = fields[8] as String?
      .._createdDate = fields[9] as String?
      .._qboId = fields[10] as dynamic
      .._paymentRefNum = fields[11] as String?
      .._rmPaymentId = fields[12] as dynamic;
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj._id)
      ..writeByte(1)
      ..write(obj._companyId)
      ..writeByte(2)
      ..write(obj._invocieId)
      ..writeByte(3)
      ..write(obj._amount)
      ..writeByte(4)
      ..write(obj._checkName)
      ..writeByte(5)
      ..write(obj._checkNumber)
      ..writeByte(6)
      ..write(obj._type)
      ..writeByte(7)
      ..write(obj._isDeposit)
      ..writeByte(8)
      ..write(obj._source)
      ..writeByte(9)
      ..write(obj._createdDate)
      ..writeByte(10)
      ..write(obj._qboId)
      ..writeByte(11)
      ..write(obj._paymentRefNum)
      ..writeByte(12)
      ..write(obj._rmPaymentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
