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
}
