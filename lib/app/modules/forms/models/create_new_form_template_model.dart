class CreateNewFormModel {
  String? templateName;
  String? category;
  String? description;
  bool signature;
  bool tpCapture;
  bool autoAssignAppointment;
  bool isActive;

  CreateNewFormModel({
    this.templateName,
    this.category,
    this.description,
    this.signature = false,
    this.tpCapture = false,
    this.autoAssignAppointment = false,
    this.isActive = true,
  });

  CreateNewFormModel copyWith({
    String? templateName,
    String? category,
    String? description,
    bool? signature,
    bool? tpCapture,
    bool? autoAssignAppointment,
    bool? isActive,
  }) {
    return CreateNewFormModel(
      templateName: templateName ?? this.templateName,
      category: category ?? this.category,
      description: description ?? this.description,
      signature: signature ?? this.signature,
      tpCapture: tpCapture ?? this.tpCapture,
      autoAssignAppointment:
          autoAssignAppointment ?? this.autoAssignAppointment,
      isActive: isActive ?? this.isActive,
    );
  }
}
