import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String? userData;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.userData,
    this.errorMessage,
  });
}

class AuthStatus {
  final bool isLoggedIn;
  final String? userData;

  AuthStatus({
    required this.isLoggedIn,
    this.userData,
  });
}

class AuthRepository {
  final SharedPreferences prefs;
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userDataKey = 'current_member';
  static const String _showHomeKey = 'showHome';

  AuthRepository({required this.prefs});

  Future<AuthResult> login(String username, String password) async {
    try {
      // This is where you would normally call your API to authenticate
      // For now, we're simulating a successful login

      // Simulate some user data
      final userData = json.encode({
        'id': '1',
        'username': username,
        'role': username.contains('admin') ? 'admin' : 'member',
        // Add other user fields as needed
      });

      // Save to SharedPreferences
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userDataKey, userData);
      await prefs.setBool(_showHomeKey, true);

      return AuthResult(
        success: true,
        userData: userData,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.setString(_userDataKey, 'no');
    // We keep showHome true to avoid showing splash screen again
  }

  Future<AuthStatus> isAuthenticated() async {
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final userData = prefs.getString(_userDataKey);

    return AuthStatus(
      isLoggedIn: isLoggedIn && userData != null && userData != 'no',
      userData: userData,
    );
  }
}
