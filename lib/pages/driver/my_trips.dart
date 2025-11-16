import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/widgets/month_selector_header.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
import 'package:frontend_sgfcp/widgets/trips_list_section.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';


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
  DateTime _selectedMonth = DateTime(2025, 9);

  final List<TripData> _trips = [
    TripData(
      date: DateTime(2025, 9, 11),
      route: 'San Lorenzo → Laboulaye',
    ),
    TripData(
      date: DateTime(2025, 9, 8),
      route: 'Venado Tuerto → San Nicolás',
    ),
    TripData(
      date: DateTime(2025, 9, 7),
      route: 'Corral de Bustos → Armstrong',
    ),
    TripData(
      date: DateTime(2025, 9, 5),
      route: 'Cruz Alta → Villa Constitución',
    ),
    TripData(
      date: DateTime(2025, 9, 4),
      route: 'Arias → Rosario',
    ),
  ];

  
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final tripsForMonth = _trips.where((t) =>
        t.date.year == _selectedMonth.year &&
        t.date.month == _selectedMonth.month);

    return SafeArea(
      
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- Current Trip section ---
            Text(
              'Viaje actual',
              style: textTheme.titleLarge,
            ),
            gap8,
            SimpleCard(
              title: 'Mattaldi → San Lorenzo',
              subtitle: 'Viaje iniciado hace 3 horas',
              icon: Symbols.delivery_truck_speed,
              label: 'Abrir',
              onPressed: () {},
            ),


            gap24,

            // --- Next Trip section ---
            Text(
              'Próximo viaje',
              style: textTheme.titleLarge,
            ),
            gap8,
            SimpleCard(
              title: 'Mattaldi → San Lorenzo',
              subtitle: 'Faltan 2 días',
              icon: Symbols.add_road,
              label: 'Iniciar',
              onPressed: () {},
            ),

            gap24,

            // --- Upcoming trips + calendar title ---
            Text(
              'Viajes anteriores',
              style: textTheme.titleLarge,
            ),
            gap8,
            MonthSelectorHeader(
              initialMonth: _selectedMonth,
              onMonthChanged: (newMonth) {
                setState(() {
                  _selectedMonth = newMonth;
                });
              },
            ),
            TripsListSection(
              trips: tripsForMonth.toList(),
              onTripTap: (trip) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Placeholder()), // TODO: Implementar navegación real
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}