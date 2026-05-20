// ==================== MODEL ====================

class Picture {
  final int id;
  final String fileName;
  final String fileUrl;
  final String uploadDate;
  final String uploadedBy;
  final int? appointmentId;
  final String? reference;
  final String taggedFrom;
  final String? taggedTo;
  final int siteId;

  Picture({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.uploadDate,
    required this.uploadedBy,
    this.appointmentId,
    this.reference,
    this.taggedFrom = 'FSM',
    this.taggedTo,
    required this.siteId,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      id: json['id'] as int,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      uploadDate: json['uploadDate'] as String,
      uploadedBy: json['uploadedBy'] as String,
      appointmentId: json['appointmentId'] as int?,
      reference: json['reference'] as String?,
      taggedFrom: json['taggedFrom'] as String? ?? 'FSM',
      taggedTo: json['taggedTo'] as String?,
      siteId: json['siteId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'uploadDate': uploadDate,
      'uploadedBy': uploadedBy,
      if (appointmentId != null) 'appointmentId': appointmentId,
      if (reference != null) 'reference': reference,
      'taggedFrom': taggedFrom,
      if (taggedTo != null) 'taggedTo': taggedTo,
      'siteId': siteId,
    };
  }
}
