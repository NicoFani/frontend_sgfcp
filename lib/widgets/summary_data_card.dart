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

  /// Optional width for the left column to align with other cards.
  final double? leftColumnWidth;
  final double? rightColumnWidth;

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
    this.leftColumnWidth,
    this.rightColumnWidth,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    Widget labelValueRow(String label, Widget value) {
      return Row(
        children: [
          Text(label, style: textTheme.labelLarge?.copyWith(color: colors.onSurfaceVariant),),
          const SizedBox(width: 8),
          Expanded(child: value),
        ],
      );
    }

    Widget leftColumn() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelValueRow(
            numberLabel,
            Text(numberValue, style: textTheme.bodyLarge, textAlign: TextAlign.left),
          ),
          const SizedBox(height: 8),
          labelValueRow(
            dateLabel,
            Text(DateFormat('dd/MM/yyyy').format(date), style: textTheme.bodyLarge, textAlign: TextAlign.left),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    Widget rightColumn() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelValueRow(
            driverLabel,
            Text(driverValue, style: textTheme.bodyLarge, textAlign: TextAlign.left),
          ),
          const SizedBox(height: 8),
          labelValueRow(
            periodLabel,
            Text(periodValue, style: textTheme.bodyLarge, textAlign: TextAlign.left),
          ),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leftColumnWidth != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: leftColumnWidth!, maxWidth: leftColumnWidth!),
                    child: leftColumn(),
                  )
                else
                  leftColumn(),
                const SizedBox(width: 16),
                if (rightColumnWidth != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: rightColumnWidth!, maxWidth: rightColumnWidth!),
                    child: rightColumn(),
                  )
                else
                  Expanded(child: rightColumn()),
              ],
            ),
            labelValueRow(
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
            ),
          ],
        ),
      ),
    );
  }
}