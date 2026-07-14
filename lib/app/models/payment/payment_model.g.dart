// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      .._rmPaymentId = fields[12] as dynamic
      .._signatures = (fields[13] as List?)?.cast<PaymentSignature>();
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer
      ..writeByte(14)
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
      ..write(obj._rmPaymentId)
      ..writeByte(13)
      ..write(obj._signatures);
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

class PaymentSignatureAdapter extends TypeAdapter<PaymentSignature> {
  @override
  final int typeId = 9;

  @override
  PaymentSignature read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentSignature()
      .._id = fields[0] as dynamic
      .._appointmentId = fields[1] as dynamic
      .._invoiceId = fields[2] as String?
      .._paymentId = fields[3] as dynamic
      .._customerId = fields[4] as dynamic
      .._companyId = fields[5] as String?
      .._signatureFileName = fields[6] as String?
      .._signatureFileURL = fields[7] as String?
      .._signatureFileContent = fields[8] as dynamic
      .._createdDate = fields[9] as String?
      .._userId = fields[10] as String?;
  }

  @override
  void write(BinaryWriter writer, PaymentSignature obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj._id)
      ..writeByte(1)
      ..write(obj._appointmentId)
      ..writeByte(2)
      ..write(obj._invoiceId)
      ..writeByte(3)
      ..write(obj._paymentId)
      ..writeByte(4)
      ..write(obj._customerId)
      ..writeByte(5)
      ..write(obj._companyId)
      ..writeByte(6)
      ..write(obj._signatureFileName)
      ..writeByte(7)
      ..write(obj._signatureFileURL)
      ..writeByte(8)
      ..write(obj._signatureFileContent)
      ..writeByte(9)
      ..write(obj._createdDate)
      ..writeByte(10)
      ..write(obj._userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentSignatureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
