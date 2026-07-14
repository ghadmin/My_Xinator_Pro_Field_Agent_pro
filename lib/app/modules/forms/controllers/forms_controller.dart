import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/forms/models/forom_get_response_model.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../models/forms/forms_models.dart';
import '../../../routes/app_pages.dart';
import '../../../service/REST/api_urls.dart';
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

  // ============== FORM SELECTION PROPERTIES ==============

  /// Available form templates for selection
  final availableFormTemplates = <FormOption>[].obs;

  /// Loading state for form templates
  final RxBool isLoadingTemplates = false.obs;

  /// Error state for form templates
  final RxBool templatesError = false.obs;

  /// Error message for templates
  final RxString templatesErrorMessage = ''.obs;

  /// Selected form IDs for multi-selection
  final RxSet<String> selectedFormIds = <String>{}.obs;

  /// Search functionality for form templates
  final TextEditingController templateSearchController =
      TextEditingController();
  final RxString templateSearchQuery = ''.obs;

  // ============== EMAIL PROPERTIES ==============

  /// Text controllers for email form
  final TextEditingController toTextController = TextEditingController();
  final TextEditingController ccTextController = TextEditingController();
  final TextEditingController subjectTextController = TextEditingController();
  final TextEditingController emailBodyTextController = TextEditingController();

  /// Focus nodes for email form
  final Rx<FocusNode> emailToFocusnode = FocusNode().obs;
  final Rx<FocusNode> emailCcFocusnode = FocusNode().obs;
  final Rx<FocusNode> emailSubjectFocusnode = FocusNode().obs;
  final Rx<FocusNode> emailBodyFocusnode = FocusNode().obs;

  /// Checkbox states for payment links
  RxBool isSendXPayLink = false.obs;
  RxBool isSendTuaPayLink = false.obs;

  /// Currently selected form for email
  final Rx<FormQueueItem?> selectedFormForEmail = Rx(null);

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
        // await MyHive.saveFormsData(resourceId.toString(), response.toJson());
        // kLog('✅ Saved to Hive for resourceId: $resourceId');

        // Then acknowledge forms to remove from server queue
        if (response.count > 0) {
          final queueIds = response.items.map((item) => item.queueId).toList();
          if (queueIds.isNotEmpty) {
            acknowledgeForms(queueIds);
          }
        }

        // Load from API directly to update UI (skip Hive)
        await _loadPendingFormsFromApi(response.items);
      } else {
        kLog('⚠️ Poll returned no data');
        // Clear the pending forms list
        pendingForms.clear();
        hasPendingForms.value = false;
      }
    } catch (e) {
      kLog('❌ Poll error: $e');
      errorMessage.value = "Failed to fetch forms: $e";
      handleError(e);
      // Try to load from Hive on error
      await _loadPendingFormsFromHive(resourceId.toString());
    } finally {
      isPolling.value = false;
      hideLoading();
    }
  }

  /// Load pending forms from API response directly
  ///
  /// Bypasses Hive and loads forms directly from API response
  Future<void> _loadPendingFormsFromApi(List<FormQueueItem> items) async {
    try {
      // The items are already FormQueueItem objects from the API response
      final forms = items.cast<FormQueueItem>().toList();

      pendingForms.assignAll(forms);
      hasPendingForms.value = true;
      kLog('✅ Loaded ${forms.length} forms from API');
    } catch (e) {
      kLog('❌ Error loading forms from API: $e');
      pendingForms.clear();
      hasPendingForms.value = false;
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
          kLog(
            '✅ Loaded ${forms.length} forms from Hive (resourceId: $resourceId)',
          );
        } else {
          pendingForms.clear();
          hasPendingForms.value = false;
          kLog('✅ No forms in Hive for resourceId: $resourceId');
        }
      } else {
        pendingForms.clear();
        hasPendingForms.value = false;
        kLog('⚠️ No data found in Hive for resourceId: $resourceId');
      }
    } catch (e) {
      kLog('❌ Error loading from Hive: $e');
      // On error, clear to show empty state
      pendingForms.clear();
      hasPendingForms.value = false;
    }
  }

  /// Save form progress data to Hive
  ///
  /// Saves field values (text, signatures, etc.) for a specific form instance
  /// This allows restoring user input when the form is opened again
  ///
  /// [formInstanceId] - Unique ID for the form instance
  /// [fieldValues] - Map of fieldId -> value (text, base64 signature, etc.)
  /// [appointmentId] - The appointment ID for data association
  Future<void> saveFormProgress(
    int formInstanceId,
    Map<String, dynamic> fieldValues, {
    String? appointmentId,
  }) async {
    try {
      await MyHive.saveFormProgress(
        formInstanceId,
        fieldValues,
        appointmentId: appointmentId,
      );
      kLog(
        '✅ Saved form progress for appointmentId=$appointmentId, formInstanceId=$formInstanceId (${fieldValues.length} fields)',
      );
    } catch (e) {
      kLog('❌ Error saving form progress: $e');
    }
  }

  /// Get saved form progress data from Hive
  ///
  /// Retrieves previously saved field values for a form instance
  /// Returns empty map if no saved data exists or appointment ID doesn't match
  ///
  /// [formInstanceId] - Unique ID for the form instance
  /// [appointmentId] - The appointment ID to verify match
  Map<String, dynamic> getFormProgress(
    int formInstanceId, {
    String? appointmentId,
  }) {
    try {
      return MyHive.getFormProgress(
        formInstanceId,
        appointmentId: appointmentId,
      );
    } catch (e) {
      kLog('❌ Error loading form progress: $e');
      return {};
    }
  }

  /// Clear saved form progress data from Hive
  ///
  /// Removes saved field values (typically after successful submission)
  ///
  /// [formInstanceId] - Unique ID for the form instance
  Future<void> clearFormProgress(int formInstanceId) async {
    try {
      await MyHive.clearFormProgress(formInstanceId);
      kLog('✅ Cleared form progress for formInstanceId=$formInstanceId');
    } catch (e) {
      kLog('❌ Error clearing form progress: $e');
    }
  }

  /// Check if form has saved progress
  ///
  /// Returns true if there's previously saved data for this form instance
  ///
  /// [formInstanceId] - Unique ID for the form instance
  bool hasFormProgress(int formInstanceId) {
    try {
      return MyHive.hasFormProgress(formInstanceId);
    } catch (e) {
      kLog('❌ Error checking form progress: $e');
      return false;
    }
  }

  /// Acknowledge downloaded forms
  ///
  /// Marks forms as downloaded so they won't be re-pushed
  Future<void> acknowledgeForms(List<int> queueIds) async {
    if (queueIds.isEmpty) {
      kLog('⚠️ No queue IDs to acknowledge');
      return;
    }

    isAcknowledging.value = true;
    errorMessage.value = '';

    try {
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        MySnackBar.showErrorToast(message: "No network connection!");
        isAcknowledging.value = false;
        return;
      }

      final companyId = await MySharedPref.getCompanyID();
      if (companyId == null || companyId.isEmpty) {
        errorMessage.value = "Company ID not found";
        isAcknowledging.value = false;
        return;
      }

      // Get device info for audit trail
      final deviceInfo = _getDeviceInfo();

      await _formsApiService.ackForms(
        companyId: companyId,
        queueIds: queueIds,
        deviceInfo: deviceInfo,
      );
    } catch (e) {
      kLog('❌ Ack error: $e');
      errorMessage.value = "Failed to acknowledge forms: $e";
      handleError(e);
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

      kLog(
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
        kLog('📥 API Response: ${jsonEncode(response.toJson())}');
      } else {
        kLog('⚠️ API Response is null');
      }

      if (response != null && response.success) {
        kLog(
          '✅ Form submitted successfully: responseId=${response.formResponseId}',
        );

        // Check for stamp errors
        if (response.stampError != null) {
          kLog('⚠️ PDF stamp error: ${response.stampError}');
          MySnackBar.showErrorToast(
            message:
                "Form saved but PDF generation failed: ${response.stampError}",
          );
        }

        // Check for email errors
        if (response.emailError != null) {
          kLog('⚠️ Email error: ${response.emailError}');
        }

        // Log stamped PDF URL if available
        if (response.stampedPdfUrl != null) {
          kLog('📄 Stamped PDF URL: ${response.stampedPdfUrl}');
        }

        // ✅ FIXED: Don't remove from pendingForms - update status instead
        // This keeps forms visible in UI with "Submitted" status
        final form =
            acknowledgedForms.firstWhereOrNull(
              (f) => f.formInstanceId == formInstanceId,
            ) ??
            pendingForms.firstWhereOrNull(
              (f) => f.formInstanceId == formInstanceId,
            );

        if (form != null) {
          // Update form with formResponseId for viewing submitted responses
          final updatedForm = FormQueueItem(
            queueId: form.queueId,
            formInstanceId: form.formInstanceId,
            appointmentId: form.appointmentId,
            templateId: form.templateId,
            resourceId: form.resourceId,
            action: form.action,
            triggerId: form.triggerId,
            createdDateTime: form.createdDateTime,
            customerId: form.customerId,
            instanceStatus: form.instanceStatus,
            sendToCustomerOnSubmit: form.sendToCustomerOnSubmit,
            template: form.template,
            smartFieldData: form.smartFieldData,
            formResponseId: response.formResponseId,
          );

          // Replace the form in pendingForms with the updated version
          final index = pendingForms.indexWhere(
            (f) => f.formInstanceId == formInstanceId,
          );
          if (index != -1) {
            pendingForms[index] = updatedForm;
          }

          // Add to completed forms list (for historical tracking)
          completedForms.add(updatedForm);

          // Keep in pendingForms but update could be done to show completed status
          // The UI will show different status based on getFormStatus() method
          kLog(
            '✅ Form $formInstanceId submitted successfully with formResponseId=${response.formResponseId}, kept in pending list with completed status',
          );
        }

        return true;
      } else {
        kLog('⚠️ Submit failed - response was null or success=false');
        errorMessage.value = "Failed to submit form";
        isError.value = true;
        return false;
      }
    } catch (e) {
      kLog('❌ Submit error: $e');
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

      kLog('📄 Downloading PDF: $pdfPath');

      final success = await _formsApiService.downloadPdf(
        relativePath: pdfPath,
        savePath: savePath,
      );

      if (success) {
        kLog('✅ PDF downloaded to: $savePath');
        return savePath;
      } else {
        kLog('⚠️ PDF download failed');
        return null;
      }
    } catch (e) {
      kLog('❌ PDF download error: $e');
      handleError(e);
      return null;
    }
  }

  /// Get the full URL for viewing a stamped PDF
  String getStampedPdfUrl(String relativePath) {
    return _formsApiService.getStampedPdfUrl(relativePath);
  }

  /// Send PDF via email to customer
  ///
  /// Sends the stamped PDF to the customer's email address
  Future<bool> sendPdfEmail({
    required String companyId,
    int? formResponseId,
    int? templateId,
    String? appointmentId,
    String? customerId,
    String? toEmail,
  }) async {
    try {
      showLoading();

      final response = await _formsApiService.sendPdfEmail(
        companyId: companyId,
        formResponseId: formResponseId,
        templateId: templateId,
        appointmentId: appointmentId,
        customerId: customerId,
        toEmail: toEmail,
      );

      hideLoading();

      if (response != null &&
          response['success'] == true &&
          response['emailError'] == null) {
        MySnackBar.showInfoToast(
          message: 'PDF sent to ${response['toEmail'] ?? 'customer'}',
        );
        kLog('✅ PDF email sent successfully: ${response['toEmail']}');
        return true;
      } else {
        final error =
            response?['emailError'] ?? response?['error'] ?? 'Unknown error';
        MySnackBar.showErrorToast(message: 'Failed to send email: $error');
        kLog('❌ PDF email failed: $error');
        return false;
      }
    } catch (e) {
      hideLoading();
      kLog('❌ Send PDF email error: $e');
      MySnackBar.showErrorToast(message: 'Failed to send email: $e');
      handleError(e);
      return false;
    }
  }

  /// Send form via email
  ///
  /// Sends the form PDF to customer email using FaProSync sendEmail API
  /// Allows custom subject, body, cc with optional PDF attachment
  ///
  /// Returns true if email sent successfully, false on error
  Future<bool> sendFormEmail({required FormQueueItem form}) async {
    try {
      showLoading();

      final companyId = await MySharedPref.getCompanyID();

      if (companyId == null || companyId.isEmpty) {
        MySnackBar.showErrorToast(message: "Company ID not found");
        hideLoading();
        return false;
      }

      // Validate required fields (to, subject, body are required per API spec)
      if (toTextController.text.isEmpty) {
        MySnackBar.showErrorToast(
          message: "Please enter recipient email address",
        );
        hideLoading();
        return false;
      }

      if (subjectTextController.text.isEmpty) {
        MySnackBar.showErrorToast(message: "Please enter email subject");
        hideLoading();
        return false;
      }

      if (emailBodyTextController.text.isEmpty) {
        MySnackBar.showErrorToast(message: "Please enter email body");
        hideLoading();
        return false;
      }

      // Prepare email fields
      final subject = subjectTextController.text;
      final body = emailBodyTextController.text;

      // Use formResponseId if the form has been submitted, otherwise null
      // If formResponseId is provided, the API will attach the stamped PDF
      final formResponseId = form.formInstanceId > 0
          ? form.formInstanceId
          : null;

      kLog(
        '📧 Sending form email: to=${toTextController.text}, cc=${ccTextController.text}, formResponseId=$formResponseId',
      );

      final response = await _formsApiService.sendCustomEmail(
        companyId: companyId,
        to: toTextController.text,
        subject: subject,
        body: body,
        cc: ccTextController.text.isNotEmpty ? ccTextController.text : null,
        customerId: form.customerId,
        formResponseId: formResponseId,
      );

      if (response == null) {
        hideLoading();
        MySnackBar.showErrorToast(message: "Failed to send email");
        return false;
      }

      // Close loading dialog first
      await hideLoading();

      // Wait for dialog to fully close and overlays to reset
      await Future.delayed(const Duration(milliseconds: 200));

      // Check response and show appropriate message
      // Per API spec: success is ONLY true when underlying pipeline returns "Sent"
      if (response['success'] == true) {
        final attached = response['attached'] == true;
        final attachmentStatus = attached
            ? "with PDF attached"
            : "without PDF attachment";
        MySnackBar.showToast(
          message: "Email sent successfully $attachmentStatus",
        );
        kLog(
          '✅ Email sent: to=${response['toEmail']}, subject=${response['subject']}, attached=$attached',
        );
        return true;
      } else {
        // Handle soft send failures (no exception, but provider rejected)
        final emailStatus = response['emailStatus'] as String?;
        final emailError = response['emailError'] as String?;
        final generalError = response['error'] as String?;

        final errorMessage =
            emailError ?? generalError ?? emailStatus ?? 'Unknown error';
        MySnackBar.showErrorToast(
          message: "Failed to send email: $errorMessage",
        );
        kLog('⚠️ Email failed: status=$emailStatus, error=$errorMessage');
        return false;
      }
    } catch (e) {
      hideLoading();
      kLog('❌ Send form email error: $e');
      MySnackBar.showErrorToast(message: 'Failed to send email: $e');
      return false;
    }
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
        kLog('✅ Form template loaded for templateId=$templateId');
        return templateData;
      } else {
        throw Exception('Failed to load form template');
      }
    } catch (e) {
      kLog('❌ Error loading form template: $e');
      rethrow;
    }
  }

  /// Get form response by ID
  ///
  /// Fetches a previously submitted form response using its formResponseId
  /// Returns the response data including field values and metadata
  Future<FormGetResponseModel?> getFormResponse(int formResponseId) async {
    try {
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        MySnackBar.showErrorToast(message: "No network connection!");
        return null;
      }

      final companyId = await MySharedPref.getCompanyID();
      if (companyId == null || companyId.isEmpty) {
        MySnackBar.showErrorToast(message: "Company ID not found");
        return null;
      }

      kLog('📋 Fetching form response: formResponseId=$formResponseId');

      final responseData = await _formsApiService.getResponse(
        companyId: companyId,
        formResponseId: formResponseId,
      );

      if (responseData != null) {
        kLog('✅ Form response loaded for formResponseId=$formResponseId');
        final formResponse = FormGetResponseModel.fromJson(responseData);

        return formResponse;
      } else {
        kLog(
          '⚠️ Form response not available for formResponseId=$formResponseId',
        );
        return null;
      }
    } catch (e) {
      kLog('❌ Error fetching form response: $e');
      MySnackBar.showErrorToast(message: 'Failed to fetch form response: $e');
      return null;
    }
  }

  /// Get form response by natural key (templateId + appointmentId + customerId)
  ///
  /// Fetches a previously submitted form response using natural key
  /// This is used for viewing forms that were submitted from the poll queue
  Future<FormGetResponseModel?> getFormResponseByNaturalKey({
    required int templateId,
    required String appointmentId,
    required String customerId,
  }) async {
    try {
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        MySnackBar.showErrorToast(message: "No network connection!");
        return null;
      }

      final companyId = await MySharedPref.getCompanyID();
      if (companyId == null || companyId.isEmpty) {
        MySnackBar.showErrorToast(message: "Company ID not found");
        return null;
      }

      kLog(
        '📋 Fetching form response by natural key: templateId=$templateId, appointmentId=$appointmentId, customerId=$customerId',
      );

      final responseData = await _formsApiService.getResponseByNaturalKey(
        companyId: companyId,
        templateId: templateId,
        appointmentId: appointmentId,
        customerId: customerId,
      );
      kLog('📥 API Response d: ${jsonEncode(responseData)}');
      if (responseData != null) {
        kLog('✅ Form response loaded by natural key');
        return FormGetResponseModel.fromJson(responseData);
      } else {
        kLog('⚠️ Form response not available by natural key');
        return null;
      }
    } catch (e) {
      kLog('❌ Error fetching form response: $e');
      // MySnackBar.showErrorToast(message: 'Failed to fetch form response: $e');
      return null;
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
        kLog(
          '✅ PDF bytes loaded for templateId=$templateId (${pdfBytes.length} bytes)',
        );
        return pdfBytes;
      } else {
        kLog('⚠️ PDF bytes not available for templateId=$templateId');
        return null;
      }
    } catch (e) {
      kLog('❌ Error loading PDF bytes: $e');
      return null;
    }
  }

  /// Get PDF as base64 string for WebView rendering
  ///
  /// Fetches PDF from server and returns base64 encoded string
  /// suitable for data URLs in web views
  ///
  /// The PDF URL is constructed as: pdfBaseUrl + template['pdfFile']['path']
  Future<String?> getFormPdfAsBase64(String pdfUrl) async {
    try {
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        throw Exception('No network connection');
      }

      kLog('📄 Fetching PDF as base64: $pdfUrl');

      final pdfBytes = await _formsApiService.fetchPdfBytes(pdfUrl);

      if (pdfBytes != null) {
        final base64 = base64Encode(pdfBytes);
        kLog(
          '✅ PDF fetched as base64 (${(pdfBytes.length / 1024).toStringAsFixed(2)} KB)',
        );
        return base64;
      } else {
        kLog('⚠️ Failed to fetch PDF bytes');
        return null;
      }
    } catch (e) {
      kLog('❌ Error fetching PDF as base64: $e');
      return null;
    }
  }

  // ============== FORM PROGRESS (HIVE) - COMMENTED OUT ==============
  /*
  /// Save form progress data to Hive
  ///
  /// Saves field values (text, signatures, etc.) for a specific form instance
  /// This allows restoring user input when the form is opened again
  ///
  /// [formInstanceId] - Unique ID for the form instance
  /// [fieldValues] - Map of fieldId -> value (text, base64 signature, etc.)
  Future<void> saveFormProgress(int formInstanceId, Map<String, dynamic> fieldValues) async {
    try {
      await MyHive.saveFormProgress(formInstanceId, fieldValues);
      kLog('✅ Saved form progress for formInstanceId=$formInstanceId (${fieldValues.length} fields)');
    } catch (e) {
      kLog('❌ Error saving form progress: $e');
    }
  }

  /// Get saved form progress data from Hive
  ///
  /// Retrieves previously saved field values for a form instance
  /// Returns empty map if no saved data exists or appointment ID doesn't match
  ///
  /// [formInstanceId] - Unique ID for the form instance
  /// [appointmentId] - The appointment ID to verify match
  Map<String, dynamic> getFormProgress(
    int formInstanceId, {
    String? appointmentId,
  }) {
    try {
      return MyHive.getFormProgress(
        formInstanceId,
        appointmentId: appointmentId,
      );
    } catch (e) {
      kLog('❌ Error loading form progress: $e');
      return {};
    }
  }

  /// Clear saved form progress data from Hive
  ///
  /// Removes saved field values (typically after successful submission)
  ///
  /// [formInstanceId] - Unique ID for the form instance
  Future<void> clearFormProgress(int formInstanceId) async {
    try {
      await MyHive.clearFormProgress(formInstanceId);
      kLog('✅ Cleared form progress for formInstanceId=$formInstanceId');
    } catch (e) {
      kLog('❌ Error clearing form progress: $e');
    }
  }

  /// Check if form has saved progress
  ///
  /// Returns true if there's previously saved data for this form instance
  ///
  /// [formInstanceId] - Unique ID for the form instance
  bool hasFormProgress(int formInstanceId) {
    try {
      return MyHive.hasFormProgress(formInstanceId);
    } catch (e) {
      kLog('❌ Error checking form progress: $e');
      return false;
    }
  }
  */

  // ============== API METHODS ==============
  ///
  /// According to the Smart Field Issue Solution PDF:
  /// - smartFieldData is a sibling property to template.structure
  /// - Both are JSON strings that need to be parsed
  /// - Smart field values are keyed by field.id (e.g., "pdf_1776450913261_56q93m")
  ///
  /// Example API response structure:
  /// items[i] = {
  ///   queueId, formInstanceId, appointmentId, templateId, customerId, ...,
  ///   template: { id, name, structure: "", ... },
  ///   smartFieldData: "" // ← the values
  /// }
  Map<String, dynamic> parseSmartFieldData(FormQueueItem form) {
    try {
      if (form.smartFieldData.isEmpty) {
        kLog('⚠️ No smartFieldData provided for form ${form.formInstanceId}');
        return {};
      }

      final smartFieldData =
          jsonDecode(form.smartFieldData) as Map<String, dynamic>;
      kLog('✅ Parsed smartFieldData: ${smartFieldData.keys.toList()}');
      return smartFieldData;
    } catch (e) {
      kLog('❌ Error parsing smartFieldData: $e');
      return {};
    }
  }

  /// Parse form template structure
  ///
  /// Parses the template.structure JSON string to extract field definitions
  /// Returns a map of field.id -> field definition for easy lookup
  Map<String, dynamic> parseTemplateStructure(FormQueueItem form) {
    try {
      if (form.template.structure.isEmpty) {
        kLog(
          '⚠️ No template structure provided for form ${form.formInstanceId}',
        );
        return {};
      }

      final structureData =
          jsonDecode(form.template.structure) as Map<String, dynamic>;
      final fields = structureData['fields'] as List? ?? [];

      final fieldMap = <String, dynamic>{};
      for (final field in fields) {
        if (field is Map<String, dynamic>) {
          final fieldId = field['id'] as String?;
          if (fieldId != null) {
            fieldMap[fieldId] = field;
          }
        }
      }

      kLog('✅ Parsed template structure: ${fieldMap.keys.length} fields');
      return fieldMap;
    } catch (e) {
      kLog('❌ Error parsing template structure: $e');
      return {};
    }
  }

  /// Get smart field values for a form
  ///
  /// Parses smartFieldData from the API response and merges with app-level values
  Future<Map<String, dynamic>> getSmartFieldValues(FormQueueItem form) async {
    try {
      // Parse smartFieldData from API first (this is the primary source)
      final apiSmartFields = parseSmartFieldData(form);

      // Get app-level values as fallback
      final technicianName = await MySharedPref.getUserName() ?? 'Unknown';
      final technicianId = MySharedPref.getResourceID();
      final companyId = await MySharedPref.getCompanyID();

      final appSmartFields = {
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

      // Merge: API smart fields take precedence over app-level fields
      return {...appSmartFields, ...apiSmartFields};
    } catch (e) {
      kLog('❌ Error getting smart field values: $e');
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

      kLog('📝 Processing ${fields.length} fields from template');

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
        kLog(
          '📋 Field: $fieldId ($type) = ${value != null ? "${value.toString().substring(0, value.toString().length > 50 ? 50 : value.toString().length)}..." : "null"}',
        );

        if (value == null || value == '') {
          // Skip empty values except for checkboxes and checks (unchecked should still be sent)
          if (type != 'checkbox' && type != 'check') {
            kLog('⏭️ Skipping empty field: $fieldId');
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

          case 'check':
            final isCheckChecked = value == true || value == 'true';
            response = FieldResponse.check(
              fieldId: fieldId,
              label: label,
              value: isCheckChecked,
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

      kLog('📋 Prepared ${responses.length} field responses for submission');

      // Log the request body
      final requestBody = {
        'formInstanceId': form.formInstanceId,
        'templateId': form.templateId,
        'appointmentId': form.appointmentId,
        'customerId': form.customerId,
        'queueId': form.queueId,
        'responses': responses.map((r) => r.toJson()).toList(),
      };
      kLog('📤 Request Body: ${jsonEncode(requestBody)}');

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
      kLog('❌ Error submitting dynamic form: $e');
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

    // Setup template search listener
    templateSearchController.addListener(() {
      templateSearchQuery.value = templateSearchController.text;
    });

    super.onReady();
  }

  // ============== FORM TEMPLATE METHODS ==============

  /// Fetch available form templates from API
  ///
  /// Loads enabled form templates that can be selected for appointment forms
  Future<void> fetchFormTemplates() async {
    try {
      isLoadingTemplates.value = true;
      templatesError.value = false;
      templatesErrorMessage.value = '';

      // Check network connectivity
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        MySnackBar.showErrorToast(message: "No network connection!");
        templatesError.value = true;
        templatesErrorMessage.value =
            'No network connection. Please check your internet and try again.';
        isLoadingTemplates.value = false;
        return;
      }

      // Get company ID from shared preferences
      final companyId = await MySharedPref.getCompanyID();

      if (companyId == null || companyId.isEmpty) {
        kLog('⚠️ CompanyId is null or empty');
        templatesError.value = true;
        templatesErrorMessage.value =
            'Company ID not found. Please log in again.';
        isLoadingTemplates.value = false;
        return;
      }

      kLog('📋 Fetching templates for companyId: $companyId');

      final response = await _formsApiService.listTemplates(
        companyId: companyId,
      );

      if (response == null) {
        kLog('⚠️ Templates response is null');
        templatesError.value = true;
        templatesErrorMessage.value = 'Failed to load forms. Please try again.';
        isLoadingTemplates.value = false;
        return;
      }

      if (!response['success']) {
        kLog('⚠️ Templates API returned success=false');
        templatesError.value = true;
        templatesErrorMessage.value =
            response['error'] ?? 'Failed to load forms.';
        isLoadingTemplates.value = false;
        return;
      }

      final templatesResponse = TemplatesResponse.fromJson(response);

      if (templatesResponse.templates.isEmpty) {
        kLog('ℹ️ No templates found');
        availableFormTemplates.clear();
      } else {
        kLog('✅ Loaded ${templatesResponse.templates.length} templates');

        // Convert template items to form options
        availableFormTemplates.assignAll(
          templatesResponse.templates
              .map((template) => template.toFormOption())
              .toList(),
        );
      }

      isLoadingTemplates.value = false;
    } catch (e, stackTrace) {
      kLog('❌ Error fetching templates: $e');
      kLog('Stack trace: $stackTrace');
      templatesError.value = true;
      templatesErrorMessage.value = 'An error occurred: ${e.toString()}';
      isLoadingTemplates.value = false;
    }
  }

  /// Get filtered form templates based on search query
  List<FormOption> get filteredFormTemplates {
    if (templateSearchQuery.value.isEmpty) return availableFormTemplates;

    return availableFormTemplates.where((option) {
      return option.name.toLowerCase().contains(
            templateSearchQuery.value.toLowerCase(),
          ) ||
          option.description.toLowerCase().contains(
            templateSearchQuery.value.toLowerCase(),
          );
    }).toList();
  }

  /// Get selected count
  int get selectedTemplatesCount => selectedFormIds.length;

  /// Toggle form template selection
  void toggleTemplateSelection(FormOption form) {
    if (pendingForms
        .where(
          (f) =>
              f.appointmentId ==
              appointmentController.selectedAppointment.value!.apptID
                  .toString(),
        )
        .any((formItem) => formItem.templateId == form.templateId)) {
      MySnackBar.showInfoToast(
        message: 'Form "${form.name}" is already in the pending list.',
      );
      return;
    }
    if (selectedFormIds.contains(form.id)) {
      selectedFormIds.remove(form.id);
      kLog('Deselected template: $form.id');
    } else {
      selectedFormIds.add(form.id);
      kLog('Selected template: $form.id');
    }
  }

  /// Check if a template is selected
  bool isTemplateSelected(String formId) {
    return selectedFormIds.contains(formId);
  }

  /// Clear template search
  void clearTemplateSearch() {
    templateSearchController.clear();
    templateSearchQuery.value = '';
  }

  /// Retry fetching templates
  void retryFetchTemplates() {
    fetchFormTemplates();
  }

  /// Get selected form templates
  List<FormOption> getSelectedTemplates() {
    return availableFormTemplates
        .where((form) => selectedFormIds.contains(form.id))
        .toList();
  }

  /// Clear template selection
  void clearTemplateSelection() {
    selectedFormIds.clear();
  }

  /// Attach selected forms to an appointment
  ///
  /// Takes selected template IDs and attaches them to the specified appointment
  /// Returns the API response with success status and form instance IDs
  Future<Map<String, dynamic>?> attachSelectedFormsToAppointment({
    required String appointmentId,
    String? customerId,
  }) async {
    try {
      if (selectedFormIds.isEmpty) {
        kLog('⚠️ No forms selected for attachment');
        return null;
      }

      // Check network connectivity
      if (!await NetworkConnectivity.isNetworkAvailable()) {
        MySnackBar.showErrorToast(message: "No network connection!");
        return null;
      }

      // Get company ID from shared preferences
      final companyId = await MySharedPref.getCompanyID();

      if (companyId == null || companyId.isEmpty) {
        kLog('⚠️ CompanyId is null or empty');
        MySnackBar.showErrorToast(
          message: 'Company ID not found. Please log in again.',
        );
        return null;
      }

      // Get selected template IDs (convert string IDs to int)
      final selectedTemplates = getSelectedTemplates();
      final templateIds = selectedTemplates
          .map(
            (template) => template.templateId ?? int.tryParse(template.id) ?? 0,
          )
          .where((id) => id > 0)
          .toList();

      if (templateIds.isEmpty) {
        kLog('⚠️ No valid template IDs found');
        MySnackBar.showErrorToast(message: 'No valid forms selected.');
        return null;
      }

      kLog(
        '📎 Attaching ${templateIds.length} forms to appointment $appointmentId',
      );

      // Get filledBy from shared preferences (technician name)
      final filledBy = await MySharedPref.getUserName();

      final response = await _formsApiService.attachTemplates(
        companyId: companyId,
        appointmentId: appointmentId,
        templateIds: templateIds,
        customerId: customerId,
        filledBy: filledBy,
      );

      if (response != null) {
        final attachResponse = AttachTemplatesResponse.fromJson(response);

        if (attachResponse.success) {
          kLog('✅ Successfully attached ${attachResponse.count} forms');

          // Show success message
          if (attachResponse.alreadyAttachedCount > 0) {
            MySnackBar.showInfoToast(
              message:
                  '${attachResponse.successCount - attachResponse.alreadyAttachedCount} forms attached, ${attachResponse.alreadyAttachedCount} were already attached',
            );
          } else {
            MySnackBar.showToast(
              message: '${attachResponse.count} form(s) attached successfully',
            );
          }

          // Clear selection after successful attachment
          clearTemplateSelection();
        } else {
          kLog('⚠️ Attach operation failed');
          MySnackBar.showErrorToast(message: 'Failed to attach forms.');
        }
      } else {
        kLog('⚠️ Attach response is null');
        MySnackBar.showErrorToast(
          message: 'Failed to attach forms. Please try again.',
        );
      }

      return response;
    } catch (e, stackTrace) {
      kLog('❌ Error attaching forms: $e');
      kLog('Stack trace: $stackTrace');
      MySnackBar.showErrorToast(
        message: 'Failed to attach forms: ${e.toString()}',
      );
      return null;
    }
  }

  /// Load pending forms from Hive for a specific resource
  /// This should be called when the app starts or when switching resources
  Future<void> loadPendingFormsFromHive(String resourceId) async {
    await _loadPendingFormsFromHive(resourceId);
  }

  /// View and navigate to a form for viewing/editing
  ///
  /// Handles the complete flow of opening a form:
  /// - Validates form template structure
  /// - Loads form response data (if already submitted)
  /// - Fetches PDF as base64
  /// - Navigates to dynamic form screen
  ///
  /// [form] - The form queue item to view
  /// [loadingController] - Optional controller for loading states (defaults to self)
  Future<void> viewForm(FormQueueItem form) async {
    kLog('selected form name ${form.template.name}');
    final jsonData = form.template.structure != '';
    if (!jsonData) {
      return MySnackBar.showErrorToast(
        message: "Form template structure is empty or invalid.",
      );
    }
    final config = {
      'form': jsonDecode(form.template.structure),
      'formInstanceId': form.formInstanceId,
      'templateId': form.templateId,
      'appointmentId': form.appointmentId,
      'customerId': form.customerId,
      'queueId': form.queueId,
      'formName': form.template.name,
    };

    if (form.smartFieldData.isNotEmpty) {
      try {
        final smartFieldValues =
            jsonDecode(form.smartFieldData) as Map<String, dynamic>;
        config['smartFieldValues'] = smartFieldValues;
        kLog('SmartField values loaded: ${smartFieldValues.length} fields');
      } catch (e) {
        kLog('Error parsing smartFieldData: $e');
      }
    }

    showLoading();
    await Future.delayed(
      const Duration(milliseconds: 200),
    ); // Ensure loading shows
    try {
      // Check if form has been submitted and has a formResponseId
      if (form.formResponseId != null && form.formResponseId! > 0) {
        kLog(
          'Fetching submitted form response: formResponseId=${form.formResponseId}',
        );
        final responseData = await getFormResponse(form.formResponseId!);

        if (responseData != null) {
          config['formResponse'] = responseData;
          config['isReadOnly'] = true; // View-only mode for submitted forms
          kLog('✅ Form response data loaded');
        }
      } else if (form.instanceStatus == 'Submitted') {
        // For submitted forms from poll, use natural key (templateId + appointmentId + customerId)
        kLog(
          'Fetching submitted form by natural key: templateId=${form.templateId}, appointmentId=${form.appointmentId}, customerId=${form.customerId}',
        );
        final responseData = await getFormResponseByNaturalKey(
          templateId: form.templateId,
          appointmentId: form.appointmentId,
          customerId: form.customerId,
        );

        if (responseData != null) {
          config['formResponse'] = responseData;
          config['isReadOnly'] = true; // View-only mode for submitted forms
          kLog('✅ Form response data loaded by instance');
        }
      }

      // Construct PDF URL using pdfBaseUrl + path from template
      // Validate that pdfFile and path exist
      final pdfFile = config['form']?['pdfFile'];
      if (pdfFile == null || pdfFile['path'] == null) {
        MySnackBar.showErrorToast(message: "Form data not found");
        kLog('⚠️ Form data invalid: pdfFile or path is null');
        Future.delayed(Duration.zero, () {
          hideLoading();
        });
        return;
      }

      final pdfUrl = ApiUrl.pdfBaseUrl + pdfFile['path'];
      final pdfBase64 = await getFormPdfAsBase64(pdfUrl);

      hideLoading();

      if (pdfBase64 == null) {
        MySnackBar.showErrorToast(message: "Failed to load form PDF.");
        return;
      }

      config['pdfBase64'] = pdfBase64;
      Get.toNamed(Routes.PDF_DYNAMIC_FORM, arguments: config);
    } catch (e, s) {
      hideLoading();
      kLog(e);
      kLog(s);
      MySnackBar.showErrorToast(
        message: "Forms data not found - Error loading form: $e",
      );
    }
  }

  @override
  void onClose() {
    clearSelection();
    // Dispose email-related resources
    toTextController.dispose();
    ccTextController.dispose();
    subjectTextController.dispose();
    emailBodyTextController.dispose();
    emailToFocusnode.value.dispose();
    emailCcFocusnode.value.dispose();
    emailSubjectFocusnode.value.dispose();
    emailBodyFocusnode.value.dispose();
    super.onClose();
  }
}
