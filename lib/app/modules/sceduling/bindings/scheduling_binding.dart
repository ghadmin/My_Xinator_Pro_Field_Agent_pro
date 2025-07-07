import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/modules/sceduling/controllers/scheduling_controller.dart';

class SchedulingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SchedulingController>(
      () => SchedulingController(),
    );
  }
}
