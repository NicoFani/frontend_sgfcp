class PayrollPeriodData {
  final int id;
  final DateTime startDate;
  final DateTime endDate;

  PayrollPeriodData({
    required this.id,
    required this.startDate,
    required this.endDate,
  });

  String get periodLabel {
    // Formato: "Enero 2025" o "Diciembre 2024"
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[startDate.month - 1]} ${startDate.year}';
  }

  factory PayrollPeriodData.fromJson(Map<String, dynamic> json) {
    return PayrollPeriodData(
      id: json['id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }
}
