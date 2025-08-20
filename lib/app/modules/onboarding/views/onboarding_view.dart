// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';

// import '../../../../config/theme/light_theme_colors.dart';
// import '../../../components/global-widgets/my_buttons.dart';
// import '../../../routes/app_pages.dart';
// import '../controllers/onboarding_controller.dart';

// class OnboardingView extends GetView<OnboardingController> {
//   const OnboardingView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     return Scaffold(
//       backgroundColor: theme.primaryColor,
//       body: SafeArea(
//         child: LayoutBuilder(builder: (context, constraints) {
//           if (constraints.maxWidth > 599) {
//             return Obx(() => Stack(
//                   children: [
//                     Positioned(
//                       bottom: 0,
//                       left: 0,
//                       right: 0,
//                       top: 100.h,
//                       child: Container(
//                         height: double.infinity,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(30.r),
//                             topRight: Radius.circular(30.r),
//                           ),
//                         ),
//                       ),
//                     ),
//                     PageView.builder(
//                       controller: controller.pageController,
//                       onPageChanged: controller.selectedPage.call,
//                       itemCount: controller.onBoardingPages.length,
//                       itemBuilder: (context, index) {
//                         return controller.onBoardingPages.isEmpty
//                             ? Center(
//                                 child: CircularProgressIndicator(
//                                   color: theme.primaryColor,
//                                 ),
//                               )
//                             : Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   SizedBox(height: 150.sp),
//                                   Container(
//                                     height: 140.h,
//                                     width: 180.w,
//                                     decoration: BoxDecoration(
//                                         image: DecorationImage(
//                                       image: AssetImage(controller
//                                           .onBoardingPages[index].imageAsset),
//                                       fit: BoxFit.fill,
//                                     )),
//                                   ),
//                                   SizedBox(height: 30.sp),
//                                   Padding(
//                                     padding:
//                                         EdgeInsets.symmetric(horizontal: 25.sp),
//                                     child: SizedBox(
//                                       width: 300.w,
//                                       child:  TextWidget(text:
//                                         controller.onBoardingPages[index].title,
//                                         style: TextStyle(
//                                           fontSize: 20.sp,
//                                           fontWeight: FontWeight.w900,
//                                           height: 1.4,
//                                           color: LightThemeColors.bodyTextColor,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                   controller.onBoardingPages[index].subtitle
//                                           .isEmpty
//                                       ? SizedBox(height: 40.sp)
//                                       : Column(
//                                           children: [
//                                             SizedBox(height: 10.sp),
//                                             SizedBox(
//                                               width: 300.w,
//                                               child:  TextWidget(text:
//                                                 controller
//                                                     .onBoardingPages[index]
//                                                     .subtitle,
//                                                 style: TextStyle(
//                                                   fontSize: 14.sp,
//                                                   fontWeight: FontWeight.w700,
//                                                   height: 1.4,
//                                                   color: LightThemeColors
//                                                       .bodyTextSecondaryColor,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               ),
//                                             ),
//                                             SizedBox(height: 10.sp),
//                                           ],
//                                         ),
//                                   SizedBox(
//                                     width: 300.w,
//                                     child:  TextWidget(text:
//                                       controller
//                                           .onBoardingPages[index].description,
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 12.sp,
//                                         fontWeight: FontWeight.w500,
//                                         color: LightThemeColors
//                                             .bodyTextSecondaryColor,
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                       },
//                     ),
//                     Positioned(
//                       bottom: 150.h,
//                       left: 130.w,
//                       child: Row(
//                         children: List.generate(
//                             controller.onBoardingPages.length,
//                             (index) => Container(
//                                   margin:
//                                       const EdgeInsets.symmetric(horizontal: 3),
//                                   height: 4,
//                                   width: 20.sp,
//                                   decoration: BoxDecoration(
//                                     color:
//                                         controller.selectedPage.value == index
//                                             ? theme.primaryColor
//                                             : theme.primaryColor
//                                                 .withValues(alpha: 0.2),
//                                     borderRadius: BorderRadius.circular(30.r),
//                                     shape: BoxShape.rectangle,
//                                   ),
//                                 )),
//                       ),
//                     ),
//                     Positioned(
//                       top: 40.sp,
//                       right: 0,
//                       child: SizedBox(
//                         width: 80.sp,
//                         height: 40.sp,
//                         child: TextButton(
//                           onPressed: () {
//                             Get.offAllNamed(Routes.LOGIN);
//                           },
//                           child:  TextWidget(text:
//                             "Skip",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16.sp,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 40.sp,
//                       left: 0,
//                       right: 0,
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 25.sp),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             controller.selectedPage.value > 0
//                                 ? SizedBox(
//                                     width: 120.sp,
//                                     height: 42.sp,
//                                     child: PrimaryButton(
//                                       title: 'Previous',
//                                       onPressed: () {
//                                         controller.backwardAction();
//                                       },
//                                       inactive: false,
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                             SizedBox(
//                               width: 120.sp,
//                               height: 42.sp,
//                               child: PrimaryButton(
//                                 title: controller.selectedPage.value >
//                                         controller.onBoardingPages.length - 2
//                                     ? "Go!"
//                                     : "Next",
//                                 onPressed: () {
//                                   if (controller.selectedPage.value >
//                                       controller.onBoardingPages.length - 2) {
//                                     Get.offAllNamed(Routes.LOGIN);
//                                   } else {
//                                     controller.forwardAction();
//                                   }
//                                 },
//                                 inactive: false,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ));
//           } else if (constraints.maxWidth > 374 && constraints.maxWidth < 430) {
//             return Obx(() => Stack(
//                   children: [
//                     Positioned(
//                       bottom: 0,
//                       left: 0,
//                       right: 0,
//                       top: 100.h,
//                       child: Container(
//                         height: double.infinity,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(30.r),
//                             topRight: Radius.circular(30.r),
//                           ),
//                         ),
//                       ),
//                     ),
//                     PageView.builder(
//                       controller: controller.pageController,
//                       onPageChanged: controller.selectedPage.call,
//                       itemCount: controller.onBoardingPages.length,
//                       itemBuilder: (context, index) {
//                         return controller.onBoardingPages.isEmpty
//                             ? Center(
//                                 child: CircularProgressIndicator(
//                                   color: theme.primaryColor,
//                                 ),
//                               )
//                             : Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   SizedBox(height: 150.sp),
//                                   Container(
//                                     height: 140.h,
//                                     width: 180.w,
//                                     decoration: BoxDecoration(
//                                         image: DecorationImage(
//                                       image: AssetImage(controller
//                                           .onBoardingPages[index].imageAsset),
//                                       fit: BoxFit.fill,
//                                     )),
//                                   ),
//                                   SizedBox(height: 30.sp),
//                                   Padding(
//                                     padding:
//                                         EdgeInsets.symmetric(horizontal: 25.sp),
//                                     child: SizedBox(
//                                       width: 300.w,
//                                       child:  TextWidget(text:
//                                         controller.onBoardingPages[index].title,
//                                         style: TextStyle(
//                                           fontSize: 20.sp,
//                                           fontWeight: FontWeight.w900,
//                                           height: 1.4,
//                                           color: LightThemeColors.bodyTextColor,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                   controller.onBoardingPages[index].subtitle
//                                           .isEmpty
//                                       ? SizedBox(height: 40.sp)
//                                       : Column(
//                                           children: [
//                                             SizedBox(height: 10.sp),
//                                             SizedBox(
//                                               width: 300.w,
//                                               child:  TextWidget(text:
//                                                 controller
//                                                     .onBoardingPages[index]
//                                                     .subtitle,
//                                                 style: TextStyle(
//                                                   fontSize: 14.sp,
//                                                   fontWeight: FontWeight.w700,
//                                                   height: 1.4,
//                                                   color: LightThemeColors
//                                                       .bodyTextSecondaryColor,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               ),
//                                             ),
//                                             SizedBox(height: 10.sp),
//                                           ],
//                                         ),
//                                   SizedBox(
//                                     width: 300.w,
//                                     child:  TextWidget(text:
//                                       controller
//                                           .onBoardingPages[index].description,
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 12.sp,
//                                         fontWeight: FontWeight.w500,
//                                         color: LightThemeColors
//                                             .bodyTextSecondaryColor,
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                       },
//                     ),
//                     Positioned(
//                       bottom: 150.h,
//                       left: 130.w,
//                       child: Row(
//                         children: List.generate(
//                             controller.onBoardingPages.length,
//                             (index) => Container(
//                                   margin:
//                                       const EdgeInsets.symmetric(horizontal: 3),
//                                   height: 4,
//                                   width: 20.sp,
//                                   decoration: BoxDecoration(
//                                     color:
//                                         controller.selectedPage.value == index
//                                             ? theme.primaryColor
//                                             : theme.primaryColor
//                                                 .withValues(alpha: 0.2),
//                                     borderRadius: BorderRadius.circular(30.r),
//                                     shape: BoxShape.rectangle,
//                                   ),
//                                 )),
//                       ),
//                     ),
//                     Positioned(
//                       top: 40.sp,
//                       right: 0,
//                       child: SizedBox(
//                         width: 80.sp,
//                         height: 40.sp,
//                         child: TextButton(
//                           onPressed: () {
//                             Get.offAllNamed(Routes.LOGIN);
//                           },
//                           child:  TextWidget(text:
//                             "Skip",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16.sp,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 40.sp,
//                       left: 0,
//                       right: 0,
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 25.sp),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             controller.selectedPage.value > 0
//                                 ? SizedBox(
//                                     width: 120.sp,
//                                     height: 42.sp,
//                                     child: PrimaryButton(
//                                       title: 'Previous',
//                                       onPressed: () {
//                                         controller.backwardAction();
//                                       },
//                                       inactive: false,
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                             SizedBox(
//                               width: 120.sp,
//                               height: 42.sp,
//                               child: PrimaryButton(
//                                 title: controller.selectedPage.value >
//                                         controller.onBoardingPages.length - 2
//                                     ? "Go!"
//                                     : "Next",
//                                 onPressed: () {
//                                   if (controller.selectedPage.value >
//                                       controller.onBoardingPages.length - 2) {
//                                     Get.offAllNamed(Routes.LOGIN);
//                                   } else {
//                                     controller.forwardAction();
//                                   }
//                                 },
//                                 inactive: false,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ));
//           } else {
//             return Obx(() => Stack(
//                   children: [
//                     Positioned(
//                       bottom: 0,
//                       left: 0,
//                       right: 0,
//                       top: 100.h,
//                       child: Container(
//                         height: double.infinity,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(30.r),
//                             topRight: Radius.circular(30.r),
//                           ),
//                         ),
//                       ),
//                     ),
//                     PageView.builder(
//                       controller: controller.pageController,
//                       onPageChanged: controller.selectedPage.call,
//                       itemCount: controller.onBoardingPages.length,
//                       itemBuilder: (context, index) {
//                         return controller.onBoardingPages.isEmpty
//                             ? Center(
//                                 child: CircularProgressIndicator(
//                                   color: theme.primaryColor,
//                                 ),
//                               )
//                             : Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   SizedBox(height: 200.sp),
//                                   Container(
//                                     height: 200.h,
//                                     width: 300.w,
//                                     decoration: BoxDecoration(
//                                         image: DecorationImage(
//                                       image: AssetImage(controller
//                                           .onBoardingPages[index].imageAsset),
//                                       fit: BoxFit.fill,
//                                     )),
//                                   ),
//                                   SizedBox(height: 40.sp),
//                                   Padding(
//                                     padding:
//                                         EdgeInsets.symmetric(horizontal: 25.sp),
//                                     child: SizedBox(
//                                       width: 300.w,
//                                       child:  TextWidget(text:
//                                         controller.onBoardingPages[index].title,
//                                         style: TextStyle(
//                                           fontSize: 30.sp,
//                                           fontWeight: FontWeight.w900,
//                                           height: 1.4,
//                                           color: LightThemeColors.bodyTextColor,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                   controller.onBoardingPages[index].subtitle
//                                           .isEmpty
//                                       ? SizedBox(height: 40.sp)
//                                       : Column(
//                                           children: [
//                                             SizedBox(height: 20.sp),
//                                             SizedBox(
//                                               width: 300.w,
//                                               child:  TextWidget(text:
//                                                 controller
//                                                     .onBoardingPages[index]
//                                                     .subtitle,
//                                                 style: TextStyle(
//                                                   fontSize: 18.sp,
//                                                   fontWeight: FontWeight.w700,
//                                                   height: 1.4,
//                                                   color: LightThemeColors
//                                                       .bodyTextSecondaryColor,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               ),
//                                             ),
//                                             SizedBox(height: 20.sp),
//                                           ],
//                                         ),
//                                   SizedBox(
//                                     width: 300.w,
//                                     child:  TextWidget(text:
//                                       controller
//                                           .onBoardingPages[index].description,
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 14.sp,
//                                         fontWeight: FontWeight.w500,
//                                         color: LightThemeColors
//                                             .bodyTextSecondaryColor,
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                       },
//                     ),
//                     Positioned(
//                       bottom: 130.h,
//                       left: 160.w,
//                       child: Row(
//                         children: List.generate(
//                             controller.onBoardingPages.length,
//                             (index) => Container(
//                                   margin:
//                                       const EdgeInsets.symmetric(horizontal: 3),
//                                   height: 4,
//                                   width: 20.sp,
//                                   decoration: BoxDecoration(
//                                     color:
//                                         controller.selectedPage.value == index
//                                             ? theme.primaryColor
//                                             : theme.primaryColor
//                                                 .withValues(alpha: 0.2),
//                                     borderRadius: BorderRadius.circular(30.r),
//                                     shape: BoxShape.rectangle,
//                                   ),
//                                 )),
//                       ),
//                     ),
//                     Positioned(
//                       top: 40.sp,
//                       right: 0,
//                       child: SizedBox(
//                         width: 80.sp,
//                         height: 40.sp,
//                         child: TextButton(
//                           onPressed: () {
//                             Get.offAllNamed(Routes.LOGIN);
//                           },
//                           child:  TextWidget(text:
//                             "Skip",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16.sp,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 40.sp,
//                       left: 0,
//                       right: 0,
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 25.sp),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             controller.selectedPage.value > 0
//                                 ? SizedBox(
//                                     width: 120.sp,
//                                     height: 40.sp,
//                                     child: PrimaryButton(
//                                       title: 'Previous',
//                                       onPressed: () {
//                                         controller.backwardAction();
//                                       },
//                                       inactive: false,
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                             SizedBox(
//                               width: 120.sp,
//                               height: 40.sp,
//                               child: PrimaryButton(
//                                 title: controller.selectedPage.value >
//                                         controller.onBoardingPages.length - 2
//                                     ? "Go!"
//                                     : "Next",
//                                 onPressed: () {
//                                   if (controller.selectedPage.value >
//                                       controller.onBoardingPages.length - 2) {
//                                     Get.offAllNamed(Routes.LOGIN);
//                                   } else {
//                                     controller.forwardAction();
//                                   }
//                                 },
//                                 inactive: false,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ));
//           }
//         }),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/constants.dart';
import '../../../components/global-widgets/my_buttons.dart';
import '../../../routes/app_pages.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
        backgroundColor: theme.primaryColor,
        body: SafeArea(
          child: Column(children: [
            SizedBox(
              height: 40.h,
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30.sp),
                    SizedBox(
                      height: 200.h,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 241.h,
                              width: 259.w,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(Onboarding.kBoard1),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 20.w,
                            top: 55.h,
                            child: Container(
                              height: 45.h,
                              width: 45.w,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(Onboarding.kBoard2),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.sp),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.sp),
                      child: SizedBox(
                        width: 300.w,
                        child: TextWidget(
                          text: "Welcome to",
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.4,
                            color: LightThemeColors.buttonDisabledColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    SizedBox(
                      width: 300.w,
                      child: TextWidget(
                        text: "XinatorBMS FA PRO",
                        style: TextStyle(
                          fontSize: 29.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          color: LightThemeColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.sp),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextWidget(
                          text:
                              "XinatorBMS FA Pro is a modular ERP built for service-first small businesses. It helps automate customer-focused operations with simplicity and control.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: LightThemeColors.bodyTextSecondaryColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.sp, vertical: 20.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              // width: 120.sp,
                              height: 60.sp,
                              child: PrimaryButton(
                                fontColor:
                                    LightThemeColors.buttonDisabledTextColor,
                                borderColor:
                                    LightThemeColors.buttonDisabledTextColor,
                                backgroundColor: LightThemeColors.fillColor,
                                title: 'Skip',
                                onPressed: () {
                                  Get.offAllNamed(Routes.LOGIN);
                                },
                                inactive: false,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            child: SizedBox(
                              // width: 120.sp,
                              height: 60.sp,
                              child: PrimaryButton(
                                fontColor: LightThemeColors.fillColor,
                                backgroundColor: LightThemeColors.buttonColor,
                                title: 'Next',
                                onPressed: () {
                                  Get.offAllNamed(Routes.LOGIN);
                                },
                                inactive: false,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }
}
