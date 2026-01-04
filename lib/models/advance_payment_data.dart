class AdvancePaymentData {
  final int id;
  final int adminId;
  final int driverId;
  final DateTime date;
  final double amount;
  final String? receipt;

  AdvancePaymentData({
    required this.id,
    required this.adminId,
    required this.driverId,
    required this.date,
    required this.amount,
    this.receipt,
  });

  factory AdvancePaymentData.fromJson(Map<String, dynamic> json) {
    return AdvancePaymentData(
      id: json['id'] as int,
      adminId: json['admin_id'] as int,
      driverId: json['driver_id'] as int,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      receipt: json['receipt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'driver_id': driverId,
      'date': date.toIso8601String().split('T')[0],
      'amount': amount,
      if (receipt != null) 'receipt': receipt,
    };
  }
}
