import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../models/forms/forms_models.dart';
import '../../../service/forms_api_service.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../../appointment/controllers/appointment_controller.dart';

/// Forms Controller
///
/// Handles all forms-related operations including:
/// - Polling for pending forms
/// - Acknowledging downloaded forms
/// - Submitting completed forms
/// - Managing local form storage
class FormsController extends GetxController with ExceptionHandler {
  final FormsApiService _formsApiService = FormsApiService();

  // ============== OBSERVABLES ==============

  /// List of pending forms from poll
  final pendingForms = <FormQueueItem>[].obs;

  /// List of forms that have been acknowledged
  final acknowledgedForms = <FormQueueItem>[].obs;

  /// List of completed (submitted) forms
  final completedForms = <FormQueueItem>[].obs;

  /// Currently selected form
  final Rx<FormQueueItem?> selectedForm = Rx(null);

  /// Loading state for poll
  final RxBool isPolling = false.obs;

  /// Loading state for submit
  final RxBool isSubmitting = false.obs;

  /// Loading state for ack
  final RxBool isAcknowledging = false.obs;

  /// Whether there are pending forms
  final RxBool hasPendingForms = false.obs;

  /// Error message
  final RxString errorMessage = ''.obs;

  /// Forms for the current appointment (filtered by appointmentId)
  final appointmentForms = <FormQueueItem>[].obs;

  /// Loading state for appointment forms
  final RxBool isLoadingAppointmentForms = false.obs;

  // ============== API METHODS ==============

  /// Poll for pending forms
  ///
  /// Fetches all pending forms for the current technician
  /// Saves to Hive first, then loads from Hive to update UI
  Future<void> pollPendingForms(int resourceId) async {
    isPolling.value = true;
    errorMessage.value = '';
    isError.value = false;

    try {
      // Check network connectivity
      showLoading();
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        MySnackBar.showErrorToast(message: "No network connection!");
        // Load from Hive even if offline
        await _loadPendingFormsFromHive(resourceId.toString());
        isPolling.value = false;
        return;
      }

      // Get company ID from shared preferences
      final companyId = await MySharedPref.getCompanyID();

      if (companyId == null || companyId.isEmpty) {
        errorMessage.value = "Company ID not found. Please login again.";
        isError.value = true;
        isPolling.value = false;
        return;
      }

      // Call the poll API
      final response = await _formsApiService.pollForms(
        companyId: companyId,
        resourceId: resourceId.toString(),
      );
      kLog('form res from poll: ${jsonEncode(response?.toJson())}');

      if (response != null && response.success && response.items.isNotEmpty) {
        // Save API response to Hive FIRST
        await MyHive.saveFormsData(resourceId.toString(), response.toJson());
        log('✅ Saved to Hive for resourceId: $resourceId');

        // Then acknowledge forms to remove from server queue
        if (response.count > 0) {
          final queueIds = response.items.map((item) => item.queueId).toList();
          if (queueIds.isNotEmpty) {
            final ackSuccess = await acknowledgeForms(queueIds);
            if (ackSuccess) {
              log('✅ Successfully acknowledged ${queueIds.length} forms');
            } else {
              log(
                '⚠️ Failed to acknowledge forms - will remain in server queue',
              );
            }
          }
        }

        // Load from Hive to update UI
        await _loadPendingFormsFromHive(resourceId.toString());
      } else {
        log('⚠️ Poll returned no data');
        // Still try to load from Hive
        await _loadPendingFormsFromHive(resourceId.toString());
      }
    } catch (e) {
      log('❌ Poll error: $e');
      errorMessage.value = "Failed to fetch forms: $e";
      handleError(e);
      // Try to load from Hive on error
      await _loadPendingFormsFromHive(resourceId.toString());
    } finally {
      isPolling.value = false;
      hideLoading();
    }
  }

  /// Load pending forms from Hive and update UI
  Future<void> _loadPendingFormsFromHive(String resourceId) async {
    try {
      final hiveData = MyHive.getFormsData(resourceId);
      kLog('hive data for resourceId $resourceId: ${jsonEncode(hiveData)}');
      if (hiveData != null && hiveData['success'] == true) {
        final items = hiveData['items'] as List?;
        if (items != null && items.isNotEmpty) {
          // Parse JSON items to FormQueueItem objects
          // Convert each item to Map<String, dynamic> first to handle _Map<dynamic, dynamic>
          final forms = items
              .map(
                (item) => FormQueueItem.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList();

          pendingForms.assignAll(forms);
          hasPendingForms.value = true;
          log(
            '✅ Loaded ${forms.length} forms from Hive (resourceId: $resourceId)',
          );
        } else {
          pendingForms.clear();
          hasPendingForms.value = false;
          log('✅ No forms in Hive for resourceId: $resourceId');
        }
      } else {
        pendingForms.clear();
        hasPendingForms.value = false;
        log('⚠️ No data found in Hive for resourceId: $resourceId');
      }
    } catch (e) {
      log('❌ Error loading from Hive: $e');
      // On error, clear to show empty state
      pendingForms.clear();
      hasPendingForms.value = false;
    }
  }

  /// Acknowledge downloaded forms
  ///
  /// Marks forms as downloaded so they won't be re-pushed
  Future<bool> acknowledgeForms(List<int> queueIds) async {
    if (queueIds.isEmpty) {
      log('⚠️ No queue IDs to acknowledge');
      return false;
    }

    isAcknowledging.value = true;
    errorMessage.value = '';

    try {
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        MySnackBar.showErrorToast(message: "No network connection!");
        isAcknowledging.value = false;
        return false;
      }

      final companyId = await MySharedPref.getCompanyID();
      if (companyId == null || companyId.isEmpty) {
        errorMessage.value = "Company ID not found";
        isAcknowledging.value = false;
        return false;
      }

      // Get device info for audit trail
      final deviceInfo = _getDeviceInfo();

      final response = await _formsApiService.ackForms(
        companyId: companyId,
        queueIds: queueIds,
        deviceInfo: deviceInfo,
      );

      if (response != null && response.success) {
        log('✅ Acknowledged ${response.acked.length} forms');

        // Move acknowledged forms from pending to acknowledged list
        final acknowledgedItems = pendingForms
            .where((form) => response.acked.contains(form.queueId))
            .toList();

        pendingForms.removeWhere(
          (form) => response.acked.contains(form.queueId),
        );
        acknowledgedForms.addAll(acknowledgedItems);

        if (pendingForms.isEmpty) {
          hasPendingForms.value = false;
        }

        return true;
      } else {
        log('⚠️ Ack failed');
        return false;
      }
    } catch (e) {
      log('❌ Ack error: $e');
      errorMessage.value = "Failed to acknowledge forms: $e";
      handleError(e);
      return false;
    } finally {
      isAcknowledging.value = false;
    }
  }

  /// Submit a completed form
  ///
  /// Submits form responses and signatures to the server
  Future<bool> submitForm({
    required int formInstanceId,
    required int templateId,
    required String appointmentId,
    String? customerId,
    required List<FieldResponse> responses,
    int? queueId,
  }) async {
    isSubmitting.value = true;
    errorMessage.value = '';
    isError.value = false;

    try {
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        MySnackBar.showErrorToast(message: "No network connection!");
        isSubmitting.value = false;
        return false;
      }

      final companyId = await MySharedPref.getCompanyID();
      if (companyId == null || companyId.isEmpty) {
        errorMessage.value = "Company ID not found";
        isSubmitting.value = false;
        return false;
      }

      // Get device info
      final deviceInfo = _getDeviceInfo();

      log(
        '📤 Submitting form: instanceId=$formInstanceId, responses=${responses.length}',
      );

      final response = await _formsApiService.submitForm(
        companyId: companyId,
        formInstanceId: formInstanceId,
        templateId: templateId,
        appointmentId: appointmentId,
        customerId: customerId,
        deviceInfo: deviceInfo,
        responses: responses,
        queueId: queueId,
      );

      // Log the full API response
      if (response != null) {
        log('📥 API Response: ${jsonEncode(response.toJson())}');
      } else {
        log('⚠️ API Response is null');
      }

      if (response != null && response.success) {
        log(
          '✅ Form submitted successfully: responseId=${response.formResponseId}',
        );

        // Check for stamp errors
        if (response.stampError != null) {
          log('⚠️ PDF stamp error: ${response.stampError}');
          MySnackBar.showErrorToast(
            message:
                "Form saved but PDF generation failed: ${response.stampError}",
          );
        }

        // Check for email errors
        if (response.emailError != null) {
          log('⚠️ Email error: ${response.emailError}');
        }

        // Log stamped PDF URL if available
        if (response.stampedPdfUrl != null) {
          log('📄 Stamped PDF URL: ${response.stampedPdfUrl}');
        }

        // Remove from acknowledged/pending lists and add to completed
        final form =
            acknowledgedForms.firstWhereOrNull(
              (f) => f.formInstanceId == formInstanceId,
            ) ??
            pendingForms.firstWhereOrNull(
              (f) => f.formInstanceId == formInstanceId,
            );

        if (form != null) {
          acknowledgedForms.remove(form);
          pendingForms.remove(form);
          completedForms.add(form);
        }

        return true;
      } else {
        log('⚠️ Submit failed - response was null or success=false');
        errorMessage.value = "Failed to submit form";
        isError.value = true;
        return false;
      }
    } catch (e) {
      log('❌ Submit error: $e');
      errorMessage.value = "Failed to submit form: $e";
      handleError(e);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Download a PDF file for a form
  ///
  /// Downloads the source PDF for a form template
  Future<String?> downloadFormPdf({
    required String pdfPath,
    required String savePath,
  }) async {
    try {
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        MySnackBar.showErrorToast(message: "No network connection!");
        return null;
      }

      log('📄 Downloading PDF: $pdfPath');

      final success = await _formsApiService.downloadPdf(
        relativePath: pdfPath,
        savePath: savePath,
      );

      if (success) {
        log('✅ PDF downloaded to: $savePath');
        return savePath;
      } else {
        log('⚠️ PDF download failed');
        return null;
      }
    } catch (e) {
      log('❌ PDF download error: $e');
      handleError(e);
      return null;
    }
  }

  /// Get the full URL for viewing a stamped PDF
  String getStampedPdfUrl(String relativePath) {
    return _formsApiService.getStampedPdfUrl(relativePath);
  }

  // ============== APPOINTMENT FORMS METHODS ==============

  /// Load forms for a specific appointment
  ///

  /// Get all forms for a specific appointment from local storage
  ///
  /// This doesn't make a network call - it filters already-loaded forms
  List<FormQueueItem> getFormsForAppointment(String appointmentId) {
    return _filterFormsByAppointmentId(appointmentId);
  }

  /// Filter forms by appointment ID across all form lists
  List<FormQueueItem> _filterFormsByAppointmentId(String appointmentId) {
    final forms = <FormQueueItem>[
      ...pendingForms.where((f) => f.appointmentId == appointmentId),
      ...acknowledgedForms.where((f) => f.appointmentId == appointmentId),
      ...completedForms.where((f) => f.appointmentId == appointmentId),
    ];

    // Remove duplicates by queueId
    final seen = <int>{};
    return forms.where((f) => seen.add(f.queueId)).toList();
  }

  /// Get forms count for an appointment
  int getAppointmentFormsCount(String appointmentId) {
    return _filterFormsByAppointmentId(appointmentId).length;
  }

  /// Get filtered pending forms by current appointment ID
  /// Returns all pending forms if no appointment is selected
  List<FormQueueItem> get filteredPendingForms {
    final appointmentController = Get.find<AppointmentController>();

    return pendingForms
        .where(
          (form) =>
              form.appointmentId ==
              appointmentController.selectedAppointment.value!.apptID
                  .toString(),
        )
        .toList();
  }

  /// Set the appointment filter to show only forms for a specific appointment

  /// Clear the appointment filter to show all forms

  // /// Refresh forms for current appointment
  // Future<void> refreshAppointmentForms() async {
  //   if (currentAppointmentId.value.isNotEmpty) {
  //     await loadFormsForAppointment(
  //       appointmentId: currentAppointmentId.value,
  //       resourceId: currentResourceId.value,
  //       refreshFromServer: true,
  //     );
  //   }
  // }

  /// Get form status for display
  String getFormStatus(FormQueueItem form) {
    // Check if it's submitted
    if (completedForms.any((f) => f.queueId == form.queueId)) {
      return 'Submitted';
    }

    // Check if it's acknowledged (downloaded but not submitted)
    if (acknowledgedForms.any((f) => f.queueId == form.queueId)) {
      return 'In Progress';
    }

    // It's pending
    return 'Pending';
  }

  /// Get form status color
  String getFormStatusColor(FormQueueItem form) {
    final status = getFormStatus(form);
    switch (status) {
      case 'Submitted':
        return '#4CAF50'; // Green
      case 'In Progress':
        return '#FF9800'; // Orange
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // ============== DYNAMIC FORM METHODS ==============

  /// Get form template JSON for dynamic form rendering
  Future<Map<String, dynamic>> getFormTemplate(int templateId) async {
    try {
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        throw Exception('No network connection');
      }

      final companyId = await MySharedPref.getCompanyID();
      if (companyId == null || companyId.isEmpty) {
        throw Exception('Company ID not found');
      }

      final templateData = await _formsApiService.getFormTemplate(
        companyId: companyId,
        templateId: templateId,
      );

      if (templateData != null) {
        log('✅ Form template loaded for templateId=$templateId');
        return templateData;
      } else {
        throw Exception('Failed to load form template');
      }
    } catch (e) {
      log('❌ Error loading form template: $e');
      rethrow;
    }
  }

  /// Get PDF bytes for form rendering
  Future<Uint8List?> getFormPdfBytes(int templateId) async {
    try {
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        throw Exception('No network connection');
      }

      final companyId = await MySharedPref.getCompanyID();
      if (companyId == null || companyId.isEmpty) {
        throw Exception('Company ID not found');
      }

      final pdfBytes = await _formsApiService.getFormPdfBytes(
        companyId: companyId,
        templateId: templateId,
      );

      if (pdfBytes != null) {
        log(
          '✅ PDF bytes loaded for templateId=$templateId (${pdfBytes.length} bytes)',
        );
        return pdfBytes;
      } else {
        log('⚠️ PDF bytes not available for templateId=$templateId');
        return null;
      }
    } catch (e) {
      log('❌ Error loading PDF bytes: $e');
      return null;
    }
  }

  /// Get PDF as base64 string for WebView rendering
  ///
  /// Fetches PDF from server and returns base64 encoded string
  /// suitable for data URLs in web views
  Future<String?> getFormPdfAsBase64(String pdfUrl) async {
    try {
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        throw Exception('No network connection');
      }

      log('📄 Fetching PDF as base64: $pdfUrl');

      final pdfBytes = await _formsApiService.fetchPdfBytes(pdfUrl);

      if (pdfBytes != null) {
        final base64 = base64Encode(pdfBytes);
        log(
          '✅ PDF fetched as base64 (${(pdfBytes.length / 1024).toStringAsFixed(2)} KB)',
        );
        return base64;
      } else {
        log('⚠️ Failed to fetch PDF bytes');
        return null;
      }
    } catch (e) {
      log('❌ Error fetching PDF as base64: $e');
      return null;
    }
  }

  /// Get smart field values for a form
  Future<Map<String, dynamic>> getSmartFieldValues(FormQueueItem form) async {
    try {
      final technicianName = await MySharedPref.getUserName() ?? 'Unknown';
      final technicianId = MySharedPref.getResourceID();
      final companyId = await MySharedPref.getCompanyID();

      return {
        'technician_name': technicianName,
        'technician_id': technicianId?.toString() ?? '',
        'company_id': companyId ?? '',
        'appointment_id': form.appointmentId,
        'form_instance_id': form.formInstanceId,
        'template_id': form.template.id,
        'customer_id': form.customerId,
        'queue_id': form.queueId.toString(),
        'date': DateTime.now().toIso8601String().split('T')[0],
        'datetime': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      log('❌ Error getting smart field values: $e');
      return {};
    }
  }

  /// Submit a dynamic form with field values
  ///
  /// Takes form values from the dynamic form viewer and converts them
  /// into FieldResponse objects for submission
  Future<bool> submitDynamicForm({
    required FormQueueItem form,
    required Map<String, dynamic> fieldValues,
  }) async {
    try {
      // Parse form structure to get field definitions
      final structureJson = jsonDecode(form.template.structure);
      final fields = structureJson['fields'] as List? ?? [];

      // Convert field values to FieldResponse objects
      final responses = <FieldResponse>[];

      log('📝 Processing ${fields.length} fields from template');

      for (final fieldData in fields) {
        final field = fieldData as Map<String, dynamic>;
        final fieldId = field['id'] as String? ?? '';
        final label =
            field['header'] as String? ?? field['label'] as String? ?? 'Field';
        final type = field['type'] as String? ?? 'text';
        final positionData = field['position'] as Map<String, dynamic>?;

        if (fieldId.isEmpty) continue;

        // Get the value from formValues
        final value = fieldValues[fieldId];

        // Debug log for each field
        log(
          '📋 Field: $fieldId ($type) = ${value != null ? "${value.toString().substring(0, value.toString().length > 50 ? 50 : value.toString().length)}..." : "null"}',
        );

        if (value == null || value == '') {
          // Skip empty values except for checkboxes (unchecked should still be sent)
          if (type != 'checkbox') {
            log('⏭️ Skipping empty field: $fieldId');
            continue;
          }
        }

        // Create FieldResponse based on field type
        final position = positionData != null
            ? FieldPosition.fromJson(positionData)
            : null;

        FieldResponse response;

        switch (type) {
          case 'signature':
          case 'image':
            response = FieldResponse(
              fieldId: fieldId,
              label: label,
              type: type,
              value: value is String ? value : jsonEncode(value),
              position: position,
            );
            break;

          case 'number':
            response = FieldResponse.number(
              fieldId: fieldId,
              label: label,
              value: value is num ? value : num.tryParse(value.toString()) ?? 0,
              position: position,
            );
            break;

          case 'checkbox':
            final isChecked = value == true || value == 'true';
            response = FieldResponse.check(
              fieldId: fieldId,
              label: label,
              value: isChecked,
              position: position,
            );
            break;

          case 'radio':
          case 'dropdown':
            response = FieldResponse(
              fieldId: fieldId,
              label: label,
              type: type,
              value: value.toString(),
              position: position,
            );
            break;

          case 'textarea':
            response = FieldResponse.textarea(
              fieldId: fieldId,
              label: label,
              value: value.toString(),
              position: position,
            );
            break;

          case 'date':
            final dateValue = value is DateTime
                ? value
                : DateTime.tryParse(value.toString()) ?? DateTime.now();
            response = FieldResponse.date(
              fieldId: fieldId,
              label: label,
              value: dateValue,
              position: position,
            );
            break;

          case 'file':
            // Handle file uploads (value is a Map with 'name' and 'data')
            if (value is Map && value.containsKey('data')) {
              response = FieldResponse(
                fieldId: fieldId,
                label: label,
                type: 'file',
                value: value['data'] ?? '',
                position: position,
              );
            } else {
              response = FieldResponse(
                fieldId: fieldId,
                label: label,
                type: 'file',
                value: value.toString(),
                position: position,
              );
            }
            break;

          default:
            // text and smartfield types
            response = FieldResponse.text(
              fieldId: fieldId,
              label: label,
              value: value.toString(),
              position: position,
            );
            break;
        }

        responses.add(response);
      }

      log('📋 Prepared ${responses.length} field responses for submission');

      // Log the request body
      final requestBody = {
        'formInstanceId': form.formInstanceId,
        'templateId': form.templateId,
        'appointmentId': form.appointmentId,
        'customerId': form.customerId,
        'queueId': form.queueId,
        'responses': responses.map((r) => r.toJson()).toList(),
      };
      log('📤 Request Body: ${jsonEncode(requestBody)}');

      // Submit the form using existing submitForm method
      return await submitForm(
        formInstanceId: form.formInstanceId,
        templateId: form.templateId,
        appointmentId: form.appointmentId,
        customerId: form.customerId,
        responses: responses,
        queueId: form.queueId,
      );
    } catch (e) {
      log('❌ Error submitting dynamic form: $e');
      errorMessage.value = "Failed to submit form: $e";
      handleError(e);
      return false;
    }
  }

  // ============== HELPER METHODS ==============

  /// Select a form for viewing/editing
  void selectForm(FormQueueItem form) {
    selectedForm.value = form;
  }

  /// Clear the selected form
  void clearSelection() {
    selectedForm.value = null;
  }

  /// Get pending forms count
  int get pendingFormsCount => pendingForms.length;

  /// Check if a specific form is in the pending list
  bool isFormPending(int queueId) {
    return pendingForms.any((form) => form.queueId == queueId);
  }

  /// Remove a form from pending list locally
  void removePendingForm(int queueId) {
    pendingForms.removeWhere((form) => form.queueId == queueId);
    if (pendingForms.isEmpty) {
      hasPendingForms.value = false;
    }
  }

  /// Clear all pending forms
  void clearPendingForms() {
    pendingForms.clear();
    hasPendingForms.value = false;
  }

  /// Get device info string for audit trail
  String _getDeviceInfo() {
    // Simple device info - can be enhanced with device_info_plus package
    return 'Field Agent App / ${_getPlatform()}';
  }

  /// Get platform name
  String _getPlatform() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    }
    return 'Mobile';
  }

  @override
  void onReady() {
    // Load forms from Hive on controller ready
    // Note: resourceId needs to be set separately before polling
    super.onReady();
  }

  /// Load pending forms from Hive for a specific resource
  /// This should be called when the app starts or when switching resources
  Future<void> loadPendingFormsFromHive(String resourceId) async {
    await _loadPendingFormsFromHive(resourceId);
  }

  @override
  void onClose() {
    clearSelection();
    super.onClose();
  }
}
