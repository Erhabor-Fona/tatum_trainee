/// A transaction limit row on the Account Limits / KYC screen.
class AccountLimit {
  final String title;
  final String subtitle;
  final double limit;
  final double? used;

  const AccountLimit({
    required this.title,
    required this.subtitle,
    required this.limit,
    this.used,
  });

  factory AccountLimit.fromJson(Map<String, dynamic> json) => AccountLimit(
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        limit: (json['limit'] as num? ?? 0).toDouble(),
        used: (json['used'] as num?)?.toDouble(),
      );
}
