import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';

import 'package:frontend_sgfcp/pages/shared/expense.dart';
import 'package:frontend_sgfcp/pages/shared/finish_trip.dart';
import 'package:frontend_sgfcp/pages/driver/start_trip.dart';
import 'package:frontend_sgfcp/pages/shared/trip.dart';

class HomePageDriver extends StatelessWidget {
  const HomePageDriver({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/home';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePageDriver());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
            const CurrentTripCard(),

            gap24,

            // --- Next Trip section ---
            Text('Tu próximo viaje', style: textTheme.titleLarge),
            gap8,
            const NextTripCard(trip: null),

            gap24,

            // --- Upcoming trips + calendar title ---
            Text('Próximos viajes', style: textTheme.titleLarge),
            gap8,

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

/// Card: "Viaje actual"
class CurrentTripCard extends StatelessWidget {
  final dynamic trip;

  const CurrentTripCard({super.key, this.trip});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Mattaldi → San Lorenzo', style: textTheme.titleMedium),
            gap4,
            Text(
              'Viaje iniciado hace 3 horas',
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
                    Navigator.of(context).push(TripPage.route());
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
                      Navigator.of(context).push(ExpensePage.route(trip: trip));
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
                Navigator.of(context).push(FinishTripPage.route(trip: trip));
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
  final dynamic trip;

  const NextTripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mattaldi → San Lorenzo', style: textTheme.titleMedium),
            gap4,
            Text(
              'Faltan 2 días',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            gap16,
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                Navigator.of(context).push(StartTripPage.route(trip: trip));
              },
              icon: const Icon(
                Icons.add_road,
              ), // poné el ícono que usaste en Figma
              label: const Text('Comenzar viaje'),
            ),
          ],
        ),
      ),
    );
  }
}
