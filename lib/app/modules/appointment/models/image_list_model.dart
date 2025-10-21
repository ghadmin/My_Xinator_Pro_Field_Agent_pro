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
  String? imageName;
  String? imageBase64;
  Uint8List? bytes;

  String? createdAt;
  String? description;

  // 👈 cached decoded bytes

  ImageList({this.imageName, this.imageBase64}) {
    if (imageBase64 != null) {
      bytes = base64Decode(imageBase64!); // decode once here
    }
  }

  ImageList.fromJson(Map<String, dynamic> json) {
    imageName = json['ImageName'];
    imageBase64 = json['ImageBase64'];
    createdAt = json['CreatedAt'];
    description = json['Description'];
    if (imageBase64 != null) {
      bytes = base64Decode(imageBase64!); // decode once when parsing
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['ImageName'] = imageName;
    data['ImageBase64'] = imageBase64;
    data['CreatedAt'] = createdAt;
    data['Description'] = description;
    return data;
  }
}
