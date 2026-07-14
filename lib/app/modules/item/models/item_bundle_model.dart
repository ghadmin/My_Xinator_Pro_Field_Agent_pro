import 'package:hive/hive.dart';
import 'item_list_model.dart';

part 'item_bundle_model.g.dart';

@HiveType(typeId: 12)
class ItemBundleModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? bundleName;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int? itemCount;

  @HiveField(4)
  String? companyId;

  @HiveField(5)
  List<String>? itemIds;

  @HiveField(6)
  List<ItemListModel>? items;

  @HiveField(7)
  int? pageNumber;

  @HiveField(8)
  int? pageSize;

  @HiveField(9)
  int? totalItems;

  ItemBundleModel({
    this.id,
    this.bundleName,
    this.description,
    this.itemCount,
    this.companyId,
    this.itemIds,
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
  });

  ItemBundleModel.fromJson(dynamic json) {
    id = json['Id'];
    bundleName = json['BundleName'];
    description = json['Description'];
    itemCount = json['ItemCount'];
    companyId = json['CompanyId'];

    if (json['ItemIds'] != null) {
      itemIds = (json['ItemIds'] as List).cast<String>();
    } else {
      itemIds = [];
    }

    if (json['Items'] != null) {
      items = (json['Items'] as List)
          .map((item) => ItemListModel.fromJson(item))
          .toList();
    } else {
      items = [];
    }

    pageNumber = json['PageNumber'];
    pageSize = json['PageSize'];
    totalItems = json['TotalItems'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Id'] = id;
    map['BundleName'] = bundleName;
    map['Description'] = description;
    map['ItemCount'] = itemCount;
    map['CompanyId'] = companyId;
    map['ItemIds'] = itemIds;
    if (items != null) {
      map['Items'] = items?.map((v) => v.toJson()).toList();
    } else {
      map['Items'] = [];
    }
    map['PageNumber'] = pageNumber;
    map['PageSize'] = pageSize;
    map['TotalItems'] = totalItems;
    return map;
  }

  /// Calculate total pages based on totalItems and pageSize
  int get totalPages {
    if (totalItems == null || totalItems == 0) return 0;
    if (pageSize == null || pageSize == 0) return 0;
    return (totalItems! / pageSize!).ceil();
  }

  /// Check if there's a next page
  bool get hasNextPage {
    if (pageNumber == null || totalItems == null || pageSize == null) return false;
    return (pageNumber! * pageSize!) < totalItems!;
  }

  /// Check if there's a previous page
  bool get hasPreviousPage {
    if (pageNumber == null) return false;
    return pageNumber! > 1;
  }
}
