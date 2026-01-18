import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';

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

class _DriverTile extends StatefulWidget {
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

  @override
  State<_DriverTile> createState() => _DriverTileState();
}

class _DriverTileState extends State<_DriverTile> {
  bool _isOnTrip = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkDriverStatus();
  }

  Future<void> _checkDriverStatus() async {
    try {
      // Obtener todos los viajes (admin puede ver todos)
      final trips = await TripService.getTrips();

      // Verificar si este chofer tiene algún viaje en curso
      final hasActiveTrip = trips.any(
        (trip) =>
            trip.driver?.id == widget.driver.id && trip.state == 'En curso',
      );

      if (mounted) {
        setState(() {
          _isOnTrip = hasActiveTrip;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOnTrip = false;
          _isLoading = false;
        });
      }
    }
  }

  String get _statusLabel => _isOnTrip ? 'En viaje' : 'Inactivo';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Symbols.delivery_truck_speed,
          color: widget.colors.onSurfaceVariant,
        ),
        title: Text(
          'Cargando...',
          style: widget.textTheme.labelLarge?.copyWith(
            color: widget.colors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          widget.driver.fullName,
          style: widget.textTheme.titleMedium,
        ),
        trailing: const Icon(Icons.arrow_right),
        onTap: widget.onTap,
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Symbols.delivery_truck_speed,
        color: _isOnTrip
            ? widget.colors.secondaryContainer
            : widget.colors.onSurfaceVariant,
        fill: _isOnTrip ? 1 : 0,
      ),
      title: Text(
        _statusLabel,
        style: widget.textTheme.labelLarge?.copyWith(
          color: widget.colors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        widget.driver.fullName,
        style: widget.textTheme.titleMedium,
      ),
      trailing: const Icon(Icons.arrow_right),
      onTap: widget.onTap,
    );
  }
}
