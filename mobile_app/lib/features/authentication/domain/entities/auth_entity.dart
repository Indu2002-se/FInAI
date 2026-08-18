class AuthEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool profileComplete;
  final String token;

  AuthEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profileComplete,
    required this.token,
  });

  String get fullName => '$firstName $lastName';
}
