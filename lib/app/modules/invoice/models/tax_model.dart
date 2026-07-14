import 'package:hive/hive.dart';

part 'tax_model.g.dart';

@HiveType(typeId: 14)
class TaxModel extends HiveObject {
  TaxModel({
    this.id,
    this.name,
    this.rate,
  });

  @HiveField(0)
  int? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  int? rate;

  TaxModel.fromJson(dynamic json) {
    id = json['Id'];
    name = json['Name'];
    rate = json['Rate'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Id'] = id;
    map['Name'] = name;
    map['Rate'] = rate;
    return map;
  }
}
