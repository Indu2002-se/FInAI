import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/authentication/data/models/login_request.dart';
import 'package:mobile_app/features/authentication/data/models/register_request.dart';

void main() {
  group('LoginRequest', () {
    test('toJson creates valid map with email and password', () {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final json = request.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
    });
  });

  group('RegisterRequest', () {
    test('toJson creates valid map with all user registration fields', () {
      final request = RegisterRequest(
        email: 'newuser@example.com',
        password: 'SecurePass123!',
        firstName: 'John',
        lastName: 'Doe',
      );

      final json = request.toJson();

      expect(json['email'], 'newuser@example.com');
      expect(json['password'], 'SecurePass123!');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
    });
  });
}
