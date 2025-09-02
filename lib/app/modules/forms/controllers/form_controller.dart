import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/my_snackbar.dart';
import 'package:xinator_fsm_pro/app/data/local/my_shared_pref.dart';
import 'package:xinator_fsm_pro/app/modules/forms/models/form_model.dart';
import 'package:xinator_fsm_pro/app/service/REST/api_urls.dart';
import 'package:xinator_fsm_pro/app/service/REST/dio_client.dart';

import '../../../service/handler/exception_handler.dart';
import '../models/create_new_form_template_model.dart';

class FormController extends GetxController with ExceptionHandler {
  final searchQuery = RxString(''); // 👈 reactive search query
  final createNewFormData = Rx<CreateNewFormModel?>(CreateNewFormModel());
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchTemplates();
  // }
  @override
  void onReady() {
    super.onReady();
    fetchTemplates();
  }

  final formModels = RxList<FormModel>([]);
  final selectedFormsIdList = RxList<int>([]);
  void updateSelectedForms(int formId) {
    if (selectedFormsIdList.contains(formId)) {
      selectedFormsIdList.remove(formId);
    } else {
      selectedFormsIdList.add(formId);
    }
  }

  Future<void> assignFormsToAppointment(
      String customerId, String appointmentId) async {
    showLoading();

    try {
      final companyID = await MySharedPref.getCompanyID();

      final userId = await MySharedPref.getUserName();

      final response = await DioClient().post(
        url: ApiUrl.assignFormUrl, // <-- create endpoint in ApiUrl
        body: {
          "requestPerams": {
            "AppointmentId": appointmentId,
            "CustomerId": customerId,
            "CompanyId": companyID,
            "FormIds": selectedFormsIdList.toString(),
            "UserId": userId,
          }
        },
      ).catchError(handleError);

      log("assignForms response ${jsonEncode(response)}");

      if (response == null) return;

      hideLoading();
      MySnackBar.showToast(message: "Forms assigned successfully");
    } catch (e) {
      hideLoading();
      MySnackBar.showToast(message: "Failed to assign forms: $e");
    }
  }

  Future<void> saveFormTemplate() async {
    showLoading();

    try {
      final companyID = await MySharedPref.getCompanyID();

      final response = await DioClient().post(
        url: ApiUrl.saveFormUrl,
        body: {
          "requestPeram": {
            "CompanyID": companyID,
            "TemplateName": createNewFormData.value!.templateName,
            "Category": createNewFormData.value!.category,
            "Description": createNewFormData.value!.description,
            "RequireSignature": createNewFormData.value!.signature,
            "RequireTip": createNewFormData.value!.tpCapture,
            "IsAutoAssignEnabled":
                createNewFormData.value!.autoAssignAppointment,
            "IsActive": createNewFormData.value!.isActive,
            "FormStructure": "test"
          }
        },
      ).catchError(handleError);
      log("save data ${jsonEncode(response)}");
      if (response == null) return;

      hideLoading();
      Get.back();
      MySnackBar.showToast(message: "Form saved successfully");
    } catch (e) {
      hideLoading();
      MySnackBar.showToast(message: "Failed to save form: $e");
    }
  }

  Future<void> updateFormTemplate() async {
    showLoading();

    try {
      final companyID = await MySharedPref.getCompanyID();

      final response = await DioClient().post(
        url: ApiUrl.updateFormUrl,
        body: {
          "requestPeram": {
            "Id": createNewFormData.value!.id,
            "CompanyID": companyID,
            "TemplateName": createNewFormData.value!.templateName,
            "Category": createNewFormData.value!.category,
            "Description": createNewFormData.value!.description,
            "RequireSignature": createNewFormData.value!.signature,
            "RequireTip": createNewFormData.value!.tpCapture,
            "IsAutoAssignEnabled":
                createNewFormData.value!.autoAssignAppointment,
            "FormStructure": "test",
            "IsActive": createNewFormData.value!.isActive,
          }
        },
      ).catchError(handleError);
      log("save data ${jsonEncode(response)}");
      if (response == null) return;

      hideLoading();
      Get.back();

      MySnackBar.showToast(message: "Form saved successfully");
      fetchTemplates();
    } catch (e) {
      hideLoading();
      MySnackBar.showToast(message: "Failed to save form: $e");
    }
  }

  Future<void> isActiveUpdate(FormModel template) async {
    showLoading();

    try {
      final companyID = await MySharedPref.getCompanyID();

      final response = await DioClient().post(
        url: ApiUrl.updateFormUrl,
        body: {
          "requestPeram": {
            "Id": createNewFormData.value!.id,
            "CompanyID": companyID,
            "TemplateName": createNewFormData.value!.templateName,
            "Category": createNewFormData.value!.category,
            "Description": createNewFormData.value!.description,
            "RequireSignature": createNewFormData.value!.signature,
            "RequireTip": createNewFormData.value!.tpCapture,
            "IsAutoAssignEnabled":
                createNewFormData.value!.autoAssignAppointment,
            "FormStructure": "test",
            "IsActive": template.isActive != null
                ? template.isActive!
                    ? false
                    : true
                : true,
          }
        },
      ).catchError(handleError);
      log("save data ${jsonEncode(response)}");
      if (response == null) return;
      fetchTemplates();
      hideLoading();
      MySnackBar.showToast(message: "Form saved successfully");
    } catch (e) {
      hideLoading();
      MySnackBar.showToast(message: "Failed to save form: $e");
    }
  }

  Future<void> fetchTemplates() async {
    try {
      showLoading();
      var companyID = await MySharedPref.getCompanyID();
      var response = await DioClient().get(
        url: ApiUrl.getFormTypeUrl,
        params: {"companyId": companyID},
      ).catchError(handleError);
      log("response of all templates $response");
      if (response != null) {
        // Assuming the response is a list of template names
        // Adjust this based on your actual API response structure
        formModels.clear();
        final resData = response as List<dynamic>;
        final tempData =
            resData.map((item) => FormModel.fromJson(item)).toList();
        formModels.assignAll(tempData);
        log(
          "Templates fetched successfully: ${formModels.length}",
          name: "FormController",
        );
      } else {
        print("Failed to fetch templates: ${response?.statusMessage}");
      }

      // // TODO: Confirm the XML structure
      // final items = document.findAllElements("FormTemplate");

      // templates.value = items
      //     .map((node) => node.getElement("FormName")?.innerText ?? "Unnamed")
      //     .toList();
      hideLoading();
    } catch (e, s) {
      hideLoading();
      print("Error fetching templates: $e");
      print("Error fetching templates: $s");
    }
  }
}
