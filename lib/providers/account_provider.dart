import 'package:flutter/foundation.dart';

import '../models/account.dart';
import '../models/account_limit.dart';
import '../models/bank_transaction.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum LoadState { idle, loading, success, empty, error }

/// Account, transactions, and limits state for the dashboard screens.
class AccountProvider extends ChangeNotifier {
  final ApiService _api;
  final StorageService _storage;

  AccountProvider({ApiService? api, StorageService? storage})
      : _api = api ?? ApiService(),
        _storage = storage ?? StorageService();

  LoadState _state = LoadState.idle;
  Account? _account;
  List<BankTransaction> _transactions = [];
  List<AccountLimit> _limits = [];
  String? _errorMessage;
  bool _balanceHidden = false;

  LoadState get state => _state;
  Account? get account => _account;
  List<BankTransaction> get transactions => List.unmodifiable(_transactions);
  List<AccountLimit> get limits => List.unmodifiable(_limits);
  String? get errorMessage => _errorMessage;
  bool get balanceHidden => _balanceHidden;

  Future<void> loadDashboard({bool refresh = false}) async {
    if (_state == LoadState.success && !refresh) return;
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await _storage.readToken() ?? '';
      final results = await Future.wait([
        _api.fetchAccount(token),
        _api.fetchTransactions(token),
        _api.fetchLimits(token),
      ]);
      _account = results[0] as Account;
      _transactions = results[1] as List<BankTransaction>;
      _limits = results[2] as List<AccountLimit>;
      _state =
          _transactions.isEmpty ? LoadState.empty : LoadState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = LoadState.error;
    } catch (_) {
      _errorMessage = 'Unable to load your account. Please try again.';
      _state = LoadState.error;
    }
    notifyListeners();
  }

  void toggleBalanceVisibility() {
    _balanceHidden = !_balanceHidden;
    notifyListeners();
  }

  /// Clears cached data on logout.
  void reset() {
    _state = LoadState.idle;
    _account = null;
    _transactions = [];
    _limits = [];
    _errorMessage = null;
    notifyListeners();
  }
}
