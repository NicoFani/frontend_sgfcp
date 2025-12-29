import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/widgets/drivers_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/create_trip.dart';
import 'package:frontend_sgfcp/pages/admin/load_advance.dart';

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({super.key});

  static const String routeName = '/admin/home';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePageAdmin());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final drivers = [
      const DriverData(name: 'Carlos Sainz', status: DriverStatus.onTrip),
      const DriverData(name: 'Alexander Albon', status: DriverStatus.inactive),
      const DriverData(name: 'Fernando Alonso', status: DriverStatus.onTrip),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Sección Choferes ---
            Text(
              'Choferes',
              style: textTheme.titleLarge,
            ),
            gap8,
            DriversList(
              drivers: drivers,
              onDriverTap: (driver) {
                // TODO: navegar al detalle del chofer
              },
            ),


            gap24,

            // --- Sección Atajos ---
            Text(
              'Atajos',
              style: textTheme.titleLarge,
            ),
            gap12,

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(CreateTripPageAdmin.route());
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
                  Navigator.of(context).push(LoadAdvancePageAdmin.route());
                },
                icon: const Icon(Symbols.mintmark),
                label: const Text('Cargar adelanto'),
              ),
            ), 

            gap24,

            // --- Sección Próximos viajes ---
            Text(
              'Próximos viajes',
              style: textTheme.titleLarge,
            ),
            gap8,

            // Calendario
            // const CalendarWidget(),
            // TODO: calendar widget will go here later
            Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colors.surfaceContainerHighest,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Calendario (por implementar)',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lista de choferes
// class DriversList extends StatelessWidget {
//   const DriversList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // TODO: Obtener datos reales del backend
//     final drivers = [
//       _DriverData(
//         name: 'Carlos Sainz',
//         status: _DriverStatus.onTrip,
//       ),
//       _DriverData(
//         name: 'Alexander Albon',
//         status: _DriverStatus.inactive,
//       ),
//       _DriverData(
//         name: 'Fernando Alonso',
//         status: _DriverStatus.onTrip,
//       ),
//     ];

//     return Column(
//       children: drivers.map((driver) => _DriverListItem(driver: driver)).toList(),
//     );
//   }
// }

/// Item de la lista de choferes
// class _DriverListItem extends StatelessWidget {
//   final _DriverData driver;

//   const _DriverListItem({required this.driver});

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return Card.outlined(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         leading: CircleAvatar(
//           backgroundColor: driver.status == _DriverStatus.onTrip
//               ? colors.secondaryContainer
//               : colors.surfaceContainerHighest,
//           child: Icon(
//             Symbols.local_shipping,
//             color: driver.status == _DriverStatus.onTrip
//                 ? colors.onSecondaryContainer
//                 : colors.onSurfaceVariant,
//           ),
//         ),
//         title: Text(
//           driver.name,
//           style: textTheme.bodyLarge?.copyWith(
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         subtitle: Text(
//           driver.status == _DriverStatus.onTrip ? 'En viaje' : 'Inactivo',
//           style: textTheme.bodySmall?.copyWith(
//             color: colors.onSurfaceVariant,
//           ),
//         ),
//         trailing: Icon(
//           Icons.chevron_right,
//           color: colors.onSurfaceVariant,
//         ),
//         onTap: () {
//           // TODO: Navegar a detalles del chofer
//         },
//       ),
//     );
//   }
// }


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
enum _DriverStatus { onTrip, inactive }

class _DriverData {
  final String name;
  final _DriverStatus status;

  _DriverData({
    required this.name,
    required this.status,
  });
}
