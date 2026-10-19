import 'package:get/get.dart';

import '../controllers/xplorpay_tap_to_pay_controller.dart';

class XplorPayTapToPayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<XplorPayTapToPayController>(() => XplorPayTapToPayController());
  }
}
