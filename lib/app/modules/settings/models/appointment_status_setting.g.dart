// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_status_setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentStatusSettingAdapter
    extends TypeAdapter<AppointmentStatusSetting> {
  @override
  final int typeId = 11;

  @override
  AppointmentStatusSetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppointmentStatusSetting(
      statusId: fields[0] as int?,
      statusName: fields[1] as String?,
      companyId: fields[2] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentStatusSetting obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.statusId)
      ..writeByte(1)
      ..write(obj.statusName)
      ..writeByte(2)
      ..write(obj.companyId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentStatusSettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
