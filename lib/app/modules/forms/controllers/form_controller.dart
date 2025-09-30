import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/my_snackbar.dart';
import 'package:xinator_fsm_pro/app/data/local/my_shared_pref.dart';
import 'package:xinator_fsm_pro/app/modules/appointment/models/appointments_form_model.dart'
    show AppointmentsFormModel;
import 'package:xinator_fsm_pro/app/modules/forms/models/form_model.dart';
import 'package:xinator_fsm_pro/app/service/REST/api_urls.dart';
import 'package:xinator_fsm_pro/app/service/REST/dio_client.dart';
import 'package:xinator_fsm_pro/app/service/helper/network_connectivity.dart'
    show NetworkConnectivity, appointmentController;

import '../../../../utils/date_converter.dart';
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
  final seeAllForms = RxList<FormModel>([]);
  final filteredTemplates = RxList<FormModel>([]);

  void updateSelectedForms(int formId) {
    if (selectedFormsIdList.contains(formId)) {
      selectedFormsIdList.remove(formId);
    } else {
      selectedFormsIdList.add(formId);
    }
  }

  void selectAttachedForms() {
    final ifOrNot = appointmentController.selectedAppointment.value == null
        ? false
        : formList
            .where((p0) =>
                p0.apptId ==
                appointmentController.selectedAppointment.value!.apptID)
            .first
            .formIds
            .isNotEmpty;

    if (ifOrNot) {
      final tempAttachedFormIds = formList
          .where((p0) =>
              p0.apptId ==
              appointmentController.selectedAppointment.value!.apptID)
          .first
          .formIds;

      // Create a Set to remove duplicates, then convert back to List
      selectedFormsIdList.assignAll(<int>{
        ...selectedFormsIdList.toSet(),
        ...tempAttachedFormIds.toSet()
      }.toList());
      update();
    } else {
      selectedFormsIdList.clear();
    }
  }

  List<AppointmentsFormModel> parseAppointmentForms(List<dynamic> jsonList) {
    return jsonList
        .map((jsonItem) => AppointmentsFormModel.fromJson(jsonItem))
        .toList();
  }

  final formList = RxList<AppointmentsFormModel>([]);
  Future<void> getAttachedForms({
    bool isRefreshed = false,
    bool isFromPeriodic = false,
  }) async {
    if (isRefreshed) showLoading();

    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = await MySharedPref.getCompanyID();
      var userID = await MySharedPref.getUserName();
      var currentDateTime = DateTime.now();

      try {
        var response = await DioClient().get(
          url: ApiUrl.getAttachedForms,
          params: {
            "appointmentTypeStatus": 2,
            "appointmentDate": dateTimeConverter(
                inputTime: currentDateTime.toString(),
                outputFormat: "yyyy/MM/dd"),
            "CompanyId": companyID,
            "userId": userID,
          },
        );

        if (response == null || (response is List && response.isEmpty)) {
          hideLoading();
          return;
        }

        if ((response as List).isNotEmpty) {
          List<AppointmentsFormModel> tempFormList =
              parseAppointmentForms(response);
          selectAttachedForms();
          formList(tempFormList);
        }
      } catch (e) {
        // ✅ Only show handleError if not from periodic
        if (!isFromPeriodic) {
          // handleError(e);
        }
      } finally {
        if (isRefreshed) hideLoading();
      }
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
          "requestPeram": {
            "AppointmentId": appointmentId,
            "CustomerId": customerId,
            "CompanyId": companyID,
            "FormIds": selectedFormsIdList,
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
      fetchTemplates();
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
