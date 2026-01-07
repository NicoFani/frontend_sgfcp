import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/simple_table_row_data.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/models/expense_data.dart';
import 'package:frontend_sgfcp/services/api_service.dart';

import 'package:frontend_sgfcp/pages/shared/edit_expense.dart';
import 'package:frontend_sgfcp/pages/shared/expense.dart';
import 'package:frontend_sgfcp/pages/shared/finish_trip.dart';
import 'package:frontend_sgfcp/pages/shared/edit_trip.dart';
import 'package:frontend_sgfcp/widgets/trip_fab_menu.dart';
import 'package:frontend_sgfcp/widgets/info_card.dart';
import 'package:frontend_sgfcp/widgets/inline_info_card.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
import 'package:frontend_sgfcp/widgets/simple_table.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';

class TripPage extends StatefulWidget {
  final int? tripId;
  final TripData? trip;

  const TripPage({super.key, this.tripId, this.trip});

  static const String routeName = '/trip';

  static Route route({int? tripId, TripData? trip}) {
    return MaterialPageRoute<void>(
      builder: (_) => TripPage(tripId: tripId, trip: trip),
    );
  }

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  late Future<TripData> _tripFuture;
  late Future<List<ExpenseData>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    // Si ya tenemos el viaje completo, no hacemos otra llamada
    if (widget.trip != null) {
      _tripFuture = Future.value(widget.trip!);
      _expensesFuture = ApiService.getExpensesByTrip(tripId: widget.trip!.id);
    } else if (widget.tripId != null) {
      _tripFuture = ApiService.getTrip(tripId: widget.tripId!);
      _expensesFuture = ApiService.getExpensesByTrip(tripId: widget.tripId!);
    } else {
      _tripFuture = ApiService.getCurrentTrip().then((trip) {
        if (trip == null) {
          throw Exception('No hay viaje actual disponible');
        }
        return trip;
      });
      _expensesFuture = _tripFuture.then(
        (trip) => ApiService.getExpensesByTrip(tripId: trip.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const double infoLabelWidth = 140;
    final bool isAdmin =
        (TokenStorage.user != null && TokenStorage.user!['is_admin'] == true);

    return Scaffold(
      appBar: AppBar(title: const Text('Viaje')),
      body: FutureBuilder<TripData>(
        future: _tripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  gap8,
                  Text('Error al cargar el viaje'),
                  gap8,
                  Text(snapshot.error.toString()),
                  gap16,
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (widget.tripId != null) {
                          _tripFuture = ApiService.getTrip(
                            tripId: widget.tripId!,
                          );
                        } else {
                          _tripFuture = ApiService.getCurrentTrip().then((
                            trip,
                          ) {
                            if (trip == null) {
                              throw Exception('No hay viaje actual disponible');
                            }
                            return trip;
                          });
                        }
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          final trip = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.route, style: textTheme.titleLarge),

                  gap8,

                  // Card de estado y acción
                  if (trip.state != 'Finalizado')
                    SimpleCard(
                      title: trip.state,
                      icon: Symbols.where_to_vote,
                      label: 'Finalizar',
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).push(FinishTripPage.route(trip: trip));
                      },
                    )
                  else
                    FinishedTripCard(trip: trip),

                  gap4,

                  InlineInfoCard(
                    title: 'Fechas',
                    leftLabel: 'Inicio',
                    leftValue: _formatDate(trip.startDate),
                    rightLabel: 'Fin',
                    rightValue: trip.endDate != null
                        ? _formatDate(trip.endDate!)
                        : 'Viaje no finalizado',
                    leftColumnWidth: infoLabelWidth,
                  ),

                  gap4,

                  if (isAdmin) ...[
                    SimpleCard.iconOnly(
                      title: 'Chofer',
                      subtitle: trip.drivers.isNotEmpty
                          ? trip.drivers.map((d) => d.fullName).join(', ')
                          : 'Sin chofer asignado',
                      icon: Symbols.arrow_right,
                      onPressed: () {
                        // TODO: Add navigation to driver detail page
                        // Navigator.of(context).push(FinishTripPage.route());
                      },
                    ),

                    gap4,
                  ],

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
                        value: '${trip.estimatedKms} km',
                      ),
                      InfoItem(
                        label: 'Tarifa por tonelada',
                        value: '\$${trip.ratePerTon}',
                      ),
                      InfoItem(
                        label: 'Vale para combustible',
                        value: '${trip.fuelLiters} lts',
                      ),
                      InfoItem(
                        label: 'Tipo de documento',
                        value: trip.documentType,
                      ),
                    ],
                    labelColumnWidth: infoLabelWidth,
                  ),

                  gap4,

                  InlineInfoCard(
                    title: 'Documento',
                    leftLabel: 'Tipo',
                    leftValue: trip.documentType,
                    rightLabel: 'Número',
                    rightValue: trip.documentNumber,
                    leftColumnWidth: infoLabelWidth,
                  ),

                  gap4,

                  InfoCard(
                    title: 'Carga',
                    items: [
                      InfoItem(
                        label: 'Peso',
                        value: '${trip.loadWeightOnLoad} kg',
                      ),
                      InfoItem(
                        label: 'Peso luego de descarga',
                        value: trip.loadWeightOnUnload > 0
                            ? '${trip.loadWeightOnUnload} kg'
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
                    rightValue: '\$${trip.ratePerTon}/t',
                    leftColumnWidth: infoLabelWidth,
                  ),

                  gap16,

                  // Sección Gastos
                  FutureBuilder<List<ExpenseData>>(
                    future: _expensesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'No hay gastos registrados',
                            style: textTheme.bodyMedium,
                          ),
                        );
                      }

                      final rows = expenses
                          .map(
                            (expense) => SimpleTableRowData(
                              col1: expense.type,
                              col2: '\$${expense.amount.toStringAsFixed(2)}',
                              onEdit: () { Navigator.of(context).push(EditExpensePage.route()); },
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
                  const SizedBox(height: 60), // Espacio para el FAB
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: TripFabMenu(
        onAddExpense: () {
          Navigator.of(context).push(ExpensePage.route());
        },
        onEditTrip: () {
          Navigator.of(context).push(EditTripPage.route());
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class FinishedTripCard extends StatelessWidget {
  final TripData trip;

  const FinishedTripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colors.secondaryContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            'Viaje finalizado',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
