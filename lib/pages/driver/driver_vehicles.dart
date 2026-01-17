import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/truck_data.dart';
import 'package:frontend_sgfcp/services/driver_truck_service.dart';
import 'package:frontend_sgfcp/pages/shared/vehicle.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:material_symbols_icons/symbols.dart';

class DriverVehiclesPage extends StatefulWidget {
  final int driverId;

  const DriverVehiclesPage({super.key, required this.driverId});

  static const String routeName = '/driver/vehicles';

  static Route route({required int driverId}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverVehiclesPage(driverId: driverId),
    );
  }

  @override
  State<DriverVehiclesPage> createState() => _DriverVehiclesPageState();
}

class _DriverVehiclesPageState extends State<DriverVehiclesPage> {
  late Future<List<TruckData>> _trucksFuture;

  @override
  void initState() {
    super.initState();
    _loadTrucks();
  }

  void _loadTrucks() {
    _trucksFuture = DriverTruckService.getTrucksByDriver(widget.driverId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Vehículos')),
      body: FutureBuilder<List<TruckData>>(
        future: _trucksFuture,
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
                    'Error al cargar vehículos',
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

          final trucks = snapshot.data ?? [];

          if (trucks.isEmpty) {
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
                    'No hay vehículos asignados',
                    style: textTheme.titleMedium,
                  ),
                  gap8,
                  Text(
                    'No tienes vehículos asignados actualmente',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trucks.length,
            itemBuilder: (context, index) {
              final truck = trucks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Symbols.local_shipping,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    '${truck.brand} ${truck.modelName}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gap4,
                      Text('Patente: ${truck.plate}'),
                      Text('Año: ${truck.fabricationYear}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(VehiclePage.route(truckId: truck.id));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
