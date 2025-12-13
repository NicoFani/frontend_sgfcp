import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/trip_detail.dart';
import 'package:frontend_sgfcp/pages/admin/create_trip.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/services/api_service.dart';

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
  final List<String> _filterStates = ['Pendiente', 'En curso', 'Finalizado'];

  late Future<List<TripData>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() {
    setState(() {
      _tripsFuture = ApiService.getTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Botón Crear viaje
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(CreateTripPageAdmin.route()).then((_) {
                // Refrescar la lista de viajes
                _loadTrips();
              });
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
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
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

        // Lista de viajes desde el backend
        Expanded(
          child: FutureBuilder<List<TripData>>(
            future: _tripsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: colors.primary),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      gap8,
                      Text('Error al cargar viajes'),
                      gap8,
                      Text(snapshot.error.toString()),
                      gap16,
                      ElevatedButton(
                        onPressed: _loadTrips,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return _buildEmptyState(context);
              }

              // Filtrar viajes según el estado seleccionado
              final filteredTrips = snapshot.data!
                  .where(
                    (trip) => trip.state == _filterStates[_selectedFilterIndex],
                  )
                  .toList();

              if (filteredTrips.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredTrips.length,
                itemBuilder: (context, index) {
                  return _TripListItem(trip: filteredTrips[index]);
                },
              );
            },
          ),
        ),
      ],
    );
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
  final TripData trip;

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
                trip: trip,
                isFinished: trip.state == 'Finalizado',
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
                      trip.route,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    gap4,
                    Text(
                      trip.state,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// Modelos de datos - Ya no necesitamos _TripStatus y _TripData
// Ya estamos usando TripData del backend
