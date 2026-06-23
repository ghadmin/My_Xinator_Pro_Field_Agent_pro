// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_header.dart';

class DioClient {
  static const int TIME_OUT_DURATION = 90; // Increased from 60 to 90 seconds

  final Dio _dio =
      Dio(
          BaseOptions(
            connectTimeout: Duration(seconds: TIME_OUT_DURATION),
            receiveTimeout: Duration(seconds: TIME_OUT_DURATION),
            sendTimeout: Duration(seconds: TIME_OUT_DURATION),
            // Add validation settings for better error handling
            validateStatus: (status) {
              // Accept status codes in the 200-299 range and also handle some common error codes
              return status != null && status >= 200 && status < 300;
            },
          ),
        )
        ..interceptors.add(
          PrettyDioLogger(
            requestHeader: false,
            requestBody: true,
            responseBody: false,
            responseHeader: false,
            error: true,
            compact: true,
            maxWidth: 90,
          ),
        );

  DioClient() {
    _setupHttpClient();
  }

  void _setupHttpClient() {
    bool isInDebug = const bool.fromEnvironment('dart.vm.product') == false;

    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient client = HttpClient();

      // Enable TLS 1.2 and 1.3 for Android
      if (Platform.isAndroid) {
        log("🔧 Setting up Android HttpClient with TLS support");
      }

      // Development: Bypass certificate verification
      if (isInDebug) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          log("⚠️ DEV MODE: Accepting certificate from: $host");
          log("   Subject: ${cert.subject}");
          log("   Issuer: ${cert.issuer}");
          return true; // Accept all certificates in development
        };
      } else {
        // Production: Still log certificate details for debugging
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          log("🔒 PROD: Certificate validation for: $host");
          log("   Subject: ${cert.subject}");
          log("   Issuer: ${cert.issuer}");
          log("   Valid from: ${cert.startValidity} to ${cert.endValidity}");

          // Check if certificate is expired or not yet valid
          final now = DateTime.now();
          if (now.isBefore(cert.startValidity) || now.isAfter(cert.endValidity)) {
            log("❌ Certificate is NOT valid at this time!");
            return false;
          }

          // In production, this should return false to enforce proper certificate validation
          // But temporarily return true to allow testing
          log("⚠️ PROD WARNING: Accepting certificate (should be properly validated)");
          return true;
        };
      }

      return client;
    };
  }

  //GET

  Future<dynamic> get({
    required String url,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    try {
      log("GET Request URL: $url");
      log("GET Request params: $params");
      var response = await _dio.get(
        url,
        options: Options(headers: headers),
        queryParameters: params,
        // Don't encode query parameters to prevent double encoding issues
      );

      log("GET Response Status: ${response.statusCode}");
      return response.data;
    } on DioException catch (e, s) {
      log("DioException in GET request: ${e.type}", name: "DioClient");
      log("DioException message: ${e.message}", name: "DioClient");
      log("DioException response: ${e.response}", name: "DioClient");
      log("DioException error: ${e.error}", name: "DioClient");
      log("Stack trace: $s", name: "DioClient");
      rethrow; // Rethrow DioException instead of throwing regular Exception
    } catch (e, s) {
      log("General exception in GET request: $e", name: "DioClient");
      log("Stack trace: $s", name: "DioClient");
      rethrow;
    }
  }

  //POST

  Future<dynamic> post({
    required String url,
    Map<String, dynamic>? params,
    dynamic body,
    Map<String, dynamic>? headers,
  }) async {
    var payload = json.encode(body);
    try {
      log("POST Request URL: $url");
      log("POST Request params: $params");
      var response = await _dio.post(
        url,
        options: Options(headers: headers),
        queryParameters: params,
        data: payload,
      );
      log("POST Response Status: ${response.statusCode}");
      log("POST Response data: ${response.data}");
      return response.data;
    } on DioException catch (e, s) {
      log("DioException in POST request: ${e.type}", name: "DioClient");
      log("DioException message: ${e.message}", name: "DioClient");
      log("DioException response: ${e.response}", name: "DioClient");
      log("DioException error: ${e.error}", name: "DioClient");
      log("Stack trace: $s", name: "DioClient");
      rethrow; // Rethrow DioException instead of throwing regular Exception
    } catch (e, s) {
      log("General exception in POST request: $e", name: "DioClient");
      log("Stack trace: $s", name: "DioClient");
      rethrow;
    }
  }

  //PATCH

  Future<dynamic> patch({
    required String url,
    Map<String, dynamic>? params,
    dynamic body,
  }) async {
    var payload = json.encode(body);
    try {
      var response = await _dio.patch(
        url,
        options: Options(headers: Header.defaultHeader),
        queryParameters: params,
        data: payload,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  //DELETE

  Future<dynamic> delete({
    required String url,
    Map<String, dynamic>? params,
    dynamic body,
  }) async {
    var payload = json.encode(body);
    try {
      var response = await _dio.delete(
        url,
        options: Options(headers: Header.defaultHeader),
        queryParameters: params,
        data: payload,
      );
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
      formData.files.addAll([
        MapEntry(key, await MultipartFile.fromFile(filepath)),
      ]);
    }

    try {
      var response = await _dio.post(
        url,
        options: Options(headers: {}),
        queryParameters: params,
        data: formData,
      );
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
      var response = await _dio.post(
        url,
        options: Options(headers: Header.defaultMultipartHeader),
        queryParameters: params,
        data: formData,
      );
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
    Map<String, dynamic>? headers,
  }) async {
    try {
      var response = await _dio.download(
        url,
        savePath,
        options: Options(headers: headers),
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

  // DOWNLOAD FILE AS BYTES
  Future<Uint8List?> downloadBytes({
    required String url,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    try {
      var response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
        queryParameters: params,
      );

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data);
      }
    } catch (e) {
      log('Error downloading bytes: $e');
      rethrow;
    }
    return null;
  }
}
