// DEPRECATED: Use lib/pages/trip.dart instead

import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/expense_data.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/models/simple_table_row_data.dart';
import 'package:frontend_sgfcp/pages/shared/edit_expense.dart';
import 'package:frontend_sgfcp/widgets/info_card.dart';
import 'package:frontend_sgfcp/widgets/inline_info_card.dart';
import 'package:frontend_sgfcp/widgets/simple_table.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/widgets/trip_fab_menu.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
// import 'package:frontend_sgfcp/pages/finish_trip.dart';
// import 'package:frontend_sgfcp/pages/admin/edit_trip.dart';
import 'package:frontend_sgfcp/pages/admin/add_expense.dart';

import 'package:frontend_sgfcp/services/expense_service.dart';

class TripDetailPageAdmin extends StatefulWidget {
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
  State<TripDetailPageAdmin> createState() => _TripDetailPageAdminState();
}

class _TripDetailPageAdminState extends State<TripDetailPageAdmin> {
  late Future<List<ExpenseData>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    // Cargar gastos del viaje si existe, de lo contrario lista vacía
    if (widget.trip != null) {
      _expensesFuture = ExpenseService.getExpensesByTrip(
        tripId: widget.trip!.id,
      );
    } else {
      _expensesFuture = Future.value(<ExpenseData>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    double infoLabelWidth = 140;

    // Si no hay trip, mostrar un error
    if (widget.trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Viaje')),
        body: const Center(child: Text('No hay datos del viaje')),
      );
    }

    final tripData = widget.trip!;
    final isFinished = tripData.state == 'Finalizado';

    return Scaffold(
      appBar: AppBar(title: const Text('Viaje')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con origen-destino
            Text(tripData.route, style: textTheme.titleLarge),

            gap8,

            // Card de estado y acción
            if (!isFinished)
              SimpleCard(
                title: 'Viaje en curso',
                icon: Symbols.where_to_vote,
                label: 'Finalizar',
                onPressed: () {
                  // Navigator.of(context).push(FinishTripPageAdmin.route());
                },
              )
            else
              FinishedTripCard(),

            gap4,

            InlineInfoCard(
              title: 'Fechas',
              leftLabel: 'Inicio',
              leftValue: _formatDate(tripData.startDate),
              rightLabel: 'Fin',
              rightValue: tripData.endDate != null
                  ? _formatDate(tripData.endDate!)
                  : 'Viaje no finalizado',
              leftColumnWidth: infoLabelWidth,
            ),

            gap4,

            SimpleCard.iconOnly(
              title: 'Chofer',
              subtitle: tripData.drivers.isNotEmpty
                  ? tripData.drivers.map((d) => d.fullName).join(', ')
                  : 'Sin chofer asignado',
              icon: Symbols.arrow_right,
              onPressed: () {
                // TODO: Add navigation to driver detail page
                // Navigator.of(context).push(FinishTripPageAdmin.route());
              },
            ),

            gap4,

            InfoCard(
              title: 'Balance',
              items: const [
                InfoItem(label: 'Comisión total', value: '\$1.064.000'),
                InfoItem(label: 'Gastos totales', value: '\$329.000'),
                InfoItem(label: 'Balance final', value: '\$735.000'),
              ],
              labelColumnWidth: infoLabelWidth,
            ),

            gap4,

            InfoCard(
              title: 'Información',
              items: [
                InfoItem(
                  label: 'Distancia',
                  value: '${tripData.estimatedKms} km',
                ),
                InfoItem(
                  label: 'Tarifa por tonelada',
                  value: '\$${tripData.rate}',
                ),
                InfoItem(
                  label: 'Vale para combustible',
                  value: '${tripData.fuelLiters} lts',
                ),
                InfoItem(
                  label: 'Tipo de documento',
                  value: tripData.documentType,
                ),
              ],
              labelColumnWidth: infoLabelWidth,
            ),

            gap4,

            InlineInfoCard(
              title: 'Documento',
              leftLabel: 'Tipo',
              leftValue: tripData.documentType,
              rightLabel: 'Número',
              rightValue: tripData.documentNumber,
              leftColumnWidth: infoLabelWidth,
            ),

            gap4,

            InfoCard(
              title: 'Carga',
              items: [
                InfoItem(
                  label: 'Peso',
                  value: '${tripData.loadWeightOnLoad} kg',
                ),
                InfoItem(
                  label: 'Peso luego de descarga',
                  value: tripData.loadWeightOnUnload > 0
                      ? '${tripData.loadWeightOnUnload} kg'
                      : 'Viaje no finalizado',
                ),
              ],
              labelColumnWidth: infoLabelWidth,
            ),

            gap4,

            InlineInfoCard(
              title: 'Tarifa',
              leftLabel: 'Tipo',
              leftValue: 'Por tonelada',
              rightLabel: 'Tarifa',
              rightValue: '\$${tripData.rate}',
              leftColumnWidth: infoLabelWidth,
            ),

            gap16,

            // Sección Gastos
            FutureBuilder<List<ExpenseData>>(
              future: _expensesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Error al cargar gastos: ${snapshot.error}',
                    style: textTheme.bodySmall,
                  );
                }

                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return Text(
                    'No hay gastos registrados',
                    style: textTheme.bodyMedium,
                  );
                }

                final rows = expenses
                    .map(
                      (expense) => SimpleTableRowData(
                        col1: expense.type,
                        col2: '\$${expense.amount.toStringAsFixed(2)}',
                        onEdit: () {
                          Navigator.of(context).push(EditExpensePage.route());
                        },
                      ),
                    )
                    .toList();

                return SimpleTable(
                  title: 'Gastos',
                  headers: ['Tipo', 'Importe', 'Editar'],
                  rows: rows,
                );
              },
            ),

            // Espacio para el FAB
            const SizedBox(height: 60),
          ],
        ),
      ),
      floatingActionButton: TripFabMenu(
        onAddExpense: () {
          Navigator.of(context).push(AddExpensePageAdmin.route());
        },
        onEditTrip: () {
          // Navigator.of(context).push(EditTripPageAdmin.route());
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class FinishedTripCard extends StatelessWidget {
  const FinishedTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}
