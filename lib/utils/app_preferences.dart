import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late SharedPreferences _prefs;
  
  // Keys
  static const String _keyThemeMode = 'themeMode';
  static const String _keyIsFirstRun = 'isFirstRun';
  static const String _keyUserLanguage = 'userLanguage';
  static const String _keyUseAnimations = 'useAnimations';
  static const String _keyMeasurementUnit = 'measurementUnit'; // metric or imperial
  static const String _keyLastLoginDate = 'lastLoginDate';
  static const String _keyAuthToken = 'authToken';
  static const String _keyUserId = 'userId';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserName = 'userName';
  static const String _keyUserPhotoUrl = 'userPhotoUrl';
  
  // Initialize preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Theme Mode
  static ThemeMode getThemeMode() {
    final String? mode = _prefs.getString(_keyThemeMode);
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
  
  static Future<void> setThemeMode(ThemeMode mode) async {
    String modeString;
    switch (mode) {
      case ThemeMode.light: modeString = 'light'; break;
      case ThemeMode.dark: modeString = 'dark'; break;
      default: modeString = 'system'; break;
    }
    await _prefs.setString(_keyThemeMode, modeString);
  }
  
  // First Run
  static bool isFirstRun() {
    return _prefs.getBool(_keyIsFirstRun) ?? true;
  }
  
  static Future<void> setFirstRunComplete() async {
    await _prefs.setBool(_keyIsFirstRun, false);
  }
  
  // Language
  static String getUserLanguage() {
    return _prefs.getString(_keyUserLanguage) ?? 'en';
  }
  
  static Future<void> setUserLanguage(String languageCode) async {
    await _prefs.setString(_keyUserLanguage, languageCode);
  }
  
  // Animations
  static bool useAnimations() {
    return _prefs.getBool(_keyUseAnimations) ?? true;
  }
  
  static Future<void> setUseAnimations(bool useAnimations) async {
    await _prefs.setBool(_keyUseAnimations, useAnimations);
  }
  
  // Measurement Unit
  static String getMeasurementUnit() {
    return _prefs.getString(_keyMeasurementUnit) ?? 'metric';
  }
  
  static Future<void> setMeasurementUnit(String unit) async {
    await _prefs.setString(_keyMeasurementUnit, unit);
  }
  
  // Authentication
  static String? getAuthToken() {
    return _prefs.getString(_keyAuthToken);
  }
  
  static Future<void> setAuthToken(String? token) async {
    if (token != null) {
      await _prefs.setString(_keyAuthToken, token);
      await _prefs.setString(_keyLastLoginDate, DateTime.now().toIso8601String());
    } else {
      await _prefs.remove(_keyAuthToken);
    }
  }
  
  static bool isLoggedIn() {
    return _prefs.containsKey(_keyAuthToken) && 
           _prefs.getString(_keyAuthToken) != null &&
           _prefs.getString(_keyAuthToken)!.isNotEmpty;
  }
  
  static Future<void> clearAuthData() async {
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserPhotoUrl);
  }
  
  // User Data
  static String? getUserId() {
    return _prefs.getString(_keyUserId);
  }
  
  static Future<void> setUserId(String? userId) async {
    if (userId != null) {
      await _prefs.setString(_keyUserId, userId);
    } else {
      await _prefs.remove(_keyUserId);
    }
  }
  
  static String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }
  
  static Future<void> setUserEmail(String? email) async {
    if (email != null) {
      await _prefs.setString(_keyUserEmail, email);
    } else {
      await _prefs.remove(_keyUserEmail);
    }
  }
  
  static String? getUserName() {
    return _prefs.getString(_keyUserName);
  }
  
  static Future<void> setUserName(String? name) async {
    if (name != null) {
      await _prefs.setString(_keyUserName, name);
    } else {
      await _prefs.remove(_keyUserName);
    }
  }
  
  static String? getUserPhotoUrl() {
    return _prefs.getString(_keyUserPhotoUrl);
  }
  
  static Future<void> setUserPhotoUrl(String? photoUrl) async {
    if (photoUrl != null) {
      await _prefs.setString(_keyUserPhotoUrl, photoUrl);
    } else {
      await _prefs.remove(_keyUserPhotoUrl);
    }
  }
  
  // Last login date
  static DateTime? getLastLoginDate() {
    final String? dateStr = _prefs.getString(_keyLastLoginDate);
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }
  
  // Clear all preferences
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
