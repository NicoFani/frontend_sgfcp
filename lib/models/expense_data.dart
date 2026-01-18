class ExpenseData {
  final int id;
  final int? tripId;
  final String type;
  final double amount;
  final DateTime createdAt;
  final String? description;
  final String? receiptUrl;
  final String? fineMunicipality;
  final String? repairType;
  final double? fuelLiters;
  final String? tollType;
  final String? tollPaidBy;
  final String? tollPortFeeName;
  final bool? accountingPaid;

  ExpenseData({
    required this.id,
    this.tripId,
    required this.type,
    required this.amount,
    required this.createdAt,
    this.description,
    this.receiptUrl,
    this.fineMunicipality,
    this.repairType,
    this.fuelLiters,
    this.tollType,
    this.tollPaidBy,
    this.tollPortFeeName,
    this.accountingPaid,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: json['id'] as int,
      tripId: json['trip_id'] as int?,
      type:
          (json['expense_type'] as String?) ??
          (json['type'] as String?) ??
          'Otro',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(
        json['date'] as String? ??
            json['created_at'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      description: json['description'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      fineMunicipality: json['fine_municipality'] as String?,
      repairType: json['repair_type'] as String?,
      fuelLiters: (json['fuel_liters'] as num?)?.toDouble(),
      tollType: json['toll_type'] as String?,
      tollPaidBy: json['toll_paid_by'] as String?,
      tollPortFeeName: json['toll_port_fee_name'] as String?,
      accountingPaid: json['accounting_paid'] as bool?,
    );
  }
}
