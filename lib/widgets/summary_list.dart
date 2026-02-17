import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/summary_data.dart';
import 'package:frontend_sgfcp/models/summary_row_data.dart';
import 'package:frontend_sgfcp/pages/admin/summary_detail.dart';

class SummaryList extends StatelessWidget {
  final List<SummaryRowData> rows;
  final VoidCallback? onSummaryChanged;

  const SummaryList({super.key, required this.rows, this.onSummaryChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final double sizedBoxWidth = 40;

    final headerStyle = textTheme.labelSmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    final bodyStyle = textTheme.bodySmall;

    return Column(
      children: [
        // Header aligned with list rows
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Row(
            children: const [
              Expanded(child: Text('Chofer')),
              Expanded(child: Text('Periodo')),
              Expanded(child: Text('Fecha')),
            ],
          ),
          trailing: SizedBox(
            width: sizedBoxWidth,
            child: Center(child: Text('Estado')),
          ),
          // Apply header style to all texts
          titleTextStyle: headerStyle,
          leadingAndTrailingTextStyle: headerStyle,
        ),
        const Divider(height: 1),
        // Rows with dividers between items only
        ...List.generate(rows.length, (index) {
          final row = rows[index];
          final isLast = index == rows.length - 1;
          return Column(
            children: [
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(row.driver, style: bodyStyle)),
                    Expanded(child: Text(row.period, style: bodyStyle)),
                    Expanded(
                      child: Text(_formatDate(row.date), style: bodyStyle),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: sizedBoxWidth,
                  child: Icon(
                    row.status.icon,
                    color: row.status.color(colors),
                    size: 20,
                  ),
                ),
                onTap: () async {
                  await Navigator.of(
                    context,
                  ).push(SummaryDetailPage.route(summaryId: row.summaryId));
                  if (onSummaryChanged != null) {
                    onSummaryChanged!();
                  }
                },
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }
}
