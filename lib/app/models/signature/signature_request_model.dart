/// Signature Request Model
///
/// Model for saving signature requests with all required parameters
class SignatureRequestModel {
  final int? appointmentId;
  final String? invoiceId;
  final int? paymentId;
  final int? customerId;
  final String? companyId;
  final String signatureFileName;
  final String signatureFileContent;
  final String? userId;

  SignatureRequestModel({
    this.appointmentId,
    this.invoiceId,
    this.paymentId,
    this.customerId,
    this.companyId,
    required this.signatureFileName,
    required this.signatureFileContent,
    this.userId,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'signature': {
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (invoiceId != null) 'invoiceId': invoiceId,
        if (paymentId != null) 'paymentId': paymentId,
        if (customerId != null) 'customerId': customerId,
        if (companyId != null) 'companyId': companyId,
        'signatureFileName': signatureFileName,
        'signatureFileContent': signatureFileContent,
        if (userId != null) 'userId': userId,
      }
    };
  }

  /// Create request for payment signature
  factory SignatureRequestModel.forPayment({
    required int paymentId,
    required String signatureFileName,
    required String signatureFileContent,
    int? customerId,
    String? companyId,
    String? userId,
    int? appointmentId,
    String? invoiceId,
  }) {
    return SignatureRequestModel(
      paymentId: paymentId,
      signatureFileName: signatureFileName,
      signatureFileContent: signatureFileContent,
      customerId: customerId,
      companyId: companyId,
      userId: userId,
      appointmentId: appointmentId,
      invoiceId: invoiceId,
    );
  }

  /// Create request for appointment signature
  factory SignatureRequestModel.forAppointment({
    required int appointmentId,
    required String signatureFileName,
    required String signatureFileContent,
    int? customerId,
    String? companyId,
    String? userId,
  }) {
    return SignatureRequestModel(
      appointmentId: appointmentId,
      signatureFileName: signatureFileName,
      signatureFileContent: signatureFileContent,
      customerId: customerId,
      companyId: companyId,
      userId: userId,
    );
  }
}