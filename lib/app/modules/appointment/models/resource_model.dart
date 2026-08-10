class ResourceModel {
  final int id;
  final String companyId;
  final String name;
  final String description;
  final String mobile;
  final String email;
  final int workingHour;
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;

  ResourceModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    required this.mobile,
    required this.email,
    required this.workingHour,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['Id'] as int? ?? 0,
      companyId: json['CompanyID']?.toString() ?? '',
      name: json['Name'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      mobile: json['Mobile'] as String? ?? '',
      email: json['Email'] as String? ?? '',
      workingHour: json['WorkingHour'] as int? ?? 0,
      monday: json['Monday'] as bool? ?? false,
      tuesday: json['Tuesday'] as bool? ?? false,
      wednesday: json['Wednesday'] as bool? ?? false,
      thursday: json['Thursday'] as bool? ?? false,
      friday: json['Friday'] as bool? ?? false,
      saturday: json['Saturday'] as bool? ?? false,
      sunday: json['Sunday'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CompanyID': companyId,
      'Name': name,
      'Description': description,
      'Mobile': mobile,
      'Email': email,
      'WorkingHour': workingHour,
      'Monday': monday,
      'Tuesday': tuesday,
      'Wednesday': wednesday,
      'Thursday': thursday,
      'Friday': friday,
      'Saturday': saturday,
      'Sunday': sunday,
    };
  }

  // Get full name with description for display
  String get displayName {
    if (description.isNotEmpty) {
      return '$name - $description';
    }
    return name;
  }

  // Check if this resource is valid
  bool get isValid => id > 0 && name.isNotEmpty;

  // Get working days as a list
  List<String> get workingDays {
    final days = <String>[];
    if (monday) days.add('Mon');
    if (tuesday) days.add('Tue');
    if (wednesday) days.add('Wed');
    if (thursday) days.add('Thu');
    if (friday) days.add('Fri');
    if (saturday) days.add('Sat');
    if (sunday) days.add('Sun');
    return days;
  }
}
