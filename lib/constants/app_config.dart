import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode { light, dark, system }

class AppConfig {
  static const String appName = 'TripOptima';
  static const String appVersion = '1.0.0';
  
  // API Keys (Consider moving these to environment variables or encrypted storage)
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY';
  
  // API Endpoints
  static const String weatherApiBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String googlePlacesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String googleDirectionsBaseUrl = 'https://maps.googleapis.com/maps/api/directions';
  
  // Cache Configuration
  static const int weatherCacheExpiration = 30 * 60; // 30 minutes in seconds
  static const int locationCacheExpiration = 24 * 60 * 60; // 24 hours in seconds
  static const int mapTileCacheSize = 100 * 1024 * 1024; // 100 MB
  
  // App Settings
  static const String prefKeyThemeMode = 'themeMode';
  static const String prefKeyIsFirstRun = 'isFirstRun';
  static const String prefKeyUserLanguage = 'userLanguage';
  static const String prefKeyUnits = 'units'; // metric or imperial
  
  // Default Values
  static const ThemeMode defaultThemeMode = ThemeMode.system;
  static const String defaultLanguage = 'en';
  static const String defaultUnits = 'metric';
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableNotifications = true;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 15);
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}

class ThemeConfig {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D47A1),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: const CardTheme(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF90CAF9),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: const CardTheme(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    ),
  );
}

class AppPreferences {
  static late SharedPreferences _preferences;
  
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }
  
  // Theme Settings
  static ThemeMode getThemeMode() {
    final index = _preferences.getInt(AppConfig.prefKeyThemeMode);
    return index != null ? ThemeMode.values[index] : AppConfig.defaultThemeMode;
  }
  
  static Future<void> setThemeMode(ThemeMode mode) async {
    await _preferences.setInt(AppConfig.prefKeyThemeMode, mode.index);
  }
  
  // First Run Flag
  static bool isFirstRun() {
    return _preferences.getBool(AppConfig.prefKeyIsFirstRun) ?? true;
  }
  
  static Future<void> setFirstRunComplete() async {
    await _preferences.setBool(AppConfig.prefKeyIsFirstRun, false);
  }
  
  // Language Settings
  static String getLanguage() {
    return _preferences.getString(AppConfig.prefKeyUserLanguage) ?? 
        AppConfig.defaultLanguage;
  }
  
  static Future<void> setLanguage(String languageCode) async {
    await _preferences.setString(AppConfig.prefKeyUserLanguage, languageCode);
  }
  
  // Units Settings (metric/imperial)
  static String getUnits() {
    return _preferences.getString(AppConfig.prefKeyUnits) ?? 
        AppConfig.defaultUnits;
  }
  
  static Future<void> setUnits(String units) async {
    await _preferences.setString(AppConfig.prefKeyUnits, units);
  }
  
  // Auth Token
  static String? getAuthToken() {
    return _preferences.getString('authToken');
  }
  
  static Future<void> setAuthToken(String token) async {
    await _preferences.setString('authToken', token);
  }
  
  static Future<void> clearAuthToken() async {
    await _preferences.remove('authToken');
  }
  
  // User ID
  static String? getUserId() {
    return _preferences.getString('userId');
  }
  
  static Future<void> setUserId(String userId) async {
    await _preferences.setString('userId', userId);
  }
  
  static Future<void> clearUserId() async {
    await _preferences.remove('userId');
  }
  
  // Clear all preferences
  static Future<void> clear() async {
    await _preferences.clear();
  }
}
