import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/location_tracking/controllers/location_tracking_controller.dart'
    show LocationTrackingController;

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(),
    ); // 📍 Initialize Location Tracking Controller on app startup
    Get.lazyPut<LocationTrackingController>(
      () => LocationTrackingController(),
      fenix: true, // Recreate if disposed, but keep it alive
    );
  }
}
