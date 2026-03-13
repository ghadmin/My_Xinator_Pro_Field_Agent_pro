class PhoneNumberFormatter {
  /// Format phone number with country code in parentheses and proper formatting
  /// Example: +1 (555) 123-4567
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    // Remove all non-numeric characters except +
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // If number doesn't start with +, add it
    if (!cleanNumber.startsWith('+')) {
      cleanNumber = '+$cleanNumber';
    }

    // Extract country code and national number
    String countryCode = '';
    String nationalNumber = '';

    if (cleanNumber.startsWith('+')) {
      // Find country code (usually 1-3 digits after +)
      int digitsAfterPlus = 0;
      for (int i = 1; i < cleanNumber.length; i++) {
        if (RegExp(r'\d').hasMatch(cleanNumber[i])) {
          digitsAfterPlus++;
          if (digitsAfterPlus > 3) break; // Max 3 digits for country code
        }
      }

      // Detect country code length based on common patterns
      int countryCodeLength = _detectCountryCodeLength(cleanNumber);

      if (cleanNumber.length > countryCodeLength + 1) {
        countryCode = cleanNumber.substring(1, countryCodeLength + 1);
        nationalNumber = cleanNumber.substring(countryCodeLength + 1);
      } else {
        return cleanNumber; // Return as is if format is unusual
      }
    }

    // Format national number based on country
    String formattedNational =
        _formatNationalNumber(countryCode, nationalNumber);

    // Combine: +countryCode (national number) for US/Canada
    if (countryCode == '1' || _isSpecialCountryCode('1$countryCode')) {
      return '+$countryCode ($formattedNational)';
    }

    // For other countries: include country code
    return '+$countryCode $formattedNational';
  }

  /// Detect country code length based on common patterns
  static int _detectCountryCodeLength(String phoneNumber) {
    // Remove + for checking
    String digits = phoneNumber.substring(1); // Skip +

    // North America (USA/Canada): +1
    if (digits.startsWith('1')) {
      // Check if next digit makes it a different country
      if (digits.length > 2) {
        // Some countries start with 1x (like Jamaica +1876)
        String potential = digits.substring(0, 3);
        if (_isSpecialCountryCode(potential)) {
          return 3;
        }
      }
      return 1;
    }

    // Check for 3-digit country codes (most common)
    if (digits.length >= 3) {
      String potential = digits.substring(0, 3);
      if (_isValidCountryCode(potential)) {
        return 3;
      }
    }

    // Check for 2-digit country codes
    if (digits.length >= 2) {
      String potential = digits.substring(0, 2);
      if (_isValidCountryCode(potential)) {
        return 2;
      }
    }

    // Default to 1 or 2 digits based on length
    return digits.length >= 2 ? 2 : 1;
  }

  /// Check if code is a valid country code
  static bool _isValidCountryCode(String code) {
    // Common 2-3 digit country codes
    final validCodes = {
      '1', // USA/Canada
      '7', // Russia/Kazakhstan
      '20', // Egypt
      '27', // South Africa
      '31', // Netherlands
      '32', // Belgium
      '33', // France
      '34', // Spain
      '39', // Italy
      '41', // Switzerland
      '43', // Austria
      '44', // UK
      '45', // Denmark
      '46', // Sweden
      '47', // Norway
      '49', // Germany
      '52', // Mexico
      '55', // Brazil
      '61', // Australia
      '81', // Japan
      '86', // China
      '91', // India
      '92', // Pakistan
      '93', // Afghanistan
      '94', // Sri Lanka
      '95', // Myanmar
      '98', // Iran
      '233', // Ghana
      '234', // Nigeria
      '250', // Rwanda
      '254', // Kenya
      '255', // Tanzania
      '256', // Uganda
      '261', // Madagascar
      '263', // Zimbabwe
      '264', // Namibia
      '265', // Malawi
      '266', // Lesotho
      '267', // Botswana
      '268', // Eswatini
      '269', // Comoros
      '351', // Portugal
      '353', // Ireland
      '357', // Cyprus
      '358', // Finland
      '370', // Lithuania
      '371', // Latvia
      '372', // Estonia
      '373', // Moldova
      '374', // Armenia
      '375', // Belarus
      '376', // Andorra
      '377', // Monaco
      '378', // San Marino
      '380', // Ukraine
      '381', // Serbia
      '382', // Montenegro
      '383', // Kosovo
      '385', // Croatia
      '386', // Slovenia
      '387', // Bosnia
      '389', // North Macedonia
      '500', // Falkland Islands
      '501', // Belize
      '502', // Guatemala
      '503', // El Salvador
      '504', // Honduras
      '505', // Nicaragua
      '506', // Costa Rica
      '507', // Panama
      '508', // Saint Pierre
      '590', // Guadeloupe
      '591', // Bolivia
      '592', // Guyana
      '593', // Ecuador
      '594', // French Guiana
      '595', // Paraguay
      '596', // Martinique
      '597', // Suriname
      '598', // Uruguay
      '965', // Kuwait
      '966', // Saudi Arabia
      '968', // Oman
      '971', // UAE
      '973', // Bahrain
      '974', // Qatar
      '994', // Azerbaijan
      '995', // Georgia
      '996', // Kyrgyzstan
      '998', // Uzbekistan
    };

    return validCodes.contains(code);
  }

  /// Check if it's a special country code starting with 1
  static bool _isSpecialCountryCode(String code) {
    // Caribbean countries that share +1 area code
    final specialCodes = {
      '1242', // Bahamas
      '1246', // Barbados
      '1264', // Anguilla
      '1268', // Antigua
      '1284', // British Virgin Islands
      '1340', // US Virgin Islands
      '1345', // Cayman Islands
      '1441', // Bermuda
      '1473', // Grenada
      '1649', // Turks and Caicos
      '1664', // Montserrat
      '1670', // Guam
      '1671', // Northern Mariana Islands
      '1684', // American Samoa
      '1721', // Sint Maarten
      '1758', // Saint Lucia
      '1767', // Dominica
      '1784', // Saint Vincent
      '1787', // Puerto Rico
      '1809', // Dominican Republic
      '1829', // Dominican Republic
      '1849', // Dominican Republic
      '1868', // Trinidad
      '1869', // Saint Kitts
      '1876', // Jamaica
      '1939', // Puerto Rico
    };

    return specialCodes.contains(code);
  }

  /// Format national number based on country rules
  static String _formatNationalNumber(
      String countryCode, String nationalNumber) {
    if (nationalNumber.isEmpty) return '';

    // USA/Canada (+1): (XXX) XXX-XXXX
    if (countryCode == '1' || _isSpecialCountryCode('1$countryCode')) {
      return _formatUSNumber(nationalNumber);
    }

    // UK (+44): XXXX XXXXXX or XXXXX XXXXXX
    if (countryCode == '44') {
      return _formatUKNumber(nationalNumber);
    }

    // India (+91): XXXXX XXXXX
    if (countryCode == '91') {
      return _formatIndianNumber(nationalNumber);
    }

    // Germany (+49): XXX XXXXXXXX
    if (countryCode == '49') {
      return _formatGermanNumber(nationalNumber);
    }

    // France (+33): X XX XX XX XX
    if (countryCode == '33') {
      return _formatFrenchNumber(nationalNumber);
    }

    // China (+86): XXX XXXX XXXX
    if (countryCode == '86') {
      return _formatChineseNumber(nationalNumber);
    }

    // Default: Group in 3-4 digits
    return _formatDefault(nationalNumber);
  }

  static String _formatUSNumber(String number) {
    if (number.length == 10) {
      return '(${number.substring(0, 3)}) ${number.substring(3, 6)}-${number.substring(6)}';
    }
    return _formatDefault(number);
  }

  static String _formatUKNumber(String number) {
    // Remove leading 0 if present
    if (number.startsWith('0')) {
      number = number.substring(1);
    }

    if (number.length == 10) {
      // London format: XXXX XXXXXX
      return '${number.substring(0, 4)} ${number.substring(4)}';
    } else if (number.length == 9) {
      // Other UK: XXXXX XXXXX
      return '${number.substring(0, 5)} ${number.substring(5)}';
    }
    return _formatDefault(number);
  }

  static String _formatIndianNumber(String number) {
    if (number.length == 10) {
      return '${number.substring(0, 5)} ${number.substring(5)}';
    }
    return _formatDefault(number);
  }

  static String _formatGermanNumber(String number) {
    // Remove leading 0 if present
    if (number.startsWith('0')) {
      number = number.substring(1);
    }

    if (number.length >= 10) {
      return '${number.substring(0, 3)} ${number.substring(3, 7)} ${number.substring(7)}';
    }
    return _formatDefault(number);
  }

  static String _formatFrenchNumber(String number) {
    // Remove leading 0 if present
    if (number.startsWith('0')) {
      number = number.substring(1);
    }

    if (number.length == 9) {
      return '${number.substring(0, 1)} ${number.substring(1, 3)} ${number.substring(3, 5)} ${number.substring(5, 7)} ${number.substring(7)}';
    }
    return _formatDefault(number);
  }

  static String _formatChineseNumber(String number) {
    if (number.length == 11) {
      return '${number.substring(0, 3)} ${number.substring(3, 7)} ${number.substring(7)}';
    }
    return _formatDefault(number);
  }

  static String _formatDefault(String number) {
    // Group digits in 3s or 4s
    List<String> groups = [];
    int i = 0;

    while (i < number.length) {
      int groupSize = (number.length - i) % 3 == 1 && i > 0 ? 2 : 3;
      if (i + groupSize > number.length) {
        groupSize = number.length - i;
      }
      groups.add(number.substring(i, i + groupSize));
      i += groupSize;
    }

    return groups.join(' ');
  }
}
