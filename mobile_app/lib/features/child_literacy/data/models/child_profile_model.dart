class ChildProfileModel {
  final int id;
  final String name;
  final int age;
  final String? avatar;
  final double currentSavings;
  final int totalPoints;
  final String email;
  final bool isActive;

  ChildProfileModel({
    required this.id,
    required this.name,
    required this.age,
    this.avatar,
    required this.currentSavings,
    required this.totalPoints,
    required this.email,
    required this.isActive,
  });

  factory ChildProfileModel.fromJson(Map<String, dynamic> json) {
    final childUser = json['childUser'] as Map<String, dynamic>?;
    final firstName = json['firstName']?.toString() ?? '';
    final lastName = json['lastName']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();

    return ChildProfileModel(
      id: json['id'] as int? ?? 0,
      // The backend returns firstName/lastName and nested childUser details.
      // Retain the older fields as fallbacks for previously stored responses.
      name: json['name']?.toString() ??
          (fullName.isNotEmpty ? fullName : 'Child'),
      age: json['age'] as int? ?? 10,
      avatar: json['avatar']?.toString(),
      currentSavings: (json['currentSavings'] as num?)?.toDouble() ?? 0.0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      email: childUser?['email']?.toString() ?? json['email']?.toString() ?? '',
      isActive: childUser?['enabled'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'avatar': avatar,
      'currentSavings': currentSavings,
      'totalPoints': totalPoints,
      'email': email,
      'isActive': isActive,
    };
  }
}

class ParentChildrenListResponse {
  final List<ChildProfileModel> children;
  final int totalChildren;
  final String parentId;
  final String parentName;

  ParentChildrenListResponse({
    required this.children,
    required this.totalChildren,
    required this.parentId,
    required this.parentName,
  });

  factory ParentChildrenListResponse.fromJson(Map<String, dynamic> json) {
    final childrenList = (json['children'] as List<dynamic>?)
            ?.map((e) => ChildProfileModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ParentChildrenListResponse(
      children: childrenList,
      totalChildren: json['totalChildren'] as int? ?? childrenList.length,
      parentId: json['parentId']?.toString() ?? '',
      parentName: json['parentName']?.toString() ?? 'Parent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'children': children.map((e) => e.toJson()).toList(),
      'totalChildren': totalChildren,
      'parentId': parentId,
      'parentName': parentName,
    };
  }
}
