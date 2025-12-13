import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/widgets/trip_fab_menu.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
import 'package:frontend_sgfcp/pages/admin/finish_trip.dart';
import 'package:frontend_sgfcp/pages/admin/edit_trip.dart';
import 'package:frontend_sgfcp/pages/admin/add_expense.dart';
import 'package:intl/intl.dart';

class TripDetailPageAdmin extends StatelessWidget {
  final TripData? trip;
  final bool isFinished;

  const TripDetailPageAdmin({super.key, this.trip, this.isFinished = false});

  static const String routeName = '/admin/trip-detail';

  static Route route({TripData? trip, bool isFinished = false}) {
    return MaterialPageRoute<void>(
      builder: (_) => TripDetailPageAdmin(trip: trip, isFinished: isFinished),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Si no hay trip, mostrar un error
    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Viaje')),
        body: const Center(child: Text('No hay datos del viaje')),
      );
    }

    final tripData = trip!;
    final isFinished = tripData.state == 'Finalizado';

    return Scaffold(
      appBar: AppBar(title: const Text('Viaje')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con origen-destino
            Container(
              width: double.infinity,
              color: colors.surfaceContainerHighest,
              padding: const EdgeInsets.all(16),
              child: Text(
                tripData.route,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón Finalizar o Badge (según el estado)
                  if (!isFinished)
                    SimpleCard(
                      title: tripData.state,
                      icon: Symbols.where_to_vote,
                      label: 'Finalizar',
                      onPressed: () {
                        Navigator.of(context).push(FinishTripPageAdmin.route());
                      },
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Viaje finalizado',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  gap16,

                  // Sección Fechas
                  _SectionHeader(
                    title: 'Fechas',
                    icon: Symbols.calendar_month,
                    iconColor: colors.tertiaryContainer,
                  ),
                  gap8,
                  _InfoRow(
                    label: 'Inicio',
                    value: _formatDate(tripData.startDate),
                  ),
                  _InfoRow(
                    label: 'Fin',
                    value: tripData.endDate != null
                        ? _formatDate(tripData.endDate!)
                        : 'Viaje no finalizado',
                  ),

                  gap24,

                  // Sección Choferes
                  _SectionHeader(
                    title: 'Choferes Asignados',
                    icon: Symbols.person,
                    iconColor: colors.secondaryContainer,
                  ),
                  gap8,
                  if (tripData.drivers.isEmpty)
                    Text(
                      'Sin choferes asignados',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    )
                  else
                    ...tripData.drivers.map(
                      (driver) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          driver.fullName,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ),

                  gap24,
                  _SectionHeader(
                    title: 'Información',
                    icon: Symbols.info,
                    iconColor: colors.primaryContainer,
                  ),
                  gap8,
                  _InfoRow(
                    label: 'Distancia',
                    value: '${tripData.estimatedKms} km',
                  ),
                  _InfoRow(
                    label: 'Tarifa por tonelada',
                    value: '\$${tripData.ratePerTon}',
                  ),
                  _InfoRow(
                    label: 'Vale para combustible',
                    value: tripData.fuelOnClient ? 'Sí' : 'No',
                  ),

                  gap24,

                  // Sección Documento
                  _SectionHeader(
                    title: 'Documento de Remito',
                    icon: Symbols.description,
                    iconColor: colors.errorContainer,
                  ),
                  gap8,
                  _InfoRow(label: 'Tipo', value: tripData.documentType),
                  _InfoRow(label: 'Número', value: tripData.documentNumber),

                  gap24,

                  // Sección Carga
                  _SectionHeader(
                    title: 'Carga',
                    icon: Symbols.inventory_2,
                    iconColor: colors.surfaceTint,
                  ),
                  gap8,
                  _InfoRow(
                    label: 'Peso al cargar',
                    value: '${tripData.loadWeightOnLoad} kg',
                  ),
                  _InfoRow(
                    label: 'Peso al descargar',
                    value: tripData.loadWeightOnUnload > 0
                        ? '${tripData.loadWeightOnUnload} kg'
                        : 'Viaje no finalizado',
                  ),

                  gap24,

                  // Sección Tarifa
                  _SectionHeader(
                    title: 'Tarifa',
                    icon: Symbols.price_check,
                    iconColor: colors.outlineVariant,
                  ),
                  gap8,
                  _InfoRow(label: 'Tipo', value: 'Por tonelada'),
                  _InfoRow(
                    label: 'Tarifa',
                    value: '\$${tripData.ratePerTon}/t',
                  ),

                  gap24,

                  // Espacio para el FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: TripFabMenu(
        onAddExpense: () {
          Navigator.of(context).push(AddExpensePageAdmin.route());
        },
        onEditTrip: () {
          Navigator.of(context).push(EditTripPageAdmin.route());
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Encabezado de sección con ícono
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor ?? colors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor != null
                ? colors.onSecondaryContainer
                : colors.onSurfaceVariant,
          ),
        ),
        gapW12,
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Fila de información
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          gapW16,
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
