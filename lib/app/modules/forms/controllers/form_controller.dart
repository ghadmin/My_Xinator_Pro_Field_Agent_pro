import 'dart:developer';

import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/data/local/my_shared_pref.dart';
import 'package:xinator_fsm_pro/app/modules/forms/models/form_model.dart';
import 'package:xinator_fsm_pro/app/service/REST/api_urls.dart';
import 'package:xinator_fsm_pro/app/service/REST/dio_client.dart';

import '../../../service/handler/exception_handler.dart';

class FormController extends GetxController with ExceptionHandler {
  var isLoading = true.obs;
  final searchQuery = RxString(''); // 👈 reactive search query

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTemplates();
  }

  final formModels = RxList<FormModel>([]);
  Future<void> fetchTemplates() async {
    try {
      var companyID = await MySharedPref.getCompanyID();
      var response = await DioClient().get(
        url: ApiUrl.getFormTypeUrl,
        params: {"companyId": companyID},
      ).catchError(handleError);

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

      isLoading.value = false;
    } catch (e, s) {
      print("Error fetching templates: $e");
      print("Error fetching templates: $s");
      isLoading.value = false;
    }
  }
}
