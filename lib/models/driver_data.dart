class DriverData {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;

  DriverData({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
  });

  String get fullName => '$firstName $lastName';

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
      id: json['id'] as int,
      firstName: (json['name'] ?? json['first_name'] ?? '') as String,
      lastName: (json['surname'] ?? json['last_name'] ?? '') as String,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String? ?? json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': firstName,
      'surname': lastName,
      'email': email,
      'phone_number': phoneNumber,
    };
  }
}
