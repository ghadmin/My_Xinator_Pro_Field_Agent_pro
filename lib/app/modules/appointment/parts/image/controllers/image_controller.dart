import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/image/models/picture_model.dart';
import 'package:intl/intl.dart';
import 'package:myxinator_pro_field_agent_pro/app/service/handler/exception_handler.dart';
import 'dart:io';
import '../../../../../services/fapro_mobile_api_service.dart';
import '../../../../../../utils/klog.dart';

// ==================== CONTROLLER ====================

class ImageController extends GetxController with ExceptionHandler {
  final FaProMobileApiService _service = FaProMobileApiService();

  // ==================== OBSERVABLES ====================

  final RxList<Picture> pictures = <Picture>[].obs;
  final RxBool picturesError = false.obs;
  final RxString picturesErrorMessage = ''.obs;
  final RxBool isUploadingPicture = false.obs;
  final RxDouble pictureUploadProgress = 0.0.obs;

  // ==================== PICTURES METHODS ====================

  /// Fetch pictures for a customer and site
  Future<void> fetchPictures({
    required String customerId,
    required int siteId,
    String? companyId,
  }) async {
    try {
      showLoading();
      picturesError.value = false;
      picturesErrorMessage.value = '';

      final response = await _service.getPicturesList(
        companyId: companyId ?? '14590',
        customerId: customerId,
        siteId: siteId,
      );

      if (response != null && _service.isSuccess(response)) {
        final items = response['items'] as List? ?? [];
        pictures.clear();
        pictures.addAll(items.map((json) => Picture.fromJson(json)).toList());
        kLog('Fetched ${pictures.length} pictures');
      } else {
        picturesError.value = true;
        picturesErrorMessage.value = _service.getErrorMessage(response);
        kLog('Error fetching pictures: ${picturesErrorMessage.value}');
      }
    } catch (e) {
      picturesError.value = true;
      picturesErrorMessage.value = 'Exception: $e';
      kLog('Exception fetching pictures: $e');
    } finally {
      hideLoading();
    }
  }

  /// Upload a picture
  Future<bool> uploadPicture({
    required String customerId,
    required int siteId,
    required File file,
    String? appointmentId,
    String? reference,
    String? companyId,
  }) async {
    try {
      isUploadingPicture.value = true;
      pictureUploadProgress.value = 0.0;

      final response = await _service.uploadPicture(
        companyId: companyId ?? '14590',
        customerId: customerId,
        siteId: siteId,
        file: file,
        appointmentId: appointmentId,
        reference: reference,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'Picture uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchPictures(
          customerId: customerId,
          siteId: siteId,
          companyId: companyId,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          _service.getErrorMessage(response),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isUploadingPicture.value = false;
      pictureUploadProgress.value = 0.0;
    }
  }

  /// Upload multiple pictures in a single batch request
  Future<bool> uploadPicturesBatch({
    required String customerId,
    required int siteId,
    required List<File> files,
    String? appointmentId,
    String? reference,
    String? companyId,
  }) async {
    try {
      isUploadingPicture.value = true;
      pictureUploadProgress.value = 0.0;

      final response = await _service.uploadPicturesBatch(
        companyId: companyId ?? '14590',
        customerId: customerId,
        siteId: siteId,
        files: files,
        appointmentId: appointmentId,
        reference: reference,
      );

      if (response != null && _service.isSuccess(response)) {
        final count = response['count'] ?? 0;
        final items = response['items'] as List? ?? [];
        int successCount = 0;
        for (var item in items) {
          if (item['success'] == true) successCount++;
        }

        Get.snackbar(
          'Success',
          '$successCount of $count pictures uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchPictures(
          customerId: customerId,
          siteId: siteId,
          companyId: companyId,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          _service.getErrorMessage(response),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isUploadingPicture.value = false;
      pictureUploadProgress.value = 0.0;
    }
  }

  /// Update picture metadata
  Future<bool> updatePicture({
    required int pictureId,
    required String customerId,
    required int siteId,
    required String reference,
    String? companyId,
  }) async {
    try {
      showLoading();

      final response = await _service.updatePicture(
        companyId: companyId ?? '14590',
        pictureId: pictureId,
        reference: reference,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'Picture updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchPictures(
          customerId: customerId,
          siteId: siteId,
          companyId: companyId,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          _service.getErrorMessage(response),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      hideLoading();
    }
  }

  /// Delete a picture
  Future<bool> deletePicture({
    required int pictureId,
    required String customerId,
    required int siteId,
    String? companyId,
  }) async {
    try {
      showLoading();

      final response = await _service.deletePicture(
        companyId: companyId ?? '14590',
        pictureId: pictureId,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'Picture deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchPictures(
          customerId: customerId,
          siteId: siteId,
          companyId: companyId,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          _service.getErrorMessage(response),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      hideLoading();
    }
  }

  // ==================== GETTERS ====================

  /// Group pictures by upload date, time, and reference
  Map<String, List<Picture>> get picturesGroupedByDate {
    final Map<String, List<Picture>> grouped = {};
    for (var picture in pictures) {
      // Parse the upload date and format it with time and reference
      try {
        final dateTime = DateTime.parse(picture.uploadDate);
        final formattedDateTime = DateFormat(
          'MMMM dd, yyyy HH:mm',
        ).format(dateTime);
        final ref = picture.reference ?? 'No reference';
        final groupKey = '$formattedDateTime - $ref';

        if (!grouped.containsKey(groupKey)) {
          grouped[groupKey] = [];
        }
        grouped[groupKey]!.add(picture);
      } catch (e) {
        // If parsing fails, use original date with reference
        final ref = picture.reference ?? 'No reference';
        final groupKey = '${picture.uploadDate} - $ref';
        if (!grouped.containsKey(groupKey)) {
          grouped[groupKey] = [];
        }
        grouped[groupKey]!.add(picture);
      }
    }
    return grouped;
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all data
  void clearAllData() {
    pictures.clear();
  }

  @override
  void onClose() {
    clearAllData();
    super.onClose();
  }
}
