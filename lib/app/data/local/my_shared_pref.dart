// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/translations/localization_service.dart';

class MySharedPref {
  // prevent making instance
  MySharedPref._();

  // shared pref init
  static SharedPreferences? _sharedPreferences;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // STORING KEYS
  static const String _fcmTokenKey = 'fcm_token';

  static const String _emailKey = 'email';
  static const String _userNameKey = 'user_name';
  static const String _companyIDKey = 'company_id';
  static const String _companyNameKey = 'company_name';
  static const String _companyTypeKey = 'company_tag';
  static const String _resourceIDKey = 'resource_id';
  static const String _currentLocalKey = 'current_local';
  static const String _lightThemeKey = 'is_theme_light';

  /// set email
  static setEmail(String email) =>
      _sharedPreferences!.setString(_emailKey, email);

  /// get email
  static getEmail() => _sharedPreferences!.getString(_emailKey);

  /// remove email
  static Future<bool> removeEmail() => _sharedPreferences!.remove(_emailKey);

  /// set userName
  static setUserName(String userName) =>
      _sharedPreferences!.setString(_userNameKey, userName);

  /// get userName
  static getUserName() => _sharedPreferences!.getString(_userNameKey);

  /// remove userName
  static Future<bool> removeUserName() =>
      _sharedPreferences!.remove(_userNameKey);

  /// set company_id
  static setCompanyID(String companyID) =>
      _sharedPreferences!.setString(_companyIDKey, companyID);

  /// get company_id
  static getCompanyID() => _sharedPreferences!.getString(_companyIDKey);

  /// remove company_id
  static Future<bool> removeCompanyID() =>
      _sharedPreferences!.remove(_companyIDKey);

  /// set company_name
  static setCompanyName(String companyName) =>
      _sharedPreferences!.setString(_companyNameKey, companyName);

  /// get company_name
  static getCompanyName() => _sharedPreferences!.getString(_companyNameKey);

  /// set company_tag
  static setCompanyType(String companyType) =>
      _sharedPreferences!.setString(_companyTypeKey, companyType);

  /// get company_tag
  static String? getCompanyType() =>
      _sharedPreferences!.getString(_companyTypeKey);

  /// set resource_id
  static setResourceID(int resourceID) =>
      _sharedPreferences!.setInt(_resourceIDKey, resourceID);

  /// get resource_id
  static int? getResourceID() => _sharedPreferences!.getInt(_resourceIDKey);

  /// remove resource_id
  static Future<bool> removeResourceID() =>
      _sharedPreferences!.remove(_resourceIDKey);

  /// remove company_name
  static Future<bool> removeCompanyName() =>
      _sharedPreferences!.remove(_companyNameKey);

  /// set theme current type as light theme
  static Future<void> setThemeIsLight(bool lightTheme) =>
      _sharedPreferences!.setBool(_lightThemeKey, lightTheme);

  /// get if the current theme type is light
  static bool getThemeIsLight() =>
      _sharedPreferences!.getBool(_lightThemeKey) ?? true;

  /// save current locale
  static void setCurrentLanguage(String languageCode) =>
      _sharedPreferences!.setString(_currentLocalKey, languageCode);

  /// get current locale
  static Locale getCurrentLocal() {
    String? langCode = _sharedPreferences!.getString(_currentLocalKey);
    // default language is english
    if (langCode == null) {
      return LocalizationService.defaultLanguage;
    }
    return LocalizationService.supportedLanguages[langCode]!;
  }

  /// save generated fcm token
  static Future<void> setFcmToken(String token) =>
      _sharedPreferences!.setString(_fcmTokenKey, token);

  /// get generated fcm token
  static String? getFcmToken() => _sharedPreferences!.getString(_fcmTokenKey);

  /// clear all data from shared pref except the current language
  static Future<void> clearExceptLanguage() async {
    // Step 1: Retrieve the current language from shared preferences
    final currentLanguage = _sharedPreferences!.getString(_currentLocalKey);

    // Step 2: Clear all the shared preferences
    await _sharedPreferences!.clear();

    // Step 3: Set the current language back to the shared preferences
    if (currentLanguage != null) {
      setCurrentLanguage(currentLanguage);
    }
  }

  /// clear all data from shared pref except email
  static Future<void> clearExceptEmail() async {
    // Step 1: Retrieve the email and company code from shared preferences
    final email = _sharedPreferences!.getString(_emailKey);

    // Step 2: Clear all the shared preferences
    await _sharedPreferences!.clear();

    // Step 3: Set the email and company code back to the shared preferences
    if (email != null) {
      setEmail(email);
    }
  }

  /// clear all data from shared pref
  static Future<void> clear() async => await _sharedPreferences!.clear();
}
