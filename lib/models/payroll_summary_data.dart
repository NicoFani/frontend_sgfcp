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

class PayrollDetailData {
  final int id;
  final String detailType;
  final int? tripId;
  final int? expenseId;
  final int? advanceId;
  final int? adjustmentId;
  final String description;
  final double amount;
  final String? calculationData;

  PayrollDetailData({
    required this.id,
    required this.detailType,
    this.tripId,
    this.expenseId,
    this.advanceId,
    this.adjustmentId,
    required this.description,
    required this.amount,
    this.calculationData,
  });

  factory PayrollDetailData.fromJson(Map<String, dynamic> json) {
    return PayrollDetailData(
      id: json['id'] as int,
      detailType: json['detail_type'] as String? ?? '',
      tripId: json['trip_id'] as int?,
      expenseId: json['expense_id'] as int?,
      advanceId: json['advance_id'] as int?,
      adjustmentId: json['adjustment_id'] as int?,
      description: json['description'] as String? ?? '',
      amount: PayrollSummaryData._parseDecimal(json['amount']),
      calculationData: json['calculation_data'] as String?,
    );
  }
}

class PayrollSummaryWithDetailsData {
  final PayrollSummaryData summary;
  final List<PayrollDetailData> details;

  PayrollSummaryWithDetailsData({required this.summary, required this.details});
}
