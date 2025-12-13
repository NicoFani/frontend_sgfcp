class ExpenseData {
  final int id;
  final int tripId;
  final String type;
  final double amount;
  final DateTime createdAt;

  ExpenseData({
    required this.id,
    required this.tripId,
    required this.type,
    required this.amount,
    required this.createdAt,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: json['id'] as int,
      tripId: json['trip_id'] as int,
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
    );
  }
}
