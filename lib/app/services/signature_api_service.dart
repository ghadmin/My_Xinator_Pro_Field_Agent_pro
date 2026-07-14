import '../service/REST/api_urls.dart';
import '../service/REST/dio_client.dart';
import '../models/signature/signature_request_model.dart';
import '../../utils/klog.dart';

/// Signature API Service
///
/// Handles signature-related API operations including payment signatures
class SignatureApiService {
  final DioClient _dioClient = DioClient();

  /// Get headers for API requests
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

  /// Save signature for payment
  ///
  /// Saves signature data for a specific payment using the new signature model structure
  /// [request] - SignatureRequestModel containing all signature data
  Future<Map<String, dynamic>?> saveSignatureForPayment({
    required SignatureRequestModel request,
  }) async {
    try {
      final url = ApiUrl.saveSignatureForPayment;

      final body = request.toJson();

      kLog('POST $url');
      kLog('Saving signature for payment: ${request.paymentId}');

      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('✅ Signature saved for payment: ${request.paymentId}');
      return response;
    } catch (e) {
      kLog('❌ Exception saving signature for payment: $e');
      return null;
    }
  }


  /// Save general signature
  ///
  /// Saves signature data for general use (not payment specific) using the new model structure
  /// [request] - SignatureRequestModel containing all signature data
  Future<Map<String, dynamic>?> saveSignature({
    required SignatureRequestModel request,
  }) async {
    try {
      final url = ApiUrl.saveSignature;

      final body = request.toJson();

      kLog('POST $url');
      kLog('Saving signature for appointment: ${request.appointmentId}');

      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('✅ Signature saved for appointment: ${request.appointmentId}');
      return response;
    } catch (e) {
      kLog('❌ Exception saving signature: $e');
      return null;
    }
  }

  /// Check if response is successful
  bool isSuccess(Map<String, dynamic>? response) {
    return response != null && response['success'] == true;
  }

  /// Get error message from response
  String getErrorMessage(Map<String, dynamic>? response) {
    if (response == null) return 'Unknown error occurred';
    if (response['error'] != null) return response['error'].toString();
    if (response['message'] != null) return response['message'].toString();
    return 'Operation failed';
  }
}