import 'package:get/get.dart';
import '../controllers/scheduling_controller.dart';

class SchedulingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SchedulingController>(() => SchedulingController());
  }
}
