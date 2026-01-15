import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/shared/trip.dart';
import 'package:frontend_sgfcp/widgets/month_selector_header.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
import 'package:frontend_sgfcp/widgets/trips_list_section.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/pages/shared/driver_data.dart';
import 'package:frontend_sgfcp/pages/shared/driver_documentation.dart';

import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';

class DriverDetailPageAdmin extends StatefulWidget {
  final int driverId;
  final String driverName;

  const DriverDetailPageAdmin({
    super.key,
    required this.driverId,
    required this.driverName,
  });

  static const String routeName = '/admin/driver-detail';

  static Route route({required String driverName, int? driverId}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverDetailPageAdmin(
        driverId: driverId ?? 0,
        driverName: driverName,
      ),
    );
  }

  @override
  State<DriverDetailPageAdmin> createState() => _DriverDetailPageAdminState();
}

class _DriverDetailPageAdminState extends State<DriverDetailPageAdmin> {
  late Future<List<TripData>> _tripsFuture;
  late Future<DriverData> _driverFuture;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _tripsFuture = TripService.getTrips();
    _driverFuture = _getDriverData();
  }

  Future<DriverData> _getDriverData() async {
    // Por ahora retornaremos datos básicos, idealmente necesitaríamos
    // un endpoint para obtener un driver específico por ID
    final drivers = await DriverService.getDrivers();
    return drivers.firstWhere(
      (d) => d.id == widget.driverId || d.fullName == widget.driverName,
      orElse: () => DriverData(
        id: widget.driverId,
        firstName: widget.driverName.split(' ').first,
        lastName: widget.driverName.split(' ').skip(1).join(' '),
      ),
    );
  }

  List<TripData> _filterTripsByDriver(List<TripData> trips) {
    return trips
        .where(
          (trip) => trip.drivers.any((driver) => driver.id == widget.driverId),
        )
        .toList();
  }

  List<TripData> _getCurrentAndNextTrips(List<TripData> trips) {
    final filtered = _filterTripsByDriver(trips);
    final current = <TripData>[];
    final next = <TripData>[];

    for (var trip in filtered) {
      if (trip.state == 'En curso') {
        current.add(trip);
      } else if (trip.state == 'Pendiente') {
        next.add(trip);
      }
    }

    // Ordenar próximos viajes por fecha
    next.sort((a, b) => a.startDate.compareTo(b.startDate));

    return [...current, ...next.take(1)];
  }

  List<TripData> _getPreviousTrips(List<TripData> trips) {
    final filtered = _filterTripsByDriver(trips);
    final previous = filtered
        .where(
          (trip) => trip.state == 'Finalizado' || trip.state == 'Cancelado',
        )
        .toList();

    // Filtrar por mes seleccionado
    final filteredByMonth = previous
        .where(
          (trip) =>
              trip.startDate.year == _selectedMonth.year &&
              trip.startDate.month == _selectedMonth.month,
        )
        .toList();

    // Ordenar por fecha descendente
    filteredByMonth.sort((a, b) => b.startDate.compareTo(a.startDate));
    return filteredByMonth;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.driverName)),
      body: FutureBuilder<List<TripData>>(
        future: _tripsFuture,
        builder: (context, tripsSnapshot) {
          return FutureBuilder<DriverData>(
            future: _driverFuture,
            builder: (context, driverSnapshot) {
              if (tripsSnapshot.connectionState == ConnectionState.waiting ||
                  driverSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (tripsSnapshot.hasError || driverSnapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error al cargar datos', style: textTheme.bodyLarge),
                      gap16,
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _tripsFuture = TripService.getTrips();
                            _driverFuture = _getDriverData();
                          });
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final trips = tripsSnapshot.data ?? [];
              final driver = driverSnapshot.data;
              final currentAndNextTrips = _getCurrentAndNextTrips(trips);
              final previousTrips = _getPreviousTrips(trips);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Viajes actuales y próximos
                  if (currentAndNextTrips.isEmpty)
                    Card.outlined(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No hay viajes en curso o próximos',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ...currentAndNextTrips.asMap().entries.map((entry) {
                      final index = entry.key;
                      final trip = entry.value;
                      final title = index == 0 && trip.state == 'En curso'
                          ? 'En viaje'
                          : 'Próximo viaje';

                      return Column(
                        children: [
                          SimpleCard(
                            title: title,
                            subtitle: '${trip.origin} → ${trip.destination}',
                            icon: Symbols.delivery_truck_speed,
                            label: 'Abrir',
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).push(TripPage.route(trip: trip));
                            },
                          ),
                          if (index < currentAndNextTrips.length - 1) gap8,
                        ],
                      );
                    }),

                  gap24,

                  // Información
                  Text('Información', style: textTheme.titleLarge),

                  gap8,

                  _ProfileOptionsList(driver: driver!),

                  gap24,

                  // Viajes anteriores
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
                  gap16,

                  // Lista de viajes anteriores
                  if (previousTrips.isEmpty)
                    Card.outlined(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No hay viajes anteriores en este mes',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    TripsListSection(
                      trips: previousTrips.toList(),
                      onTripTap: (trip) {
                        Navigator.of(context).push(TripPage.route(trip: trip));
                      },
                    )
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Lista de opciones del perfil
class _ProfileOptionsList extends StatelessWidget {
  final DriverData driver;

  const _ProfileOptionsList({required this.driver});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Symbols.user_attributes),
          title: Text('Datos del chofer'),
          trailing: const Icon(Icons.arrow_right),
          onTap: () {
            Navigator.of(context).push(
              DriverDataPage.route(driver: driver)
              );
          }
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Divider(height: 1),
        ),
        ListTile(
          leading: Icon(Symbols.id_card),
          title: Text('Documentación'),
          trailing: const Icon(Icons.arrow_right),
          onTap: () {
                Navigator.of(context).push(
                  DriverDocumentationPage.route(driver: driver),
                );
              }
        ),
      ],
    );
  }
}