import 'package:frontend_sgfcp/models/client_data.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/load_owner_data.dart';
import 'package:frontend_sgfcp/models/load_type_data.dart';

class TripData {
  final int id;
  final String origin;
  final String? originDescription;
  final String destination;
  final String? destinationDescription;
  final DateTime startDate;
  final DateTime? endDate;
  final String state;
  final String documentType;
  final String documentNumber;
  final double estimatedKms;
  final double loadWeightOnLoad;
  final double loadWeightOnUnload;
  final bool calculatedPerKm;
  final double rate;
  final bool fuelOnClient;
  final double fuelLiters;
  final int? loadOwnerId;
  final int? loadTypeId;
  final LoadTypeData? loadType;
  final LoadOwnerData? loadOwner;
  final int? clientId;
  final ClientData? client;
  final int driverId;
  final DriverData? driver;
  final double clientAdvancePayment;

  TripData({
    required this.id,
    required this.origin,
    this.originDescription,
    required this.destination,
    this.destinationDescription,
    required this.startDate,
    this.endDate,
    required this.state,
    required this.documentType,
    required this.documentNumber,
    required this.estimatedKms,
    required this.loadWeightOnLoad,
    required this.loadWeightOnUnload,
    required this.calculatedPerKm,
    required this.rate,
    required this.fuelOnClient,
    required this.fuelLiters,
    this.loadOwnerId,
    this.loadOwner,
    this.loadTypeId,
    this.loadType,
    this.clientId,
    this.client,
    required this.driverId,
    this.driver,
    required this.clientAdvancePayment,
  });

  factory TripData.fromJson(Map<String, dynamic> json) {
    // Parsear driver si existe
    DriverData? driver;
    if (json['driver'] != null) {
      driver = DriverData.fromJson(json['driver'] as Map<String, dynamic>);
    }

    // Parsear load_type si existe
    LoadTypeData? loadType;
    if (json['load_type'] != null) {
      loadType = LoadTypeData.fromJson(
        json['load_type'] as Map<String, dynamic>,
      );
    }

    // Parsear load_owner si existe
    LoadOwnerData? loadOwner;
    if (json['load_owner'] != null) {
      loadOwner = LoadOwnerData.fromJson(
        json['load_owner'] as Map<String, dynamic>,
      );
    }

    // Parsear client si existe
    ClientData? client;
    if (json['client'] != null) {
      client = ClientData.fromJson(
        json['client'] as Map<String, dynamic>
        );
    }

    return TripData(
      id: json['id'] as int,
      origin: json['origin'] as String,
      originDescription: json['origin_description'] as String?,
      destination: json['destination'] as String,
      destinationDescription: json['destination_description'] as String?,
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
      calculatedPerKm: json['calculated_per_km'] as bool? ?? false,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      fuelOnClient: json['fuel_on_client'] as bool? ?? false,
      fuelLiters: (json['fuel_liters'] as num?)?.toDouble() ?? 0.0,
      loadOwnerId: json['load_owner_id'] as int?,
      loadOwner: loadOwner,
      loadTypeId: json['load_type_id'] as int?,
      loadType: loadType,
      clientId: json['client_id'] as int?,
      client: client,
      driverId: json['driver_id'] as int,
      driver: driver,
      clientAdvancePayment:
          (json['client_advance_payment'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get route => '$origin → $destination';
  DateTime get date => startDate;
}
