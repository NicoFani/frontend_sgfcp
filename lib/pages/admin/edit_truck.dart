import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_sgfcp/pages/admin/trucks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/truck_service.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/driver_truck_service.dart';
import 'package:frontend_sgfcp/models/truck_data.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

class EditTruckPage extends StatefulWidget {
  final int truckId;

  const EditTruckPage({
    super.key,
    required this.truckId,
  });

  static const String routeName = '/admin/edit-truck';

  static Route route({
    required int truckId,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => EditTruckPage(
        truckId: truckId,
      ),
    );
  }

  @override
  State<EditTruckPage> createState() => _EditTruckPageState();
}

class _EditTruckPageState extends State<EditTruckPage> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  
  int? _selectedDriverId;
  int? _originalDriverId; // To track if driver changed
  int? _originalDriverTruckId;
  bool _assignmentSelectionChanged = false;
  bool _isLoading = false;
  late Future<TruckData> _truckFuture;
  late Future<List<DriverData>> _driversFuture;
  late Future<Map<String, dynamic>?> _currentDriverFuture;

  // Validation controllers
  final WidgetStatesController _brandStatesController = WidgetStatesController();
  final WidgetStatesController _modelStatesController = WidgetStatesController();
  final WidgetStatesController _yearStatesController = WidgetStatesController();
  final WidgetStatesController _plateStatesController = WidgetStatesController();
  bool _showValidationErrors = false;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _truckFuture = TruckService.getTruckById(truckId: widget.truckId);
    _driversFuture = DriverService.getDrivers();
    _currentDriverFuture = TruckService.getTruckCurrentDriver(truckId: widget.truckId);
    _loadOriginalAssignment();

    // Add validation listeners
    _brandController.addListener(_updateValidationStates);
    _modelController.addListener(_updateValidationStates);
    _yearController.addListener(_updateValidationStates);
    _plateController.addListener(_updateValidationStates);
  }

  Future<void> _loadOriginalAssignment() async {
    try {
      final assignment = await DriverTruckService.getCurrentAssignmentByTruck(widget.truckId);
      if (assignment == null) {
        return;
      }

      if (mounted) {
        setState(() {
          _originalDriverTruckId = assignment.id;
          _originalDriverId ??= assignment.driverId;
        });
      }
    } catch (_) {
      // Ignore assignment load errors here; we'll retry on save.
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _brandStatesController.dispose();
    _modelStatesController.dispose();
    _yearStatesController.dispose();
    _plateStatesController.dispose();
    super.dispose();
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;

    setState(() {
      _brandStatesController.update(
        WidgetState.error,
        _brandController.text.trim().isEmpty,
      );
      _modelStatesController.update(
        WidgetState.error,
        _modelController.text.trim().isEmpty,
      );
      
      // Year validation: must be 4 digits
      final yearText = _yearController.text.trim();
      _yearStatesController.update(
        WidgetState.error,
        yearText.isEmpty || yearText.length != 4,
      );
      
      // Plate validation
      _plateStatesController.update(
        WidgetState.error,
        !isValidPlate(_plateController.text),
      );
    });
  }

  bool _validateRequiredFields() {
    final hasBrand = _brandController.text.trim().isNotEmpty;
    final hasModel = _modelController.text.trim().isNotEmpty;
    final yearText = _yearController.text.trim();
    final hasYear = yearText.isNotEmpty && yearText.length == 4;
    final hasValidPlate = isValidPlate(_plateController.text);

    setState(() {
      _showValidationErrors = true;
      _brandStatesController.update(WidgetState.error, !hasBrand);
      _modelStatesController.update(WidgetState.error, !hasModel);
      _yearStatesController.update(WidgetState.error, !hasYear);
      _plateStatesController.update(WidgetState.error, !hasValidPlate);
    });

    return hasBrand && hasModel && hasYear && hasValidPlate;
  }

  Future<void> _removeOriginalAssignmentIfNeeded() async {
    if (_originalDriverId == _selectedDriverId && _originalDriverTruckId == null) {
      return;
    }

    if (_originalDriverTruckId != null) {
      await DriverTruckService.removeDriverFromTruck(
        driverTruckId: _originalDriverTruckId!,
      );
      return;
    }

    final assignment = await DriverTruckService.getCurrentAssignmentByTruck(widget.truckId);
    if (assignment == null) {
      return;
    }

    await DriverTruckService.removeDriverFromTruck(
      driverTruckId: assignment.id,
    );
  }

  Future<void> _saveChanges() async {
    if (!_validateRequiredFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Actualizar datos del camión
      await TruckService.updateTruck(
        truckId: widget.truckId,
        brand: _brandController.text,
        modelName: _modelController.text,
        fabricationYear: int.parse(_yearController.text),
        plate: _plateController.text.replaceAll(' ', ''),
      );

      // Si el chofer cambió, crear nueva asignación
      if (_assignmentSelectionChanged) {
        await _removeOriginalAssignmentIfNeeded();
        if (_selectedDriverId != null) {
          await DriverTruckService.assignDriverToTruck(
            driverId: _selectedDriverId!,
            truckId: widget.truckId,
            date: DateTime.now(),
          );
        }
        // Note: If _selectedDriverId is null, we're unassigning the driver
        // The current driver will no longer be considered "current" as there's
        // no new assignment for this truck
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehículo actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _assignmentSelectionChanged = false;
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

  Future<void> _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dar de baja vehículo?'),
        content: const Text(
          'El vehículo será dado de baja. Esta acción es irreversible, y el vehículo no podrá ser utilizado ni editado posteriormente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _deleteTruck();
    }
  }

  Future<void> _deleteTruck() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final assignment = _originalDriverTruckId != null
          ? null
          : await DriverTruckService.getCurrentAssignmentByTruck(widget.truckId);

      if (_originalDriverTruckId != null) {
        await DriverTruckService.removeDriverFromTruck(
          driverTruckId: _originalDriverTruckId!,
        );
      } else if (assignment != null) {
        await DriverTruckService.removeDriverFromTruck(
          driverTruckId: assignment.id,
        );
      }

      await TruckService.deleteTruck(truckId: widget.truckId);

      if (mounted) {
        Navigator.of(context).pushReplacement(TrucksPageAdmin.route());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehículo dado de baja correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al dar de baja el vehículo: $e'),
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
            onPressed: _showDeleteDialog,
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
          
          if (!_controllersInitialized) {
            _brandController.text = truck.brand;
            _modelController.text = truck.modelName;
            _yearController.text = truck.fabricationYear.toString();
            _plateController.text = formatPlate(truck.plate);
            _controllersInitialized = true;
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

              return FutureBuilder<Map<String, dynamic>?>(
                future: _currentDriverFuture,
                builder: (context, currentDriverSnapshot) {
                  // Set the selected driver from current assignment
                  if (currentDriverSnapshot.hasData && _selectedDriverId == null) {
                    final driverData = currentDriverSnapshot.data?['driver'];
                    if (driverData != null) {
                      _selectedDriverId = driverData['id'] as int;
                      _originalDriverId = _selectedDriverId; // Track original
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
                              statesController: _brandStatesController,
                              decoration: InputDecoration(
                                labelText: 'Marca',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                errorText: _showValidationErrors &&
                                        _brandController.text.isEmpty
                                    ? 'Ingresa una marca'
                                    : null,
                              ),
                            ),

                            gap12,

                            // Modelo
                            TextField(
                              controller: _modelController,
                              statesController: _modelStatesController,
                              decoration: InputDecoration(
                                labelText: 'Modelo',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                errorText: _showValidationErrors &&
                                        _modelController.text.isEmpty
                                    ? 'Ingresa un modelo'
                                    : null,
                              ),
                            ),

                            gap12,

                            // Año
                            TextField(
                              controller: _yearController,
                              statesController: _yearStatesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              maxLength: 4,
                              decoration: InputDecoration(
                                labelText: 'Año',
                                hintText: '2024',
                                counterText: '',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                errorText: _showValidationErrors
                                    ? () {
                                        final text = _yearController.text.trim();
                                        if (text.isEmpty) return 'Ingresa un año';
                                        if (text.length != 4) return 'Debe tener 4 dígitos';
                                        return null;
                                      }()
                                    : null,
                              ),
                            ),

                            gap12,

                            // Patente
                            TextField(
                              controller: _plateController,
                              statesController: _plateStatesController,
                              inputFormatters: [PlateInputFormatter()],
                              maxLength: 9,
                              decoration: InputDecoration(
                                labelText: 'Patente',
                                hintText: 'ABC 123 o AB 123 CD',
                                counterText: '',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                errorText: _showValidationErrors &&
                                        !isValidPlate(_plateController.text)
                                    ? 'Formato inválido'
                                    : null,
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
                                return DropdownMenu<int?>(
                                  expandedInsets: EdgeInsets.zero,
                                  initialSelection: _selectedDriverId,
                                  label: const Text('Chofer asignado'),
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
                                            enabled: (driver.currentTruck == null), // Solo habilitar si no tiene camión asignado o es el chofer actual
                                          ),
                                        )
                                  ],
                                  onSelected: (value) {
                                    setState(() {
                                      if (value != _selectedDriverId) {
                                        _assignmentSelectionChanged = true;
                                      }
                                      _selectedDriverId = value;
                                    });
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
