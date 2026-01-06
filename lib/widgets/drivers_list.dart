import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';


enum DriverStatus { onTrip, inactive }

class DriverData {
  final String name;
  final DriverStatus status;

  const DriverData({
    required this.name,
    required this.status,
  });
}

/// Listado de choferes (como en el diseño)
class DriversList extends StatelessWidget {
  final List<DriverData> drivers;
  final void Function(DriverData driver)? onDriverTap; // opcional por item

  const DriversList({
    super.key,
    required this.drivers,
    this.onDriverTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        for (int i = 0; i < drivers.length; i++) ...[
          _DriverTile(
            driver: drivers[i],
            driverStatus: drivers[i].status,
            onTap: () {
              if (onDriverTap != null) onDriverTap!(drivers[i]);
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
  final DriverStatus driverStatus;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colors;

  const _DriverTile({
    required this.driver,
    required this.driverStatus,
    required this.onTap,
    required this.textTheme,
    required this.colors,
  });

  String get _statusLabel {
    switch (driver.status) {
      case DriverStatus.onTrip:
        return 'En viaje';
      case DriverStatus.inactive:
        return 'Inactivo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Symbols.delivery_truck_speed,
        color: driverStatus == DriverStatus.onTrip ? colors.secondaryContainer : colors.onSurfaceVariant,
        fill: driverStatus == DriverStatus.onTrip ? 1 : 0,
      ),
      title: Text(
        _statusLabel,
        style: textTheme.labelLarge?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        driver.name,
        style: textTheme.titleMedium,
      ),
      trailing: const Icon(Icons.arrow_right),
      onTap: onTap,
    );
  }
}
