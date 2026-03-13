import 'dart:convert';
import 'dart:typed_data';

class ImageListModel {
  int? customerId;
  int? appointmentId;
  int? cSLId;
  String? companyId;
  String? tagName;
  List<ImageList>? imageList;

  ImageListModel({
    this.customerId,
    this.appointmentId,
    this.cSLId,
    this.companyId,
    this.tagName,
    this.imageList,
  });

  ImageListModel.fromJson(Map<String, dynamic> json) {
    customerId = json['CustomerId'];
    appointmentId = json['AppointmentId'];
    cSLId = json['CSLId'];
    companyId = json['CompanyId'];
    tagName = json['TagName'];
    if (json['ImageList'] != null) {
      imageList = <ImageList>[];
      json['ImageList'].forEach((v) {
        imageList!.add(ImageList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['CustomerId'] = customerId;
    data['AppointmentId'] = appointmentId;
    data['CSLId'] = cSLId;
    data['CompanyId'] = companyId;
    data['TagName'] = tagName;
    if (imageList != null) {
      data['ImageList'] = imageList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImageList {
  // ============================================
  // OLD FIELD STRUCTURE (Kept for reference)
  // ============================================
  // String? imageName;
  // String? imageBase64;
  // Uint8List? bytes;
  // String? createdAt;
  // String? description;
  // ============================================

  // New field structure matching API response
  int? id;
  String? companyId;
  String? customerId;
  int? siteId;
  String? fileName;
  String? fileContent;
  String? uploadDate;
  String? uploadedBy;
  int? appointmentId;
  String? reference;

  Uint8List? bytes; // Cached decoded bytes

  ImageList({this.fileName, this.fileContent}) {
    if (fileContent != null) {
      bytes = base64Decode(fileContent!); // decode once here
    }
  }

  // ============================================
  // OLD FROM JSON (Kept for reference)
  // ============================================
  // ImageList.fromJson(Map<String, dynamic> json) {
  //   imageName = json['ImageName'];
  //   imageBase64 = json['ImageBase64'];
  //   createdAt = json['CreatedAt'];
  //   description = json['Description'];
  //   if (imageBase64 != null) {
  //     bytes = base64Decode(imageBase64!); // decode once when parsing
  //   }
  // }
  // ============================================

  ImageList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    companyId = json['companyId']?.toString() ?? json['CompanyID']?.toString();
    customerId = json['customerId']?.toString() ?? json['CustomerID']?.toString();
    siteId = json['siteId'] ?? json['SiteId'];
    fileName = json['fileName'] ?? json['FileName'];
    fileContent = json['fileContent'] ?? json['FileContent'];
    uploadDate = json['uploadDate'] ?? json['UploadDate'];
    uploadedBy = json['uploadedBy'] ?? json['UploadedBy'];
    appointmentId = json['appointmentId'] ?? json['AppointmentId'];
    reference = json['reference'] ?? json['Reference'];
    if (fileContent != null) {
      bytes = base64Decode(fileContent!); // decode once when parsing
    }
  }

  // ============================================
  // OLD TO JSON (Kept for reference)
  // ============================================
  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = {};
  //   data['ImageName'] = imageName;
  //   data['ImageBase64'] = imageBase64;
  //   data['CreatedAt'] = createdAt;
  //   data['Description'] = description;
  //   return data;
  // }
  // ============================================

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Id'] = id;
    data['companyId'] = companyId;
    data['customerId'] = customerId;
    data['siteId'] = siteId;
    data['fileName'] = fileName;
    data['fileContent'] = fileContent;
    data['uploadDate'] = uploadDate;
    data['uploadedBy'] = uploadedBy;
    data['appointmentId'] = appointmentId;
    data['reference'] = reference;
    return data;
  }
}
