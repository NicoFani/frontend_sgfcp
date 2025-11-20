import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class InlineInfoCard extends StatelessWidget {
  final String title;

  final String leftLabel;
  final String leftValue;

  final String rightLabel;
  final String rightValue;

  const InlineInfoCard({
    super.key,
    required this.title,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

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

            // Fila con dos columnas (Inicio / Fin, por ejemplo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Columna izquierda
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leftLabel,
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    gap4,
                    Text(
                      leftValue,
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ),

                // Columna derecha
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rightLabel,
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      gap4,
                      Text(
                        rightValue,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
