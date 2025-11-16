import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelectorHeader extends StatefulWidget {
  final DateTime initialMonth;
  final ValueChanged<DateTime>? onMonthChanged;

  const MonthSelectorHeader({
    super.key,
    required this.initialMonth,
    this.onMonthChanged,
  });

  @override
  State<MonthSelectorHeader> createState() => _MonthSelectorHeaderState();
}

class _MonthSelectorHeaderState extends State<MonthSelectorHeader> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month);
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Elegir mes',
    );

    if (picked != null) {
      final normalized = DateTime(picked.year, picked.month);
      setState(() {
        _selectedMonth = normalized;
      });
      widget.onMonthChanged?.call(normalized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final locale = Localizations.localeOf(context).toString(); // ej: es_AR, es_ES
    final formattedMonth = DateFormat.yMMMM(locale).format(_selectedMonth);  // Ej: "septiembre de 2025"

    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedMonth[0].toUpperCase() + formattedMonth.substring(1),
            style: textTheme.titleMedium,
          ),
          FilledButton.tonalIcon(
            onPressed: _pickMonth,
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            label: Text(
              'Elegir mes',
              style: textTheme.labelLarge?.copyWith(
                color: colors.onSecondaryContainer
              )
            ),
            style: FilledButton.styleFrom(
              // que no se expanda a todo el ancho
              padding: const EdgeInsets.symmetric(horizontal: 16),
              fixedSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
