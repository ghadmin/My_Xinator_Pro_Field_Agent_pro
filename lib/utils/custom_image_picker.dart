import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../config/theme/light_theme_colors.dart';

class CustomImagePicker {
  Rx<File?> pickedImage = Rx<File?>(null);

  /// Pick Image From Gallery
  Future getImageFromGallery({required bool canCrop}) async {
    var galleryImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (galleryImage != null) {
      if (canCrop) {
        pickedImage.value = await cropImage(File(galleryImage.path));
      } else {
        pickedImage.value = File(galleryImage.path);
      }
    } else {
      return;
    }
  }

  /// Pick Image From  Camera
  Future getImageFromCamera({required bool canCrop}) async {
    var cameraImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (cameraImage != null) {
      if (canCrop) {
        pickedImage.value = await cropImage(File(cameraImage.path));
      } else {
        pickedImage.value = File(cameraImage.path);
      }
    } else {
      return;
    }
  }

  /// Crop Image
  cropImage(File croppedImage) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: croppedImage.path,
      compressQuality: 50,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: LightThemeColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
      ],
    );
    if (croppedFile != null) {
      imageCache.clear();
      return File(croppedFile.path);
    }
    return null;
  }

  /// Get the size of the file in MB
  double getFileSizeInMB(File file) {
    int bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }
}

/// How to use?

// 1. initiate the Class in your getx controller.
// final customImagePicker = CustomImagePicker();

/// How to check file size

// double fileSizeInMB = controller.customImagePicker
//     .getFileSizeInMB(controller
//     .customImagePicker.pickedImage.value!);

//print("Image file size: ${fileSizeInMB.toStringAsFixed(2)} MB");
