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

  FormModel(
      {this.id,
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
      this.updatedDateTime});

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
    updatedBy = json['UpdatedBy'] ?? null;
    updatedDateTime = json['UpdatedDateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CompanyID'] = this.companyID;
    data['TemplateName'] = this.templateName;
    data['Description'] = this.description;
    data['Category'] = this.category;
    data['IsAutoAssignEnabled'] = this.isAutoAssignEnabled;
    data['AutoAssignServiceTypes'] = this.autoAssignServiceTypes;
    data['FormStructure'] = this.formStructure;
    data['RequireSignature'] = this.requireSignature;
    data['RequireTip'] = this.requireTip;
    data['IsActive'] = this.isActive;
    data['CreatedBy'] = this.createdBy;
    data['CreatedDateTime'] = this.createdDateTime;
    data['UpdatedBy'] = this.updatedBy;
    data['UpdatedDateTime'] = this.updatedDateTime;
    return data;
  }
}
