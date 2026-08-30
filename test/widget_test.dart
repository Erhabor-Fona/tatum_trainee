import 'package:flutter_test/flutter_test.dart';
import 'package:tatum_bank/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email accepts a valid address', () {
      expect(Validators.email('sarima.hassan@email.com'), isNull);
    });

    test('email rejects an invalid address', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('password enforces all four rules', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('alllowercase1!'), isNotNull);
      expect(Validators.password('NoNumber!!'), isNotNull);
      expect(Validators.password('NoSpecial99'), isNotNull);
      expect(Validators.password('Str0ng@Pass'), isNull);
    });

    test('confirmPassword must match', () {
      expect(Validators.confirmPassword('abc', 'abc'), isNull);
      expect(Validators.confirmPassword('abc', 'xyz'), isNotNull);
    });

    test('phone accepts Nigerian formats', () {
      expect(Validators.phone('08061234567'), isNull);
      expect(Validators.phone('+2348061234567'), isNull);
      expect(Validators.phone('123'), isNotNull);
    });
  });
}
