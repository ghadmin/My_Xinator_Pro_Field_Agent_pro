import 'dart:developer';
import 'package:dio/dio.dart';
import '../../data/local/my_shared_pref.dart';
import '../../service/REST/dio_client.dart';
import '../REST/api_urls.dart';
import 'models/location_model.dart';

/// API service for sending location data to server
class LocationApiService {
  final DioClient _dioClient = DioClient();

  /// Send a single location to the API
  Future<LocationApiResult> sendLocation(LocationModel location) async {
    try {
      log('📍 Sending location: ${location.toString()}');

      var companyID = MySharedPref.getCompanyID();

      final response = await _dioClient.post(
        url: 'https://mxp.myserviceforce.com/fsm/FaProTrack.ashx?op=ping',
        headers: {
          'X-Api-Key': ApiUrl.apiKey, // Header auth (preferred)
        },
        body: {
          "companyId": companyID, // or ?companyId= on the query string
          "resourceId":
              location.resourceId, // tbl_Resources.Id — same as FaProSync
          "deviceId": 'A1B2C3D4-E5F6', // optional, applies to the whole batch
          "points": [
            {
              "latitude": location.latitude,
              "longitude": location.longitude,
              "recordedAt": location.recordedAt,
              "accuracy": location.accuracy,
              "speed": location.speed,
              "heading": location.heading,
              "altitude": location.altitude,
              "batteryLevel": location.batteryLevel,
              "networkType": location.networkType,
            },
          ],
        },
      );

      if (response != null && _isSuccessResponse(response)) {
        log('✅ Location sent successfully');
        return LocationApiResult.success();
      } else {
        log('❌ Location send failed: Invalid response');
        return LocationApiResult.failure(
          LocationApiFailureType.invalidResponse,
          'Invalid response from server',
        );
      }
    } on DioException catch (e) {
      log('❌ Dio error sending location: ${e.message}');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      log('❌ Unexpected error sending location: $e');
      log('Stack trace: $stackTrace');
      return LocationApiResult.failure(
        LocationApiFailureType.unknown,
        e.toString(),
      );
    }
  }

  /// Send multiple locations in batch
  Future<List<LocationApiResult>> sendBatchLocations(
    List<LocationModel> locations,
  ) async {
    final results = <LocationApiResult>[];

    for (final location in locations) {
      final result = await sendLocation(location);
      results.add(result);

      // Don't overwhelm the server - add small delay between requests
      if (results.length < locations.length) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return results;
  }

  /// Check if response indicates success
  bool _isSuccessResponse(dynamic response) {
    if (response == null) return false;

    // Check for common success patterns
    if (response is Map) {
      // Look for success indicators
      if (response.containsKey('success')) {
        return response['success'] == true;
      }
      if (response.containsKey('status')) {
        final status = response['status'].toString().toLowerCase();
        return status == 'success' || status == 'ok' || status == '200';
      }
      if (response.containsKey('IsValid')) {
        return response['IsValid'] == true;
      }
      // If no explicit failure, consider it successful
      return true;
    }

    return false;
  }

  /// Handle Dio specific errors
  LocationApiResult _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return LocationApiResult.failure(
          LocationApiFailureType.timeout,
          'Request timeout: ${error.message}',
        );

      case DioExceptionType.badResponse:
        return _handleStatusCodeError(error.response?.statusCode, error);

      case DioExceptionType.cancel:
        return LocationApiResult.failure(
          LocationApiFailureType.cancelled,
          'Request was cancelled',
        );

      case DioExceptionType.connectionError:
        return LocationApiResult.failure(
          LocationApiFailureType.networkError,
          'Connection error: ${error.message}',
        );

      case DioExceptionType.badCertificate:
        return LocationApiResult.failure(
          LocationApiFailureType.securityError,
          'Certificate validation failed',
        );

      case DioExceptionType.unknown:
      default:
        return LocationApiResult.failure(
          LocationApiFailureType.unknown,
          'Unknown error: ${error.message}',
        );
    }
  }

  /// Handle HTTP status code errors
  LocationApiResult _handleStatusCodeError(
    int? statusCode,
    DioException error,
  ) {
    if (statusCode == null) {
      return LocationApiResult.failure(
        LocationApiFailureType.unknown,
        'No status code in response',
      );
    }

    switch (statusCode) {
      case 400:
      case 422:
        return LocationApiResult.failure(
          LocationApiFailureType.validationError,
          'Validation error: ${error.response?.data}',
        );

      case 401:
      case 403:
        return LocationApiResult.failure(
          LocationApiFailureType.authError,
          'Authentication error: ${error.response?.data}',
        );

      case 404:
        return LocationApiResult.failure(
          LocationApiFailureType.notFound,
          'Endpoint not found',
        );

      case 429:
        return LocationApiResult.failure(
          LocationApiFailureType.rateLimited,
          'Rate limited: Too many requests',
        );

      case 500:
      case 502:
      case 503:
        return LocationApiResult.failure(
          LocationApiFailureType.serverError,
          'Server error: $statusCode',
        );

      default:
        return LocationApiResult.failure(
          LocationApiFailureType.httpError,
          'HTTP error: $statusCode',
        );
    }
  }
}

/// Result of location API operation
class LocationApiResult {
  final bool success;
  final LocationApiFailureType? failureType;
  final String? errorMessage;

  LocationApiResult._({
    required this.success,
    this.failureType,
    this.errorMessage,
  });

  factory LocationApiResult.success() {
    return LocationApiResult._(success: true);
  }

  factory LocationApiResult.failure(
    LocationApiFailureType type,
    String message,
  ) {
    return LocationApiResult._(
      success: false,
      failureType: type,
      errorMessage: message,
    );
  }

  /// Check if this error should trigger a retry
  bool get shouldRetry {
    if (success) return false;

    return failureType == LocationApiFailureType.timeout ||
        failureType == LocationApiFailureType.networkError ||
        failureType == LocationApiFailureType.serverError ||
        failureType == LocationApiFailureType.rateLimited ||
        failureType == LocationApiFailureType.unknown;
  }

  /// Check if this is an authentication error (should not retry)
  bool get isAuthError {
    return failureType == LocationApiFailureType.authError;
  }

  /// Check if this is a validation error (should not retry)
  bool get isValidationError {
    return failureType == LocationApiFailureType.validationError;
  }
}

/// Types of API failures
enum LocationApiFailureType {
  timeout,
  networkError,
  authError,
  validationError,
  notFound,
  rateLimited,
  serverError,
  httpError,
  securityError,
  cancelled,
  invalidResponse,
  unknown,
}

extension LocationApiFailureTypeExtension on LocationApiFailureType {
  /// Get retry delay in milliseconds based on failure type
  int get retryDelayMs {
    switch (this) {
      case LocationApiFailureType.rateLimited:
        return 60000; // 1 minute for rate limit
      case LocationApiFailureType.serverError:
        return 30000; // 30 seconds for server errors
      case LocationApiFailureType.timeout:
      case LocationApiFailureType.networkError:
        return 10000; // 10 seconds for network issues
      default:
        return 5000; // 5 seconds default
    }
  }
}
