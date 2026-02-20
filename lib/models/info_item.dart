typedef StringFormatter = String Function(String);

class InfoItem {
  final String label;
  final String value;
  final StringFormatter? formatter;

  const InfoItem({
    required this.label,
    required this.value,
    this.formatter,
  });
}
