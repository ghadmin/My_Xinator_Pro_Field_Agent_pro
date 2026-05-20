import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../services/fapro_mobile_api_service.dart';
import '../models/note_model.dart';
import '../../../../../../utils/klog.dart';
import '../../../../../service/handler/exception_handler.dart';

class NotesController extends GetxController with ExceptionHandler {
  final FaProMobileApiService _service = FaProMobileApiService();

  // ==================== OBSERVABLES ====================

  final RxBool isLoadingNotes = false.obs;
  final RxList<Note> notes = <Note>[].obs;
  final RxBool notesError = false.obs;
  final RxString notesErrorMessage = ''.obs;

  // Controllers for forms
  final noteDescriptionController = TextEditingController();
  final noteReferenceController = TextEditingController();

  // ==================== NOTES METHODS ====================

  /// Fetch notes for a customer and site
  Future<void> fetchNotes({
    required String customerId,
    required int siteId,
    String? companyId,
  }) async {
    try {
      showLoading();
      notesError.value = false;
      notesErrorMessage.value = '';

      final response = await _service.getNotesList(
        companyId: companyId ?? '14590',
        customerId: customerId,
        siteId: siteId,
      );

      if (response != null && _service.isSuccess(response)) {
        final items = response['items'] as List? ?? [];
        notes.clear();
        notes.addAll(items.map((json) => Note.fromJson(json)).toList());
        kLog('Fetched ${notes.length} notes');
      } else {
        notesError.value = true;
        notesErrorMessage.value = _service.getErrorMessage(response);
        kLog('Error fetching notes: ${notesErrorMessage.value}');
      }
    } catch (e) {
      notesError.value = true;
      notesErrorMessage.value = 'Exception: $e';
      kLog('Exception fetching notes: $e');
    } finally {
      hideLoading();
    }
  }

  /// Create a new note
  Future<bool> createNote({
    required String customerId,
    required int siteId,
    required String description,
    String? reference,
    String? companyId,
  }) async {
    try {
      isLoadingNotes.value = true;

      final response = await _service.createNote(
        companyId: companyId ?? '14590',
        customerId: customerId,
        siteId: siteId,
        description: description,
        reference: reference,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'Note created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchNotes(
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
      isLoadingNotes.value = false;
    }
  }

  /// Create multiple notes in a single batch request
  Future<bool> createNotesBatch({
    required String companyId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      isLoadingNotes.value = true;

      final response = await _service.createNotesBatch(
        companyId: companyId,
        items: items,
      );

      if (response != null && _service.isSuccess(response)) {
        final count = response['count'] ?? 0;
        final responseItems = response['items'] as List? ?? [];
        int successCount = 0;
        for (var item in responseItems) {
          if (item['success'] == true) successCount++;
        }

        Get.snackbar(
          'Success',
          '$successCount of $count notes created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        if (items.isNotEmpty) {
          final firstItem = items[0];
          await fetchNotes(
            customerId: firstItem['customerId'] as String,
            siteId: firstItem['siteId'] as int,
            companyId: companyId,
          );
        }
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
      isLoadingNotes.value = false;
    }
  }

  /// Update an existing note
  Future<bool> updateNote({
    required int noteId,
    required String customerId,
    required int siteId,
    required String description,
    String? reference,
    String? companyId,
  }) async {
    try {
      isLoadingNotes.value = true;

      final response = await _service.updateNote(
        companyId: companyId ?? '14590',
        noteId: noteId,
        description: description,
        reference: reference,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'Note updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchNotes(
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
      isLoadingNotes.value = false;
    }
  }

  /// Delete a note
  Future<bool> deleteNote({
    required int noteId,
    required String customerId,
    required int siteId,
    String? companyId,
  }) async {
    try {
      isLoadingNotes.value = true;

      final response = await _service.deleteNote(
        companyId: companyId ?? '14590',
        noteId: noteId,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'Note deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchNotes(
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
      isLoadingNotes.value = false;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all data
  void clearAllData() {
    notes.clear();
    notesError.value = false;
    notesErrorMessage.value = '';
  }

  @override
  void onClose() {
    noteDescriptionController.dispose();
    noteReferenceController.dispose();
    clearAllData();
    super.onClose();
  }
}
