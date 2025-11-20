import 'package:flutter/material.dart';

class SimpleCard extends StatelessWidget {

  final String title;
  final String? subtitle;
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;      // null cuando es iconOnly
  final bool _iconOnly;     // flag interno
  final bool _tonal;        // por si después querés otras variantes

  const SimpleCard({
    super.key,
    required this.title,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.subtitle,
  })  : _iconOnly = false,
        _tonal = false;

  /// VARIANTE: Tonal icon-only button
  factory SimpleCard.iconOnly({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SimpleCard._internal(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onPressed: onPressed,
      label: null,    // sin label
      iconOnly: true,
      tonal: true,
    );
  }

  const SimpleCard._internal({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
    required this.label,
    required bool iconOnly,
    required bool tonal,
  })  : _iconOnly = iconOnly,
        _tonal = tonal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEFT: título + subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // RIGHT: botón según variante
            _buildActionButton(colors, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(ColorScheme colors, TextTheme textTheme) {
  // VARIANTE icon-only tonal
  if (_iconOnly && _tonal) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        fixedSize: const Size(48, 48),
        padding: EdgeInsets.zero,
      ),
      child: Icon(icon),
    );
  }

  // VARIANTE por defecto: primary con label + icon
  return FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 20),
    label: Text(
      label!,
      style: textTheme.labelLarge?.copyWith(
        color: colors.onPrimary
      )
    ),    
    style: FilledButton.styleFrom(
      fixedSize: const Size(double.infinity, 48),
    ),
  );
}

}