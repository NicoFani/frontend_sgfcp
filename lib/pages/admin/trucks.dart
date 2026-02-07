import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/shared/truck.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/pages/admin/create_truck.dart';
import 'package:frontend_sgfcp/services/truck_service.dart';
import 'package:frontend_sgfcp/models/truck_data.dart';

class TrucksPageAdmin extends StatefulWidget {
  const TrucksPageAdmin({super.key});

  static const String routeName = '/admin/trucks';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const TrucksPageAdmin());
  }

  @override
  State<TrucksPageAdmin> createState() => _TrucksPageAdminState();
}

class _TrucksPageAdminState extends State<TrucksPageAdmin> {
  late Future<List<TruckData>> _trucksFuture;

  @override
  void initState() {
    super.initState();
    _loadTrucks();
  }

  void _loadTrucks() {
    setState(() {
      _trucksFuture = TruckService.getTrucks();
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
              ).push(CreateTruckPageAdmin.route());
              // Recargar la lista si se creó un vehículo
              if (result == true) {
                _loadTrucks();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<TruckData>>(
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
                      onPressed: _loadTrucks,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
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
                _loadTrucks();
                await _trucksFuture;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: trucks.length,
                separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(height: 1),
                ),
                itemBuilder: (context, index) {
                  final truck = trucks[index];
                  return ListTile(
                    title: Text('${truck.brand} ${truck.modelName}'),
                    subtitle: Text(truck.plate),
                    leading: Icon(
                      Symbols.local_shipping,
                      color: truck.operational ? Colors.green : Colors.grey,
                    ),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(TruckPage.route(truckId: truck.id));
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
