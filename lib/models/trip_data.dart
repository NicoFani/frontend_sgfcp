import 'package:frontend_sgfcp/models/driver_data.dart';

class TripData {
  final int id;
  final String origin;
  final String destination;
  final DateTime startDate;
  final DateTime? endDate;
  final String state;
  final String documentType;
  final String documentNumber;
  final double estimatedKms;
  final double loadWeightOnLoad;
  final double loadWeightOnUnload;
  final double ratePerTon;
  final bool fuelOnClient;
  final double fuelLiters;
  final DriverData driver;

  TripData({
    required this.id,
    required this.origin,
    required this.destination,
    required this.startDate,
    this.endDate,
    required this.state,
    required this.documentType,
    required this.documentNumber,
    required this.estimatedKms,
    required this.loadWeightOnLoad,
    required this.loadWeightOnUnload,
    required this.ratePerTon,
    required this.fuelOnClient,
    required this.fuelLiters,
    required this.driver
  });

  factory TripData.fromJson(Map<String, dynamic> json) {

    return TripData(
      id: json['id'] as int,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      state: json['state_id'] as String,
      documentType: json['document_type'] as String? ?? '',
      documentNumber: json['document_number'] as String? ?? '',
      estimatedKms: (json['estimated_kms'] as num?)?.toDouble() ?? 0.0,
      loadWeightOnLoad:
          (json['load_weight_on_load'] as num?)?.toDouble() ?? 0.0,
      loadWeightOnUnload:
          (json['load_weight_on_unload'] as num?)?.toDouble() ?? 0.0,
      ratePerTon: (json['rate_per_ton'] as num?)?.toDouble() ?? 0.0,
      fuelOnClient: json['fuel_on_client'] as bool? ?? false,
      fuelLiters: (json['fuel_liters'] as num?)?.toDouble() ?? 0.0,
      driver: DriverData.fromJson(json['driver'] as Map<String, dynamic>),
    );
  }

  String get route => '$origin → $destination';
  DateTime get date => startDate;
}
