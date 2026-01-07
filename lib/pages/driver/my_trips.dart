import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/services/api_service.dart';

import 'package:frontend_sgfcp/pages/driver/start_trip.dart';
import 'package:frontend_sgfcp/pages/shared/trip.dart';
import 'package:frontend_sgfcp/widgets/month_selector_header.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
import 'package:frontend_sgfcp/widgets/trips_list_section.dart';

class MiTripsPage extends StatefulWidget {
  const MiTripsPage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/my_trips';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const MiTripsPage());
  }

  @override
  State<MiTripsPage> createState() => _MiTripsPageState();
}

class _MiTripsPageState extends State<MiTripsPage> {
  DateTime _selectedMonth = DateTime.now();
  late Future<List<TripData>> _tripsFuture;
  late Future<TripData?> _currentTripFuture;
  late Future<TripData?> _nextTripFuture;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() {
    setState(() {
      _tripsFuture = ApiService.getTrips();
      _currentTripFuture = ApiService.getCurrentTrip();
      _nextTripFuture = ApiService.getNextTrip();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Current Trip section ---
            Text('Viaje actual', style: textTheme.titleLarge),
            gap8,
            FutureBuilder<TripData?>(
              future: _currentTripFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return SimpleCard(
                    title: 'Error al cargar',
                    subtitle: snapshot.error.toString(),
                    icon: Symbols.error,
                    label: 'Reintentar',
                    onPressed: _loadTrips,
                  );
                }

                if (snapshot.data == null) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No hay viajes en curso',
                      style: textTheme.bodyMedium,
                    ),
                  );
                }

                final currentTrip = snapshot.data!;
                return SimpleCard(
                  title: currentTrip.route,
                  subtitle: 'Viaje iniciado',
                  icon: Symbols.delivery_truck_speed,
                  label: 'Abrir',
                  onPressed: () {
                    Navigator.of(context).push(TripPage.route(trip: currentTrip));
                  },
                );
              },
            ),
            gap24,

            // --- Next Trip section ---
            Text('Próximo viaje', style: textTheme.titleLarge),
            gap8,
            FutureBuilder<TripData?>(
              future: _nextTripFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return SimpleCard(
                    title: 'Error al cargar',
                    subtitle: snapshot.error.toString(),
                    icon: Symbols.error,
                    label: 'Reintentar',
                    onPressed: _loadTrips,
                  );
                }

                if (snapshot.data == null) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No hay próximos viajes',
                      style: textTheme.bodyMedium,
                    ),
                  );
                }

                final nextTrip = snapshot.data!;
                final daysUntilTrip = nextTrip.startDate
                    .difference(DateTime.now())
                    .inDays;

                return SimpleCard(
                  title: nextTrip.route,
                  subtitle: daysUntilTrip == 0
                      ? 'Hoy'
                      : daysUntilTrip == 1
                      ? 'Mañana'
                      : 'En $daysUntilTrip días',
                  icon: Symbols.add_road,
                  label: 'Comenzar',
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(StartTripPage.route(trip: nextTrip));
                  },
                );
              },
            ),
            gap24,

            // --- Previous Trips with dynamic data ---
            Text('Viajes anteriores', style: textTheme.titleLarge),
            gap8,
            MonthSelectorHeader(
              initialMonth: _selectedMonth,
              onMonthChanged: (newMonth) {
                setState(() {
                  _selectedMonth = newMonth;
                });
              },
            ),
            FutureBuilder<List<TripData>>(
              future: _tripsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          gap8,
                          Text(
                            'Error al cargar viajes',
                            style: textTheme.bodyMedium,
                          ),
                          gap8,
                          Text(
                            snapshot.error.toString(),
                            style: textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          gap16,
                          ElevatedButton(
                            onPressed: _loadTrips,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No hay viajes disponibles',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  );
                }

                // Filtrar viajes por mes seleccionado
                final tripsForMonth = snapshot.data!.where(
                  (t) =>
                      t.date.year == _selectedMonth.year &&
                      t.date.month == _selectedMonth.month,
                );

                if (tripsForMonth.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No hay viajes en este mes',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  );
                }

                return TripsListSection(
                  trips: tripsForMonth.toList(),
                  onTripTap: (trip) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TripPage(trip: trip)),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
