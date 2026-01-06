import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/vehicle_detail.dart';
import 'package:frontend_sgfcp/pages/admin/create_vehicle.dart';

class VehiclesPageAdmin extends StatelessWidget {
  const VehiclesPageAdmin({super.key});

  static const String routeName = '/admin/vehicles';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const VehiclesPageAdmin());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: colors.outlineVariant,
          ),
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return _VehicleListItem(
              vehicle: vehicle,
              onTap: () {
                Navigator.of(context).push(
                  VehicleDetailPageAdmin.route(
                    brand: vehicle.brand,
                    model: vehicle.model,
                    plate: vehicle.plate,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _VehicleListItem extends StatelessWidget {
  final _VehicleData vehicle;
  final VoidCallback onTap;

  const _VehicleListItem({
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Icono del vehículo
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.local_shipping,
                color: colors.onSurface,
                size: 24,
              ),
            ),

            gapW12,

            // Información del vehículo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  gap4,
                  Text(
                    vehicle.plate,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: colors.onSurfaceVariant,
            ),
          ],
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
