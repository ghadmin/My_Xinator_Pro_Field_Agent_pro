import 'package:hive/hive.dart';

part 'appointment_status_setting.g.dart';

@HiveType(typeId: 11)
class AppointmentStatusSetting extends HiveObject {
  AppointmentStatusSetting({
    this.statusId,
    this.statusName,
    this.companyId,
  });

  @HiveField(0)
  int? statusId;

  @HiveField(1)
  String? statusName;

  @HiveField(2)
  dynamic companyId;

  AppointmentStatusSetting.fromJson(dynamic json) {
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
