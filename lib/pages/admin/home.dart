import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/widgets/drivers_list.dart';
import 'package:frontend_sgfcp/widgets/trips_calendar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/create_trip.dart';
import 'package:frontend_sgfcp/pages/admin/add_advance_payment.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/pages/admin/driver_detail.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  static const String routeName = '/admin/home';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePageAdmin());
  }

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  late Future<List<DriverData>> _driversFuture;
  late Future<List<TripData>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    _loadTrips();
  }

  void _loadDrivers() {
    setState(() {
      _driversFuture = DriverService.getDrivers();
    });
  }

  void _loadTrips() {
    setState(() {
      _tripsFuture = TripService.getTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _loadDrivers();
          _loadTrips();
          await Future.wait([
            _driversFuture,
            _tripsFuture,
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Sección Choferes ---
              Text('Choferes', style: textTheme.titleLarge),
              gap8,
              FutureBuilder<List<DriverData>>(
                future: _driversFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 32,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error al cargar choferes',
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _loadDrivers,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final drivers = snapshot.data ?? [];

                  if (drivers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No hay choferes registrados',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }

                  return DriversList(
                    drivers: drivers,
                    onDriverTap: (driverId) {
                      // Buscar el driver completo para obtener el nombre
                      final driver = drivers.firstWhere(
                        (d) => d.id == driverId,
                      );
                      Navigator.of(context).push(
                        DriverDetailPageAdmin.route(
                          driverId: driverId,
                          driverName: driver.fullName,
                        ),
                      );
                    },
                  );
                },
              ),

              gap24,

              // --- Sección Atajos ---
              Text('Atajos', style: textTheme.titleLarge),
              gap16,

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(CreateTripPageAdmin.route())
                        .then((created) {
                      if (created == true) {
                        _loadDrivers();
                        _loadTrips();
                      }
                    });
                  },
                  icon: const Icon(Symbols.add_road),
                  label: const Text('Crear viaje'),
                ),
              ),
              gap8,
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).push(AddAdvancePaymentPage.route());
                  },
                  icon: const Icon(Symbols.mintmark),
                  label: const Text('Cargar adelanto'),
                ),
              ),

              gap24,

              // Calendario
              FutureBuilder<List<TripData>>(
                future: _tripsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 32,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error al cargar viajes',
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _loadTrips,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final trips = snapshot.data ?? [];

                  if (trips.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No hay viajes registrados',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }

                  return TripsCalendar(
                    trips: trips,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}