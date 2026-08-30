import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app/constants.dart';
import '../models/account.dart';
import '../models/account_limit.dart';
import '../models/bank_transaction.dart';
import '../models/user.dart';

/// Thrown for any API failure so the UI can show a friendly message
/// (Week 5, Session 14 — handling API responses and managing errors).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// REST API layer (Week 5).
///
/// When [AppConstants.useMockApi] is true (the classroom default) every call
/// resolves against in-memory demo data after a short delay, so the whole
/// app works offline. Flip the flag and the same methods hit the real
/// backend over HTTP — the screens never change.
class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers([String? token]) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ---------------------------------------------------------------- AUTH --

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    if (AppConstants.useMockApi) {
      await _mockDelay();
      if (password.length < 8) {
        throw const ApiException('Invalid email/phone or password.');
      }
      return {
        'token': 'mock.jwt.token',
        'user': _mockUser.toJson(),
      };
    }
    final res = await _client.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
      headers: _headers(),
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (AppConstants.useMockApi) {
      await _mockDelay();
      return {
        'otpRequired': true,
        'phoneMasked': '+234 **** ${phone.length >= 4 ? phone.substring(phone.length - 4) : phone}',
      };
    }
    final res = await _client.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> verifyOtp(String code) async {
    if (AppConstants.useMockApi) {
      await _mockDelay();
      if (code != '000000' && code.length == AppConstants.otpLength) {
        return {'token': 'mock.jwt.token', 'user': _mockUser.toJson()};
      }
      throw const ApiException("That code didn't match. Please try again.");
    }
    final res = await _client.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/verify-otp'),
      headers: _headers(),
      body: jsonEncode({'code': code}),
    );
    return _decode(res);
  }

  Future<void> requestPasswordReset(String identifier) async {
    if (AppConstants.useMockApi) {
      await _mockDelay();
      return;
    }
    final res = await _client.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/forgot-password'),
      headers: _headers(),
      body: jsonEncode({'identifier': identifier}),
    );
    _decode(res);
  }

  Future<void> resetPassword(String newPassword) async {
    if (AppConstants.useMockApi) {
      await _mockDelay();
      return;
    }
    final res = await _client.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/reset-password'),
      headers: _headers(),
      body: jsonEncode({'password': newPassword}),
    );
    _decode(res);
  }

  // ------------------------------------------------------------- ACCOUNT --

  Future<Account> fetchAccount(String token) async {
    if (AppConstants.useMockApi) {
      await _mockDelay();
      return _mockAccount;
    }
    final res = await _client.get(
      Uri.parse('${AppConstants.apiBaseUrl}/accounts/me'),
      headers: _headers(token),
    );
    return Account.fromJson(_decode(res));
  }

  Future<List<BankTransaction>> fetchTransactions(String token) async {
    if (AppConstants.useMockApi) {
      await _mockDelay();
      return _mockTransactions;
    }
    final res = await _client.get(
      Uri.parse('${AppConstants.apiBaseUrl}/transactions'),
      headers: _headers(token),
    );
    final list = _decode(res)['items'] as List<dynamic>? ?? [];
    return list
        .map((e) => BankTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AccountLimit>> fetchLimits(String token) async {
    if (AppConstants.useMockApi) {
      await _mockDelay();
      return _mockLimits;
    }
    final res = await _client.get(
      Uri.parse('${AppConstants.apiBaseUrl}/accounts/limits'),
      headers: _headers(token),
    );
    final list = _decode(res)['items'] as List<dynamic>? ?? [];
    return list
        .map((e) => AccountLimit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ------------------------------------------------------------- HELPERS --

  Map<String, dynamic> _decode(http.Response res) {
    final body = res.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    if (res.statusCode == 401) {
      throw const ApiException('Your session has expired. Please log in again.',
          statusCode: 401);
    }
    throw ApiException(
      body['message'] as String? ?? 'Something went wrong. Please try again.',
      statusCode: res.statusCode,
    );
  }

  Future<void> _mockDelay() =>
      Future<void>.delayed(const Duration(milliseconds: 900));

  // ----------------------------------------------------------- MOCK DATA --

  static const User _mockUser = User(
    id: 'usr_001',
    fullName: 'Sarima Hassan',
    email: 'sarima.hassan@email.com',
    phone: '0806 123 4567',
    dateOfBirth: '12 March 1990',
    address: '12 Ahmed Onibudo Street,\nVictoria Island, Lagos, Nigeria',
  );

  static const Account _mockAccount = Account(
    accountNumber: '7099887766',
    accountType: 'Savings Account',
    availableBalance: 165700.00,
    currency: 'NGN',
    bvnMasked: '**** **** 3456',
    dateOpened: '12 Jan 2023',
    status: 'ACTIVE',
  );

  static final List<BankTransaction> _mockTransactions = [
    BankTransaction(
      id: 'txn_1',
      title: 'Salary Credit',
      amount: 120000,
      type: TransactionType.credit,
      date: DateTime(2024, 5, 28, 8, 35),
      category: 'credit',
    ),
    BankTransaction(
      id: 'txn_2',
      title: 'Transfer to John Doe',
      amount: 25000,
      type: TransactionType.debit,
      date: DateTime(2024, 5, 27, 16, 21),
      category: 'transfer',
    ),
    BankTransaction(
      id: 'txn_3',
      title: 'Phcn Electricity Bill',
      amount: 6500,
      type: TransactionType.debit,
      date: DateTime(2024, 5, 27, 11, 10),
      category: 'bills',
    ),
    BankTransaction(
      id: 'txn_4',
      title: 'Phcn Electricity Bill',
      amount: 2500,
      type: TransactionType.debit,
      date: DateTime(2024, 5, 27, 11, 10),
      category: 'bills',
    ),
  ];

  static const List<AccountLimit> _mockLimits = [
    AccountLimit(
      title: 'Daily Transfer Limit',
      subtitle: 'Across all channels',
      limit: 1000000,
      used: 120000,
    ),
    AccountLimit(
      title: 'Daily Withdrawal Limit',
      subtitle: 'ATM & Branch',
      limit: 500000,
      used: 50000,
    ),
    AccountLimit(
      title: 'Single Transfer Limit',
      subtitle: 'Per transaction',
      limit: 500000,
    ),
    AccountLimit(
      title: 'Airtime Purchase Limit',
      subtitle: 'Daily',
      limit: 50000,
      used: 5000,
    ),
  ];
}
