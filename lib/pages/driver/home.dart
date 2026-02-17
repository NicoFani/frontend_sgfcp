import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/widgets/trips_calendar.dart';

import 'package:frontend_sgfcp/pages/shared/expense.dart';
import 'package:frontend_sgfcp/pages/shared/finish_trip.dart';
import 'package:frontend_sgfcp/pages/driver/start_trip.dart';
import 'package:frontend_sgfcp/pages/shared/trip.dart';

class HomePageDriver extends StatefulWidget {
  const HomePageDriver({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/home';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePageDriver());
  }

  @override
  State<HomePageDriver> createState() => _HomePageDriverState();
}

class _HomePageDriverState extends State<HomePageDriver> {
  bool _isLoading = true;
  String? _error;
  TripData? _currentTrip;
  TripData? _nextTrip;
  List<TripData> _trips = [];
  String driverName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Obtener nombre del conductor
      final user = TokenStorage.user;
      driverName = user?['username'] ?? 'Conductor';
      final driverId = user?['id'] as int?;

      // Cargar viajes en paralelo
      final currentTripFuture = TripService.getCurrentTrip();
      final nextTripFuture = TripService.getNextTrip();
      final tripsFuture = driverId != null
          ? TripService.getTripsByDriver(driverId: driverId)
          : Future.value(<TripData>[]);

      final results = await Future.wait([
        currentTripFuture,
        nextTripFuture,
        tripsFuture,
      ]);

      if (!mounted) return;
      setState(() {
        _currentTrip = results[0] as TripData?;
        _nextTrip = results[1] as TripData?;
        _trips = results[2] as List<TripData>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar datos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            gap16,
            Text(_error!, style: textTheme.bodyMedium),
            gap16,
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Current Trip section ---
              Text('Viaje actual', style: textTheme.titleLarge),
              gap8,
              CurrentTripCard(trip: _currentTrip, onRefresh: _loadData),

              gap24,

              // --- Next Trip section ---
              Text('Tu próximo viaje', style: textTheme.titleLarge),
              gap8,
              NextTripCard(trip: _nextTrip, onRefresh: _loadData),

              gap24,

              // --- Upcoming trips + calendar title ---
              Text('Próximos viajes', style: textTheme.titleLarge),
              gap8,

              TripsCalendar(trips: _trips),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card: "Viaje actual"
class CurrentTripCard extends StatelessWidget {
  final TripData? trip;
  final Future<void> Function() onRefresh;

  const CurrentTripCard({super.key, this.trip, required this.onRefresh});

  String _getTimeElapsed(DateTime startDate) {
    final now = DateTime.now();
    final difference = now.difference(startDate);

    if (difference.inDays > 0) {
      return 'Viaje iniciado hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Viaje iniciado hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Viaje iniciado hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Viaje recién iniciado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Si no hay viaje actual, mostrar mensaje
    if (trip == null) {
      return Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No hay viaje en curso',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              '${trip!.origin} → ${trip!.destination}',
              style: textTheme.titleMedium,
            ),
            gap4,
            Text(
              _getTimeElapsed(trip!.startDate),
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            gap16,

            // Secondary & side actions row
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(TripPage.route(trip: trip)).then((_) => onRefresh());
                  },
                  icon: Icon(
                    Icons.info_outline,
                    color: colors.onSurfaceVariant,
                  ),
                  label: Text(
                    'Info',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),

                gapW8,

                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(ExpensePage.route(trip: trip!))
                          .then((_) => onRefresh());
                    },
                    icon: const Icon(Symbols.garage_money),
                    label: const Text('Cargar gasto'),
                  ),
                ),
              ],
            ),

            gap8,

            // Primary action (full width)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(FinishTripPage.route(trip: trip!))
                    .then((_) => onRefresh());
              },
              icon: const Icon(Symbols.where_to_vote),
              label: const Text('Finalizar viaje'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card: "Tu próximo viaje"
class NextTripCard extends StatelessWidget {
  final TripData? trip;
  final Future<void> Function() onRefresh;

  const NextTripCard({super.key, required this.trip, required this.onRefresh});

  String _getTimeUntilStart(DateTime startDate) {
    final now = DateTime.now();
    final difference = startDate.difference(now);

    if (difference.inDays > 0) {
      return 'Faltan ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Faltan ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Faltan ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Listo para comenzar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Si no hay próximo viaje, mostrar mensaje
    if (trip == null) {
      return Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No hay próximos viajes programados',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${trip!.origin} → ${trip!.destination}',
              style: textTheme.titleMedium,
            ),
            gap4,
            Text(
              _getTimeUntilStart(trip!.startDate),
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            gap16,
            // Secondary action (info button)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(TripPage.route(trip: trip))
                          .then((_) => onRefresh());
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: colors.onSurfaceVariant,
                    ),
                    label: Text(
                      'Ver información',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
            gap8,
            // Primary action (full width)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(StartTripPage.route(trip: trip!))
                    .then((_) => onRefresh());
              },
              icon: const Icon(Icons.add_road),
              label: const Text('Comenzar viaje'),
            ),
          ],
        ),
      ),
    );
  }
}
