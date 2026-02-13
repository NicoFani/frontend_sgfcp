import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/truck_service.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

class CreateTruckPageAdmin extends StatefulWidget {
  const CreateTruckPageAdmin({super.key});

  static const String routeName = '/admin/create-truck';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const CreateTruckPageAdmin());
  }

  @override
  State<CreateTruckPageAdmin> createState() => _CreateTruckPageAdminState();
}

class _CreateTruckPageAdminState extends State<CreateTruckPageAdmin> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _vtvDateController = TextEditingController();
  final TextEditingController _serviceDateController = TextEditingController();
  final TextEditingController _plateDateController = TextEditingController();

  final brandMaxLength = 24;
  final modelMaxLength = 24;
  
  int? _selectedDriverId;
  bool _isLoading = false;
  late Future<List<DriverData>> _driversFuture;
  
  DateTime _vtvDueDate = DateTime.now().add(const Duration(days: 365));
  DateTime _serviceDueDate = DateTime.now().add(const Duration(days: 180));
  DateTime _plateDueDate = DateTime.now().add(const Duration(days: 365));

  // Validation controllers
  final WidgetStatesController _brandStatesController = WidgetStatesController();
  final WidgetStatesController _modelStatesController = WidgetStatesController();
  final WidgetStatesController _yearStatesController = WidgetStatesController();
  final WidgetStatesController _plateStatesController = WidgetStatesController();
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _driversFuture = DriverService.getDrivers();
    // Initialize date controllers with default dates
    final dateFormat = DateFormat('dd/MM/yyyy');
    _vtvDateController.text = dateFormat.format(_vtvDueDate);
    _serviceDateController.text = dateFormat.format(_serviceDueDate);
    _plateDateController.text = dateFormat.format(_plateDueDate);

    // Add validation listeners
    _brandController.addListener(_updateValidationStates);
    _modelController.addListener(_updateValidationStates);
    _yearController.addListener(_updateValidationStates);
    _plateController.addListener(_updateValidationStates);
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _vtvDateController.dispose();
    _serviceDateController.dispose();
    _plateDateController.dispose();
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

  Future<void> _pickDate(String type) async {
    final now = DateTime.now();
    final currentDate = type == 'vtv'
        ? _vtvDueDate
        : type == 'service'
            ? _serviceDueDate
            : _plateDueDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        final dateFormat = DateFormat('dd/MM/yyyy');
        if (type == 'vtv') {
          _vtvDueDate = picked;
          _vtvDateController.text = dateFormat.format(picked);
        } else if (type == 'service') {
          _serviceDueDate = picked;
          _serviceDateController.text = dateFormat.format(picked);
        } else {
          _plateDueDate = picked;
          _plateDateController.text = dateFormat.format(picked);
        }
      });
    }
  }

  Future<void> _createTruck() async {
    if (!_validateRequiredFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await TruckService.createTruck(
        plate: _plateController.text.replaceAll(' ', ''),
        operational: true,
        brand: _brandController.text,
        modelName: _modelController.text,
        fabricationYear: int.parse(_yearController.text),
        serviceDueDate: _serviceDueDate,
        vtvDueDate: _vtvDueDate,
        plateDueDate: _plateDueDate,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehículo creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear vehículo: $e'),
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
        title: const Text('Alta de vehículo'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Marca
                TextField(
                  controller: _brandController,
                  statesController: _brandStatesController,
                  maxLength: brandMaxLength,
                  decoration: InputDecoration(
                    labelText: 'Marca',
                    border: const OutlineInputBorder(),
                    counterText: '', // Ocultar contador de caracteres
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    errorText: _showValidationErrors &&
                            _brandController.text.trim().isEmpty
                        ? 'Ingresa una marca'
                        : null,
                  ),
                ),

                gap12,

                // Modelo
                TextField(
                  controller: _modelController,
                  statesController: _modelStatesController,
                  maxLength: modelMaxLength,
                  decoration: InputDecoration(
                    labelText: 'Modelo',
                    border: const OutlineInputBorder(),
                    counterText: '', // Ocultar contador de caracteres
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    errorText: _showValidationErrors &&
                            _modelController.text.trim().isEmpty
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
                  maxLength: 9, // Max formatted length: "AA 000 AA"
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
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final drivers = snapshot.data ?? [];
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
                              ),
                            )
                      ],
                      onSelected: (value) {
                        setState(() {
                          _selectedDriverId = value;
                        });
                      },
                    );
                  },
                ),

                gap12,

                // VTV Due Date
                TextField(
                  controller: _vtvDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'VTV - Fecha de vencimiento',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  onTap: () => _pickDate('vtv'),
                ),

                gap12,

                // Service Due Date
                TextField(
                  controller: _serviceDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Service - Fecha de vencimiento',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  onTap: () => _pickDate('service'),
                ),

                gap12,

                // Plate Due Date
                TextField(
                  controller: _plateDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Patente - Fecha de vencimiento',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  onTap: () => _pickDate('plate'),
                ),

                gap16,

                // Botón Dar vehículo de alta
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _isLoading ? null : _createTruck,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Symbols.check),
                  label: Text(_isLoading ? 'Creando...' : 'Dar vehículo de alta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
