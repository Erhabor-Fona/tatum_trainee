import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Coordinates the API and local storage for authentication
/// (Week 5, Session 15 — Authentication and Protected Application Flows).
class AuthService {
  final ApiService _api;
  final StorageService _storage;

  AuthService({ApiService? api, StorageService? storage})
      : _api = api ?? ApiService(),
        _storage = storage ?? StorageService();

  Future<User> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    final data = await _api.login(identifier: identifier, password: password);
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    await _storage.saveToken(data['token'] as String);
    await _storage.saveUser(user);
    await _storage.saveRememberMe(rememberMe);
    return user;
  }

  Future<String> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _api.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );
    return data['phoneMasked'] as String? ?? '+234 **** 1234';
  }

  Future<User> verifyOtp(String code) async {
    final data = await _api.verifyOtp(code);
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    await _storage.saveToken(data['token'] as String);
    await _storage.saveUser(user);
    return user;
  }

  Future<void> requestPasswordReset(String identifier) =>
      _api.requestPasswordReset(identifier);

  Future<void> resetPassword(String newPassword) =>
      _api.resetPassword(newPassword);

  /// Restores a previous session, if one exists (used by the splash screen).
  Future<User?> restoreSession() async {
    final token = await _storage.readToken();
    if (token == null) return null;
    return _storage.readUser();
  }

  Future<String?> get token => _storage.readToken();

  Future<void> logout() => _storage.clearSession();
}
