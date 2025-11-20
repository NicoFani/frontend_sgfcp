import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/info_item.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final List<InfoItem> items;

  const InfoCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 1. Calcular el ancho máximo de los labels
    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    double maxLabelWidth = 0;

    for (final item in items) {
      painter.text = TextSpan(
        text: item.label,
        style: textTheme.bodySmall,
      );
      painter.layout();
      maxLabelWidth = max(maxLabelWidth, painter.width);
    }

    // Añadir padding adicional para respirar
    maxLabelWidth += 4;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),

            gap12,

            for (int i = 0; i < items.length; i++) ...[
              _InfoRow(
                item: items[i],
                labelWidth: maxLabelWidth,
              ),
              if (i < items.length - 1) gap8,
            ],
          ],
        ),
      ),
    );
  }
}


class _InfoRow extends StatelessWidget {
  final InfoItem item;
  final double labelWidth; // nuevo parámetro

  const _InfoRow({
    required this.item,
    required this.labelWidth,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: labelWidth,
            maxWidth: labelWidth,
          ),
          child: Text(
            item.label,
            style: textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),

        gapW8,

        Expanded(
          child: Text(
            item.value,
            textAlign: TextAlign.left,
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

