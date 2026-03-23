import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

/// Model for a single file entry
class FileModel {
  int? id;
  String? companyId;
  String? customerId;
  int? siteId;
  String? fileName;
  String? fileType;
  int? fileSize;
  String? fileContent;
  String? fileURL; // Network URL for files from API (FileURL)
  String? uploadDate;
  String? uploadedBy;
  int? appointmentId;
  String? reference;

  Uint8List? bytes; // Cached decoded bytes
  File? localFile; // For storing local file path before upload

  FileModel({
    this.fileName,
    this.fileType,
    this.fileSize,
    this.fileContent,
    this.fileURL,
    this.localFile,
  }) {
    // Only decode base64 if we have fileContent (for locally uploaded files)
    if (fileContent != null && fileContent!.isNotEmpty) {
      try {
        bytes = base64Decode(fileContent!);
      } catch (e) {
        bytes = null;
      }
    }
  }

  FileModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'] ?? json['id'];
    companyId = json['companyId']?.toString() ?? json['CompanyID']?.toString();
    customerId = json['customerId']?.toString() ?? json['CustomerID']?.toString();
    siteId = json['siteId'] ?? json['SiteId'];
    fileName = json['fileName'] ?? json['FileName'];
    fileType = json['fileType'] ?? json['FileType'];
    fileSize = json['fileSize'] ?? json['FileSize'];
    fileContent = json['fileContent'] ?? json['FileContent'];
    fileURL = json['fileURL'] ?? json['FileURL'];
    uploadDate = json['uploadDate'] ?? json['UploadDate'];
    uploadedBy = json['uploadedBy'] ?? json['UploadedBy'];
    appointmentId = json['appointmentId'] ?? json['AppointmentId'];
    reference = json['reference'] ?? json['Reference'];

    // Only decode base64 if we have fileContent (for locally uploaded files)
    if (fileContent != null && fileContent!.isNotEmpty) {
      try {
        bytes = base64Decode(fileContent!);
      } catch (e) {
        bytes = null;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Id'] = id;
    data['companyId'] = companyId;
    data['customerId'] = customerId;
    data['siteId'] = siteId;
    data['fileName'] = fileName;
    data['fileType'] = fileType;
    data['fileSize'] = fileSize;
    data['fileContent'] = fileContent;
    data['fileURL'] = fileURL;
    data['uploadDate'] = uploadDate;
    data['uploadedBy'] = uploadedBy;
    data['appointmentId'] = appointmentId;
    data['reference'] = reference;
    return data;
  }

  /// Get file extension from filename
  String? get fileExtension {
    if (fileName == null || fileName!.isEmpty) return null;
    final parts = fileName!.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : null;
  }

  /// Check if file is PDF
  bool get isPdf => fileExtension == 'pdf';

  /// Check if file is an image
  bool get isImage {
    final ext = fileExtension;
    return ext != null && ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Model for file list response wrapper
class FileListModel {
  List<FileModel>? fileList;

  FileListModel({this.fileList});

 FileListModel.fromJson(Map<String, dynamic> json) {
    if (json['FileList'] != null || json['fileList'] != null) {
      final list = json['FileList'] ?? json['fileList'];
      fileList = <FileModel>[];
      if (list is List) {
        for (var v in list) {
          fileList!.add(FileModel.fromJson(v as Map<String, dynamic>));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fileList != null) {
      data['FileList'] = fileList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
