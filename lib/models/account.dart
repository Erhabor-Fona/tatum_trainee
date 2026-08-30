/// A bank account belonging to the logged-in user.
class Account {
  final String accountNumber;
  final String accountType;
  final double availableBalance;
  final String currency;
  final String bvnMasked;
  final String dateOpened;
  final String status;

  const Account({
    required this.accountNumber,
    required this.accountType,
    required this.availableBalance,
    this.currency = 'NGN',
    this.bvnMasked = '',
    this.dateOpened = '',
    this.status = 'ACTIVE',
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        accountNumber: json['accountNumber'] as String? ?? '',
        accountType: json['accountType'] as String? ?? 'Savings Account',
        availableBalance: (json['availableBalance'] as num? ?? 0).toDouble(),
        currency: json['currency'] as String? ?? 'NGN',
        bvnMasked: json['bvnMasked'] as String? ?? '',
        dateOpened: json['dateOpened'] as String? ?? '',
        status: json['status'] as String? ?? 'ACTIVE',
      );

  Map<String, dynamic> toJson() => {
        'accountNumber': accountNumber,
        'accountType': accountType,
        'availableBalance': availableBalance,
        'currency': currency,
        'bvnMasked': bvnMasked,
        'dateOpened': dateOpened,
        'status': status,
      };
}
