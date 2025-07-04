import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../config/translations/strings_enum.dart';

class DioExceptions implements Exception {
  String message = "";

  DioExceptions.fromDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        message = Strings.requestCanceled.tr;
        break;
      case DioExceptionType.connectionTimeout:
        message = Strings.connectionTimeout.tr;
        break;
      case DioExceptionType.receiveTimeout:
        message = Strings.receiveTimeout.tr;
        break;
      case DioExceptionType.sendTimeout:
        message = Strings.sendTimeout.tr;
        break;
      case DioExceptionType.badResponse:
        message = _handleError(dioException.response!.statusCode!.toInt(),
            dioException.response!.data);
        break;

      default:
        message = Strings.somethingWrong.tr;
        break;
    }
  }

  String _handleError(int statusCode, dynamic error) {
    if (error is Map) {
      return error['error'] ??
          error["message"] ??
          _defaultErrorMessage(statusCode);
    } else if (error is String) {
      final isHtml =
          error.contains('<!DOCTYPE html>') || error.contains('<html');
      return isHtml
          ? _defaultErrorMessage(statusCode)
          : (error.isNotEmpty ? error : _defaultErrorMessage(statusCode));
    } else {
      return _defaultErrorMessage(statusCode);
    }
  }

  String _defaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return Strings.badRequest.tr;
      case 401:
        return Strings.unauthorized.tr;
      case 404:
        return Strings.urlIncorrect.tr;
      case 500:
        return Strings.internalServerError.tr;
      default:
        return Strings.somethingWrong.tr;
    }
  }

  @override
  String toString() => message;
}
