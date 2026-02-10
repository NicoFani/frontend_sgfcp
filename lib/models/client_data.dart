class ClientData {
  final int id;
  final String name;
  final String? phone;
  final String? email;

  ClientData({required this.id, required this.name, this.phone, this.email});

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone, 'email': email};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
