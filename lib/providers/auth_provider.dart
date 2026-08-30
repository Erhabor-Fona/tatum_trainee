import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

/// App-wide authentication state (Week 4, Session 11 — Provider).
///
/// Screens read [status], [user], [isLoading] and [errorMessage]; the
/// provider owns the business logic and notifies listeners on change.
class AuthProvider extends ChangeNotifier {
  final AuthService _auth;
  final StorageService _storage;

  AuthProvider({AuthService? auth, StorageService? storage})
      : _auth = auth ?? AuthService(),
        _storage = storage ?? StorageService();

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String _pendingPhoneMasked = '';
  bool _darkMode = false;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get pendingPhoneMasked => _pendingPhoneMasked;
  bool get darkMode => _darkMode;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  /// Called by the splash screen to restore any saved session.
  Future<void> bootstrap() async {
    _darkMode = await _storage.readDarkMode();
    final restored = await _auth.restoreSession();
    _user = restored;
    _status = restored == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    _begin();
    try {
      _user = await _auth.login(
        identifier: identifier,
        password: password,
        rememberMe: rememberMe,
      );
      _status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to log in right now. Please try again.';
      return false;
    } finally {
      _end();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _begin();
    try {
      _pendingPhoneMasked = await _auth.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _end();
    }
  }

  Future<bool> verifyOtp(String code) async {
    _begin();
    try {
      _user = await _auth.verifyOtp(code);
      _status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _end();
    }
  }

  Future<bool> requestPasswordReset(String identifier) async {
    _begin();
    try {
      await _auth.requestPasswordReset(identifier);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _end();
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    _begin();
    try {
      await _auth.resetPassword(newPassword);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _end();
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _darkMode = value;
    await _storage.saveDarkMode(value);
    notifyListeners();
  }

  void _begin() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _end() {
    _isLoading = false;
    notifyListeners();
  }
}
