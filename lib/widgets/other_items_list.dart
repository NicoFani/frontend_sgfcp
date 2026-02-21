import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/other_item_row_data.dart';
import 'package:frontend_sgfcp/models/other_items_type.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

class OtherItemsList extends StatelessWidget {
  final List<OtherItemRowData> rows;
  final VoidCallback? onItemChanged;

  const OtherItemsList({super.key, required this.rows, this.onItemChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              Expanded(child: Text('Concepto')),
              Expanded(child: Text('Chofer')),
              Expanded(child: Text('Importe')),
            ],
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
                    Expanded(child: Text(row.itemType.label, style: bodyStyle)),
                    Expanded(child: Text(row.driver, style: bodyStyle)),
                    Expanded(
                      child: Text(formatCurrency(row.amount), style: bodyStyle),
                    ),
                  ],
                ),
                onTap: () async {
                  // TODO: Navigate to edit page
                  // await Navigator.of(
                  //   context,
                  // ).push(OtherItemDetailPage.route(itemId: row.itemId));
                  // if (onItemChanged != null) {
                  //   onItemChanged!();
                  // }
                },
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }),
      ],
    );
  }
}
