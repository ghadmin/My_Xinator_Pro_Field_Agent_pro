// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_location_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingLocationModelAdapter extends TypeAdapter<PendingLocationModel> {
  @override
  final int typeId = 18;

  @override
  PendingLocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingLocationModel(
      id: fields[0] as String,
      company_id: fields[1] as String,
      user_id: fields[2] as String,
      username: fields[3] as String,
      email: fields[4] as String,
      latitude: fields[5] as double,
      longitude: fields[6] as double,
      accuracy: fields[7] as double,
      locationTimestamp: fields[8] as DateTime,
      queuedAt: fields[9] as DateTime,
      retryCount: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PendingLocationModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.company_id)
      ..writeByte(2)
      ..write(obj.user_id)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.accuracy)
      ..writeByte(8)
      ..write(obj.locationTimestamp)
      ..writeByte(9)
      ..write(obj.queuedAt)
      ..writeByte(10)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingLocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
