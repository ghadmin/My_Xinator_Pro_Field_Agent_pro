// ignore_for_file: strict_top_level_inference

import 'dart:developer';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../components/global-widgets/my_snackbar.dart';
import '../REST/api_exceptions.dart';
import '../helper/loading_service.dart';

mixin class ExceptionHandler {
  RxBool isError = false.obs;

  /// FOR REST API
  void handleError(error) {
    isError.value = true;
    hideLoading(debugInfo: "Error occurred: ${error.toString()}");

    String errorText;

    // Handle both DioException and regular Exception types
    if (error is DioException) {
      log("Handling DioException: ${error.type}", name: "ExceptionHandler");
      errorText = DioExceptions.fromDioError(error).toString();
    } else if (error is Exception) {
      log("Handling regular Exception: $error", name: "ExceptionHandler");
      errorText = error.toString().replaceAll("Exception: ", "");
    } else {
      log("Handling unknown error type: $error", name: "ExceptionHandler");
      errorText = error.toString();
    }

    showErrorDialog("Error", errorText);
  }

  showLoading({String? debugInfo}) {
    isError.value = false;
    LoadingService.show(debugInfo: debugInfo ?? "ExceptionHandler");
  }

  hideLoading({String? debugInfo}) {
    LoadingService.hide(debugInfo: debugInfo ?? "ExceptionHandler");
  }

  showErrorDialog(String title, String message) {
    /// for toast view
    MySnackBar.showErrorToast(message: message);

    /// for dialog view
    // DialogHelper.showErrorDialog(title, message);
  }
}
