import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../components/global-widgets/my_snackbar.dart';
import '../REST/api_exceptions.dart';
import '../helper/dialog_helper.dart';

mixin class ExceptionHandler {
  RxBool isError = false.obs;

  /// FOR REST API
  void handleError(error) {
    isError.value = true;
    hideLoading();

    var errorText = DioExceptions.fromDioError(error).toString();

    showErrorDialog("Error", errorText);
    Logger().e(errorText);
  }

  showLoading() {
    isError.value = false;
    DialogHelper.showLoading();
  }

  hideLoading() {
    DialogHelper.hideLoading();
  }

  showErrorDialog(String title, String message) {
    /// for toast view
    MySnackBar.showErrorToast(message: message);

    /// for dialog view
    // DialogHelper.showErrorDialog(title, message);
  }
}
