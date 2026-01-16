class TruckData {
  final int id;
  final String plate;
  final bool operational;
  final String brand;
  final String modelName;
  final int fabricationYear;
  final DateTime serviceDueDate;
  final DateTime vtvDueDate;
  final DateTime plateDueDate;

  TruckData({
    required this.id,
    required this.plate,
    required this.operational,
    required this.brand,
    required this.modelName,
    required this.fabricationYear,
    required this.serviceDueDate,
    required this.vtvDueDate,
    required this.plateDueDate,
  });

  factory TruckData.fromJson(Map<String, dynamic> json) {
    return TruckData(
      id: json['id'] as int,
      plate: json['plate'] as String,
      operational: json['operational'] as bool,
      brand: json['brand'] as String,
      modelName: json['model_name'] as String,
      fabricationYear: json['fabrication_year'] as int,
      serviceDueDate: DateTime.parse(json['service_due_date'] as String),
      vtvDueDate: DateTime.parse(json['vtv_due_date'] as String),
      plateDueDate: DateTime.parse(json['plate_due_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate': plate,
      'operational': operational,
      'brand': brand,
      'model_name': modelName,
      'fabrication_year': fabricationYear,
      'service_due_date': serviceDueDate.toIso8601String(),
      'vtv_due_date': vtvDueDate.toIso8601String(),
      'plate_due_date': plateDueDate.toIso8601String(),
    };
  }
}