/// Form validators (Week 3, Session 8 — Forms and Input Validation).
class Validators {
  Validators._();

  static String? requiredField(String? value, [String label = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  static String? fullName(String? value) {
    final base = requiredField(value, 'Full name');
    if (base != null) return base;
    if (value!.trim().split(RegExp(r'\s+')).length < 2) {
      return 'Enter your first and last name.';
    }
    return null;
  }

  static String? email(String? value) {
    final base = requiredField(value, 'Email address');
    if (base != null) return base;
    final pattern = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');
    if (!pattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? phone(String? value) {
    final base = requiredField(value, 'Phone number');
    if (base != null) return base;
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 14) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  /// Email OR phone — used by the login and forgot-password screens.
  static String? identifier(String? value) {
    final base = requiredField(value, 'Email or phone number');
    if (base != null) return base;
    return (email(value) == null || phone(value) == null)
        ? null
        : 'Enter a valid email or phone number.';
  }

  static String? password(String? value) {
    final base = requiredField(value, 'Password');
    if (base != null) return base;
    if (value!.length < 8) return 'Password must be at least 8 characters.';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number.';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]]').hasMatch(value)) {
      return 'Include at least one special character.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final base = requiredField(value, 'Confirm password');
    if (base != null) return base;
    if (value != original) return 'Passwords do not match.';
    return null;
  }
}
