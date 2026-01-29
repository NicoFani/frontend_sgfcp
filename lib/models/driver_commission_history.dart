class DriverCommissionHistory {
  final int id;
  final int driverId;
  final double commissionPercentage;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final DateTime createdAt;

  DriverCommissionHistory({
    required this.id,
    required this.driverId,
    required this.commissionPercentage,
    required this.effectiveFrom,
    this.effectiveUntil,
    required this.createdAt,
  });

  factory DriverCommissionHistory.fromJson(Map<String, dynamic> json) {
    return DriverCommissionHistory(
      id: json['id'] as int,
      driverId: json['driver_id'] as int,
      commissionPercentage: (json['commission_percentage'] is String
          ? double.parse(json['commission_percentage'])
          : json['commission_percentage']) as double,
      effectiveFrom: json['effective_from'] is String
          ? DateTime.parse(json['effective_from'] as String)
          : json['effective_from'] as DateTime,
      effectiveUntil: json['effective_until'] != null
          ? (json['effective_until'] is String
              ? DateTime.parse(json['effective_until'] as String)
              : json['effective_until'] as DateTime)
          : null,
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : json['created_at'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'commission_percentage': commissionPercentage,
      'effective_from': effectiveFrom.toIso8601String(),
      'effective_until': effectiveUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isActive => effectiveUntil == null;

  @override
  String toString() =>
      'DriverCommissionHistory(id: $id, driverId: $driverId, commissionPercentage: $commissionPercentage%, effectiveFrom: $effectiveFrom, effectiveUntil: $effectiveUntil)';
}
