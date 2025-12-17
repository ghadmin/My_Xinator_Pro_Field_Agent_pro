import 'package:get/get.dart';

import '../controllers/form_controller.dart';

class FormBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FormController>(FormController());
  }
}
