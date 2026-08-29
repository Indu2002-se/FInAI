enum UserType { parent, child }

class AuthEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool profileComplete;
  final String token;
  final UserType userType;
  final int? childProfileId; // For child users

  AuthEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profileComplete,
    required this.token,
    required this.userType,
    this.childProfileId,
  });

  String get fullName => '$firstName $lastName';

  bool get isParent => userType == UserType.parent;
  bool get isChild => userType == UserType.child;
}
