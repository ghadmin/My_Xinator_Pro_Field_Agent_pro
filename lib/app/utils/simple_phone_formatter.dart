import 'package:flutter/services.dart';

/// Simple phone number formatter for xxx-xxx-xxxx format
class SimplePhoneFormatter {
  /// Format phone number to xxx-xxx-xxxx
  /// Handles various input formats and returns consistent xxx-xxx-xxxx format
  static String format(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    // Remove all non-digit characters
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Handle number with 10 digits (US format)
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    // Handle number with 11 digits (starts with 1 for US country code)
    if (digits.length == 11 && digits.startsWith('1')) {
      return '${digits.substring(1, 4)}-${digits.substring(4, 7)}-${digits.substring(7)}';
    }

    // For other lengths, return as is or try to format
    if (digits.length < 3) return digits;
    if (digits.length < 6) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    }
    if (digits.length <= 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    // If more than 10 digits after removing 1 prefix, return original
    return phoneNumber;
  }

  /// Validate if phone number matches xxx-xxx-xxxx format
  static bool isValid(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    // Check if matches xxx-xxx-xxxx format
    final regex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    return regex.hasMatch(phoneNumber);
  }

  /// Clean phone number (remove formatting, return digits only)
  static String clean(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  }
}

/// Input formatter for xxx-xxx-xxxx phone number format
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 10 digits
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    // Format as xxx-xxx-xxxx
    String formatted = '';
    if (digits.isNotEmpty) {
      formatted += digits.substring(0, digits.length > 3 ? 3 : digits.length);
    }
    if (digits.length > 3) {
      formatted += '-${digits.substring(3, digits.length > 6 ? 6 : digits.length)}';
    }
    if (digits.length > 6) {
      formatted += '-${digits.substring(6)}';
    }

    // Calculate cursor position
    int cursorPosition = formatted.length;
    if (oldValue.selection.baseOffset < newValue.selection.baseOffset) {
      // User is typing forward
      cursorPosition = formatted.length;
    } else {
      // User is deleting
      int offset = oldValue.selection.baseOffset - newValue.selection.baseOffset;
      cursorPosition = (formatted.length - offset).clamp(0, formatted.length);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

/// Formatter for displaying phone numbers consistently
class PhoneDisplayFormatter {
  /// Format phone number for display
  /// Returns formatted phone number or original if can't format
  static String format(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return '';
    }

    return SimplePhoneFormatter.format(phoneNumber);
  }
}
