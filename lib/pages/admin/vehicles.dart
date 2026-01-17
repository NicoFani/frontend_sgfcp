import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/shared/vehicle.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/pages/admin/create_vehicle.dart';
import 'package:frontend_sgfcp/services/truck_service.dart';
import 'package:frontend_sgfcp/models/truck_data.dart';

class VehiclesPageAdmin extends StatefulWidget {
  const VehiclesPageAdmin({super.key});

  static const String routeName = '/admin/vehicles';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const VehiclesPageAdmin());
  }

  @override
  State<VehiclesPageAdmin> createState() => _VehiclesPageAdminState();
}

class _VehiclesPageAdminState extends State<VehiclesPageAdmin> {
  late Future<List<TruckData>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    setState(() {
      _vehiclesFuture = TruckService.getTrucks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: () async {
              final result = await Navigator.of(
                context,
              ).push(CreateVehiclePageAdmin.route());
              // Recargar la lista si se creó un vehículo
              if (result == true) {
                _loadVehicles();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<TruckData>>(
          future: _vehiclesFuture,
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
                      'Error al cargar vehículos',
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
                      onPressed: _loadVehicles,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final vehicles = snapshot.data ?? [];

            if (vehicles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Symbols.local_shipping,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay vehículos registrados',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Presiona el botón + para agregar uno',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadVehicles();
                await _vehiclesFuture;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vehicles.length,
                separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(height: 1),
                ),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return ListTile(
                    title: Text('${vehicle.brand} ${vehicle.modelName}'),
                    subtitle: Text(vehicle.plate),
                    leading: Icon(
                      Symbols.local_shipping,
                      color: vehicle.operational ? Colors.green : Colors.grey,
                    ),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(VehiclePage.route(truckId: vehicle.id));
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
