class AppointmentsFormModel {
  final int apptId;
  final List<int> formIds;

  AppointmentsFormModel({
    required this.apptId,
    required this.formIds,
  });

  factory AppointmentsFormModel.fromJson(Map<String, dynamic> json) {
    return AppointmentsFormModel(
      apptId: json['ApptID'] as int,
      formIds: (json['FormIds'] as List<dynamic>?)?.cast<int>() ?? [],
    );
  }
}
