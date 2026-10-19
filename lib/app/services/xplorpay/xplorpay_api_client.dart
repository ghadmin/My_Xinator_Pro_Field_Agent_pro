import 'package:package_info_plus/package_info_plus.dart';

import '../../service/REST/dio_client.dart';
import 'xplorpay_models.dart';

/// Submits the reader's encrypted JWT to the Xplor Pay Mobile Payment
/// Transactions API.
///
/// Contract (per docs.xplorpay.com OpenAPI spec):
///   POST {base}/rest/v2/mobile/transactions/sale
///   Headers: api-key, mobilejwt
///   Body:    { amount, type, software-type, software-type-version }
///
/// SECURITY: [mobileJwt] is a one-time, single-use credential. Never log it;
/// in production prefer pointing [baseUrl] at your own backend, which holds
/// the API key and calls Xplor Pay server-side.
class XplorPayApiClient {
  static const _salePath = '/rest/v2/mobile/transactions/sale';

  final DioClient _dioClient = DioClient();

  /// Submits the JWT and returns the parsed gateway response.
  Future<XplorPayTransactionResult> submitSaleJwt({
    required String baseUrl,
    required String apiKey,
    required String mobileJwt,
    required MobileSaleRequest request,
  }) async {
    final response = await _dioClient.post(
      url: '$baseUrl$_salePath',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'api-key': apiKey,
        'mobilejwt': mobileJwt,
      },
      body: request.toJson(),
    );

    if (response is Map) {
      return XplorPayTransactionResult.fromGatewayJson(
          Map<String, dynamic>.from(response));
    }
    throw const XplorPayApiException('Unexpected gateway response format');
  }

  /// Convenience: builds the software-type/version pair from package info so
  /// the gateway sees the real app identity.
  static Future<(String, String)> softwareIdentity() async {
    final info = await PackageInfo.fromPlatform();
    return ('MyXinatorProFieldAgent', info.version);
  }
}

/// Gateway-side failure (HTTP 400/401/402/500 → errorResults array) or an
/// unexpected response shape.
class XplorPayApiException implements Exception {
  final String message;

  const XplorPayApiException(this.message);

  @override
  String toString() => 'XplorPayApiException: $message';
}
