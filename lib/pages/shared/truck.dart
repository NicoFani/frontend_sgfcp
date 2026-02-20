import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/admin/driver_detail.dart';
import 'package:frontend_sgfcp/pages/admin/edit_truck.dart';
import 'package:frontend_sgfcp/pages/shared/documentation_update.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/truck_service.dart';
import 'package:frontend_sgfcp/models/truck_data.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/models/simple_table_row_data.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

import 'package:frontend_sgfcp/widgets/info_card.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
import 'package:frontend_sgfcp/widgets/simple_table.dart';
import 'package:material_symbols_icons/symbols.dart';

class TruckPage extends StatefulWidget {
  final int truckId;

  const TruckPage({super.key, required this.truckId});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/truck';

  /// Helper to create a route to this page
  static Route route({required int truckId}) {
    return MaterialPageRoute<void>(
      builder: (_) => TruckPage(truckId: truckId),
    );
  }

  @override
  State<TruckPage> createState() => _TruckPageState();
}

class _TruckPageState extends State<TruckPage> {
  late Future<TruckData> _truckFuture;
  late Future<Map<String, dynamic>?> _driverFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _truckFuture = TruckService.getTruckById(truckId: widget.truckId);
      _driverFuture = TruckService.getTruckCurrentDriver(
        truckId: widget.truckId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const double infoLabelWidth = 125;
    final bool isAdmin =
        (TokenStorage.user != null && TokenStorage.user!['is_admin'] == true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículo'),
        actions: [ if (isAdmin)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              if (mounted) {
                final result = await Navigator.of(context).push(
                  EditTruckPage.route(
                    truckId: widget.truckId,
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<TruckData>(
          future: _truckFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar vehículo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final truck = snapshot.data!;
            final dateFormat = DateFormat('dd/MM/yyyy');

            return RefreshIndicator(
              onRefresh: () async {
                _loadData();
                await _truckFuture;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Card: Datos del vehículo ---
                    InfoCard(
                      title: 'Datos del vehículo',
                      items: [
                        InfoItem(label: 'Marca', value: truck.brand),
                        InfoItem(label: 'Modelo', value: truck.modelName),
                        InfoItem(
                          label: 'Año',
                          value: truck.fabricationYear.toString(),
                        ),
                        InfoItem(
                          label: 'Patente',
                          value: truck.plate,
                          formatter: formatPlate,
                        ),
                      ],
                      labelColumnWidth: infoLabelWidth,
                    ),

                    gap12,

                    // --- Card: Chofer asignado (solo admin) ---
                    if (isAdmin) ...[
                      FutureBuilder<Map<String, dynamic>?>(
                        future: _driverFuture,
                        builder: (context, driverSnapshot) {
                          if (driverSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

                          final driverData = driverSnapshot.data;
                          final driver = driverData?['driver'];

                          if (driver == null) {
                            return Card.outlined(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Chofer',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Sin asignar',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Symbols.person_off,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final driverName =
                              '${driver['name']} ${driver['surname']}';
                          final driverId = driver['id'] as int;

                          return SimpleCard.iconOnly(
                            title: 'Chofer',
                            subtitle: driverName,
                            icon: Symbols.arrow_right,
                            onPressed: () {
                              Navigator.of(context).push(
                                DriverDetailPageAdmin.route(
                                  driverId: driverId,
                                  driverName: driverName,
                                ),
                              );
                            },
                          );
                        },
                      ),

                      gap12,
                    ],

                    // --- Table: Documentación del vehículo ---
                    SimpleTable.statusColumn(
                      title: 'Documentación del vehículo',
                      headers: [
                        'Documentación',
                        'Vencimiento',
                        'Vigente',
                        'Editar',
                      ],
                      rows: [
                        SimpleTableRowData(
                          col1: 'VTV',
                          col2: dateFormat.format(truck.vtvDueDate),
                          dateToValidate: truck.vtvDueDate,
                          onEdit: () async {
                            final result = await Navigator.of(context).push(
                              DocumentationUpdatePage.route(
                                type: 'truck',
                                entity: truck,
                                documentType: 'vtv',
                              ),
                            );
                            if (result == true) {
                              _loadData();
                            }
                          },
                        ),
                        SimpleTableRowData(
                          col1: 'Service',
                          col2: dateFormat.format(truck.serviceDueDate),
                          dateToValidate: truck.serviceDueDate,
                          onEdit: () async {
                            final result = await Navigator.of(context).push(
                              DocumentationUpdatePage.route(
                                type: 'truck',
                                entity: truck,
                                documentType: 'service',
                              ),
                            );
                            if (result == true) {
                              _loadData();
                            }
                          },
                        ),
                        SimpleTableRowData(
                          col1: 'Patente',
                          col2: dateFormat.format(truck.plateDueDate),
                          dateToValidate: truck.plateDueDate,
                          onEdit: () async {
                            final result = await Navigator.of(context).push(
                              DocumentationUpdatePage.route(
                                type: 'truck',
                                entity: truck,
                                documentType: 'plate',
                              ),
                            );
                            if (result == true) {
                              _loadData();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
