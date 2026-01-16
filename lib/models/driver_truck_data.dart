class DriverTruckData {
  final int id;
  final int driverId;
  final int truckId;
  final DateTime date;

  DriverTruckData({
    required this.id,
    required this.driverId,
    required this.truckId,
    required this.date,
  });

  factory DriverTruckData.fromJson(Map<String, dynamic> json) {
    return DriverTruckData(
      id: json['id'] as int,
      driverId: json['driver_id'] as int,
      truckId: json['truck_id'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'truck_id': truckId,
      'date': date.toIso8601String(),
    };
  }
}