class FormModel {
  int? id;
  String? companyID;
  String? templateName;
  String? description;
  String? category;
  bool? isAutoAssignEnabled;
  String? autoAssignServiceTypes;
  String? formStructure;
  bool? requireSignature;
  bool? requireTip;
  bool? isActive;
  String? createdBy;
  String? createdDateTime;
  String? updatedBy;
  String? updatedDateTime;

  FormModel({
    this.id,
    this.companyID,
    this.templateName,
    this.description,
    this.category,
    this.isAutoAssignEnabled,
    this.autoAssignServiceTypes,
    this.formStructure,
    this.requireSignature,
    this.requireTip,
    this.isActive,
    this.createdBy,
    this.createdDateTime,
    this.updatedBy,
    this.updatedDateTime,
  });

  FormModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    companyID = json['CompanyID'];
    templateName = json['TemplateName'];
    description = json['Description'];
    category = json['Category'];
    isAutoAssignEnabled = json['IsAutoAssignEnabled'];
    autoAssignServiceTypes = json['AutoAssignServiceTypes'];
    formStructure = json['FormStructure'];
    requireSignature = json['RequireSignature'];
    requireTip = json['RequireTip'];
    isActive = json['IsActive'];
    createdBy = json['CreatedBy'];
    createdDateTime = json['CreatedDateTime'];
    updatedBy = json['UpdatedBy'];
    updatedDateTime = json['UpdatedDateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['CompanyID'] = companyID;
    data['TemplateName'] = templateName;
    data['Description'] = description;
    data['Category'] = category;
    data['IsAutoAssignEnabled'] = isAutoAssignEnabled;
    data['AutoAssignServiceTypes'] = autoAssignServiceTypes;
    data['FormStructure'] = formStructure;
    data['RequireSignature'] = requireSignature;
    data['RequireTip'] = requireTip;
    data['IsActive'] = isActive;
    data['CreatedBy'] = createdBy;
    data['CreatedDateTime'] = createdDateTime;
    data['UpdatedBy'] = updatedBy;
    data['UpdatedDateTime'] = updatedDateTime;
    return data;
  }
}
