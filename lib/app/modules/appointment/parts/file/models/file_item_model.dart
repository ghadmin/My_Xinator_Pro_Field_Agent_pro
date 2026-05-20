class FileItem {
  final int id;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String fileUrl;
  final String uploadDate;
  final String uploadedBy;
  final int? appointmentId;
  final String? reference;
  final String taggedFrom;
  final String? taggedTo;
  final int siteId;

  FileItem({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.fileUrl,
    required this.uploadDate,
    required this.uploadedBy,
    this.appointmentId,
    this.reference,
    this.taggedFrom = 'FSM',
    this.taggedTo,
    required this.siteId,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      id: json['id'] as int,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
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
      'fileType': fileType,
      'fileSize': fileSize,
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

  /// Get file size in human-readable format (e.g., "1.5 MB")
  String get fileSizeFormatted {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (fileSize >= gb) {
      return '${(fileSize / gb).toStringAsFixed(2)} GB';
    } else if (fileSize >= mb) {
      return '${(fileSize / mb).toStringAsFixed(2)} MB';
    } else if (fileSize >= kb) {
      return '${(fileSize / kb).toStringAsFixed(2)} KB';
    } else {
      return '$fileSize bytes';
    }
  }

  /// Get file extension
  String get extension {
    return fileName.split('.').last.toLowerCase();
  }
}
