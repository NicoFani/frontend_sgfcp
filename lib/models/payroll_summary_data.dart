class PayrollSummaryData {
  final int id;
  final int periodId;
  final int driverId;
  final double driverCommissionPercentage;
  final double driverMinimumGuaranteed;
  final double commissionFromTrips;
  final double expensesToReimburse;
  final double expensesToDeduct;
  final double guaranteedMinimumApplied;
  final double advancesDeducted;
  final double otherItemsTotal;
  final double totalAmount;
  final String status;
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? periodMonth;
  final int? periodYear;
  final String? driverName;

  PayrollSummaryData({
    required this.id,
    required this.periodId,
    required this.driverId,
    required this.driverCommissionPercentage,
    required this.driverMinimumGuaranteed,
    required this.commissionFromTrips,
    required this.expensesToReimburse,
    required this.expensesToDeduct,
    required this.guaranteedMinimumApplied,
    required this.advancesDeducted,
    required this.otherItemsTotal,
    required this.totalAmount,
    required this.status,
    this.errorMessage,
    this.createdAt,
    this.updatedAt,
    this.periodMonth,
    this.periodYear,
    this.driverName,
  });

  factory PayrollSummaryData.fromJson(Map<String, dynamic> json) {
    return PayrollSummaryData(
      id: json['id'] as int,
      periodId: json['period_id'] as int,
      driverId: json['driver_id'] as int,
      driverCommissionPercentage: _parseDecimal(
        json['driver_commission_percentage'],
      ),
      driverMinimumGuaranteed: _parseDecimal(json['driver_minimum_guaranteed']),
      commissionFromTrips: _parseDecimal(json['commission_from_trips']),
      expensesToReimburse: _parseDecimal(json['expenses_to_reimburse']),
      expensesToDeduct: _parseDecimal(json['expenses_to_deduct']),
      guaranteedMinimumApplied: _parseDecimal(
        json['guaranteed_minimum_applied'],
      ),
      advancesDeducted: _parseDecimal(json['advances_deducted']),
      otherItemsTotal: _parseDecimal(json['other_items_total']),
      totalAmount: _parseDecimal(json['total_amount']),
      status: json['status'] as String,
      errorMessage: json['error_message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      periodMonth: json['period_month'] as int?,
      periodYear: json['period_year'] as int?,
      driverName: json['driver_name'] as String?,
    );
  }

  static double _parseDecimal(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
