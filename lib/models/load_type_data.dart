class LoadTypeData {
  final int id;
  final String name;
  final bool defaultCalculatedPerKm;

  LoadTypeData({
    required this.id,
    required this.name,
    required this.defaultCalculatedPerKm,
  });

  factory LoadTypeData.fromJson(Map<String, dynamic> json) {
    return LoadTypeData(
      id: json['id'] as int,
      name: json['name'] as String,
      defaultCalculatedPerKm: json['default_calculated_per_km'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'default_calculated_per_km': defaultCalculatedPerKm,
    };
  }
}
