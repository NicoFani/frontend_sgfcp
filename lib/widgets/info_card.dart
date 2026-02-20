import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/info_item.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final List<InfoItem> items;

  final bool _footerButton;
  final IconData? _footerIcon;
  final String? _footerLabel;
  final VoidCallback? _footerOnPressed;
  final double? labelColumnWidth;


  const InfoCard({
    super.key,
    required this.title,
    required this.items,
    this.labelColumnWidth,
  })  : _footerButton = false,
        _footerIcon = null,
        _footerLabel = null,
        _footerOnPressed = null;

  /// Variante: muestra un botón al pie, ocupando todo el ancho, con icono y etiqueta.
  factory InfoCard.footerButton({
    Key? key,
    required String title,
    required List<InfoItem> items,
    required IconData buttonIcon,
    required String buttonLabel,
    required VoidCallback onPressed,
    double? labelColumnWidth, 
  }) {
    return InfoCard._internal(
      key: key,
      title: title,
      items: items,
      footerButton: true,
      footerIcon: buttonIcon,
      footerLabel: buttonLabel,
      footerOnPressed: onPressed,
      labelColumnWidth: labelColumnWidth,
    );
  }

  const InfoCard._internal({
    super.key,
    required this.title,
    required this.items,
    required bool footerButton,
    IconData? footerIcon,
    String? footerLabel,
    VoidCallback? footerOnPressed,
    this.labelColumnWidth, 
  })  : _footerButton = footerButton,
        _footerIcon = footerIcon,
        _footerLabel = footerLabel,
        _footerOnPressed = footerOnPressed,
        assert(
          !footerButton ||
              (footerIcon != null &&
               footerLabel != null &&
               footerOnPressed != null),
          'Cuando footerButton es true, icon/label/onPressed no pueden ser null.',
        );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final maxLabelWidth =
      (labelColumnWidth ?? _computeMaxLabelWidth(context)) + 4;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            gap12,

            // filas label/value
            for (int i = 0; i < items.length; i++) ...[
              _InfoRow(
                item: items[i],
                labelWidth: maxLabelWidth,
              ),
              if (i < items.length - 1) gap8,
            ],

            // botón opcional al pie
            if (_footerButton) ...[
              gap12,
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _footerOnPressed!, // seguro por el assert
                  icon: Icon(_footerIcon),
                  label: Text(_footerLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _computeMaxLabelWidth(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final painter = TextPainter(textDirection: TextDirection.ltr);

    double maxLabelWidth = 0;

    for (final item in items) {
      painter.text = TextSpan(
        text: item.label,
        style: textTheme.bodySmall,
      );
      painter.layout();
      maxLabelWidth = max(maxLabelWidth, painter.width);
    }

    return maxLabelWidth;
  }
}

class _InfoRow extends StatelessWidget {
  final InfoItem item;
  final double labelWidth;

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
            item.formatter != null ? item.formatter!(item.value) : item.value,
            textAlign: TextAlign.left,
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
