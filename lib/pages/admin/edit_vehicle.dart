import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/truck_service.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/models/truck_data.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';

class EditVehiclePage extends StatefulWidget {
  final int truckId;

  const EditVehiclePage({
    super.key,
    required this.truckId,
  });

  static const String routeName = '/admin/edit-vehicle';

  static Route route({
    required int truckId,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => EditVehiclePage(
        truckId: truckId,
      ),
    );
  }

  @override
  State<EditVehiclePage> createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  
  int? _selectedDriverId;
  bool _isLoading = false;
  late Future<TruckData> _truckFuture;
  late Future<List<DriverData>> _driversFuture;
  late Future<Map<String, dynamic>?> _currentDriverFuture;

  @override
  void initState() {
    super.initState();
    _truckFuture = TruckService.getTruckById(truckId: widget.truckId);
    _driversFuture = DriverService.getDrivers();
    _currentDriverFuture = TruckService.getTruckCurrentDriver(truckId: widget.truckId);
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TruckService.updateTruck(
        truckId: widget.truckId,
        brand: _brandController.text,
        modelName: _modelController.text,
        fabricationYear: int.parse(_yearController.text),
        plate: _plateController.text,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehículo actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar vehículo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar datos del vehículo'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.delete),
            onPressed: () {
              // TODO: Implementar dialog de eliminar vehículo
            },
          ),
        ],
      ),
      body: FutureBuilder<TruckData>(
        future: _truckFuture,
        builder: (context, truckSnapshot) {
          if (truckSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (truckSnapshot.hasError) {
            return Center(child: Text('Error: ${truckSnapshot.error}'));
          }

          if (!truckSnapshot.hasData) {
            return const Center(child: Text('No se encontraron datos del vehículo'));
          }

          final truck = truckSnapshot.data!;
          
          // Initialize controllers with truck data if not already set
          if (_brandController.text.isEmpty) {
            _brandController.text = truck.brand;
            _modelController.text = truck.modelName;
            _yearController.text = truck.fabricationYear.toString();
            _plateController.text = truck.plate;
          }

          return FutureBuilder<List<DriverData>>(
            future: _driversFuture,
            builder: (context, driversSnapshot) {
              if (driversSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (driversSnapshot.hasError) {
                return Center(child: Text('Error: ${driversSnapshot.error}'));
              }

              final drivers = driversSnapshot.data ?? [];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _currentDriverFuture,
                builder: (context, currentDriverSnapshot) {
                  // Set the selected driver from current assignment
                  if (currentDriverSnapshot.hasData && _selectedDriverId == null) {
                    final driverData = currentDriverSnapshot.data?['driver'];
                    if (driverData != null) {
                      _selectedDriverId = driverData['id'] as int;
                    }
                  }

                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Marca
                            TextField(
                              controller: _brandController,
                              decoration: const InputDecoration(
                                labelText: 'Marca',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),

                            gap12,

                            // Modelo
                            TextField(
                              controller: _modelController,
                              decoration: const InputDecoration(
                                labelText: 'Modelo',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),

                            gap12,

                            // Año
                            TextField(
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Año',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),

                            gap12,

                            // Patente
                            TextField(
                              controller: _plateController,
                              decoration: const InputDecoration(
                                labelText: 'Patente',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),

                            gap12,

                            // Chofer asignado
                            FutureBuilder<List<DriverData>>(
                              future: _driversFuture,
                              builder: (context, driversSnapshot) {
                                if (driversSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (driversSnapshot.hasError) {
                                  return Text('Error: ${driversSnapshot.error}');
                                }
                                final drivers = driversSnapshot.data ?? [];
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return DropdownMenu<int?>(
                                      width: constraints.maxWidth,
                                      label: const Text('Chofer asignado'),
                                      initialSelection: _selectedDriverId,
                                      dropdownMenuEntries: [
                                        const DropdownMenuEntry<int?>(
                                          value: null,
                                          label: 'Sin asignar',
                                        ),
                                        ...drivers
                                            .map(
                                              (driver) => DropdownMenuEntry<int?>(
                                                value: driver.id,
                                                label: driver.fullName,
                                              ),
                                            )
                                            .toList(),
                                      ],
                                      onSelected: (value) {
                                        setState(() {
                                          _selectedDriverId = value;
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),

                            gap16,

                            // Botón Guardar cambios
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: _isLoading ? null : _saveChanges,
                              icon: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Symbols.check),
                              label: Text(_isLoading ? 'Guardando...' : 'Guardar cambios'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
