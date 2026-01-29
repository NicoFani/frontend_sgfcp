class MinimumGuaranteedHistory {
  final int id;
  final int driverId;
  final double minimumGuaranteed;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final DateTime createdAt;

  MinimumGuaranteedHistory({
    required this.id,
    required this.driverId,
    required this.minimumGuaranteed,
    required this.effectiveFrom,
    this.effectiveUntil,
    required this.createdAt,
  });

  factory MinimumGuaranteedHistory.fromJson(Map<String, dynamic> json) {
    return MinimumGuaranteedHistory(
      id: json['id'] as int,
      driverId: json['driver_id'] as int,
      minimumGuaranteed: (json['minimum_guaranteed'] is String
          ? double.parse(json['minimum_guaranteed'])
          : json['minimum_guaranteed']) as double,
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
      'minimum_guaranteed': minimumGuaranteed,
      'effective_from': effectiveFrom.toIso8601String(),
      'effective_until': effectiveUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isActive => effectiveUntil == null;

  @override
  String toString() =>
      'MinimumGuaranteedHistory(id: $id, driverId: $driverId, minimumGuaranteed: $minimumGuaranteed, effectiveFrom: $effectiveFrom, effectiveUntil: $effectiveUntil)';
}
