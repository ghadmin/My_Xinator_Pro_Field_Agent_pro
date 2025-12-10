import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:xinator_fsm_pro/app/modules/appointment/controllers/custom_fields_controller.dart';

class CustomFieldsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomFieldsController>(() {
      final controller = CustomFieldsController();
      controller.getCustomFields(); // Automatically call getCustomFields
      return controller;
    });
  }
}
