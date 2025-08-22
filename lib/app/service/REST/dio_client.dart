// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_header.dart';

class DioClient {
  static const int TIME_OUT_DURATION = 20;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: TIME_OUT_DURATION),
    receiveTimeout: Duration(seconds: TIME_OUT_DURATION),
    sendTimeout: Duration(seconds: TIME_OUT_DURATION),
  ))
    ..interceptors.add(PrettyDioLogger(
      requestHeader: false,
      requestBody: true,
      responseBody: false,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

  DioClient() {
    // Bypass certificate verification - DEV ONLY
    bool isInDebug = const bool.fromEnvironment('dart.vm.product') == false;

    if (isInDebug) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          print("⚠️ Accepting bad certificate from: $host");
          return true; // Accept all certificates (development only)
        };
        return client;
      };
    }
  }

  //GET

  Future<dynamic> get({
    required String url,
    Map<String, dynamic>? params,
  }) async {
    try {
      var response = await _dio.get(url,
          options: Options(headers: {}), queryParameters: params);

      return response.data;
    } catch (e, s) {
      log("message: $e", name: "AuthController");
      log("stack: $s", name: "AuthController");
      rethrow;
    }
  }

  //POST

  Future<dynamic> post(
      {required String url, Map<String, dynamic>? params, dynamic body}) async {
    var payload = json.encode(body);
    try {
      var response = await _dio.post(url,
          options: Options(headers: {}),
          queryParameters: params,
          data: payload);
      log("inside response : $response");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  //PATCH

  Future<dynamic> patch(
      {required String url, Map<String, dynamic>? params, dynamic body}) async {
    var payload = json.encode(body);
    try {
      var response = await _dio.patch(url,
          options: Options(headers: Header.defaultHeader),
          queryParameters: params,
          data: payload);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  //DELETE

  Future<dynamic> delete(
      {required String url, Map<String, dynamic>? params, dynamic body}) async {
    var payload = json.encode(body);
    try {
      var response = await _dio.delete(url,
          options: Options(headers: Header.defaultHeader),
          queryParameters: params,
          data: payload);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  //MULTIPART FOR MULTIPLE FILE UPLOAD

  List<File>? docFileList = [];

  Future<dynamic> multipartRequest({
    required String url,
    Map<String, dynamic>? params,
    required Map<String, dynamic> body,
    String? filepath,
    required String key,
  }) async {
    var formData = FormData.fromMap(body);
    for (var files in docFileList!) {
      filepath = files.path;
      formData.files
          .addAll([MapEntry(key, await MultipartFile.fromFile(filepath))]);
    }

    try {
      var response = await _dio.post(url,
          options: Options(headers: {}),
          queryParameters: params,
          data: formData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  //MULTIPART FOR SINGLE FILE UPLOAD

  Future<dynamic> multipartSingleFile({
    required String url,
    Map<String, dynamic>? params,
    required Map<String, dynamic> body,
    String? filepath,
    required String key,
  }) async {
    var formData = FormData.fromMap(body);
    if (filepath != null) {
      formData.files.add(MapEntry(key, await MultipartFile.fromFile(filepath)));
    }

    try {
      var response = await _dio.post(url,
          options: Options(headers: Header.defaultMultipartHeader),
          queryParameters: params,
          data: formData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // DOWNLOAD FILE
  Future<dynamic> download({
    required String url,
    Map<String, dynamic>? params,
    required String savePath, // Full path to save the file
  }) async {
    try {
      var response = await _dio.download(
        url,
        savePath,
        options: Options(headers: Header.defaultHeader),
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        return File(savePath);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
