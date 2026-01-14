import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/summary_data.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:intl/intl.dart';


class SummaryItemGroupCard extends StatelessWidget {
  final String title;
  final List<SummaryItemEntry> items;
  final void Function(int index)? onItemTap;
  final String locale;
  final String currencySymbol;

  // Internal flag/values for the `total` factory variant
  final bool _isTotalVariant;
  final num? _creditBalance;
  final num? _debitBalance;
  final num? _total;

  const SummaryItemGroupCard({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
    this.locale = 'es_AR',
    this.currencySymbol = r'$',
  })  : _isTotalVariant = false,
        _creditBalance = null,
        _debitBalance = null,
        _total = null;

  /// Factory constructor for the "Total" variant.
  factory SummaryItemGroupCard.total({
    Key? key,
    required num creditBalance,
    required num debitBalance,
    required num total,
    String title = 'Total',
    String locale = 'es_AR',
    String currencySymbol = r'$',
  }) {
    return SummaryItemGroupCard._total(
      key: key,
      title: title,
      creditBalance: creditBalance,
      debitBalance: debitBalance,
      total: total,
      locale: locale,
      currencySymbol: currencySymbol,
    );
  }

  const SummaryItemGroupCard._total({
    super.key,
    required this.title,
    required num creditBalance,
    required num debitBalance,
    required num total,
    // ignore: unused_element_parameter
    this.onItemTap,
    this.locale = 'es_AR',
    this.currencySymbol = r'$',
  })  : items = const [],
        _isTotalVariant = true,
        _creditBalance = creditBalance,
        _debitBalance = debitBalance,
        _total = total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final fmt = NumberFormat.currency(locale: locale, symbol: currencySymbol, decimalDigits: 2);

    final cardColor = _isTotalVariant ? colors.surfaceContainerHigh : null;

    return Card(
      elevation: 2,
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            gap8,
            if (_isTotalVariant) ...[
              // Credit balance row
              Row(
                children: [
                  Expanded(
                    child: Text('Saldo a favor', style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                  ),
                  Text(fmt.format(_creditBalance), style: textTheme.bodyMedium),
                ],
              ),
              gap8,
              // Debit balance row
              Row(
                children: [
                  Expanded(
                    child: Text('Saldo en contra', style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                  ),
                  Text(fmt.format(_debitBalance), style: textTheme.bodyMedium),
                ],
              ),
              gap8,
              const Divider(height: 1),
              gap8,
              // Total row
              Row(
                children: [
                  Expanded(child: Text('Total', style: textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant))),
                  Text(fmt.format(_total), style: textTheme.titleMedium),
                ],
              ),
            ] else ...[
              ...List.generate(items.length, (i) {
                final item = items[i];
                final valueText = fmt.format(item.amount);
                final isNegative = item.amount < 0;

                final row = Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(item.label, style: textTheme.labelLarge?.copyWith(color: colors.onSurfaceVariant))
                      ),
                      gap12,
                      Text(
                        valueText,
                        style: textTheme.bodyMedium?.copyWith(
                          color: isNegative ? colors.error : null,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      if (item.navigable) ...[
                        gapW12,
                        Icon(Icons.arrow_forward_ios, size: 16, color: colors.onSurfaceVariant),
                      ],
                    ],
                  ),
                );

                final child = item.navigable
                    ? InkWell(
                        onTap: onItemTap != null ? () => onItemTap!(i) : null,
                        child: row,
                      )
                    : row;

                return Column(children: [child]);
              }),
            ],
          ],
        ),
      ),
    );
  }
}
