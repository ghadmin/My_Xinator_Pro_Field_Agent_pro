// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemListModelAdapter extends TypeAdapter<ItemListModel> {
  @override
  final int typeId = 10;

  @override
  ItemListModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemListModel(
      id: fields[0] as String?,
      name: fields[1] as String?,
      description: fields[2] as String?,
      barcode: fields[3] as String?,
      itemTypeId: fields[4] as int?,
      price: fields[5] as double?,
      location: fields[6] as String?,
      isTaxable: fields[7] as bool?,
      companyId: fields[8] as String?,
      isDeleted: fields[9] as bool?,
      qboId: fields[10] as int?,
      quantityOnHand: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ItemListModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.barcode)
      ..writeByte(4)
      ..write(obj.itemTypeId)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.isTaxable)
      ..writeByte(8)
      ..write(obj.companyId)
      ..writeByte(9)
      ..write(obj.isDeleted)
      ..writeByte(10)
      ..write(obj.qboId)
      ..writeByte(11)
      ..write(obj.quantityOnHand);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemListModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
