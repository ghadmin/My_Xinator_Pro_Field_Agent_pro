// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_group_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemGroupModelAdapter extends TypeAdapter<ItemGroupModel> {
  @override
  final int typeId = 11;

  @override
  ItemGroupModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemGroupModel(
      id: fields[0] as int?,
      groupName: fields[1] as String?,
      description: fields[2] as String?,
      itemCount: fields[3] as int?,
      companyId: fields[4] as String?,
      itemIds: (fields[5] as List?)?.cast<String>(),
      items: (fields[6] as List?)?.cast<ItemListModel>(),
      pageNumber: fields[7] as int?,
      pageSize: fields[8] as int?,
      totalItems: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ItemGroupModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groupName)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.itemCount)
      ..writeByte(4)
      ..write(obj.companyId)
      ..writeByte(5)
      ..write(obj.itemIds)
      ..writeByte(6)
      ..write(obj.items)
      ..writeByte(7)
      ..write(obj.pageNumber)
      ..writeByte(8)
      ..write(obj.pageSize)
      ..writeByte(9)
      ..write(obj.totalItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemGroupModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
