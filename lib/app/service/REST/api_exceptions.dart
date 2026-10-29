import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../config/translations/strings_enum.dart';

class DioExceptions implements Exception {
  String message = "";

  DioExceptions.fromDioError(DioException dioException) {
    log("DioException type: ${dioException.type}", name: "DioExceptions");
    log("DioException message: ${dioException.message}", name: "DioExceptions");
    log("DioException error: ${dioException.error}", name: "DioExceptions");

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
        message = _handleError(
          dioException.response!.statusCode!.toInt(),
          dioException.response!.data,
        );
        break;
      case DioExceptionType.unknown:
        log("DioExceptionType.unknown occurred", name: "DioExceptions");
        message = _messageForUnknown(dioException);
        break;
      case DioExceptionType.connectionError:
        log("DioExceptionType.connectionError occurred", name: "DioExceptions");
        message = "Unable to connect to server. Please check your internet connection.";
        break;
      default:
        log("Unhandled DioException type: ${dioException.type}", name: "DioExceptions");
        message = Strings.somethingWrong.tr;
        break;
    }
  }

  /// `DioExceptionType.unknown` wraps every non-HTTP failure, so check the
  /// underlying error before blaming connectivity. A [FormatException] means
  /// the server responded but the body could not be decoded (e.g. an HTML
  /// error page instead of JSON) — that is a server issue, not "no internet".
  String _messageForUnknown(DioException dioException) {
    final error = dioException.error;
    if (error is FormatException) {
      return "The server sent an invalid response. Please try again later.";
    }
    if (error is HandshakeException) {
      return "Secure connection failed. Please check your network or try again later.";
    }
    // SocketException and anything else — treat as a connectivity problem
    return "Network connection failed. Please check your internet connection and try again.";
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
