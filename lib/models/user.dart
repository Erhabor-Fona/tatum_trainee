/// The authenticated Tatum Bank customer.
///
/// Model classes convert raw JSON from the API into typed Dart objects
/// (Week 5, Session 13 — fromJson / toJson).
class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String address;
  final String avatarUrl;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.dateOfBirth = '',
    this.address = '',
    this.avatarUrl = '',
  });

  String get firstName =>
      fullName.trim().isEmpty ? '' : fullName.trim().split(' ').first;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        dateOfBirth: json['dateOfBirth'] as String? ?? '',
        address: json['address'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'address': address,
        'avatarUrl': avatarUrl,
      };
}
