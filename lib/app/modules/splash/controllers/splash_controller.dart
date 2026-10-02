import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../routes/app_pages.dart';
import '../../../../utils/responsive.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animationController.forward();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 4), () async {
      var companyID = MySharedPref.getCompanyID();
      var email = MySharedPref.getEmail();
      if (companyID != null && companyID != "") {
        // Tablets open the landing shell (menu rail + swappable pane);
        // phones keep the plain appointments screen.
        Get.offAllNamed(
          AppDevice.isTabletDevice ? Routes.TABLET_SHELL : Routes.APPOINTMENT,
        );
        // Location tracking auto-starts after appointments load (see
        // AppointmentController._triggerLocationTrackingOnce) so the
        // resource id is available
      } else if ((companyID == null || companyID == "") &&
          (email != null && email != "")) {
        Get.offAllNamed(Routes.LOGIN);
      } else if ((companyID == null || companyID == "") &&
          (email == null || email == "")) {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  @override
  void onReady() {
    _navigateToNextScreen();
    super.onReady();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
