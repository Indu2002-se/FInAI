import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/authentication/data/models/login_response.dart';

void main() {
  group('LoginResponse', () {
    test('fromJson parses standard backend authentication response correctly', () {
      final json = {
        'token': 'jwt-test-token-xyz',
        'refreshToken': 'jwt-refresh-token-xyz',
        'userType': 'PARENT',
        'user': {
          'id': '101',
          'email': 'parent@example.com',
          'firstName': 'John',
          'lastName': 'Doe',
          'profileComplete': true,
        },
      };

      final response = LoginResponse.fromJson(json);

      expect(response.token, 'jwt-test-token-xyz');
      expect(response.refreshToken, 'jwt-refresh-token-xyz');
      expect(response.userType, 'PARENT');
      expect(response.childProfileId, isNull);
      expect(response.user.id, '101');
      expect(response.user.email, 'parent@example.com');
      expect(response.user.firstName, 'John');
      expect(response.user.lastName, 'Doe');
      expect(response.user.profileComplete, isTrue);
    });

    test('fromJson handles wrapped ApiResponse data payload', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'token': 'bearer-jwt-token',
          'refreshToken': 'bearer-jwt-token',
          'userType': 'CHILD',
          'childProfileId': 42,
          'user': {
            'id': '202',
            'email': 'child@example.com',
            'firstName': 'Ava',
            'lastName': 'Doe',
            'profileComplete': false,
          },
        },
      };

      final response = LoginResponse.fromJson(json);

      expect(response.token, 'bearer-jwt-token');
      expect(response.userType, 'CHILD');
      expect(response.childProfileId, 42);
      expect(response.user.email, 'child@example.com');
      expect(response.user.profileComplete, isFalse);
    });

    test('toJson produces expected map format', () {
      final user = UserData(
        id: '1',
        email: 'user@example.com',
        firstName: 'Alice',
        lastName: 'Smith',
        profileComplete: true,
        userType: 'PARENT',
      );

      final response = LoginResponse(
        token: 'sample-token',
        refreshToken: 'sample-refresh',
        user: user,
        userType: 'PARENT',
      );

      final map = response.toJson();

      expect(map['token'], 'sample-token');
      expect(map['refreshToken'], 'sample-refresh');
      expect(map['userType'], 'PARENT');
      expect(map['user']['email'], 'user@example.com');
    });
  });
}
