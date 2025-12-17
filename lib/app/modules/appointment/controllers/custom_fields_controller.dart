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
  onReady() {
    super.onReady();
    getCustomFields();
  }

  final allCustomFields = RxList<CustomFieldModel>([]);

  final selectedCustomFields = RxList<CustomFieldModel>([]);
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
    // showLoading();
    try {
      if (await NetworkConnectivity.isNetworkAvailable()) {
        var companyID = await MySharedPref.getCompanyID();

        var response = await DioClient()
            .get(
              url: ApiUrl.getCustomFieldsUrl,
              params: {"companyId": companyID},
            )
            .catchError(handleError);

        if (response == null || response.isEmpty) {
          MySnackBar.showErrorToast(message: "No custom fields found.");
          return;
        }

        final List<CustomFieldModel> customFields = (response as List)
            .map((e) => CustomFieldModel.fromJson(e as Map<String, dynamic>))
            .toList();

        allCustomFields.value = customFields;

        // Process or store the custom fields as needed
        log("Custom Fields: ${customFields.length}");
      } else {
        MySnackBar.showErrorToast(message: "No network connection.");
      }
    } catch (e) {
      log("Error fetching custom fields: $e");
    } finally {
      // hideLoading();
    }
  }
}
