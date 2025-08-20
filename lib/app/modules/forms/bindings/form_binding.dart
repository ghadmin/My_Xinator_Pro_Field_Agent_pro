import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/modules/forms/controllers/form_controller.dart';

class FormBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FormController>(
      FormController(),
    );
  }
}
