import 'package:hive/hive.dart';

part 'item_list_model.g.dart';

@HiveType(typeId: 10)
class ItemListModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? barcode;

  @HiveField(4)
  int? itemTypeId;

  @HiveField(5)
  double? price;

  @HiveField(6)
  String? location;

  @HiveField(7)
  bool? isTaxable;

  @HiveField(8)
  String? companyId;

  @HiveField(9)
  bool? isDeleted;

  @HiveField(10)
  int? qboId;

  ItemListModel({
    this.id,
    this.name,
    this.description,
    this.barcode,
    this.itemTypeId,
    this.price,
    this.location,
    this.isTaxable,
    this.companyId,
    this.isDeleted,
    this.qboId,
  });

  ItemListModel.fromJson(dynamic json) {
    id = json['Id'];
    name = json['Name'];
    description = json['Description'];
    barcode = json['Barcode'];
    itemTypeId = json['ItemTypeId'];
    price = json['Price'];
    location = json['Location'];
    isTaxable = json['IsTaxable'];
    companyId = json['CompanyId'];
    isDeleted = json['IsDeleted'];
    qboId = json['QboId'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Id'] = id;
    map['Name'] = name;
    map['Description'] = description;
    map['Barcode'] = barcode;
    map['ItemTypeId'] = itemTypeId;
    map['Price'] = price;
    map['Location'] = location;
    map['IsTaxable'] = isTaxable;
    map['CompanyId'] = companyId;
    map['IsDeleted'] = isDeleted;
    map['QboId'] = qboId;
    return map;
  }
}
