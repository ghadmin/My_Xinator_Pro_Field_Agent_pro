import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../models/attached_custom_field_model.dart';
import '../models/custom_field_model.dart';

class CustomFieldsController extends GetxController
    with ExceptionHandler, WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();
    log("CustomFieldsController: onInit called");
    getCustomFields();
  }

  final allCustomFields = RxList<CustomFieldModel>([]);

  final selectedCustomFields = RxList<CustomFieldModel>([]);

  final attachedCustomFields = RxList<AttachedCustomFieldModel>([]);

  /// Save custom field values to the server via POST API
  ///
  /// [appointmentId] - The appointment ID (required)
  /// [fieldsValue] - JSON string containing all custom field values (required)
  ///
  /// Example:
  /// ```dart
  /// await controller.saveCustomFieldToServer(
  ///   appointmentId: 12345,
  ///   fieldsValue: '{"Field1": "Value1", "Field2": "Value2"}',
  /// );
  /// ```

  setInitialCustomFieldValues() {}

  Future<void> saveCustomFieldToServer({
    required int appointmentId,
    required String fieldsValue,
  }) async {
    showLoading();

    try {
      if (await NetworkConnectivity.isNetworkAvailable()) {
        // Prepare the request body according to API specification
        final Map<String, dynamic> body = {
          "AppointmentId": appointmentId,
          "FeildsValue": fieldsValue,
        };

        var response = await DioClient()
            .post(url: ApiUrl.saveCustomFieldUrl, body: body)
            .catchError(handleError);

        hideLoading();

        if (response == null) {
          MySnackBar.showErrorToast(message: "Failed to save custom field.");
          return;
        }

        if (response["IsValid"] == true || response["Success"] == true) {
          log("✅ Custom field saved successfully: $response");
          MySnackBar.showToast(message: "Custom field saved successfully");

          // Refresh the custom fields list after saving
          await getCustomFields();
        } else {
          log("⚠️ Failed to save custom field: $response");
          MySnackBar.showErrorToast(
            message: response["Message"] ?? "Failed to save custom field.",
          );
        }
      } else {
        hideLoading();
        MySnackBar.showErrorToast(message: "No network connection.");
      }
    } catch (e, stackTrace) {
      hideLoading();
      log("❌ Error saving custom field: $e");
      log("❌ Stack trace: $stackTrace");
      MySnackBar.showErrorToast(
        message: "An error occurred while saving the custom field.",
      );
    }
  }

  Future<void> saveCustomField(CustomFieldModel? selectedCustomField) async {
    if (selectedCustomField == null) {
      MySnackBar.showErrorToast(message: "Please select a custom field.");
      return;
    }

    try {
      // Check if field with same fieldID already exists
      final existingField = selectedCustomFields.firstWhereOrNull(
        (field) => field.fieldID == selectedCustomField.fieldID,
      );

      if (existingField != null) {
        return;
      }

      // Add the selected custom field to a list
      selectedCustomFields.add(selectedCustomField);
    } catch (e) {
      log("Error adding custom field: $e");
      MySnackBar.showErrorToast(
        message: "An error occurred while adding the custom field.",
      );
    }
  }

  Future<void> getCustomFields() async {
    log("getCustomFields: Starting to fetch custom fields...");
    // showLoading();
    try {
      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = await MySharedPref.getCompanyID();
        log("getCustomFields: CompanyID = $companyID");

        var response = await DioClient().get(
          url: ApiUrl.getCustomFieldsUrl,
          params: {"companyId": companyID},
        ).catchError(handleError);

        log("getCustomFields: Response = $response");

        if (response == null || response.isEmpty) {
          log("getCustomFields: Response is null or empty");
          return;
        }

        final List<CustomFieldModel> customFields = (response as List)
            .map((e) => CustomFieldModel.fromJson(e as Map<String, dynamic>))
            .toList();

        allCustomFields.value = customFields;

        // Process or store the custom fields as needed
        log("✅ Custom Fields loaded successfully: ${customFields.length} fields");
      } else {
        log("❌ getCustomFields: No network connection");
        MySnackBar.showErrorToast(message: "No network connection.");
      }
    } catch (e, stackTrace) {
      log("❌ Error fetching custom fields: $e");
      log("❌ Stack trace: $stackTrace");
    } finally {
      // hideLoading();
    }
  }

  /// Get attached custom fields for a specific appointment
  ///
  /// [appointmentId] - The appointment ID (required)
  /// [fieldId] - The field ID (optional, defaults to 0)
  ///
  /// Example:
  /// ```dart
  /// await controller.getAttachedCustomFields(
  ///   appointmentId: 12345,
  ///   fieldId: 0,
  /// );
  /// ```
  Future<void> getAttachedCustomFields({
    required int appointmentId,
    int fieldId = 0,
  }) async {
    log("getAttachedCustomFields: Starting to fetch attached custom fields...");
    try {
      showLoading();
      if (await NetworkConnectivity.isNetworkAvailable()) {
        var response = await DioClient().get(
          url: ApiUrl.getAttachedCustomFieldsUrl,
          params: {
            "appointmentId": appointmentId,
            "fieldId": fieldId,
          },
        ).catchError(handleError);

        log("getAttachedCustomFields: Response = $response");

        if (response == null || response.isEmpty) {
          log("getAttachedCustomFields: Response is null or empty");
          attachedCustomFields.value = [];
          selectedCustomFields.clear();
          appointmentController.customFieldTextController.value.clear();
          appointmentController.customFieldDropdownValue.value = '';
          appointmentController.customFieldChecklistValues.clear();
          return;
        }

        final List<AttachedCustomFieldModel> customFields = (response as List)
            .map((e) =>
                AttachedCustomFieldModel.fromJson(e as Map<String, dynamic>))
            .toList();

        if (customFields.isNotEmpty) {
          attachedCustomFields.value = customFields;

          // Clear previously selected fields
          selectedCustomFields.clear();

          // Process each attached field
          for (var attachedField in attachedCustomFields) {
            // Find matching field definition from allCustomFields
            var fieldDef = allCustomFields.firstWhereOrNull(
              (f) => f.fieldID == attachedField.fieldID,
            );

            if (fieldDef != null) {
              // Create a new instance of the field
              var newField = CustomFieldModel(
                fieldID: fieldDef.fieldID,
                fieldName: fieldDef.fieldName,
                fieldType: fieldDef.fieldType,
                fieldOptions: fieldDef.fieldOptions,
                isActive: fieldDef.isActive,
                options: fieldDef.options,
              );

              // Set the value based on field type and attached field value
              switch (fieldDef.fieldType) {
                case 'text':
                  newField.textValue = attachedField.fieldValue;
                  appointmentController.customFieldTextController.value.text =
                      attachedField.fieldValue!;
                  break;
                case 'number':
                  newField.numberValue = attachedField.fieldValue;
                  break;
                case 'dropdown':
                  newField.selectedValue = attachedField.fieldValue;
                  appointmentController.customFieldDropdownValue.value =
                      attachedField.fieldValue ?? '';
                  break;
                case 'checklist':
                  // For checklist, FieldValue is a JSON array string like "[\"option1\",\"option2\"]"
                  newField.selectedOptions =
                      attachedField.getFieldValueAsList();
                  appointmentController.customFieldChecklistValues.value =
                      newField.selectedOptions ?? [];
                  break;
              }

              // Add to selected fields
              selectedCustomFields.add(newField);
            }
          }
        } else {
          attachedCustomFields.value = [];
          selectedCustomFields.clear();
        }

        // Process or store the custom fields as needed
        log("✅ Attached Custom Fields loaded successfully: ${customFields.length} fields");
      } else {
        log("❌ getAttachedCustomFields: No network connection");
        MySnackBar.showErrorToast(message: "No network connection.");
      }
    } catch (e, stackTrace) {
      log("❌ Error fetching attached custom fields: $e");
      log("❌ Stack trace: $stackTrace");
    } finally {
      hideLoading();
    }
  }

  /// Save attached custom fields for an appointment
  ///
  /// [appointmentId] - The appointment ID (required)
  ///
  /// Example:
  /// ```dart
  /// await controller.saveAttachedCustomFields(
  ///   appointmentId: 101,
  /// );
  /// ```
  Future<void> saveAttachedCustomFields({
    required int appointmentId,
  }) async {
    if (selectedCustomFields.isEmpty) {
      log("saveAttachedCustomFields: No custom fields to save");
      return;
    }

    showLoading();

    try {
      if (await NetworkConnectivity.isNetworkAvailable()) {
        // Build the fields array from selectedCustomFields
        List<Map<String, dynamic>> fields = selectedCustomFields.map((field) {
          String fieldValue = '';

          // Format the field value based on field type
          switch (field.fieldType) {
            case 'checklist':
              // Convert selected options to JSON array string
              // Example: "[\"Bring diagnostic scanner\",\"Bring multimeter/testing tools\",\"Bring safety equipment\"]"
              fieldValue = jsonEncode(field.selectedOptions ?? []);
              break;
            case 'dropdown':
              fieldValue = field.selectedValue ?? '';
              break;
            case 'text':
              fieldValue = field.textValue ?? '';
              break;
            case 'number':
              fieldValue = field.numberValue ?? '';
              break;
            default:
              fieldValue = '';
          }

          return {
            "AppointmentID": appointmentId,
            "FieldID": field.fieldID,
            "FieldValue": fieldValue,
          };
        }).toList();

        // Prepare the request body
        final Map<String, dynamic> body = {
          "fields": fields,
        };

        log("saveAttachedCustomFields: Request body = ${jsonEncode(body)}");

        var response = await DioClient()
            .post(url: ApiUrl.saveAttachedCustomFieldsUrl, body: body)
            .catchError(handleError);

        hideLoading();

        if (response == null) {
          MySnackBar.showErrorToast(message: "Failed to save custom fields.");
          return;
        } else {
          log("✅ Custom fields saved successfully: $response");
          MySnackBar.showToast(message: "Custom fields saved successfully");

          // Clear selected fields after successful save
          selectedCustomFields.clear();

          // Refresh the attached fields list after saving
          await getAttachedCustomFields(appointmentId: appointmentId);
        }
      } else {
        hideLoading();
        MySnackBar.showErrorToast(message: "No network connection.");
      }
    } catch (e, stackTrace) {
      hideLoading();
      log("❌ Error saving custom fields: $e");
      log("❌ Stack trace: $stackTrace");
      MySnackBar.showErrorToast(
        message: "An error occurred while saving custom fields.",
      );
    }
  }
}
