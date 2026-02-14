enum UserRole { student, teacher }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImage;
  final int xpPoints;
  final DateTime createdAt;
  final bool hasAgreedToPolicy;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    required this.xpPoints,
    required this.createdAt,
    required this.hasAgreedToPolicy,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values[json['role']],
      profileImage: json['profileImage'],
      xpPoints: json['xpPoints'],
      createdAt: DateTime.parse(json['createdAt']),
      hasAgreedToPolicy: json['hasAgreedToPolicy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.index,
      'profileImage': profileImage,
      'xpPoints': xpPoints,
      'createdAt': createdAt.toIso8601String(),
      'hasAgreedToPolicy': hasAgreedToPolicy,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? profileImage,
    int? xpPoints,
    DateTime? createdAt,
    bool? hasAgreedToPolicy,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      xpPoints: xpPoints ?? this.xpPoints,
      createdAt: createdAt ?? this.createdAt,
      hasAgreedToPolicy: hasAgreedToPolicy ?? this.hasAgreedToPolicy,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
