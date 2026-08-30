enum TransactionType { credit, debit }

/// A single line on the recent-transactions list.
class BankTransaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String status;
  final String category; // e.g. transfer, bills, airtime

  const BankTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.status = 'Successful',
    this.category = 'transfer',
  });

  bool get isCredit => type == TransactionType.credit;

  factory BankTransaction.fromJson(Map<String, dynamic> json) =>
      BankTransaction(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        amount: (json['amount'] as num? ?? 0).toDouble(),
        type: (json['type'] as String? ?? 'debit') == 'credit'
            ? TransactionType.credit
            : TransactionType.debit,
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        status: json['status'] as String? ?? 'Successful',
        category: json['category'] as String? ?? 'transfer',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': isCredit ? 'credit' : 'debit',
        'date': date.toIso8601String(),
        'status': status,
        'category': category,
      };
}
