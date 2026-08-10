class PaymentSignatureModel {
  PaymentSignatureModel({
    this.paymentId,
    this.signature,
  });

  factory PaymentSignatureModel.fromJson(Map<String, dynamic> json) {
    return PaymentSignatureModel(
      paymentId: json['paymentId'] as String?,
      signature: json['signature'] as String?,
    );
  }

  final String? paymentId;
  final String? signature;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['paymentId'] = paymentId;
    map['signature'] = signature;
    return map;
  }

  PaymentSignatureModel copyWith({
    String? paymentId,
    String? signature,
  }) {
    return PaymentSignatureModel(
      paymentId: paymentId ?? this.paymentId,
      signature: signature ?? this.signature,
    );
  }

  @override
  String toString() {
    return 'PaymentSignatureModel(paymentId: $paymentId, signature: ${signature?.substring(0, 20)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaymentSignatureModel &&
        other.paymentId == paymentId &&
        other.signature == signature;
  }

  @override
  int get hashCode => paymentId.hashCode ^ signature.hashCode;
}
