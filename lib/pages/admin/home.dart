import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/widgets/drivers_list.dart';
import 'package:frontend_sgfcp/widgets/trips_calendar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/create_trip.dart';
import 'package:frontend_sgfcp/pages/admin/add_advance_payment.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/pages/admin/driver_detail.dart';

// Mock trips data for calendar visualization
final List<TripData> _mockTrips = [
  TripData(
    id: 1,
    origin: 'Buenos Aires',
    destination: 'Córdoba',
    startDate: DateTime(2026, 1, 31),
    endDate: DateTime(2026, 2, 1),
    state: 'in_progress',
    documentType: 'DNI',
    documentNumber: '12345678',
    estimatedKms: 750,
    loadWeightOnLoad: 5000,
    loadWeightOnUnload: 4800,
    calculatedPerKm: true,
    rate: 50.0,
    fuelOnClient: false,
    fuelLiters: 120,
    driverId: 1,
    clientAdvancePayment: 1000,
  ),
  TripData(
    id: 2,
    origin: 'Rosario',
    destination: 'Santa Fe',
    startDate: DateTime(2026, 2, 5),
    endDate: DateTime(2026, 2, 5),
    state: 'completed',
    documentType: 'DNI',
    documentNumber: '87654321',
    estimatedKms: 300,
    loadWeightOnLoad: 3000,
    loadWeightOnUnload: 2900,
    calculatedPerKm: true,
    rate: 45.0,
    fuelOnClient: true,
    fuelLiters: 50,
    driverId: 2,
    clientAdvancePayment: 500,
  ),
  TripData(
    id: 3,
    origin: 'Mendoza',
    destination: 'San Juan',
    startDate: DateTime(2026, 2, 10),
    endDate: DateTime(2026, 2, 12),
    state: 'pending',
    documentType: 'DNI',
    documentNumber: '11223344',
    estimatedKms: 200,
    loadWeightOnLoad: 2000,
    loadWeightOnUnload: 1800,
    calculatedPerKm: false,
    rate: 2000.0,
    fuelOnClient: false,
    fuelLiters: 40,
    driverId: 3,
    clientAdvancePayment: 800,
  ),
  TripData(
    id: 4,
    origin: 'La Plata',
    destination: 'Mar del Plata',
    startDate: DateTime(2026, 2, 15),
    endDate: DateTime(2026, 2, 16),
    state: 'in_progress',
    documentType: 'DNI',
    documentNumber: '55667788',
    estimatedKms: 400,
    loadWeightOnLoad: 4000,
    loadWeightOnUnload: 3800,
    calculatedPerKm: true,
    rate: 55.0,
    fuelOnClient: false,
    fuelLiters: 80,
    driverId: 1,
    clientAdvancePayment: 1200,
  ),
  TripData(
    id: 5,
    origin: 'Salta',
    destination: 'Jujuy',
    startDate: DateTime(2026, 2, 20),
    state: 'pending',
    documentType: 'DNI',
    documentNumber: '99887766',
    estimatedKms: 150,
    loadWeightOnLoad: 1500,
    loadWeightOnUnload: 1400,
    calculatedPerKm: true,
    rate: 40.0,
    fuelOnClient: true,
    fuelLiters: 30,
    driverId: 2,
    clientAdvancePayment: 400,
  ),
];

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

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  void _loadDrivers() {
    setState(() {
      _driversFuture = DriverService.getDrivers();
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
          await _driversFuture;
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
              gap12,

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(CreateTripPageAdmin.route()).then((_) {
                      _loadDrivers();
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

              // --- Sección Próximos viajes ---
              Text('Próximos viajes', style: textTheme.titleLarge),
              gap8,

              // Calendario
              TripsCalendar(
                trips: _mockTrips,
                onDaySelected: (selectedDay) {
                  print('Selected: $selectedDay');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget del calendario
// class CalendarWidget extends StatefulWidget {
//   const CalendarWidget({super.key});

//   @override
//   State<CalendarWidget> createState() => _CalendarWidgetState();
// }

// class _CalendarWidgetState extends State<CalendarWidget> {
//   DateTime _selectedDate = DateTime.now();
//   DateTime _focusedMonth = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
//     final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
//     final daysInMonth = lastDayOfMonth.day;
//     final firstWeekday = firstDayOfMonth.weekday % 7; // Domingo = 0

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Fecha seleccionada y controles de mes
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _getFormattedDate(_selectedDate),
//                     style: textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   // Selector de mes
//                   DropdownButton<int>(
//                     value: _focusedMonth.month,
//                     underline: const SizedBox(),
//                     items: List.generate(12, (index) {
//                       return DropdownMenuItem(
//                         value: index + 1,
//                         child: Text(_getMonthName(index + 1)),
//                       );
//                     }),
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() {
//                           _focusedMonth = DateTime(_focusedMonth.year, value, 1);
//                         });
//                       }
//                     },
//                   ),
//                   gapW8,
//                   // Botón anterior
//                   IconButton(
//                     icon: const Icon(Icons.chevron_left),
//                     onPressed: () {
//                       setState(() {
//                         _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
//                       });
//                     },
//                   ),
//                   // Botón siguiente
//                   IconButton(
//                     icon: const Icon(Icons.chevron_right),
//                     onPressed: () {
//                       setState(() {
//                         _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           gap16,

//           // Encabezados de días de la semana
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
//               return SizedBox(
//                 width: 32,
//                 child: Center(
//                   child: Text(
//                     day,
//                     style: textTheme.labelSmall?.copyWith(
//                       color: colors.onSurfaceVariant,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),

//           gap8,

//           // Días del mes
//           ...List.generate(6, (weekIndex) {
//             final weekDays = <Widget>[];
//             for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
//               final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;

//               if (dayNumber < 1 || dayNumber > daysInMonth) {
//                 weekDays.add(const SizedBox(width: 32, height: 32));
//               } else {
//                 final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
//                 final isSelected = date.year == _selectedDate.year &&
//                     date.month == _selectedDate.month &&
//                     date.day == _selectedDate.day;
//                 final isToday = date.year == DateTime.now().year &&
//                     date.month == DateTime.now().month &&
//                     date.day == DateTime.now().day;

//                 // TODO: Agregar lógica para días con viajes programados
//                 final hasTrip = dayNumber == 7 || dayNumber == 10;

//                 weekDays.add(
//                   InkWell(
//                     onTap: () {
//                       setState(() {
//                         _selectedDate = date;
//                       });
//                     },
//                     borderRadius: BorderRadius.circular(16),
//                     child: Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? colors.primary
//                             : hasTrip
//                                 ? colors.primaryContainer
//                                 : null,
//                         shape: BoxShape.circle,
//                         border: isToday && !isSelected
//                             ? Border.all(color: colors.primary, width: 1)
//                             : null,
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(
//                         '$dayNumber',
//                         style: textTheme.bodyMedium?.copyWith(
//                           color: isSelected
//                               ? colors.onPrimary
//                               : hasTrip
//                                   ? colors.onPrimaryContainer
//                                   : colors.onSurface,
//                           fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }
//             }

//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: weekDays,
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   String _getFormattedDate(DateTime date) {
//     final weekday = _getWeekdayName(date.weekday);
//     final month = _getMonthName(date.month);
//     return '$weekday, $month ${date.day}';
//   }

//   String _getWeekdayName(int weekday) {
//     const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return weekdays[weekday];
//   }

//   String _getMonthName(int month) {
//     const months = [
//       '',
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December'
//     ];
//     return months[month];
//   }
// }

// Modelos de datos
// enum _DriverStatus { onTrip, inactive }

// class _DriverData {
//   final String name;
//   final _DriverStatus status;

//   _DriverData({
//     required this.name,
//     required this.status,
//   });
// }
