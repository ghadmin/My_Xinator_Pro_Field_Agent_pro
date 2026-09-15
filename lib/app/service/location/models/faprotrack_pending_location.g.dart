// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faprotrack_pending_location.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FaProTrackPendingLocationAdapter
    extends TypeAdapter<FaProTrackPendingLocation> {
  @override
  final int typeId = 19;

  @override
  FaProTrackPendingLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FaProTrackPendingLocation(
      id: fields[0] as String,
      companyId: fields[1] as String,
      resourceId: fields[2] as int,
      deviceId: fields[3] as String,
      latitude: fields[4] as double,
      longitude: fields[5] as double,
      recordedAt: fields[6] as String,
      accuracy: fields[7] as double,
      speed: fields[8] as double,
      heading: fields[9] as double,
      altitude: fields[10] as double,
      batteryLevel: fields[11] as int,
      networkType: fields[12] as String,
      queuedAt: fields[13] as DateTime,
      retryCount: fields[14] as int,
      lastRetryAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FaProTrackPendingLocation obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.companyId)
      ..writeByte(2)
      ..write(obj.resourceId)
      ..writeByte(3)
      ..write(obj.deviceId)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.recordedAt)
      ..writeByte(7)
      ..write(obj.accuracy)
      ..writeByte(8)
      ..write(obj.speed)
      ..writeByte(9)
      ..write(obj.heading)
      ..writeByte(10)
      ..write(obj.altitude)
      ..writeByte(11)
      ..write(obj.batteryLevel)
      ..writeByte(12)
      ..write(obj.networkType)
      ..writeByte(13)
      ..write(obj.queuedAt)
      ..writeByte(14)
      ..write(obj.retryCount)
      ..writeByte(15)
      ..write(obj.lastRetryAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaProTrackPendingLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
