import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/driver_data.dart';
import 'package:frontend_sgfcp/pages/admin/driver_documentation.dart';
import 'package:frontend_sgfcp/pages/admin/driver_documentation.dart';

class DriverDetailPageAdmin extends StatelessWidget {
  final String driverName;

  const DriverDetailPageAdmin({
    super.key,
    required this.driverName,
  });

  static const String routeName = '/admin/driver-detail';

  static Route route({required String driverName}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverDetailPageAdmin(driverName: driverName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Obtener datos reales del backend
    final currentTrip = _TripInfo(
      origin: 'Mattaldi',
      destination: 'San Lorenzo',
    );

    final nextTrip = _TripInfo(
      origin: 'Venado Tuerto',
      destination: 'San Nicolás',
    );

    final previousTrips = [
      _PreviousTripInfo(
        date: '11/09/2025',
        origin: 'San Lorenzo',
        destination: 'Laboulaye',
      ),
      _PreviousTripInfo(
        date: '06/09/2025',
        origin: 'Venado Tuerto',
        destination: 'San Nicolás',
      ),
      _PreviousTripInfo(
        date: '07/09/2025',
        origin: 'Corral de Bustos',
        destination: 'Armstrong',
      ),
      _PreviousTripInfo(
        date: '05/09/2025',
        origin: 'Cruz Alta',
        destination: 'Villa Constitución',
      ),
      _PreviousTripInfo(
        date: '04/09/2025',
        origin: 'Arias',
        destination: 'Rosario',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(driverName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Viaje actual
          _TripCard(
            title: 'En viaje',
            trip: currentTrip,
            buttonLabel: 'Abrir',
            onPressed: () {
              // TODO: Navegar al detalle del viaje
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ver viaje en curso')),
              );
            },
          ),

          gap16,

          // Próximo viaje
          _TripCard(
            title: 'Próximo viaje',
            trip: nextTrip,
            buttonLabel: 'Abrir',
            onPressed: () {
              // TODO: Navegar al detalle del viaje
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ver próximo viaje')),
              );
            },
          ),

          gap24,

          // Información
          Text(
            'Información',
            style: textTheme.titleLarge,
          ),

          gap8,

          // Datos del chofer
          Card.outlined(
            child: ListTile(
              leading: Icon(
                Symbols.person,
                color: colors.onSurfaceVariant,
              ),
              title: const Text('Datos del chofer'),
              trailing: Icon(
                Icons.chevron_right,
                color: colors.onSurfaceVariant,
              ),
              onTap: () {
                Navigator.of(context).push(
                  DriverDataPageAdmin.route(driverName: driverName),
                );
              },
            ),
          ),

          gap8,

          // Documentación
          Card.outlined(
            child: ListTile(
              leading: Icon(
                Symbols.description,
                color: colors.onSurfaceVariant,
              ),
              title: const Text('Documentación'),
              trailing: Icon(
                Icons.chevron_right,
                color: colors.onSurfaceVariant,
              ),
              onTap: () {
                Navigator.of(context).push(
                  DriverDocumentationPageAdmin.route(driverName: driverName),
                );
              },
            ),
          ),

          gap24,

          // Viajes anteriores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Viajes anteriores',
                style: textTheme.titleLarge,
              ),
            ],
          ),

          gap8,

          // Selector de mes
          Row(
            children: [
              Text(
                'Septiembre, 2025',
                style: textTheme.bodyMedium,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  // TODO: Selector de mes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selector de mes - En desarrollo')),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.secondaryContainer,
                  foregroundColor: colors.onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Symbols.calendar_today, size: 18),
                label: const Text('Elegir mes'),
              ),
            ],
          ),

          gap16,

          // Lista de viajes anteriores
          ...previousTrips.map((trip) => _PreviousTripListItem(trip: trip)),
        ],
      ),
    );
  }
}

/// Card de viaje (actual o próximo)
class _TripCard extends StatelessWidget {
  final String title;
  final _TripInfo trip;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _TripCard({
    required this.title,
    required this.trip,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            gap8,
            Text(
              '${trip.origin} → ${trip.destination}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            gap12,
            FilledButton.icon(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Symbols.open_in_new, size: 18),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item de viaje anterior
class _PreviousTripListItem extends StatelessWidget {
  final _PreviousTripInfo trip;

  const _PreviousTripListItem({required this.trip});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(
              trip.date,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gap4,
            Text(
              '${trip.origin} → ${trip.destination}',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colors.onSurfaceVariant,
        ),
        onTap: () {
          // TODO: Navegar a detalle del viaje
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ver viaje anterior')),
          );
        },
      ),
    );
  }
}

// Modelos de datos
class _TripInfo {
  final String origin;
  final String destination;

  _TripInfo({
    required this.origin,
    required this.destination,
  });
}

class _PreviousTripInfo {
  final String date;
  final String origin;
  final String destination;

  _PreviousTripInfo({
    required this.date,
    required this.origin,
    required this.destination,
  });
}
