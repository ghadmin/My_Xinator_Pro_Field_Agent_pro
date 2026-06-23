/// Signature Model
///
/// Represents a user's signature with both drawn and typed options
class SignatureModel {
  /// Unique identifier for this signature
  final String id;

  /// Full name of the user (for typed signatures)
  final String fullName;

  /// Selected font name for typed signatures
  final String? fontName;

  /// Base64 encoded signature image
  final String? signatureImageData;

  /// Signature type: 'drawn' or 'typed'
  final SignatureType type;

  /// Timestamp when signature was created
  final DateTime createdAt;

  /// Timestamp when signature was last updated
  final DateTime updatedAt;

  SignatureModel({
    required this.id,
    required this.fullName,
    this.fontName,
    this.signatureImageData,
    required this.type,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  /// Create from JSON
  factory SignatureModel.fromJson(Map<String, dynamic> json) {
    return SignatureModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      fontName: json['fontName'] as String?,
      signatureImageData: json['signatureImageData'] as String?,
      type: SignatureType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SignatureType.drawn,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'fontName': fontName,
      'signatureImageData': signatureImageData,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  SignatureModel copyWith({
    String? id,
    String? fullName,
    String? fontName,
    String? signatureImageData,
    SignatureType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SignatureModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      fontName: fontName ?? this.fontName,
      signatureImageData: signatureImageData ?? this.signatureImageData,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'SignatureModel(id: $id, fullName: $fullName, type: $type)';
  }
}

/// Signature type enum
enum SignatureType {
  /// Signature was drawn by hand
  drawn,

  /// Signature was typed with a font
  typed,
}
