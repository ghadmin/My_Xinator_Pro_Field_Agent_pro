class TimeSlotModel {
  final int id;
  final String companyId;
  final String name;
  final String startTime;
  final String endTime;
  final String label;

  TimeSlotModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.label,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['Id'] as int? ?? 0,
      companyId: json['CompanyID']?.toString() ?? '',
      name: json['Name'] as String? ?? '',
      startTime: json['StartTime'] as String? ?? '',
      endTime: json['EndTime'] as String? ?? '',
      label: json['Label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CompanyID': companyId,
      'Name': name,
      'StartTime': startTime,
      'EndTime': endTime,
      'Label': label,
    };
  }

  // Convenience method to get the time range for display
  String get timeRange => '$startTime - $endTime';

  // Check if this is a valid time slot
  bool get isValid => id > 0 && name.isNotEmpty;
}
