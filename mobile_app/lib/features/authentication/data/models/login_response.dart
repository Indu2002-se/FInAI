class LoginResponse {
  final String token;
  final String refreshToken;
  final UserData user;
  final String userType; // 'PARENT' or 'CHILD'
  final int? childProfileId; // For child users

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.userType,
    this.childProfileId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json.containsKey('data') && json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    return LoginResponse(
      token: (data['token'] ?? data['accessToken'] ?? '').toString(),
      refreshToken: (data['refreshToken'] ?? '').toString(),
      user: UserData.fromJson(
        data['user'] is Map<String, dynamic>
            ? data['user'] as Map<String, dynamic>
            : {},
      ),
      userType: (data['userType'] ?? 'PARENT').toString(),
      childProfileId: data['childProfileId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'userType': userType,
      'childProfileId': childProfileId,
    };
  }
}

class UserData {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool profileComplete;
  final String? userType; // 'PARENT' or 'CHILD'

  UserData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profileComplete,
    this.userType,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      profileComplete: json['profileComplete'] == true,
      userType: json['userType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileComplete': profileComplete,
      'userType': userType,
    };
  }
}
