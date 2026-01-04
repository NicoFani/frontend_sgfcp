class DriverData {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? cuil;
  final String? cbu;
  final DateTime? driverLicenseDueDate;
  final DateTime? medicalExamDueDate;

  DriverData({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.cuil,
    this.cbu,
    this.driverLicenseDueDate,
    this.medicalExamDueDate,
  });

  String get fullName => '$firstName $lastName';

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
      id: json['id'] as int,
      firstName: (json['name'] ?? json['first_name'] ?? '') as String,
      lastName: (json['surname'] ?? json['last_name'] ?? '') as String,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String? ?? json['phone'] as String?,
      cuil: json['cuil'] as String?,
      cbu: json['cbu'] as String?,
      driverLicenseDueDate: json['driver_license_due_date'] != null
          ? DateTime.parse(json['driver_license_due_date'] as String)
          : null,
      medicalExamDueDate: json['medical_exam_due_date'] != null
          ? DateTime.parse(json['medical_exam_due_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': firstName,
      'surname': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'cuil': cuil,
      'cbu': cbu,
      'driver_license_due_date': driverLicenseDueDate?.toIso8601String(),
      'medical_exam_due_date': medicalExamDueDate?.toIso8601String(),
    };
  }
}
