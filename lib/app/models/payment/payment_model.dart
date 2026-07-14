import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 8)
class Payment {
  @HiveField(0)
  dynamic _id;
  @HiveField(1)
  String? _companyId;
  @HiveField(2)
  String? _invocieId;
  @HiveField(3)
  double? _amount;
  @HiveField(4)
  String? _checkName;
  @HiveField(5)
  String? _checkNumber;
  @HiveField(6)
  String? _type;
  @HiveField(7)
  bool? _isDeposit;
  @HiveField(8)
  String? _source;
  @HiveField(9)
  String? _createdDate;
  @HiveField(10)
  dynamic _qboId;
  @HiveField(11)
  String? _paymentRefNum;
  @HiveField(12)
  dynamic _rmPaymentId;
  @HiveField(13)
  List<PaymentSignature>? _signatures;

  Payment({
    dynamic id,
    String? companyId,
    String? invocieId,
    dynamic amount,
    String? checkName,
    String? checkNumber,
    String? type,
    bool? isDeposit,
    String? source,
    String? createdDate,
    dynamic qboId,
    String? paymentRefNum,
    dynamic rmPaymentId,
    List<PaymentSignature>? signatures,
  }) {
    _id = id;
    _companyId = companyId;
    _invocieId = invocieId;
    _amount = amount;
    _checkName = checkName;
    _checkNumber = checkNumber;
    _type = type;
    _isDeposit = isDeposit;
    _source = source;
    _createdDate = createdDate;
    _qboId = qboId;
    _paymentRefNum = paymentRefNum;
    _rmPaymentId = rmPaymentId;
    _signatures = signatures;
  }

  Payment.fromJson(dynamic json) {
    _id = json['Id'];
    _companyId = json['CompanyId'];
    _invocieId = json['InvocieId'];
    _amount = json['Amount'];
    _checkName = json['CheckName'];
    _checkNumber = json['CheckNumber'];
    _type = json['Type'];
    _isDeposit = json['IsDeposit'];
    _source = json['Source'];
    _createdDate = json['CreatedDate'];
    _qboId = json['QboId'];
    _paymentRefNum = json['PaymentRefNum'];
    _rmPaymentId = json['RMPaymentId'];
    if (json['Signatures'] != null) {
      _signatures = [];
      json['Signatures'].forEach((v) {
        _signatures?.add(PaymentSignature.fromJson(v));
      });
    }
  }

  Payment copyWith({
    dynamic id,
    String? companyId,
    String? invocieId,
    dynamic amount,
    String? checkName,
    String? checkNumber,
    String? type,
    bool? isDeposit,
    String? source,
    String? createdDate,
    dynamic qboId,
    String? paymentRefNum,
    dynamic rmPaymentId,
    List<PaymentSignature>? signatures,
  }) =>
      Payment(
        id: id ?? _id,
        companyId: companyId ?? _companyId,
        invocieId: invocieId ?? _invocieId,
        amount: amount ?? _amount,
        checkName: checkName ?? _checkName,
        checkNumber: checkNumber ?? _checkNumber,
        type: type ?? _type,
        isDeposit: isDeposit ?? _isDeposit,
        source: source ?? _source,
        createdDate: createdDate ?? _createdDate,
        qboId: qboId ?? _qboId,
        paymentRefNum: paymentRefNum ?? _paymentRefNum,
        rmPaymentId: rmPaymentId ?? _rmPaymentId,
        signatures: signatures ?? _signatures,
      );

  dynamic get id => _id;
  String? get companyId => _companyId;
  String? get invocieId => _invocieId;
  dynamic get amount => _amount;
  String? get checkName => _checkName;
  String? get checkNumber => _checkNumber;
  String? get type => _type;
  bool? get isDeposit => _isDeposit;
  String? get source => _source;
  String? get createdDate => _createdDate;
  dynamic get qboId => _qboId;
  String? get paymentRefNum => _paymentRefNum;
  dynamic get rmPaymentId => _rmPaymentId;
  List<PaymentSignature>? get signatures => _signatures;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Id'] = _id;
    map['CompanyId'] = _companyId;
    map['InvocieId'] = _invocieId;
    map['Amount'] = _amount;
    map['CheckName'] = _checkName;
    map['CheckNumber'] = _checkNumber;
    map['Type'] = _type;
    map['IsDeposit'] = _isDeposit;
    map['Source'] = _source;
    map['CreatedDate'] = _createdDate;
    map['QboId'] = _qboId;
    map['PaymentRefNum'] = _paymentRefNum;
    map['RMPaymentId'] = _rmPaymentId;
    if (_signatures != null) {
      map['Signatures'] = _signatures?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

@HiveType(typeId: 9)
class PaymentSignature {
  @HiveField(0)
  dynamic _id;
  @HiveField(1)
  dynamic _appointmentId;
  @HiveField(2)
  String? _invoiceId;
  @HiveField(3)
  dynamic _paymentId;
  @HiveField(4)
  dynamic _customerId;
  @HiveField(5)
  String? _companyId;
  @HiveField(6)
  String? _signatureFileName;
  @HiveField(7)
  String? _signatureFileURL;
  @HiveField(8)
  dynamic _signatureFileContent;
  @HiveField(9)
  String? _createdDate;
  @HiveField(10)
  String? _userId;

  PaymentSignature({
    dynamic id,
    dynamic appointmentId,
    String? invoiceId,
    dynamic paymentId,
    dynamic customerId,
    String? companyId,
    String? signatureFileName,
    String? signatureFileURL,
    dynamic signatureFileContent,
    String? createdDate,
    String? userId,
  }) {
    _id = id;
    _appointmentId = appointmentId;
    _invoiceId = invoiceId;
    _paymentId = paymentId;
    _customerId = customerId;
    _companyId = companyId;
    _signatureFileName = signatureFileName;
    _signatureFileURL = signatureFileURL;
    _signatureFileContent = signatureFileContent;
    _createdDate = createdDate;
    _userId = userId;
  }

  PaymentSignature.fromJson(dynamic json) {
    _id = json['Id'];
    _appointmentId = json['AppointmentId'];
    _invoiceId = json['InvoiceId'];
    _paymentId = json['PaymentId'];
    _customerId = json['CustomerId'];
    _companyId = json['CompanyId'];
    _signatureFileName = json['SignatureFileName'];
    _signatureFileURL = json['SignatureFileURL'];
    _signatureFileContent = json['SignatureFileContent'];
    _createdDate = json['CreatedDate'];
    _userId = json['UserId'];
  }

  PaymentSignature copyWith({
    dynamic id,
    dynamic appointmentId,
    String? invoiceId,
    dynamic paymentId,
    dynamic customerId,
    String? companyId,
    String? signatureFileName,
    String? signatureFileURL,
    dynamic signatureFileContent,
    String? createdDate,
    String? userId,
  }) =>
      PaymentSignature(
        id: id ?? _id,
        appointmentId: appointmentId ?? _appointmentId,
        invoiceId: invoiceId ?? _invoiceId,
        paymentId: paymentId ?? _paymentId,
        customerId: customerId ?? _customerId,
        companyId: companyId ?? _companyId,
        signatureFileName: signatureFileName ?? _signatureFileName,
        signatureFileURL: signatureFileURL ?? _signatureFileURL,
        signatureFileContent: signatureFileContent ?? _signatureFileContent,
        createdDate: createdDate ?? _createdDate,
        userId: userId ?? _userId,
      );

  dynamic get id => _id;
  dynamic get appointmentId => _appointmentId;
  String? get invoiceId => _invoiceId;
  dynamic get paymentId => _paymentId;
  dynamic get customerId => _customerId;
  String? get companyId => _companyId;
  String? get signatureFileName => _signatureFileName;
  String? get signatureFileURL => _signatureFileURL;
  dynamic get signatureFileContent => _signatureFileContent;
  String? get createdDate => _createdDate;
  String? get userId => _userId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Id'] = _id;
    map['AppointmentId'] = _appointmentId;
    map['InvoiceId'] = _invoiceId;
    map['PaymentId'] = _paymentId;
    map['CustomerId'] = _customerId;
    map['CompanyId'] = _companyId;
    map['SignatureFileName'] = _signatureFileName;
    map['SignatureFileURL'] = _signatureFileURL;
    map['SignatureFileContent'] = _signatureFileContent;
    map['CreatedDate'] = _createdDate;
    map['UserId'] = _userId;
    return map;
  }
}