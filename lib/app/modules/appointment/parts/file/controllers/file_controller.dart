import 'package:get/get.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/file/models/file_item_model.dart';
import '../../../../../services/fapro_mobile_api_service.dart';
import '../../../../../../utils/klog.dart';
import '../../../../../service/handler/exception_handler.dart';

// ==================== CONTROLLER ====================

class FileController extends GetxController with ExceptionHandler {
  final FaProMobileApiService _service = FaProMobileApiService();

  // ==================== OBSERVABLES ====================

  final RxBool isLoadingFiles = false.obs;
  final RxList<FileItem> files = <FileItem>[].obs;
  final RxBool filesError = false.obs;
  final RxString filesErrorMessage = ''.obs;
  final RxBool isUploadingFile = false.obs;
  final RxDouble fileUploadProgress = 0.0.obs;

  // ==================== FILES METHODS ====================

  /// Fetch files for a customer and site
  Future<void> fetchFiles({
    required String customerId,
    required int siteId,
    String? companyId,
  }) async {
    try {
      showLoading();
      filesError.value = false;
      filesErrorMessage.value = '';

      final response = await _service.getFilesList(
        companyId: companyId ?? '14590',
        customerId: customerId,
        siteId: siteId,
      );
      kLog(response);
      if (response != null && _service.isSuccess(response)) {
        final items = response['items'] as List? ?? [];
        files.clear();
        files.addAll(items.map((json) => FileItem.fromJson(json)).toList());
        kLog('Fetched ${files.length} files');
      } else {
        filesError.value = true;
        filesErrorMessage.value = _service.getErrorMessage(response);
        kLog('Error fetching files: ${filesErrorMessage.value}');
      }
    } catch (e) {
      filesError.value = true;
      filesErrorMessage.value = 'Exception: $e';
      kLog('Exception fetching files: $e');
    } finally {
      hideLoading();
    }
  }

  /// Upload a file
  Future<bool> uploadFile({
    required String customerId,
    required int siteId,
    required File file,
    String? appointmentId,
    String? reference,
    String? companyId,
  }) async {
    try {
      isUploadingFile.value = true;
      fileUploadProgress.value = 0.0;

      final response = await _service.uploadFile(
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
          'File uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchFiles(
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
      await fetchFiles(customerId: customerId, siteId: siteId);
      isUploadingFile.value = false;
      fileUploadProgress.value = 0.0;
    }
  }

  /// Upload multiple files in a single batch request
  Future<bool> uploadFilesBatch({
    required String customerId,
    required int siteId,
    required List<File> files,
    String? appointmentId,
    String? reference,
    String? companyId,
  }) async {
    try {
      isUploadingFile.value = true;
      fileUploadProgress.value = 0.0;

      final response = await _service.uploadFilesBatch(
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
          '$successCount of $count files uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchFiles(
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
      await fetchFiles(customerId: customerId, siteId: siteId);
      isUploadingFile.value = false;
      fileUploadProgress.value = 0.0;
    }
  }

  /// Update file metadata
  Future<bool> updateFile({
    required int fileId,
    required String customerId,
    required int siteId,
    String? fileName,
    String? reference,
    String? companyId,
  }) async {
    try {
      isLoadingFiles.value = true;

      final response = await _service.updateFile(
        companyId: companyId ?? '14590',
        fileId: fileId,
        fileName: fileName,
        reference: reference,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'File updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchFiles(
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
      isLoadingFiles.value = false;
    }
  }

  /// Delete a file
  Future<bool> deleteFile({
    required int fileId,
    required String customerId,
    required int siteId,
    String? companyId,
  }) async {
    try {
      isLoadingFiles.value = true;

      final response = await _service.deleteFile(
        companyId: companyId ?? '14590',
        fileId: fileId,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'File deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchFiles(
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
      isLoadingFiles.value = false;
    }
  }

  // ==================== GETTERS ====================

  /// Group files by upload date, time, and reference
  Map<String, List<FileItem>> get filesGroupedByDate {
    final Map<String, List<FileItem>> grouped = {};
    for (var file in files) {
      // Parse the upload date and format it with time and reference
      try {
        final dateTime = DateTime.parse(file.uploadDate);
        final formattedDateTime = DateFormat('MMMM dd, yyyy HH:mm').format(dateTime);
        final ref = file.reference ?? 'No reference';
        final groupKey = '$formattedDateTime - $ref';

        if (!grouped.containsKey(groupKey)) {
          grouped[groupKey] = [];
        }
        grouped[groupKey]!.add(file);
      } catch (e) {
        // If parsing fails, use original date with reference
        final ref = file.reference ?? 'No reference';
        final groupKey = '${file.uploadDate} - $ref';
        if (!grouped.containsKey(groupKey)) {
          grouped[groupKey] = [];
        }
        grouped[groupKey]!.add(file);
      }
    }
    return grouped;
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all data
  void clearAllData() {
    files.clear();
  }

  @override
  void onClose() {
    clearAllData();
    super.onClose();
  }
}
