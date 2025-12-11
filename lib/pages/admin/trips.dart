import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/trip_detail.dart';
import 'package:frontend_sgfcp/pages/admin/create_trip.dart';

class TripsPageAdmin extends StatefulWidget {
  const TripsPageAdmin({super.key});

  static const String routeName = '/admin/trips';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const TripsPageAdmin());
  }

  @override
  State<TripsPageAdmin> createState() => _TripsPageAdminState();
}

class _TripsPageAdminState extends State<TripsPageAdmin> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['Pendientes', 'Actuales', 'Finalizados'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Obtener viajes reales del backend
    final trips = _getTripsForFilter(_selectedFilterIndex);

    return Column(
      children: [
        // Botón Crear viaje
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(CreateTripPageAdmin.route());
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Symbols.route),
            label: const Text('Crear viaje'),
          ),
        ),

        // Filtros
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_filters.length, (index) {
              final isSelected = _selectedFilterIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_filters[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                  backgroundColor: colors.surfaceContainerHighest,
                  selectedColor: colors.secondaryContainer,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? colors.onSecondaryContainer
                        : colors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide.none,
                ),
              );
            }),
          ),
        ),

        gap16,

        // Lista de viajes
        Expanded(
          child: trips.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    return _TripListItem(trip: trips[index]);
                  },
                ),
        ),
      ],
    );
  }

  List<_TripData> _getTripsForFilter(int filterIndex) {
    // TODO: Filtrar según el backend
    final allTrips = [
      _TripData(
        origin: 'San Lorenzo',
        destination: 'Laboulaye',
        driverName: 'Carlos Sainz',
        status: _TripStatus.pending,
      ),
      _TripData(
        origin: 'Corral de Bustos',
        destination: 'Armstrong',
        driverName: 'Fernando Alonso',
        status: _TripStatus.pending,
      ),
    ];

    return allTrips;
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.local_shipping,
            size: 64,
            color: colors.onSurfaceVariant,
          ),
          gap16,
          Text(
            'No hay viajes',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item de la lista de viajes
class _TripListItem extends StatelessWidget {
  final _TripData trip;

  const _TripListItem({required this.trip});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TripDetailPageAdmin(
                isFinished: trip.status == _TripStatus.finished,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip.origin} → ${trip.destination}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    gap4,
                    Text(
                      trip.driverName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modelos de datos
enum _TripStatus { pending, active, finished }

class _TripData {
  final String origin;
  final String destination;
  final String driverName;
  final _TripStatus status;

  _TripData({
    required this.origin,
    required this.destination,
    required this.driverName,
    required this.status,
  });
}
