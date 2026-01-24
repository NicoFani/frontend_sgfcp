import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/summary_data.dart';
import 'package:frontend_sgfcp/models/summary_row_data.dart';
import 'package:frontend_sgfcp/pages/admin/summary_detail.dart';

class SummaryList extends StatelessWidget {
  final List<SummaryRowData> rows;

  const SummaryList({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final double sizedBoxWidth = 48;

    final headerStyle = textTheme.labelLarge?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Column(
      children: [
        // Header aligned with list rows
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: SizedBox(width: sizedBoxWidth, child: const Text('id')),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: SizedBox(
                  width: sizedBoxWidth,
                  child: Text(row.id, style: textTheme.bodySmall),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(row.driver, style: textTheme.bodyMedium),
                    ),
                    Expanded(
                      child: Text(row.period, style: textTheme.bodyMedium),
                    ),
                    Expanded(
                      child: Text(
                        _formatDate(row.date),
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: sizedBoxWidth,
                  child: Icon(row.status.icon, color: row.status.color(colors)),
                ),
                onTap: () => Navigator.of(
                  context,
                ).push(SummaryDetailPage.route(summaryId: row.summaryId)),
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
