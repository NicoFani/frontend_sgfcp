import 'package:frontend_sgfcp/models/summary_data.dart';

class SummaryRowData {
  final int summaryId;
  final String id;
  final String driver;
  final String period;
  final DateTime date;
  final SummaryStatus status;

  const SummaryRowData({
    required this.summaryId,
    required this.id,
    required this.driver,
    required this.period,
    required this.date,
    required this.status,
  });
}
