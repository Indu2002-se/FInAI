import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/app/core/constants/validators.dart';

void main() {
  group('AppValidators', () {
    group('validateEmail', () {
      test('returns error for empty email', () {
        expect(AppValidators.validateEmail(''), 'Email is required');
        expect(AppValidators.validateEmail(null), 'Email is required');
      });

      test('returns error for invalid email format', () {
        expect(AppValidators.validateEmail('invalid-email'), 'Please enter a valid email address');
        expect(AppValidators.validateEmail('user@'), 'Please enter a valid email address');
        expect(AppValidators.validateEmail('@domain.com'), 'Please enter a valid email address');
      });

      test('returns null for valid email address', () {
        expect(AppValidators.validateEmail('john.doe@example.com'), isNull);
        expect(AppValidators.validateEmail('user123@domain.org'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error when password is empty', () {
        expect(AppValidators.validatePassword(''), 'Password is required');
        expect(AppValidators.validatePassword(null), 'Password is required');
      });

      test('returns error when password is shorter than 8 chars', () {
        expect(AppValidators.validatePassword('Pass1'), 'Password must be at least 8 characters long');
      });

      test('returns error when missing uppercase, lowercase, or number', () {
        expect(AppValidators.validatePassword('alllowercase1'), 'Password must contain at least one uppercase letter');
        expect(AppValidators.validatePassword('ALLUPPERCASE1'), 'Password must contain at least one lowercase letter');
        expect(AppValidators.validatePassword('NoNumbersHere'), 'Password must contain at least one number');
      });

      test('returns null for compliant strong password', () {
        expect(AppValidators.validatePassword('ValidPass123!'), isNull);
      });
    });

    group('validateConfirmPassword', () {
      test('returns error when passwords do not match', () {
        expect(AppValidators.validateConfirmPassword('Pass1', 'Pass2'), 'Passwords do not match');
      });

      test('returns null when passwords match', () {
        expect(AppValidators.validateConfirmPassword('Secret123', 'Secret123'), isNull);
      });
    });

    group('validateAmount', () {
      test('returns error for empty or non-numeric amount', () {
        expect(AppValidators.validateAmount(''), 'Amount is required');
        expect(AppValidators.validateAmount('abc'), 'Please enter a valid amount');
      });

      test('returns error for non-positive amount', () {
        expect(AppValidators.validateAmount('0'), 'Amount must be greater than 0');
        expect(AppValidators.validateAmount('-50'), 'Amount must be greater than 0');
      });

      test('returns null for positive valid amount', () {
        expect(AppValidators.validateAmount('1500.50'), isNull);
      });
    });
  });
}
