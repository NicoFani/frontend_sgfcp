import 'package:frontend_sgfcp/models/other_items_type.dart';

class OtherItemRowData {
  final int itemId;
  final OtherItemsType itemType;
  final String driver;
  final double amount;
  final String description;
  final DateTime date;
  final int? periodMonth;
  final int? periodYear;

  const OtherItemRowData({
    required this.itemId,
    required this.itemType,
    required this.driver,
    required this.amount,
    required this.description,
    required this.date,
    this.periodMonth,
    this.periodYear,
  });
}
