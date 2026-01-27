import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/version_controller.dart';
import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../routes/app_pages.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';

class AuthController extends GetxController with ExceptionHandler {
  final versionController = Get.put(VersionController());

  final TextEditingController emailLoginTextController = TextEditingController(
    text: MySharedPref.getEmail() ?? "",
  );
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
    await MySharedPref.setCompanyType(response["CompanyType"] ?? "");
    await MySharedPref.setEmail(emailLoginTextController.text.trim());
  }

  Future<void> login(String userId, String password) async {
    showLoading();

    try {
      var response = await DioClient().get(
        url: ApiUrl.login,
        params: {
          "UserName": userId.trim(),
          "Password": password.trim(),
          "AppType": 2,
        },
      );

      log("✅ Login successful - Response: ${jsonEncode(response)}");
      hideLoading();

      if (response["IsValid"] == true) {
        log("✅ Profile all data: ${response.toString()}");
        await storeUserData(response);
        MySnackBar.showToast(message: "Login Successful");
        Get.offAllNamed(Routes.APPOINTMENT);
      } else {
        log("⚠️ Invalid credentials - Response: $response");
        MySnackBar.showErrorToast(message: "Wrong Credentials");
      }
    } catch (e, stackTrace) {
      hideLoading();
      log("❌ Login error: $e");
      log("❌ Stack trace: $stackTrace");

      // Enhanced error handling with device info
      final errorMessage = _getDetailedErrorMessage(e);
      MySnackBar.showErrorToast(message: errorMessage);

      // Log detailed error for debugging
      log("📱 Device Error Details:", name: "LoginError");
      log("Error Type: ${e.runtimeType}", name: "LoginError");
      log("Error Message: $errorMessage", name: "LoginError");
      log("User ID: ${userId.trim()}", name: "LoginError");
    }
  }

  String _getDetailedErrorMessage(dynamic error) {
    final errorString = error.toString();

    // Network connectivity issues
    if (errorString.contains("SocketException") ||
        errorString.contains("NetworkException")) {
      return "No internet connection. Please check your network and try again.";
    }

    // Timeout issues
    if (errorString.contains("TimeoutException") ||
        errorString.contains("TimeoutException")) {
      return "Request timed out. Please check your connection and try again.";
    }

    // SSL/TLS Certificate issues (critical for production)
    if (errorString.contains("HandshakeException") ||
        errorString.contains("Certificate") ||
        errorString.contains("SSL") ||
        errorString.contains("TLS")) {
      log("🔒 SSL/TLS Error Details: $errorString", name: "SSLError");
      return "Secure connection failed. This may be due to an outdated device or certificate issue. Please contact support with error code: SSL-001";
    }

    // HTTP status codes
    if (errorString.contains("401") || errorString.contains("403")) {
      return "Invalid username or password.";
    }
    if (errorString.contains("404")) {
      return "Service not found. Please contact support.";
    }
    if (errorString.contains("500") ||
        errorString.contains("502") ||
        errorString.contains("503")) {
      return "Server error. Please try again later.";
    }

    // Connection errors
    if (errorString.contains("Connection") ||
        errorString.contains("ConnectException")) {
      return "Network error. Please check your internet connection or try again later.";
    }

    return "Something went wrong. Please try again or contact support.";
  }

  Future<void> doLogout() async {
    showLoading();
    await 2.delay();
    await MySharedPref.clearExceptEmail();
    appointmentController.stop();
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
