import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UIProvider with ChangeNotifier {
  // Theme state
  ThemeMode _themeMode = ThemeMode.system;
  
  // Loading state
  bool _isLoading = false;
  
  // Error state
  String? _errorMessage;
  bool _hasError = false;
  
  // Navigation state
  int _currentNavIndex = 0;
  
  // Modal states
  bool _isBottomSheetVisible = false;
  bool _isDialogVisible = false;
  
  // App Settings
  bool _useAnimations = true;
  String _languageCode = 'en';
  String _measurementUnit = 'metric'; // metric or imperial
  
  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  int get currentNavIndex => _currentNavIndex;
  bool get isBottomSheetVisible => _isBottomSheetVisible;
  bool get isDialogVisible => _isDialogVisible;
  bool get useAnimations => _useAnimations;
  String get languageCode => _languageCode;
  String get measurementUnit => _measurementUnit;
  
  // Theme methods
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    // Persist setting
    // AppPreferences.setThemeMode(mode);
  }
  
  // Toggle between light and dark mode
  void toggleThemeMode() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
  
  // Loading methods
  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
  
  // Show loading with optional timeout
  void showLoading({int timeoutSeconds = 30}) {
    _isLoading = true;
    notifyListeners();
    
    if (timeoutSeconds > 0) {
      // Auto-hide after timeout
      Future.delayed(Duration(seconds: timeoutSeconds), () {
        if (_isLoading) {
          _isLoading = false;
          notifyListeners();
        }
      });
    }
  }
  
  void hideLoading() {
    _isLoading = false;
    notifyListeners();
  }
  
  // Error methods
  void setError(String message) {
    _errorMessage = message;
    _hasError = true;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    _hasError = false;
    notifyListeners();
  }
  
  // Navigation methods
  void setCurrentNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }
  
  // Modal methods
  void showBottomSheet() {
    _isBottomSheetVisible = true;
    notifyListeners();
  }
  
  void hideBottomSheet() {
    _isBottomSheetVisible = false;
    notifyListeners();
  }
  
  void showDialog() {
    _isDialogVisible = true;
    notifyListeners();
  }
  
  void hideDialog() {
    _isDialogVisible = false;
    notifyListeners();
  }
  
  // Settings methods
  void toggleAnimations() {
    _useAnimations = !_useAnimations;
    notifyListeners();
    // Persist setting
    // AppPreferences.setBool('useAnimations', _useAnimations);
  }
  
  void setLanguage(String languageCode) {
    _languageCode = languageCode;
    notifyListeners();
    // Persist setting
    // AppPreferences.setLanguage(languageCode);
  }
  
  void setMeasurementUnit(String unit) {
    if (unit == 'metric' || unit == 'imperial') {
      _measurementUnit = unit;
      notifyListeners();
      // Persist setting
      // AppPreferences.setUnits(unit);
    }
  }
  
  // Initialize from stored preferences
  Future<void> initFromPreferences() async {
    // Example implementation - would be replaced with actual preferences loading
    /*
    _themeMode = AppPreferences.getThemeMode();
    _useAnimations = AppPreferences.getBool('useAnimations') ?? true;
    _languageCode = AppPreferences.getLanguage();
    _measurementUnit = AppPreferences.getUnits();
    notifyListeners();
    */
  }
}
