import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/update_vehicle_document.dart';
import 'package:frontend_sgfcp/pages/admin/edit_vehicle.dart';

class VehicleDetailPageAdmin extends StatelessWidget {
  final String brand;
  final String model;
  final String plate;

  const VehicleDetailPageAdmin({
    super.key,
    required this.brand,
    required this.model,
    required this.plate,
  });

  static const String routeName = '/admin/vehicle-detail';

  static Route route({
    required String brand,
    required String model,
    required String plate,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => VehicleDetailPageAdmin(
        brand: brand,
        model: model,
        plate: plate,
      ),
    );
  }

  void _showUnregisterDialog(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dar de baja vehículo?'),
        content: const Text(
          'El vehículo será dado de baja. Podrás acceder a él en el listado de vehículos dados de baja.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vehículo dado de baja'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Obtener datos reales del backend
    final vehicleData = {
      'Marca': brand,
      'Modelo': model,
      'Año': '2021',
      'Patente': plate,
    };

    final assignedDriver = 'Carlos Sainz';

    final documents = [
      _DocumentData(
        name: 'VTV',
        expirationDate: DateTime(2025, 12, 13),
      ),
      _DocumentData(
        name: 'Service',
        expirationDate: DateTime(2026, 4, 26),
      ),
      _DocumentData(
        name: 'Patente',
        expirationDate: DateTime(2025, 9, 7),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículo'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.edit),
            onPressed: () {
              Navigator.of(context).push(
                EditVehiclePageAdmin.route(
                  brand: brand,
                  model: model,
                  plate: plate,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Symbols.delete),
            onPressed: () => _showUnregisterDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Datos del vehículo
              Text(
                'Datos del vehículo',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              gap8,

              Card.outlined(
                child: Column(
                  children: vehicleData.entries.map((entry) {
                    final isLast = entry.key == vehicleData.keys.last;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: textTheme.bodyLarge,
                              ),
                              Text(
                                entry.value,
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        if (!isLast) Divider(height: 1, color: colors.outlineVariant),
                      ],
                    );
                  }).toList(),
                ),
              ),

              gap16,

              // Chofer asignado
              Text(
                'Chofer asignado',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              gap8,

              Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Nombre',
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      Text(
                        assignedDriver,
                        style: textTheme.bodyLarge,
                      ),
                      gapW12,
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Symbols.edit,
                          size: 16,
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              gap16,

              // Documentación
              Text(
                'Documentación',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              gap8,

              // Tabs de documentación
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Documentación',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Vencimiento',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Vigente',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Editar',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              gap12,

              // Lista de documentos
              ...documents.map((doc) {
                final now = DateTime.now();
                final daysUntilExpiration = doc.expirationDate.difference(now).inDays;

                IconData statusIcon;
                Color statusColor;

                if (daysUntilExpiration < 0) {
                  statusIcon = Symbols.cancel;
                  statusColor = colors.error;
                } else {
                  statusIcon = Symbols.check_circle;
                  statusColor = Colors.green;
                }

                final formattedDate = DateFormat('dd/MM/yyyy').format(doc.expirationDate);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          doc.name,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          formattedDate,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Icon(
                            statusIcon,
                            color: statusColor,
                            size: 20,
                            fill: 1,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                UpdateVehicleDocumentPageAdmin.route(
                                  documentName: doc.name,
                                  currentDate: doc.expirationDate,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colors.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Symbols.edit,
                                size: 16,
                                color: colors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentData {
  final String name;
  final DateTime expirationDate;

  _DocumentData({
    required this.name,
    required this.expirationDate,
  });
}
