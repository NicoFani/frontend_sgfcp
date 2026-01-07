import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/shared/vehicle.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/pages/admin/create_vehicle.dart';

class VehiclesPageAdmin extends StatelessWidget {
  const VehiclesPageAdmin({super.key});

  static const String routeName = '/admin/vehicles';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const VehiclesPageAdmin());
  }

  @override
  Widget build(BuildContext context) {

    // TODO: Obtener datos reales del backend
    final vehicles = [
      _VehicleData(
        brand: 'Scania',
        model: 'R450 6x2',
        plate: 'AE 698 LE',
      ),
      _VehicleData(
        brand: 'Cargo',
        model: '1723 6x2',
        plate: 'AC 907 KH',
      ),
      _VehicleData(
        brand: 'Cursor',
        model: '330 6x2',
        plate: 'AB 563 JE',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: () {
              Navigator.of(context).push(CreateVehiclePageAdmin.route());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: vehicles.length,
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Divider(height: 1),
          ),
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return ListTile(
              title: Text('${vehicle.brand} ${vehicle.model}'),
              subtitle: Text(vehicle.plate),
              leading: Icon(Symbols.local_shipping),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                Navigator.of(context).push(
                  VehiclePage.route()
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _VehicleData {
  final String brand;
  final String model;
  final String plate;

  _VehicleData({
    required this.brand,
    required this.model,
    required this.plate,
  });
}
