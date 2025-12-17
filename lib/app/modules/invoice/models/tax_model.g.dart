// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaxModelAdapter extends TypeAdapter<TaxModel> {
  @override
  final int typeId = 9;

  @override
  TaxModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaxModel(
      id: fields[0] as int?,
      name: fields[1] as String?,
      rate: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TaxModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.rate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
