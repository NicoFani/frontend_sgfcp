import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class InlineInfoCard extends StatelessWidget {
  final String title;

  final String leftLabel;
  final String leftValue;

  final String rightLabel;
  final String rightValue;

  /// Ancho de la columna izquierda (labels+values de la izquierda),
  /// para poder alinearlo con InfoCard. Si es null, usa el ancho “natural”.
  final double? leftColumnWidth;

  const InlineInfoCard({
    super.key,
    required this.title,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    this.leftColumnWidth,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final leftColumn = _LabelValueColumn(
      label: leftLabel,
      value: leftValue,
    );

    final rightColumn = _LabelValueColumn(
      label: rightLabel,
      value: rightValue,
    );

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              title,
              style: textTheme.titleMedium,
            ),

            gap8,

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda con ancho fijo opcional
                if (leftColumnWidth != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: leftColumnWidth!,
                      maxWidth: leftColumnWidth!,
                    ),
                    child: leftColumn,
                  )
                else
                  leftColumn,

                gapW16,

                // Columna derecha ocupa el resto
                Expanded(child: rightColumn),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelValueColumn extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValueColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        gap4,
        Text(
          value,
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}
