import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../theme/spacing.dart';


class MiTripsPage extends StatelessWidget {
  const MiTripsPage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/my_trips';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const MiTripsPage());
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


          ],
        ),
      ),
    );
  }
}