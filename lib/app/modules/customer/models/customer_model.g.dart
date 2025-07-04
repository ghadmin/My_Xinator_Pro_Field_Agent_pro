// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerModelAdapter extends TypeAdapter<CustomerModel> {
  @override
  final int typeId = 13;

  @override
  CustomerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerModel(
      companyID: fields[0] as String?,
      createdCompanyID: fields[1] as String?,
      tagID: fields[2] as int?,
      customerID: fields[3] as String?,
      aMCustomerID: fields[4] as String?,
      customerGuid: fields[5] as String?,
      title: fields[6] as String?,
      title2: fields[7] as dynamic,
      firstName: fields[8] as String?,
      firstName2: fields[9] as dynamic,
      lastName: fields[10] as String?,
      lastName2: fields[11] as dynamic,
      jobTitle: fields[12] as String?,
      jobTitle2: fields[13] as dynamic,
      address1: fields[14] as String?,
      address2: fields[15] as String?,
      city: fields[16] as String?,
      state: fields[17] as String?,
      zipCode: fields[18] as String?,
      phone: fields[19] as String?,
      mobile: fields[20] as String?,
      email: fields[21] as String?,
      notes: fields[22] as String?,
      createdDateTime: fields[23] as dynamic,
      callPopUploaded: fields[24] as bool?,
      qboId: fields[25] as int?,
      callPopAppId: fields[26] as dynamic,
      isPrimaryContact: fields[27] as bool?,
      businessID: fields[28] as int?,
      syncToken: fields[29] as int?,
      businessName: fields[30] as String?,
      isBusinessContact: fields[31] as bool?,
      companyName: fields[32] as String?,
      companyName2: fields[33] as dynamic,
      dealerID: fields[34] as String?,
      isDealer: fields[35] as bool?,
      customerCode: fields[36] as String?,
      updateDate: fields[37] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerModel obj) {
    writer
      ..writeByte(38)
      ..writeByte(0)
      ..write(obj.companyID)
      ..writeByte(1)
      ..write(obj.createdCompanyID)
      ..writeByte(2)
      ..write(obj.tagID)
      ..writeByte(3)
      ..write(obj.customerID)
      ..writeByte(4)
      ..write(obj.aMCustomerID)
      ..writeByte(5)
      ..write(obj.customerGuid)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.title2)
      ..writeByte(8)
      ..write(obj.firstName)
      ..writeByte(9)
      ..write(obj.firstName2)
      ..writeByte(10)
      ..write(obj.lastName)
      ..writeByte(11)
      ..write(obj.lastName2)
      ..writeByte(12)
      ..write(obj.jobTitle)
      ..writeByte(13)
      ..write(obj.jobTitle2)
      ..writeByte(14)
      ..write(obj.address1)
      ..writeByte(15)
      ..write(obj.address2)
      ..writeByte(16)
      ..write(obj.city)
      ..writeByte(17)
      ..write(obj.state)
      ..writeByte(18)
      ..write(obj.zipCode)
      ..writeByte(19)
      ..write(obj.phone)
      ..writeByte(20)
      ..write(obj.mobile)
      ..writeByte(21)
      ..write(obj.email)
      ..writeByte(22)
      ..write(obj.notes)
      ..writeByte(23)
      ..write(obj.createdDateTime)
      ..writeByte(24)
      ..write(obj.callPopUploaded)
      ..writeByte(25)
      ..write(obj.qboId)
      ..writeByte(26)
      ..write(obj.callPopAppId)
      ..writeByte(27)
      ..write(obj.isPrimaryContact)
      ..writeByte(28)
      ..write(obj.businessID)
      ..writeByte(29)
      ..write(obj.syncToken)
      ..writeByte(30)
      ..write(obj.businessName)
      ..writeByte(31)
      ..write(obj.isBusinessContact)
      ..writeByte(32)
      ..write(obj.companyName)
      ..writeByte(33)
      ..write(obj.companyName2)
      ..writeByte(34)
      ..write(obj.dealerID)
      ..writeByte(35)
      ..write(obj.isDealer)
      ..writeByte(36)
      ..write(obj.customerCode)
      ..writeByte(37)
      ..write(obj.updateDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
