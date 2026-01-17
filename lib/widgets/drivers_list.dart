import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';

/// Listado de choferes (como en el diseño)
class DriversList extends StatelessWidget {
  final List<DriverData> drivers;
  final void Function(int driverId)? onDriverTap; // opcional por item

  const DriversList({super.key, required this.drivers, this.onDriverTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        for (int i = 0; i < drivers.length; i++) ...[
          _DriverTile(
            driver: drivers[i],
            onTap: () {
              if (onDriverTap != null) onDriverTap!(drivers[i].id);
            },
            textTheme: textTheme,
            colors: colors,
          ),
          if (i < drivers.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }
}

class _DriverTile extends StatelessWidget {
  final DriverData driver;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colors;

  const _DriverTile({
    required this.driver,
    required this.onTap,
    required this.textTheme,
    required this.colors,
  });

  // TODO: Determinar el estado del chofer (En viaje/Inactivo) consultando viajes activos
  String get _statusLabel => 'Inactivo';
  bool get _isOnTrip => false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Symbols.delivery_truck_speed,
        color: _isOnTrip ? colors.secondaryContainer : colors.onSurfaceVariant,
        fill: _isOnTrip ? 1 : 0,
      ),
      title: Text(
        _statusLabel,
        style: textTheme.labelLarge?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(driver.fullName, style: textTheme.titleMedium),
      trailing: const Icon(Icons.arrow_right),
      onTap: onTap,
    );
  }
}
