import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/admin/driver_detail.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/simple_table_row_data.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/models/expense_data.dart';

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
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/services/expense_service.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';
import 'package:frontend_sgfcp/services/driver_commission_service.dart';

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
  Future<Map<String, dynamic>>? _commissionFuture;
  TripData? _currentTrip;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
    _loadData();
  }

  Future<TripData> _getTripWithFallback(int tripId) async {
    try {
      return await TripService.getTrip(tripId: tripId);
    } catch (_) {
      if (widget.trip != null && widget.trip!.id == tripId) {
        return widget.trip!;
      }
      rethrow;
    }
  }

  void _loadData() {
    final int? effectiveTripId = widget.tripId ?? widget.trip?.id;

    if (effectiveTripId != null) {
      setState(() {
        _tripFuture = _getTripWithFallback(effectiveTripId);
        _expensesFuture = ExpenseService.getExpensesByTrip(
          tripId: effectiveTripId,
        );
        // Load commission after trip loads if finalized
        _tripFuture.then((trip) {
          if (trip.state == 'Finalizado' && trip.driver != null) {
            setState(() {
              _commissionFuture = DriverCommissionService.getDriverCommissionById(
                driverId: trip.driverId,
              );
            });
          }
        });
      });
    } else {
      setState(() {
        _tripFuture = TripService.getCurrentTrip().then((trip) {
          if (trip == null) {
            throw Exception('No hay viaje actual disponible');
          }
          return trip;
        });
        _expensesFuture = _tripFuture.then(
          (trip) => ExpenseService.getExpensesByTrip(tripId: trip.id),
        );
        // Load commission after trip loads if finalized
        _tripFuture.then((trip) {
          if (trip.state == 'Finalizado' && trip.driver != null) {
            setState(() {
              _commissionFuture = DriverCommissionService.getDriverCommissionById(
                driverId: trip.driverId,
              );
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const double infoLabelWidth = 140;
    final bool isAdmin =
        (TokenStorage.user != null && TokenStorage.user!['is_admin'] == true);
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
      locale: 'es_AR',
    );

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
                      _loadData();
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
          _currentTrip = trip; // Guardar en estado para usar fuera del builder

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.route, style: textTheme.titleLarge),

                  gap8,

                  // Card de estado y acción
                  if (trip.state == 'En curso')
                    SimpleCard(
                      title: 'Viaje en curso',
                      icon: Symbols.where_to_vote,
                      label: 'Finalizar',
                      onPressed: () {
                        Navigator.of(context)
                            .push(FinishTripPage.route(trip: trip))
                            .then((finished) {
                          if (finished == true) {
                            _loadData();
                          }
                        });
                      },
                    )
                  else if (trip.state == 'Pendiente')
                    const FinishedTripCard(
                      trip: null,
                      customText: 'Viaje pendiente',
                    )
                  else
                    FinishedTripCard(trip: trip),

                  gap4,

                  // Dates card - shown for all states
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

                  // Driver card - shown for all states (admin only)
                  if (isAdmin) ...[
                    if (trip.driver != null)
                      SimpleCard.iconOnly(
                        title: 'Chofer',
                        subtitle: trip.driver!.fullName,
                        icon: Symbols.arrow_right,
                        onPressed: () {
                          Navigator.of(context).push(
                            DriverDetailPageAdmin.route(
                              driverName: trip.driver!.fullName,
                              driverId: trip.driver!.id,
                            ),
                          );
                        },
                      )
                    else
                      Card.outlined(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Chofer',
                                      style: textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sin chofer asignado',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    gap4,
                  ],

                  // Origin/Destination descriptions - shown for all states
                  if (trip.originDescription != null ||
                      trip.destinationDescription != null) ...[
                    InlineInfoCard(
                      title: 'Descripciones',
                      leftLabel: 'Origen',
                      leftValue: trip.originDescription ??
                          'Descripción no proporcionada',
                      rightLabel: 'Destino',
                      rightValue: trip.destinationDescription ??
                          'Descripción no proporcionada',
                      leftColumnWidth: infoLabelWidth,
                    ),
                    gap4,
                  ],

                  InlineInfoCard(
                    title: 'Documento',
                    leftLabel: 'Tipo',
                    leftValue: trip.documentType,
                    rightLabel: 'Número',
                    rightValue: trip.documentNumber,
                    leftColumnWidth: infoLabelWidth,
                  ),

                  gap4,

                  // Rest of the information - hidden for "Pendiente"
                  if (trip.state != 'Pendiente') ...[
                    // Balance será calculado junto a los gastos más abajo
                    InfoCard(
                      title: 'Cliente',
                      items: [
                        InfoItem(
                          label: 'Nombre',
                          value: trip.client!.name,
                        ),
                        if(trip.fuelOnClient)
                          InfoItem(
                            label: 'Vale para combustible',
                            value: '${trip.fuelLiters} lts',
                          ),
                        if(trip.clientAdvancePayment > 0)
                          InfoItem(
                            label: 'Adelanto',
                            value: currencyFormat.format(trip.clientAdvancePayment),
                          ),
                      ],
                      labelColumnWidth: infoLabelWidth,
                    ),

                    gap4,

                    InfoCard(
                      title: 'Carga y distancia',
                      items: [
                        InfoItem(
                          label: 'Peso',
                          value:
                              '${trip.loadWeightOnLoad.toStringAsFixed(2)} ton',
                        ),
                        InfoItem(
                          label: 'Peso luego de descarga',
                          value: trip.loadWeightOnUnload > 0
                              ? '${trip.loadWeightOnUnload.toStringAsFixed(2)} ton'
                              : 'Viaje no finalizado',
                        ),
                        InfoItem(
                          label: 'Dueño de la carga',
                          value: trip.loadOwner!.name,
                        ),
                        InfoItem(
                          label: 'Tipo de carga',
                          value: trip.loadType!.name,
                        ),
                        InfoItem(
                          label: 'Distancia',
                          value: '${trip.estimatedKms} km',
                        ),
                      ],
                      labelColumnWidth: infoLabelWidth,
                    ),

                    gap4,

                    InlineInfoCard(
                      title: 'Tarifa',
                      leftLabel: 'Tipo de cálculo',
                      leftValue: trip.calculatedPerKm ? 'Por kilómetro' : 'Por tonelada',
                      rightLabel: 'Tarifa',
                      rightValue: trip.rate > 0 ? 
                        (trip.calculatedPerKm ? '${currencyFormat.format(trip.rate)}/km' : '${currencyFormat.format(trip.rate)}/t') :
                        'Sin tarifa',
                      leftColumnWidth: infoLabelWidth,
                    ),

                    gap4,

                    // Balance - only for Finalizado
                    if (trip.state == 'Finalizado' && _commissionFuture != null && trip.rate > 0)
                      FutureBuilder<Map<String, dynamic>>(
                        future: _commissionFuture,
                        builder: (context, commissionSnapshot) {
                          if (commissionSnapshot.connectionState == ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }

                          return _buildBalanceCard(
                            trip: trip,
                            commissionSnapshot: commissionSnapshot,
                            currencyFormat: currencyFormat,
                            infoLabelWidth: infoLabelWidth,
                          );
                        },
                      ),

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

                          return _buildExpensesSection(
                            expenses: snapshot.data ?? [],
                            currencyFormat: currencyFormat,
                            textTheme: textTheme,
                          );
                        },
                      ),
                  ], // End of "if (trip.state != 'Pendiente')"
                  const SizedBox(height: 60), // Espacio para el FAB
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _currentTrip != null
          ? TripFabMenu(
              onAddExpense: () {
                Navigator.of(context)
                    .push(ExpensePage.route(trip: _currentTrip!))
                    .then((_) => _loadData());
              },
              onEditTrip: () async {
                final updated = await Navigator.of(context).push(
                  EditTripPage.route(trip: _currentTrip!),
                );

                if (!mounted) return;

                if (updated is TripData) {
                  setState(() {
                    _currentTrip = updated;
                    _tripFuture = Future.value(updated);
                    _expensesFuture = ExpenseService.getExpensesByTrip(
                      tripId: updated.id,
                    );
                    if (updated.state == 'Finalizado' && updated.driver != null) {
                      _commissionFuture = DriverCommissionService.getDriverCommissionById(
                        driverId: updated.driverId,
                      );
                    } else {
                      _commissionFuture = null;
                    }
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Viaje actualizado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  _loadData();
                }
              },
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildBalanceCard({
    required TripData trip,
    required AsyncSnapshot<Map<String, dynamic>> commissionSnapshot,
    required NumberFormat currencyFormat,
    required double infoLabelWidth,
  }) {
    double commissionDecimal = 0.0;
    
    if (commissionSnapshot.hasData) {
      final commissionValue = commissionSnapshot.data!['commission_percentage'];
      
      // Handle both String and num types from API
      if (commissionValue is String) {
        commissionDecimal = double.tryParse(commissionValue) ?? 0.0;
      } else if (commissionValue is num) {
        commissionDecimal = commissionValue.toDouble();
      }
    }

    // Convert from decimal (0.0-1.0) to percentage (0-100)
    final double commissionPercentage = commissionDecimal * 100;

    // Calculate total commission based on calculatedPerKm flag
    final double commissionTotal = trip.calculatedPerKm
        ? trip.rate * trip.estimatedKms
        : trip.rate * trip.loadWeightOnUnload;
    
    // Calculate driver commission (using decimal for calculation)
    final double driverCommission = commissionTotal * commissionDecimal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: 'Balance',
          items: [
            InfoItem(
              label: 'Comisión total',
              value: currencyFormat.format(commissionTotal),
            ),
            InfoItem(
              label: 'Porcentaje de comisión del chofer',
              value: '${commissionPercentage.toStringAsFixed(1)}%',
            ),
            InfoItem(
              label: 'Comisión del chofer',
              value: currencyFormat.format(driverCommission),
            ),
          ],
          labelColumnWidth: infoLabelWidth,
        ),
        gap16,
      ],
    );
  }

  Widget _buildExpensesSection({
    required List<ExpenseData> expenses,
    required NumberFormat currencyFormat,
    required TextTheme textTheme,
  }) {
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
            col2: currencyFormat.format(expense.amount),
            onEdit: () {
              Navigator.of(context)
                  .push(
                    EditExpensePage.route(expense: expense, trip: _currentTrip),
                  )
                  .then((_) => _loadData());
            },
          ),
        )
        .toList();

    return SimpleTable(
      title: 'Gastos',
      headers: const ['Tipo', 'Importe', 'Editar'],
      rows: rows,
    );
  }
}

class FinishedTripCard extends StatelessWidget {
  final TripData? trip;
  final String? customText;

  const FinishedTripCard({super.key, this.trip, this.customText});

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
            customText ?? 'Viaje finalizado',
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
