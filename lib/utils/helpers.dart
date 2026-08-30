import 'package:intl/intl.dart';

/// Formatting helpers shared across screens.
class Helpers {
  Helpers._();

  static final NumberFormat _naira =
      NumberFormat.currency(locale: 'en_NG', symbol: '\u20A6', decimalDigits: 2);
  static final NumberFormat _nairaWhole =
      NumberFormat.currency(locale: 'en_NG', symbol: '\u20A6', decimalDigits: 2);

  /// 165700.0 -> ₦165,700.00
  static String naira(double amount) => _naira.format(amount);

  /// Signed amount for a transaction row: +₦120,000.00 / –₦25,000.00
  static String signedNaira(double amount, {required bool credit}) =>
      '${credit ? '+' : '-'} ${_nairaWhole.format(amount)}';

  /// 28 May 2024 · 08:35 AM
  static String transactionDate(DateTime date) =>
      DateFormat('dd MMM yyyy \u00B7 hh:mm a').format(date);
}
