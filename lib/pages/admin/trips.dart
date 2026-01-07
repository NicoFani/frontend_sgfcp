import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/shared/trip.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/services/api_service.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';

import 'package:frontend_sgfcp/widgets/trips_list_section.dart';
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botón Crear viaje
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(CreateTripPageAdmin.route()).then((_) {
                // Refrescar la lista de viajes
                _loadTrips();
              });
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Symbols.add_road),
            label: const Text('Crear viaje'),
          ),

          gap12,

          // Filtros
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  side: BorderSide.none,
                ),
              );
            }),
          ),

          gap12,

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
                      (trip) =>
                          trip.state == _filterStates[_selectedFilterIndex],
                    )
                    .toList();

                if (filteredTrips.isEmpty) {
                  return _buildEmptyState(context);
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TripsListSection(
                    trips: filteredTrips,
                    showDriverNameSubtitle: true,
                    onTripTap: (trip) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TripPage(trip: trip),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
