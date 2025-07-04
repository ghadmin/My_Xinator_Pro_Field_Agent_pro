import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Centered Logo Animation
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: controller.animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, controller.animation.value * 400.h),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    AppImages.kCECIcon,
                    width: 180.sp,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            // Branding Animation
            AnimatedBuilder(
              animation: controller.animation,
              builder: (context, child) {
                return Opacity(
                  opacity: 1.0 - controller.animation.value,
                  child: Transform.translate(
                    offset: Offset(0, 50.h * controller.animation.value),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 30.h),
                child: Image.asset(
                  AppImages.kCECBrand,
                  width: 130.sp,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
