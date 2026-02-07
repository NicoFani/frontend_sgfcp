import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/truck_data.dart';
import 'package:frontend_sgfcp/services/driver_truck_service.dart';
import 'package:frontend_sgfcp/pages/shared/truck.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:material_symbols_icons/symbols.dart';

class DriverTrucksPage extends StatefulWidget {
  final int driverId;

  const DriverTrucksPage({super.key, required this.driverId});

  static const String routeName = '/driver/trucks';

  static Route route({required int driverId}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverTrucksPage(driverId: driverId),
    );
  }

  @override
  State<DriverTrucksPage> createState() => _DriverTrucksPageState();
}

class _DriverTrucksPageState extends State<DriverTrucksPage> {
  late Future<TruckData?> _currentTruckFuture;

  @override
  void initState() {
    super.initState();
    _loadCurrentTruck();
  }

  void _loadCurrentTruck() {
    _currentTruckFuture = DriverTruckService.getCurrentTruckByDriver(
      widget.driverId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Vehículo')),
      body: FutureBuilder<TruckData?>(
        future: _currentTruckFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.error_outline, size: 64, color: colors.error),
                  gap16,
                  Text(
                    'Error al cargar vehículo',
                    style: textTheme.titleMedium,
                  ),
                  gap8,
                  Text(
                    snapshot.error.toString(),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final truck = snapshot.data;

          if (truck == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.local_shipping,
                    size: 64,
                    color: colors.onSurfaceVariant,
                  ),
                  gap16,
                  Text(
                    'No hay vehículo asignado',
                    style: textTheme.titleMedium,
                  ),
                  gap8,
                  Text(
                    'No tienes un vehículo asignado actualmente',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: colors.primaryContainer,
                          child: Icon(
                            Symbols.local_shipping,
                            size: 32,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                        gap16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${truck.brand} ${truck.modelName}',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              gap4,
                              Text(
                                'Patente: ${truck.plate}',
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    gap24,
                    const Divider(),
                    gap16,
                    _buildInfoRow(
                      context,
                      'Año de fabricación',
                      truck.fabricationYear.toString(),
                    ),
                    gap12,
                    _buildInfoRow(
                      context,
                      'Estado',
                      truck.operational ? 'Operativo' : 'No operativo',
                    ),
                    gap12,
                    _buildInfoRow(
                      context,
                      'Vencimiento VTV',
                      '${truck.vtvDueDate.day}/${truck.vtvDueDate.month}/${truck.vtvDueDate.year}',
                    ),
                    gap12,
                    _buildInfoRow(
                      context,
                      'Vencimiento Service',
                      '${truck.serviceDueDate.day}/${truck.serviceDueDate.month}/${truck.serviceDueDate.year}',
                    ),
                    gap24,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).push(TruckPage.route(truckId: truck.id));
                        },
                        icon: const Icon(Symbols.info),
                        label: const Text('Ver detalles completos'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
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
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
