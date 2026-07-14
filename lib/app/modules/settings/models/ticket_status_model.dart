import 'package:hive/hive.dart';

part 'ticket_status_model.g.dart';

@HiveType(typeId: 15)
class TicketStatusSettings extends HiveObject {
  @HiveField(0)
  int? statusId;
  @HiveField(1)
  String? statusName;
  @HiveField(2)
  dynamic companyId;

  TicketStatusSettings({
    this.statusId,
    this.statusName,
    this.companyId,
  });

  TicketStatusSettings.fromJson(dynamic json) {
    statusId = json['StatusId'];
    statusName = json['StatusName'];
    companyId = json['CompanyId'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['StatusId'] = statusId;
    map['StatusName'] = statusName;
    map['CompanyId'] = companyId;
    return map;
  }
}
