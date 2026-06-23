import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/forms/controllers/forms_controller.dart';

class FormBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormsController>(() => FormsController());
  }
}
