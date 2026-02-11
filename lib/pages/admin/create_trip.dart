import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/client_data.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';

import 'package:frontend_sgfcp/services/client_service.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';

class CreateTripPageAdmin extends StatefulWidget {
  const CreateTripPageAdmin({super.key});

  static const String routeName = '/admin/create-trip';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const CreateTripPageAdmin());
  }

  @override
  State<CreateTripPageAdmin> createState() => _CreateTripPageAdminState();
}

class _CreateTripPageAdminState extends State<CreateTripPageAdmin> {
  final maxCityLength = 22;
  final maxDescriptionLength = 40;

  DateTime? _startDate;
  final List<int> _selectedDriverIds = [];
  int? _selectedClientId;
  bool _isLoading = false;
  bool _showValidationErrors = false;

  late final Future<List<ClientData>> _clientsFuture;
  late final Future<List<DriverData>> _driversFuture;

  // Controllers
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _originDescController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _destinationDescController =
      TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

  final WidgetStatesController _originStatesController =
      WidgetStatesController();
  final WidgetStatesController _destinationStatesController =
      WidgetStatesController();
  final WidgetStatesController _dateStatesController =
      WidgetStatesController();
  final WidgetStatesController _clientStatesController =
      WidgetStatesController();

  @override
  void initState() {
    super.initState();
    _clientsFuture = ClientService.getClients();
    _driversFuture = DriverService.getDrivers();

    _originController.addListener(_updateValidationStates);
    _destinationController.addListener(_updateValidationStates);
  }

  @override
  void dispose() {
    _originController.dispose();
    _originDescController.dispose();
    _destinationController.dispose();
    _destinationDescController.dispose();
    _startDateController.dispose();
    _originStatesController.dispose();
    _destinationStatesController.dispose();
    _dateStatesController.dispose();
    _clientStatesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        final locale = Localizations.localeOf(context).toString();
        _startDateController.text = DateFormat(
          'dd/MM/yyyy',
          locale,
        ).format(picked);
        _updateValidationStates();
      });
    }
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;
    _originStatesController.update(
      WidgetState.error,
      _originController.text.trim().isEmpty,
    );
    _destinationStatesController.update(
      WidgetState.error,
      _destinationController.text.trim().isEmpty,
    );
    _dateStatesController.update(WidgetState.error, _startDate == null);
    _clientStatesController.update(
      WidgetState.error,
      _selectedClientId == null,
    );
  }

  bool _validateRequiredFields() {
    final hasOrigin = _originController.text.trim().isNotEmpty;
    final hasDestination = _destinationController.text.trim().isNotEmpty;
    final hasStartDate = _startDate != null;
    final hasClient = _selectedClientId != null;
    final hasDriver = _selectedDriverIds.isNotEmpty;

    setState(() {
      _showValidationErrors = true;
      _originStatesController.update(WidgetState.error, !hasOrigin);
      _destinationStatesController.update(WidgetState.error, !hasDestination);
      _dateStatesController.update(WidgetState.error, !hasStartDate);
      _clientStatesController.update(WidgetState.error, !hasClient);
    });

    return hasOrigin && hasDestination && hasStartDate && hasClient && hasDriver;
  }

  void _createTrip() async {
    if (!_validateRequiredFields()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final createdTrips = await TripService.createTrip(
        origin: _originController.text,
        originDescription: _originDescController.text.isNotEmpty
            ? _originDescController.text
            : null,
        destination: _destinationController.text,
        destinationDescription: _destinationDescController.text.isNotEmpty
            ? _destinationDescController.text
            : null,
        startDate: _startDate!,
        clientId: _selectedClientId!,
        driverIds: _selectedDriverIds,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${createdTrips.length} viaje(s) creado(s) correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear viaje: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Viaje')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Origen
              TextField(
                controller: _originController,
                enabled: !_isLoading,
                statesController: _originStatesController,
                maxLength: maxCityLength,
                decoration: InputDecoration(
                  labelText: 'Origen',
                  counterText: '',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          _originController.text.trim().isEmpty
                      ? 'Campo requerido'
                      : null,
                ),
              ),
              gap12,

              // Descripción Origen
              TextField(
                controller: _originDescController,
                enabled: !_isLoading,
                maxLength: maxDescriptionLength,
                decoration: const InputDecoration(
                  labelText: 'Descripción Origen',
                  counterText: '',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              gap12,

              // Destino
              TextField(
                controller: _destinationController,
                enabled: !_isLoading,
                statesController: _destinationStatesController,
                maxLength: maxCityLength,
                decoration: InputDecoration(
                  labelText: 'Destino',
                  counterText: '',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          _destinationController.text.trim().isEmpty
                      ? 'Campo requerido'
                      : null,
                ),
              ),
              gap12,

              // Descripción Destino
              TextField(
                controller: _destinationDescController,
                enabled: !_isLoading,
                maxLength: maxDescriptionLength,
                decoration: const InputDecoration(
                  labelText: 'Descripción Destino',
                  counterText: '',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              gap12,

              // Fecha de inicio
              TextField(
                controller: _startDateController,
                readOnly: true,
                enabled: !_isLoading,
                statesController: _dateStatesController,
                decoration: InputDecoration(
                  labelText: 'Fecha Inicio',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors && _startDate == null
                      ? 'Campo requerido'
                      : null,
                ),
                onTap: _isLoading ? null : _pickStartDate,
              ),
              gap16,

              // Cliente
              FutureBuilder<List<ClientData>>(
                future: _clientsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.outline),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error al cargar clientes: ${snapshot.error}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.error,
                      ),
                    );
                  }

                  final clients = snapshot.data ?? [];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return DropdownMenu<int>(
                        enabled: !_isLoading,
                        width: constraints.maxWidth,
                        label: const Text('Cliente'),
                        errorText: _showValidationErrors &&
                                _selectedClientId == null
                            ? 'Campo requerido'
                            : null,
                        initialSelection: _selectedClientId,
                        dropdownMenuEntries: clients
                            .map(
                              (client) => DropdownMenuEntry(
                                value: client.id,
                                label: client.name,
                              ),
                            )
                            .toList(),
                        onSelected: (value) {
                          setState(() {
                            _selectedClientId = value;
                            _updateValidationStates();
                          });
                        },
                      );
                    },
                  );
                },
              ),
              gap16,

              // Choferes Asignados
              Text('Choferes Asignados', style: textTheme.titleMedium),
              if (_showValidationErrors && _selectedDriverIds.isEmpty) ...[
                gap4,
                Text(
                  'Selecciona al menos un chofer',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
                ),
              ],
              gap8,

              // Selector de choferes
              FutureBuilder<List<DriverData>>(
                future: _driversFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error al cargar choferes: ${snapshot.error}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.error,
                      ),
                    );
                  }

                  final drivers = snapshot.data ?? [];

                  if (drivers.isEmpty) {
                    return Text(
                      'No hay choferes disponibles',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    );
                  }

                  return Column(
                    children: drivers.map((driver) {
                      final isSelected = _selectedDriverIds.contains(driver.id);
                      return CheckboxListTile(
                        enabled: !_isLoading,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(vertical: -4),
                        title: Text(driver.fullName),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedDriverIds.add(driver.id);
                            } else {
                              _selectedDriverIds.remove(driver.id);
                            }
                            _updateValidationStates();
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  );
                },
              ),
              gap24,

              // Botón Crear viaje
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isLoading ? null : _createTrip,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Symbols.add_road),
                label: Text(_isLoading ? 'Creando...' : 'Crear viaje'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
