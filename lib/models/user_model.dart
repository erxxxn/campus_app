class User {
  final String? id;
  final String name;
  final String email;
  final String mobile;
  final String role; // 'user' or 'provider'
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['phone'] ?? '',
      role: json['role'] ?? 'user',
 profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: phone ?? this.mobile,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
