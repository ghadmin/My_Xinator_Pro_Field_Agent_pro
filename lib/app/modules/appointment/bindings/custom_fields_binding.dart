import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import '../controllers/custom_fields_controller.dart';

class CustomFieldsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CustomFieldsController>(
      CustomFieldsController(),
    );
  }
}
