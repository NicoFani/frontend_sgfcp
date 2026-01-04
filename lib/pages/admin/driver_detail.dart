import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/api_service.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/pages/admin/driver_data.dart';
import 'package:frontend_sgfcp/pages/admin/driver_documentation.dart';
import 'package:frontend_sgfcp/pages/admin/trip_detail.dart';
import 'package:intl/intl.dart';

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
    _tripsFuture = ApiService.getTrips();
    _driverFuture = _getDriverData();
  }

  Future<DriverData> _getDriverData() async {
    // Por ahora retornaremos datos básicos, idealmente necesitaríamos
    // un endpoint para obtener un driver específico por ID
    final drivers = await ApiService.getDrivers();
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
                            _tripsFuture = ApiService.getTrips();
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
              final monthFormatter = DateFormat('MMMM, yyyy', 'es_ES');
              final selectedMonthText = monthFormatter.format(_selectedMonth);

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
                          _TripCard(
                            title: title,
                            trip: trip,
                            buttonLabel: 'Abrir',
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).push(TripDetailPageAdmin.route(trip: trip));
                            },
                          ),
                          if (index < currentAndNextTrips.length - 1) gap16,
                        ],
                      );
                    }),

                  gap24,

                  // Información
                  Text('Información', style: textTheme.titleLarge),

                  gap8,

                  // Datos del chofer
                  Card.outlined(
                    child: ListTile(
                      leading: Icon(
                        Symbols.person,
                        color: colors.onSurfaceVariant,
                      ),
                      title: const Text('Datos del chofer'),
                      subtitle: driver != null
                          ? Text(
                              '${driver.firstName} ${driver.lastName}',
                              style: textTheme.bodySmall,
                            )
                          : const Text('Cargando...'),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colors.onSurfaceVariant,
                      ),
                      onTap: driver != null
                          ? () {
                              Navigator.of(
                                context,
                              ).push(DriverDataPageAdmin.route(driver: driver));
                            }
                          : null,
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
                      subtitle: const Text('Ver documentos del chofer'),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colors.onSurfaceVariant,
                      ),
                      onTap: driver != null
                          ? () {
                              Navigator.of(context).push(
                                DriverDocumentationPageAdmin.route(
                                  driver: driver,
                                ),
                              );
                            }
                          : null,
                    ),
                  ),

                  gap24,

                  // Viajes anteriores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Viajes anteriores', style: textTheme.titleLarge),
                    ],
                  ),

                  gap8,

                  // Selector de mes
                  Row(
                    children: [
                      Text(selectedMonthText, style: textTheme.bodyMedium),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedMonth,
                            firstDate: DateTime(2020, 1),
                            lastDate: DateTime.now(),
                            selectableDayPredicate: (DateTime date) {
                              return true;
                            },
                          );

                          if (picked != null) {
                            setState(() {
                              _selectedMonth = DateTime(
                                picked.year,
                                picked.month,
                                1,
                              );
                            });
                          }
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
                    ...previousTrips.map(
                      (trip) => _PreviousTripListItem(trip: trip),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Card de viaje (actual o próximo)
class _TripCard extends StatelessWidget {
  final String title;
  final TripData trip;
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
  final TripData trip;

  const _PreviousTripListItem({required this.trip});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(
              dateFormatter.format(trip.startDate),
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
        trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        onTap: () {
          Navigator.of(context).push(TripDetailPageAdmin.route(trip: trip));
        },
      ),
    );
  }
}
