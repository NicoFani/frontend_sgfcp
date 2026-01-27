class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final bool isAdmin;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isAdmin,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: (json['name'] ?? json['first_name'] ?? '') as String,
      lastName: (json['surname'] ?? json['last_name'] ?? '') as String,
      email: json['email'] as String,
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': firstName,
      'surname': lastName,
      'email': email,
      'is_admin': isAdmin,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
