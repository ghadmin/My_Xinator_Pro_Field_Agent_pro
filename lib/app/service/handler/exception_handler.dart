// ignore_for_file: strict_top_level_inference

import 'package:get/get.dart';

import '../../components/global-widgets/my_snackbar.dart';
import '../REST/api_exceptions.dart';
import '../helper/loading_service.dart';

mixin class ExceptionHandler {
  RxBool isError = false.obs;

  /// FOR REST API
  void handleError(error) {
    isError.value = true;
    hideLoading(debugInfo: "Error occurred: ${error.toString()}");

    var errorText = DioExceptions.fromDioError(error).toString();

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
