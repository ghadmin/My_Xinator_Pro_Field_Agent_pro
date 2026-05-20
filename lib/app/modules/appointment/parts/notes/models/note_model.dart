class Note {
  final int id;
  final String description;
  final String? reference;
  final String createdAt;
  final String? userId;
  final String? taggedTo;
  final String taggedFrom;
  final String? appointmentId;
  final String customerId;
  final int siteId;

  Note({
    required this.id,
    required this.description,
    this.reference,
    required this.createdAt,
    this.userId,
    this.taggedTo,
    this.taggedFrom = 'FSM',
    this.appointmentId,
    required this.customerId,
    required this.siteId,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,
      description: json['description'] as String,
      reference: json['reference'] as String?,
      createdAt: json['createdAt'] as String,
      userId: json['userId'] as String?,
      taggedTo: json['taggedTo'] as String?,
      taggedFrom: json['taggedFrom'] as String? ?? 'FSM',
      appointmentId: json['appointmentId']?.toString(),
      customerId: json['customerId'] as String,
      siteId: json['siteId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      if (reference != null) 'reference': reference,
      'createdAt': createdAt,
      if (userId != null) 'userId': userId,
      if (taggedTo != null) 'taggedTo': taggedTo,
      'taggedFrom': taggedFrom,
      if (appointmentId != null) 'appointmentId': appointmentId,
      'customerId': customerId,
      'siteId': siteId,
    };
  }
}
