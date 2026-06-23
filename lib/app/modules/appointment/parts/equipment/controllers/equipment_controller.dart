import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/services/fapro_mobile_api_service.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

import '../../../../../service/handler/exception_handler.dart';
import '../models/equipment_model.dart';

class EquipmentController extends GetxController with ExceptionHandler {
  final FaProMobileApiService _service = FaProMobileApiService();

  // ==================== OBSERVABLES ====================

  final RxList<Equipment> equipment = <Equipment>[].obs;
  final RxBool equipmentError = false.obs;
  final RxString equipmentErrorMessage = ''.obs;
  final RxBool isLoadingEquipmentTypes = false.obs;
  final RxList<EquipmentType> equipmentTypes = <EquipmentType>[].obs;

  // Controllers for forms
  final equipmentMakeController = TextEditingController();
  final equipmentModelController = TextEditingController();
  final equipmentNotesController = TextEditingController();
  final equipmentBarcodeController = TextEditingController();
  final equipmentSerialNumberController = TextEditingController();

  // ==================== EQUIPMENT METHODS ====================

  /// Fetch equipment for a customer and site
  Future<void> fetchEquipment({
    required String customerGuid,
    required int siteId,
    String? companyId,
  }) async {
    try {
      showLoading();
      equipmentError.value = false;
      equipmentErrorMessage.value = '';

      final response = await _service.getEquipmentList(
        companyId: companyId ?? '14590',
        customerGuid: customerGuid,
        siteId: siteId,
      );

      if (response != null && _service.isSuccess(response)) {
        final items = response['items'] as List? ?? [];
        equipment.clear();
        equipment.addAll(
          items.map((json) => Equipment.fromJson(json)).toList(),
        );
        kLog('Fetched ${equipment.length} equipment items');
      } else {
        equipmentError.value = true;
        equipmentErrorMessage.value = _service.getErrorMessage(response);
        kLog('Error fetching equipment: ${equipmentErrorMessage.value}');
      }
    } catch (e) {
      equipmentError.value = true;
      equipmentErrorMessage.value = 'Exception: $e';
      kLog('Exception fetching equipment: $e');
    } finally {
      hideLoading();
    }
  }

  /// Fetch equipment types
  Future<void> fetchEquipmentTypes({String? companyId}) async {
    try {
      isLoadingEquipmentTypes.value = true;

      final response = await _service.getEquipmentTypes(
        companyId: companyId ?? '14590',
      );

      if (response != null && _service.isSuccess(response)) {
        final items = response['items'] as List? ?? [];
        equipmentTypes.clear();
        equipmentTypes.addAll(
          items.map((json) => EquipmentType.fromJson(json)).toList(),
        );
        kLog('Fetched ${equipmentTypes.length} equipment types');
      } else {
        kLog(
          'Error fetching equipment types: ${_service.getErrorMessage(response)}',
        );
      }
    } catch (e) {
      kLog('Exception fetching equipment types: $e');
    } finally {
      isLoadingEquipmentTypes.value = false;
    }
  }

  /// Create new equipment
  Future<bool> createEquipment({
    required String customerId,
    required String customerGuid,
    required int siteId,
    String? make,
    String? model,
    String? notes,
    int? equipmentTypeId,
    String? barcode,
    String? serialNumber,
    String? warrantyStart,
    String? warrantyEnd,
    String? laborWarrantyStart,
    String? laborWarrantyEnd,
    String? installDate,
    String? companyId,
  }) async {
    try {
      showLoading();

      final response = await _service.createEquipment(
        companyId: companyId ?? '14590',
        customerId: customerId,
        customerGuid: customerGuid,
        siteId: siteId,
        make: make,
        model: model,
        notes: notes,
        equipmentTypeId: equipmentTypeId,
        barcode: barcode,
        serialNumber: serialNumber,
        warrantyStart: warrantyStart,
        warrantyEnd: warrantyEnd,
        laborWarrantyStart: laborWarrantyStart,
        laborWarrantyEnd: laborWarrantyEnd,
        installDate: installDate,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'Equipment created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchEquipment(
          customerGuid: customerGuid,
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

  /// Update equipment
  Future<bool> updateEquipment({
    required int id,
    required String customerId,
    required String customerGuid,
    required int siteId,
    String? make,
    String? model,
    String? notes,
    int? equipmentTypeId,
    String? barcode,
    String? serialNumber,
    String? warrantyStart,
    String? warrantyEnd,
    String? laborWarrantyStart,
    String? laborWarrantyEnd,
    String? installDate,
    String? companyId,
  }) async {
    try {showLoading();

      final response = await _service.updateEquipment(
        companyId: companyId ?? '14590',
        id: id,
        siteId: siteId,
        customerId: customerId,
        customerGuid: customerGuid,
        make: make,
        model: model,
        notes: notes,
        equipmentTypeId: equipmentTypeId,
        barcode: barcode,
        serialNumber: serialNumber,
        warrantyStart: warrantyStart,
        warrantyEnd: warrantyEnd,
        laborWarrantyStart: laborWarrantyStart,
        laborWarrantyEnd: laborWarrantyEnd,
        installDate: installDate,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'Equipment updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchEquipment(
          customerGuid: customerGuid,
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

  /// Delete equipment
  Future<bool> deleteEquipment({
    required int id,
    required String customerGuid,
    required int siteId,
    String? companyId,
  }) async {
    try {
      showLoading();

      final response = await _service.deleteEquipment(
        companyId: companyId ?? '14590',
        id: id,
      );

      if (response != null && _service.isSuccess(response)) {
        Get.snackbar(
          'Success',
          'Equipment deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchEquipment(
          customerGuid: customerGuid,
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

  // ==================== UTILITY METHODS ====================

  /// Clear all form controllers
  void clearForms() {
    equipmentMakeController.clear();
    equipmentModelController.clear();
    equipmentNotesController.clear();
    equipmentBarcodeController.clear();
    equipmentSerialNumberController.clear();
  }

  /// Clear all data
  void clearAllData() {
    equipment.clear();
    equipmentTypes.clear();
    clearForms();
  }

  @override
  void onClose() {
    equipmentMakeController.dispose();
    equipmentModelController.dispose();
    equipmentNotesController.dispose();
    equipmentBarcodeController.dispose();
    equipmentSerialNumberController.dispose();
    super.onClose();
  }
}
