import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../app/constants.dart';
import '../models/user.dart';

/// Thin wrapper around SharedPreferences (Week 4, Session 12).
///
/// Keeping storage behind a service class means screens and providers never
/// talk to SharedPreferences directly — swap in Hive/SQLite later without
/// touching the UI.
class StorageService {
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kAuthToken, token);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.kAuthToken);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kLoggedInUser, jsonEncode(user.toJson()));
  }

  Future<User?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.kLoggedInUser);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kRememberMe, value);
  }

  Future<bool> readRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.kRememberMe) ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kDarkMode, value);
  }

  Future<bool> readDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.kDarkMode) ?? false;
  }

  /// Clears the session on logout (token + cached user).
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.kAuthToken);
    await prefs.remove(AppConstants.kLoggedInUser);
  }
}
