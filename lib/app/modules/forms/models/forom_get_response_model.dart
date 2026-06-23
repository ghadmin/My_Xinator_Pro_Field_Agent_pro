class FormGetResponseModel {
  bool? success;
  int? formResponseId;
  int? templateId;
  String? appointmentId;
  int? customerId;
  String? templateName;
  String? instanceStatus;
  String? submittedDateTime;
  List<Responses>? responses;
  dynamic responsesRaw;

  FormGetResponseModel({
    this.success,
    this.formResponseId,
    this.templateId,
    this.appointmentId,
    this.customerId,
    this.templateName,
    this.instanceStatus,
    this.submittedDateTime,
    this.responses,
    this.responsesRaw,
  });

  FormGetResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    formResponseId = json['formResponseId'];
    templateId = json['templateId'];
    appointmentId = json['appointmentId'];
    customerId = json['customerId'];
    templateName = json['templateName'];
    instanceStatus = json['instanceStatus'];
    submittedDateTime = json['submittedDateTime'];
    if (json['responses'] != null) {
      responses = <Responses>[];
      json['responses'].forEach((v) {
        responses!.add(new Responses.fromJson(v));
      });
    }
    responsesRaw = json['responsesRaw'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['formResponseId'] = formResponseId;
    data['templateId'] = templateId;
    data['appointmentId'] = appointmentId;
    data['customerId'] = customerId;
    data['templateName'] = templateName;
    data['instanceStatus'] = instanceStatus;
    data['submittedDateTime'] = submittedDateTime;
    if (responses != null) {
      data['responses'] = responses!.map((v) => v.toJson()).toList();
    }
    data['responsesRaw'] = responsesRaw;
    return data;
  }
}

class Responses {
  String? fieldId;
  String? label;
  String? type;
  String? value;
  Position? position;

  Responses({this.fieldId, this.label, this.type, this.value, this.position});

  Responses.fromJson(Map<String, dynamic> json) {
    fieldId = json['fieldId'];
    label = json['label'];
    type = json['type'];
    value = json['value'];
    position = json['position'] != null
        ? new Position.fromJson(json['position'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fieldId'] = fieldId;
    data['label'] = label;
    data['type'] = type;
    data['value'] = value;
    if (position != null) {
      data['position'] = position!.toJson();
    }
    return data;
  }
}

class Position {
  int? page;
  double? xPct;
  double? yPct;
  double? wPct;
  double? hPct;

  Position({this.page, this.xPct, this.yPct, this.wPct, this.hPct});

  Position.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    xPct = json['xPct'];
    yPct = json['yPct'];
    wPct = json['wPct'];
    hPct = json['hPct'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['xPct'] = xPct;
    data['yPct'] = yPct;
    data['wPct'] = wPct;
    data['hPct'] = hPct;
    return data;
  }
}
