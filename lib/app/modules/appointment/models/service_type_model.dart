class ServiceTypeModel {
  final String companyId;
  final int serviceTypeId;
  final String serviceName;
  final int hour;
  final int minute;
  final String calendarColor;
  final bool isInternalUse;
  final String? resource;
  final String? createdDateTime;
  final int? reminderId;

  ServiceTypeModel({
    required this.companyId,
    required this.serviceTypeId,
    required this.serviceName,
    required this.hour,
    required this.minute,
    required this.calendarColor,
    required this.isInternalUse,
    this.resource,
    this.createdDateTime,
    this.reminderId,
  });

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      companyId: json['CompanyID']?.toString() ?? '',
      serviceTypeId: json['ServiceTypeID'] as int? ?? 0,
      serviceName: json['ServiceName'] as String? ?? '',
      hour: json['Hour'] as int? ?? 0,
      minute: json['Minute'] as int? ?? 0,
      calendarColor: json['CalenderColor'] as String? ?? '#3B7DD8',
      isInternalUse: json['IsInternalUse'] as bool? ?? false,
      resource: json['Resource'] as String?,
      createdDateTime: json['CreatedDateTime'] as String?,
      reminderId: json['ReminderID'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CompanyID': companyId,
      'ServiceTypeID': serviceTypeId,
      'ServiceName': serviceName,
      'Hour': hour,
      'Minute': minute,
      'CalenderColor': calendarColor,
      'IsInternalUse': isInternalUse,
      'Resource': resource,
      'CreatedDateTime': createdDateTime,
      'ReminderID': reminderId,
    };
  }

  // Get formatted time duration (e.g., "1 Hr 30 Min", "2 Hr 0 Min", "0 Hr 45 Min")
  String get timeDuration {
    if (hour > 0 && minute > 0) {
      return '$hour Hr $minute Min';
    } else if (hour > 0) {
      return '$hour Hr 0 Min';
    } else if (minute > 0) {
      return '0 Hr $minute Min';
    }
    return '0 Hr 0 Min';
  }

  // Get total minutes
  int get totalMinutes => (hour * 60) + minute;

  // Check if this is a valid service type
  bool get isValid => serviceTypeId > 0 && serviceName.isNotEmpty;
}
