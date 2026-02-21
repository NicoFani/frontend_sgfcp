import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/models/summary_data.dart';

/// Widget that displays the "Datos" card used in the summary detail screen.
class SummaryDataCard extends StatelessWidget {
  final String numberLabel;
  final String numberValue;

  final String dateLabel;
  final DateTime date;

  final String driverLabel;
  final String driverValue;

  final String periodLabel;
  final String periodValue;

  final String statusLabel;
  final SummaryStatus status;

  const SummaryDataCard({
    super.key,
    this.numberLabel = 'Número',
    required this.numberValue,
    this.dateLabel = 'Fecha',
    required this.date,
    this.driverLabel = 'Chofer',
    required this.driverValue,
    this.periodLabel = 'Período',
    required this.periodValue,
    this.statusLabel = 'Estado',
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    const double labelWidth = 58;

    Widget labelValuePair(String label, Widget value, double width) {
      return Row(
        children: [
          SizedBox(
            width: width,
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: value),
        ],
      );
    }

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            
            // First row: Número - Chofer
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: labelValuePair(
                    numberLabel,
                    Text(
                      numberValue,
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.left,
                    ),
                    labelWidth,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: labelValuePair(
                    driverLabel,
                    Text(
                      driverValue,
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.left,
                    ),
                    labelWidth,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Second row: Fecha - Período
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: labelValuePair(
                    dateLabel,
                    Text(
                      DateFormat('dd/MM/yyyy').format(date),
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.left,
                    ),
                    labelWidth,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: labelValuePair(
                    periodLabel,
                    Text(
                      periodValue,
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.left,
                    ),
                    labelWidth,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Estado row
            labelValuePair(
              statusLabel,
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(status.label, style: textTheme.bodyLarge),
                  const SizedBox(width: 8),
                  Icon(status.icon, color: status.color(colors), size: 18),
                ],
              ),
              labelWidth,
            ),
          ],
        ),
      ),
    );
  }
}