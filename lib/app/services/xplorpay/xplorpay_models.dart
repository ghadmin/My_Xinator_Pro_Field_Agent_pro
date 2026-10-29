/// Request/response models for the Xplor Pay Mobile Payment Transactions API
/// (POST /rest/v2/mobile/transactions/sale).
///
/// Field names follow the published OpenAPI spec (ClearentGatewayRequest /
/// transaction model): kebab-case JSON keys, string values.
library;

/// Body of POST /rest/v2/mobile/transactions/sale.
///
/// The gateway requires `amount`, `software-type`, `software-type-version`
/// and `type`. The reader's JWT goes in the `mobilejwt` header, not the body.
class MobileSaleRequest {
  /// Total transaction amount, e.g. "10.00".
  final String amount;

  /// "SALE" for the sale endpoint.
  final String type;

  /// Identifies the requesting software to the gateway.
  final String softwareType;
  final String softwareTypeVersion;

  // Optional gateway fields (strings per the spec).
  final String? invoice;
  final String? description;
  final String? comments;
  final String? orderId;
  final String? customerId;

  MobileSaleRequest({
    required this.amount,
    this.type = 'SALE',
    required this.softwareType,
    required this.softwareTypeVersion,
    this.invoice,
    this.description,
    this.comments,
    this.orderId,
    this.customerId,
  });

  Map<String, String> toJson() {
    return {
      'amount': amount,
      'type': type,
      'software-type': softwareType,
      'software-type-version': softwareTypeVersion,
      'invoice': ?invoice,
      'description': ?description,
      'comments': ?comments,
      'order-id': ?orderId,
      'customer-id': ?customerId,
    };
  }
}

/// Result of a submitted mobile transaction as returned by the gateway.
class XplorPayTransactionResult {
  /// Gateway transaction id.
  final String? id;

  /// APPROVED, DECLINED or ERROR.
  final String? result;

  /// Gateway result code (e.g. "00" for approved).
  final String? resultCode;

  /// Human readable gateway message.
  final String? displayMessage;

  final String? authorizationCode;
  final String? lastFour;
  final String? cardType;
  final String? amount;
  final String? type;
  final String? created;

  const XplorPayTransactionResult({
    this.id,
    this.result,
    this.resultCode,
    this.displayMessage,
    this.lastFour,
    this.cardType,
    this.amount,
    this.type,
    this.created,
    this.authorizationCode,
  });

  /// APPROVED, DECLINED or ERROR.
  bool get approved => (result ?? '').toUpperCase() == 'APPROVED';

  /// Parses the sale response. The gateway may return the transaction object
  /// directly or wrapped in a "transaction" payload; error responses carry
  /// "errorResults".
  factory XplorPayTransactionResult.fromGatewayJson(Map<String, dynamic> json) {
    Map<String, dynamic> tx = json;
    if (json['transaction'] is Map) {
      tx = Map<String, dynamic>.from(json['transaction'] as Map);
    }

    final errorResults = json['errorResults'];
    if (errorResults is List && errorResults.isNotEmpty) {
      final first = Map<Object?, Object?>.from(errorResults.first as Map);
      return XplorPayTransactionResult(
        result: 'ERROR',
        displayMessage: first['errorMessage'] as String?,
        resultCode: first['resultCode']?.toString(),
      );
    }

    return XplorPayTransactionResult(
      id: tx['id'] as String?,
      result: tx['result'] as String?,
      resultCode: (tx['result-code'] ?? tx['code'])?.toString(),
      displayMessage: (tx['display-message'] ?? tx['exchangeMessage']) as String?,
      authorizationCode: tx['authorization-code'] as String?,
      lastFour: tx['last-four'] as String?,
      cardType: tx['card-type'] as String?,
      amount: tx['amount'] as String?,
      type: tx['type'] as String?,
      created: tx['created'] as String?,
    );
  }

  @override
  String toString() {
    return 'XplorPayTransactionResult('
        'id: $id, result: $result, displayMessage: $displayMessage, '
        'lastFour: $lastFour, cardType: $cardType)';
  }
}
