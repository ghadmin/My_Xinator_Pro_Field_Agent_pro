import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../routes/app_pages.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';

class AuthController extends GetxController with ExceptionHandler {
  final TextEditingController emailLoginTextController =
      TextEditingController(text: MySharedPref.getEmail() ?? "");
  final TextEditingController passwordLoginTextController =
      TextEditingController();
  final TextEditingController emailSignupTextController =
      TextEditingController();
  final TextEditingController passwordSignupTextController =
      TextEditingController();
  final TextEditingController fullNameTextController = TextEditingController();

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode signEmailFocusNode = FocusNode();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode signPasswordFocusNode = FocusNode();
  RxString emailValidator = "".obs;
  RxString passwordValidator = "".obs;
  RxBool isPasswordVisible = false.obs;
  RxBool isButtonActive = false.obs;
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  final isTextFieldFocused = false.obs;

  void setTextFieldFocus(bool isFocused) {
    isTextFieldFocused.value = isFocused;
  }

  @override
  void onInit() {
    super.onInit();

    emailLoginTextController.addListener(_validateForm);

    passwordLoginTextController.addListener(_validateForm);
  }

  void _validateForm() {
    isButtonActive.value = emailLoginTextController.text.isNotEmpty &&
        passwordLoginTextController.text.isNotEmpty;
  }

  ///                 API         ///

  Future<void> storeUserData(dynamic response) async {
    // if (response["auth_token"] != null || response["user"] != null) {
    //   await MySharedPref.setAuthToken(response["auth_token"]);
    //   MySharedPref.setProfilePhoto(response["user"]?["photo"] ?? "");
    //   MySharedPref.setFirstName(response["user"]?["first_name"] ?? "");
    //   MySharedPref.setLastName(response["user"]?["last_name"] ?? "");
    //   MySharedPref.setEmail(response["user"]?["email"] ?? "");
    //   MySharedPref.setTimeZone(response["user"]?["timezone"] ?? "");
    //   MySharedPref.setCompanyCode(response["user"]?["company_code"] ?? "");
    // }
    // return;

    await MySharedPref.setCompanyID(response["CompanyID"]);
    await MySharedPref.setUserName(response["UserName"]);
    await MySharedPref.setCompanyName(response["CompanyName"]);

    await MySharedPref.setEmail(emailLoginTextController.text.trim());
  }

  login(String userId, String password) async {
    showLoading();
    var response = await DioClient().get(
      url: ApiUrl.login,
      params: {
        "UserName": userId.trim(),
        "Password": password.trim(),
      },
    ).catchError(handleError);

    if (response == null) return;

    hideLoading();
    if (response["IsValid"] == true) {
      log("Profile all data: ${response.toString()}");
      await storeUserData(response);

      MySnackBar.showToast(message: "Login Successful");
      Get.offAllNamed(Routes.APPOINTMENT);
    } else {
      MySnackBar.showErrorToast(message: "Wrong Credentials");
    }
  }

  doLogout() async {
    showLoading();
    await 2.delay();
    await MySharedPref.clearExceptEmail();
    hideLoading();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    signEmailFocusNode.dispose();
    nameFocusNode.dispose();
    passwordFocusNode.dispose();
    signPasswordFocusNode.dispose();
    emailSignupTextController.dispose();
    passwordSignupTextController.dispose();
    fullNameTextController.dispose();
    emailLoginTextController.dispose();
    passwordLoginTextController.dispose();

    super.dispose();
  }
}
