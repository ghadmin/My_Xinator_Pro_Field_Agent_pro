import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myxinator_pro_field_agent_pro/app/models/signature/signature_model.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

/// Signature Repository
///
/// Handles local storage of signatures using Hive
class SignatureRepository {
  static const String _signaturesBoxKey = 'user_signatures';
  static Box<dynamic>? _signaturesBox;
  static bool _isInitialized = false;

  /// Initialize the signatures box
  static Future<void> initSignaturesBox() async {
    if (_isInitialized) return;

    try {
      _signaturesBox = await Hive.openBox<dynamic>(_signaturesBoxKey);
      _isInitialized = true;
      kLog('✅ Signatures box initialized');
    } catch (e) {
      kLog('❌ Error initializing signatures box: $e');
    }
  }

  /// Ensure the box is initialized before use
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized || _signaturesBox == null) {
      await initSignaturesBox();
    }
  }

  /// Save a signature to local storage
  Future<bool> saveSignature(SignatureModel signature) async {
    try {
      await _ensureInitialized();
      await _signaturesBox!.put(signature.id, signature.toJson());
      kLog('✅ Signature saved: ${signature.id}');
      return true;
    } catch (e) {
      kLog('❌ Error saving signature: $e');
      return false;
    }
  }

  /// Get all saved signatures
  Future<List<SignatureModel>> getAllSignatures() async {
    try {
      await _ensureInitialized();
      final signatures = <SignatureModel>[];
      final box = _signaturesBox!;
      for (final key in box.keys) {
        final data = box.get(key);
        if (data != null && data is Map<String, dynamic>) {
          try {
            signatures.add(SignatureModel.fromJson(data));
          } catch (e) {
            log('Error parsing signature: $e');
          }
        }
      }
      return signatures;
    } catch (e) {
      kLog('❌ Error loading signatures: $e');
      return [];
    }
  }

  /// Get a specific signature by ID
  Future<SignatureModel?> getSignatureById(String id) async {
    try {
      await _ensureInitialized();
      final data = _signaturesBox!.get(id);
      if (data != null && data is Map) {
        return SignatureModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      kLog('❌ Error getting signature: $e');
      return null;
    }
  }

  /// Get the most recent signature
  Future<SignatureModel?> getLatestSignature() async {
    try {
      final signatures = await getAllSignatures();
      if (signatures.isEmpty) return null;

      signatures.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return signatures.first;
    } catch (e) {
      kLog('❌ Error getting latest signature: $e');
      return null;
    }
  }

  /// Delete a signature by ID
  Future<bool> deleteSignature(String id) async {
    try {
      await _ensureInitialized();
      await _signaturesBox!.delete(id);
      kLog('✅ Signature deleted: $id');
      return true;
    } catch (e) {
      kLog('❌ Error deleting signature: $e');
      return false;
    }
  }

  /// Clear all signatures
  Future<bool> clearAllSignatures() async {
    try {
      await _ensureInitialized();
      await _signaturesBox!.clear();
      kLog('✅ All signatures cleared');
      return true;
    } catch (e) {
      kLog('❌ Error clearing signatures: $e');
      return false;
    }
  }
}
