import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../model/on_boarding_model.dart';

class OnboardingController extends GetxController {
  RxInt selectedPage = 0.obs;
  final pageController = PageController();
  final autoScrollDuration =
      const Duration(seconds: 4); // Adjust the duration as needed
  Timer? autoScrollTimer;

  /// Next
  forwardAction() {
    pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease);
  }

  /// Previous
  backwardAction() {
    pageController.previousPage(duration: 300.milliseconds, curve: Curves.ease);
  }

  /// Auto scroll
  void startAutoScroll() {
    autoScrollTimer = Timer.periodic(autoScrollDuration, (timer) {
      if (selectedPage.value < onBoardingPages.length - 1) {
        selectedPage.value++;
        pageController.animateToPage(
          selectedPage.value,
          duration: 600.milliseconds,
          curve: Curves.ease,
        );
      } else {
        autoScrollTimer?.cancel();
      }
    });
  }

  /// List of Page
  List<OnBoardingModel> onBoardingPages = [
    OnBoardingModel(
        imageAsset: Onboarding.kBoard1,
        title: 'Welcome to CEC Servco',
        subtitle: "",
        description:
            'Browse our range of services, from customer appointment scheduling to payment processing and field service management.'),
    OnBoardingModel(
        imageAsset: Onboarding.kBoard2,
        title: 'Servco Features',
        subtitle: 'Book Appointments',
        description:
            'Use the calendar to schedule appointments and manage your commitments seamlessly.'),
    OnBoardingModel(
        imageAsset: Onboarding.kBoard3,
        title: 'Servco Features',
        subtitle: 'Smoother Payment Process',
        description:
            'Use the calendar to schedule appointments and manage your commitments seamlessly.'),
    OnBoardingModel(
        imageAsset: Onboarding.kBoard4,
        title: 'Servco Features',
        subtitle: 'Manage Forms & Signatures',
        description:
            'Use the calendar to schedule appointments and manage your commitments seamlessly.'),
  ];
  @override
  void onInit() {
    super.onInit();
    startAutoScroll();
  }

  @override
  void onClose() {
    autoScrollTimer?.cancel();
    super.onClose();
  }
}
