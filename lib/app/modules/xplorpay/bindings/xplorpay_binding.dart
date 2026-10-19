import 'package:get/get.dart';

import '../controllers/xplorpay_terminal_controller.dart';

class XplorPayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<XplorPayTerminalController>(() => XplorPayTerminalController());
  }
}
