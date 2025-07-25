import 'package:get/get.dart';

import '../controllers/signature_controller.dart';

class SignatureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignatureGetxController>(
      () => SignatureGetxController(),
    );
  }
}
