import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trip_optima_mobile_app/models/user_model.dart';
import 'package:trip_optima_mobile_app/constants/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  registering,
  loggingIn,
  loggingOut,
  verifyingEmail,
  resettingPassword,
  error
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  Timer? _authTimer;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  
  AuthProvider() {
    // Check if user is already logged in
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    _setStatus(AuthStatus.initial);
    
    try {
      // Check for existing auth token
      final storedToken = AppPreferences.getAuthToken();
      final userId = AppPreferences.getUserId();
      
      if (storedToken != null && userId != null) {
        // Auto-login from stored credentials
        final user = _firebaseAuth.currentUser;
        
        if (user != null) {
          await _fetchUserData(user.uid);
          _setStatus(AuthStatus.authenticated);
          _startAuthExpirationTimer();
        } else {
          // Token exists but Firebase session expired
          AppPreferences.clearAuthToken();
          AppPreferences.clearUserId();
          _setStatus(AuthStatus.unauthenticated);
        }
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _handleError('Auto-login failed: ${e.toString()}');
      _setStatus(AuthStatus.unauthenticated);
    }
  }
  
  // Register with email and password
  Future<bool> registerWithEmailAndPassword(
    String email, 
    String password, 
    String name
  ) async {
    _setStatus(AuthStatus.registering);
    _clearError();
    
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Update user profile
        await userCredential.user!.updateDisplayName(name);
        
        // Create user record in database
        final newUser = UserModel(
          id: userCredential.user!.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        // Save user to database
        await _saveUserToDatabase(newUser);
        
        // Send email verification
        await userCredential.user!.sendEmailVerification();
        
        // Set current user
        _currentUser = newUser;
        
        // Save auth data
        _saveAuthData(userCredential);
        
        _setStatus(AuthStatus.authenticated);
        return true;
      }
      
      _setStatus(AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      _handleError('Registration failed: ${e.toString()}');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }
  
  // Login with email and password
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    _setStatus(AuthStatus.loggingIn);
    _clearError();
    
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _fetchUserData(userCredential.user!.uid);
        
        // Update last login time
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(
            lastLoginAt: DateTime.now(),
          );
          await _updateUserLastLogin(_currentUser!);
        }
        
        // Save auth data
        _saveAuthData(userCredential);
        
        _setStatus(AuthStatus.authenticated);
        _startAuthExpirationTimer();
        return true;
      }
      
      _setStatus(AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      _handleError('Login failed: ${e.toString()}');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }
  
  // Login with Google
  Future<bool> loginWithGoogle() async {
    _setStatus(AuthStatus.loggingIn);
    _clearError();
    
    try {
      // Trigger the Google Sign In flow
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in flow
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }
      
      // Get authentication details
      final googleAuth = await googleUser.authentication;
      
      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if this is a new or existing user
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        
        if (isNewUser) {
          // Create new user profile
          final newUser = UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            name: userCredential.user!.displayName ?? 'User',
            photoUrl: userCredential.user!.photoURL,
            isEmailVerified: true, // Google accounts are verified
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          
          await _saveUserToDatabase(newUser);
          _currentUser = newUser;
        } else {
          // Fetch existing user data
          await _fetchUserData(userCredential.user!.uid);
          
          // Update last login
          if (_currentUser != null) {
            _currentUser = _currentUser!.copyWith(
              lastLoginAt: DateTime.now(),
            );
            await _updateUserLastLogin(_currentUser!);
          }
        }
        
        // Save auth data
        _saveAuthData(userCredential);
        
        _setStatus(AuthStatus.authenticated);
        _startAuthExpirationTimer();
        return true;
      }
      
      _setStatus(AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      _handleError('Google login failed: ${e.toString()}');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }
  
  // Log out
  Future<void> logout() async {
    _setStatus(AuthStatus.loggingOut);
    
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // Clear auth data
      AppPreferences.clearAuthToken();
      AppPreferences.clearUserId();
      
      // Clear auth timer
      _cancelAuthExpirationTimer();
      
      // Clear current user
      _currentUser = null;
      
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _handleError('Logout failed: ${e.toString()}');
    }
  }
  
  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setStatus(AuthStatus.resettingPassword);
    _clearError();
    
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _setStatus(AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      _handleError('Password reset failed: ${e.toString()}');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }
  
  // Verify email
  Future<bool> sendEmailVerification() async {
    if (_firebaseAuth.currentUser == null) {
      _handleError('No user is signed in');
      return false;
    }
    
    _setStatus(AuthStatus.verifyingEmail);
    _clearError();
    
    try {
      await _firebaseAuth.currentUser!.sendEmailVerification();
      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _handleError('Email verification failed: ${e.toString()}');
      _setStatus(AuthStatus.authenticated);
      return false;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    if (_currentUser == null) {
      _handleError('No user is signed in');
      return false;
    }
    
    _clearError();
    
    try {
      // Update Firebase user profile if needed
      if (name != null) {
        await _firebaseAuth.currentUser!.updateDisplayName(name);
      }
      
      if (photoUrl != null) {
        await _firebaseAuth.currentUser!.updatePhotoURL(photoUrl);
      }
      
      // Create updated user
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        preferences: preferences ?? _currentUser!.preferences,
      );
      
      // Update database
      await _updateUserInDatabase(updatedUser);
      
      // Update local user
      _currentUser = updatedUser;
      notifyListeners();
      
      return true;
    } catch (e) {
      _handleError('Profile update failed: ${e.toString()}');
      return false;
    }
  }
  
  // Update user password
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    if (_firebaseAuth.currentUser == null || _currentUser == null) {
      _handleError('No user is signed in');
      return false;
    }
    
    _clearError();
    
    try {
      // Re-authenticate user first
      final credential = EmailAuthProvider.credential(
        email: _currentUser!.email,
        password: currentPassword,
      );
      
      await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
      
      // Update password
      await _firebaseAuth.currentUser!.updatePassword(newPassword);
      
      return true;
    } catch (e) {
      _handleError('Password update failed: ${e.toString()}');
      return false;
    }
  }
  
  // Delete user account
  Future<bool> deleteAccount(String password) async {
    if (_firebaseAuth.currentUser == null || _currentUser == null) {
      _handleError('No user is signed in');
      return false;
    }
    
    _clearError();
    
    try {
      // Re-authenticate user first
      AuthCredential? credential;
      
      // Check if this is an email/password user
      if (_firebaseAuth.currentUser!.providerData.any(
        (info) => info.providerId == 'password'
      )) {
        credential = EmailAuthProvider.credential(
          email: _currentUser!.email,
          password: password,
        );
      } else if (_firebaseAuth.currentUser!.providerData.any(
        (info) => info.providerId == 'google.com'
      )) {
        // For Google users, need to reauth with Google
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          _handleError('Authentication canceled');
          return false;
        }
        
        final googleAuth = await googleUser.authentication;
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      } else {
        _handleError('Unsupported authentication provider');
        return false;
      }
      
      // Reauthenticate
      await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
      
      // Delete user data from database
      await _deleteUserFromDatabase(_currentUser!.id);
      
      // Delete Firebase user
      await _firebaseAuth.currentUser!.delete();
      
      // Clear local data
      AppPreferences.clearAuthToken();
      AppPreferences.clearUserId();
      _currentUser = null;
      _cancelAuthExpirationTimer();
      
      _setStatus(AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      _handleError('Account deletion failed: ${e.toString()}');
      return false;
    }
  }
  
  // Update favorite locations
  Future<bool> updateFavoriteLocations(List<String> favoriteLocations) async {
    if (_currentUser == null) {
      _handleError('No user is signed in');
      return false;
    }
    
    try {
      final updatedUser = _currentUser!.copyWith(
        favoriteLocations: favoriteLocations,
      );
      
      await _updateUserInDatabase(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
      
      return true;
    } catch (e) {
      _handleError('Failed to update favorite locations: ${e.toString()}');
      return false;
    }
  }
  
  // Private methods
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
  
  void _handleError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  Future<void> _fetchUserData(String userId) async {
    try {
      // TODO: Implement actual API call to fetch user data
      // This is a placeholder - in a real app, you would fetch from your backend
      
      // For now, create a basic user with the ID
      _currentUser = UserModel(
        id: userId,
        email: _firebaseAuth.currentUser?.email ?? '',
        name: _firebaseAuth.currentUser?.displayName ?? 'User',
        photoUrl: _firebaseAuth.currentUser?.photoURL,
        isEmailVerified: _firebaseAuth.currentUser?.emailVerified ?? false,
        createdAt: DateTime.now(), // Should come from database
        lastLoginAt: DateTime.now(),
      );
    } catch (e) {
      _handleError('Failed to fetch user data: ${e.toString()}');
      throw e; // Re-throw to be handled by calling method
    }
  }
  
  Future<void> _saveUserToDatabase(UserModel user) async {
    // TODO: Implement actual API call to save user data
    // This is a placeholder - in a real app, you would save to your backend
  }
  
  Future<void> _updateUserInDatabase(UserModel user) async {
    // TODO: Implement actual API call to update user data
    // This is a placeholder - in a real app, you would update in your backend
  }
  
  Future<void> _deleteUserFromDatabase(String userId) async {
    // TODO: Implement actual API call to delete user data
    // This is a placeholder - in a real app, you would delete from your backend
  }
  
  Future<void> _updateUserLastLogin(UserModel user) async {
    // TODO: Implement actual API call to update last login
    // This is a placeholder - in a real app, you would update in your backend
  }
  
  void _saveAuthData(UserCredential credential) {
    // Get token
    credential.user?.getIdToken().then((token) {
      if (token != null) {
        AppPreferences.setAuthToken(token);
        AppPreferences.setUserId(credential.user!.uid);
      }
    });
  }
  
  void _startAuthExpirationTimer() {
    _cancelAuthExpirationTimer();
    
    // Refresh token every hour to ensure it doesn't expire
    _authTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) async {
        if (_firebaseAuth.currentUser != null) {
          final newToken = await _firebaseAuth.currentUser!.getIdToken(true);
          AppPreferences.setAuthToken(newToken);
        }
      },
    );
  }
  
  void _cancelAuthExpirationTimer() {
    _authTimer?.cancel();
    _authTimer = null;
  }
  
  @override
  void dispose() {
    _cancelAuthExpirationTimer();
    super.dispose();
  }
}
