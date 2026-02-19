import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:frontend_sgfcp/models/client_data.dart';
import 'package:frontend_sgfcp/models/load_owner_data.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/load_type_data.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/widgets/document_type_selector.dart';
import 'package:frontend_sgfcp/widgets/checkbox_text_field.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';
import 'package:frontend_sgfcp/services/client_service.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/load_owner_service.dart';
import 'package:frontend_sgfcp/services/load_type_service.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';
import 'package:frontend_sgfcp/utils/document_type_mapper.dart';

class EditTripPage extends StatefulWidget {
  final TripData trip;

  const EditTripPage({super.key, required this.trip});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/edit_trip';

  /// Helper to create a route to this page
  static Route route({required TripData trip}) {
    return MaterialPageRoute<void>(builder: (_) => EditTripPage(trip: trip));
  }

  @override
  State<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  late Future<List<DriverData>> _driversFuture;
  late Future<List<ClientData>> _clientsFuture;
  late final Future<List<LoadOwnerData>> _loadOwnersFuture;
  late final Future<List<LoadTypeData>> _loadTypesFuture;

  DocumentType _docType = DocumentType.ctg;
  bool _isLoading = false;
  LoadOwnerData? _selectedLoadOwner;
  LoadTypeData? _selectedLoadType;
  ClientData? _selectedClient;
  DateTime? _startDate;
  DateTime? _endDate;
  DriverData? _selectedDriver;
  bool _showValidationErrors = false;
  bool _calculatedPerKm = false;
  bool _fuelDelivered = false;
  bool _clientAdvancePayment = false;

  // Controllers
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _originDescController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _destinationDescController =
      TextEditingController();
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _netWeightController = TextEditingController();
  final TextEditingController _kmsController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _fuelLitersController = TextEditingController();

  final WidgetStatesController _docNumberStatesController =
      WidgetStatesController();
  final WidgetStatesController _weightStatesController =
      WidgetStatesController();
  final WidgetStatesController _kmStatesController = WidgetStatesController();
  final WidgetStatesController _originStatesController =
      WidgetStatesController();
  final WidgetStatesController _destinationStatesController =
      WidgetStatesController();

    bool get isAdmin =>
      (TokenStorage.user != null && TokenStorage.user!['is_admin'] == true);
  bool get _isFinalized => widget.trip.state == 'Finalizado';
  bool get _isPending => widget.trip.state == 'Pendiente';
  bool get _isInProgress => widget.trip.state == 'En curso';

  @override
  void initState() {
    super.initState();
    _driversFuture = DriverService.getDrivers();
    _clientsFuture = ClientService.getClients();
    _loadOwnersFuture = LoadOwnerService.getLoadOwners();
    _loadTypesFuture = LoadTypeService.getLoadTypes();
    _docNumberController.addListener(_updateValidationStates);
    _originController.addListener(_updateValidationStates);
    _destinationController.addListener(_updateValidationStates);
    _netWeightController.addListener(_updateValidationStates);
    _kmsController.addListener(_updateValidationStates);

    // Populate data
    _docType = parseDocumentType(widget.trip.documentType);
    _docNumberController.text = widget.trip.documentNumber;
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
    _selectedDriver = widget.trip.driver;
    _selectedLoadOwner = widget.trip.loadOwner;
    _selectedLoadType = widget.trip.loadType;
    _selectedClient = widget.trip.client;
    _originController.text = widget.trip.origin;
    _originDescController.text = widget.trip.originDescription ?? '';
    _destinationController.text = widget.trip.destination;
    _destinationDescController.text = widget.trip.destinationDescription ?? '';
    _calculatedPerKm = widget.trip.calculatedPerKm;
    final currencyFormatter = CurrencyTextInputFormatter.currency(
      locale: 'es_AR',
      symbol: '',
      decimalDigits: 2,
      enableNegative: false,
    );
    _netWeightController.text = currencyFormatter.formatDouble(widget.trip.loadWeightOnLoad);
    _kmsController.text = currencyFormatter.formatDouble(widget.trip.estimatedKms);
    _rateController.text = currencyFormatter.formatDouble(widget.trip.rate);
    _advanceController.text = widget.trip.clientAdvancePayment > 0
      ? currencyFormatter.formatDouble(widget.trip.clientAdvancePayment)
      : '';
    _fuelLitersController.text = widget.trip.fuelLiters > 0
      ? widget.trip.fuelLiters.toString()
      : '';
    _fuelDelivered = widget.trip.fuelOnClient;
    _clientAdvancePayment = widget.trip.clientAdvancePayment > 0;

    // Formato de fecha sin necesidad de context
    _startDateController.text = DateFormat('dd/MM/yyyy').format(_startDate!);
    _endDateController.text = _endDate != null
      ? DateFormat('dd/MM/yyyy').format(_endDate!)
      : '';
  }

  // Datepicker para seleccionar fecha
  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final currentDate = isStart ? _startDate : _endDate;

    final DateTime firstDate;
    final DateTime lastDate;

    if (isStart && _isPending) {
      // Misma validación que en crear viaje: desde hoy hasta +5 años
      firstDate = now;
      lastDate = DateTime(now.year + 5);
    } else {
      firstDate = DateTime(now.year - 5);
      lastDate = DateTime(now.year + 5);
    }

    DateTime initialDate = currentDate ?? now;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }

        final locale = Localizations.localeOf(context).toString();
        final formatted = DateFormat(
          'dd/MM/yyyy',
          locale,
        ).format(picked);
        if (isStart) {
          _startDateController.text = formatted;
        } else {
          _endDateController.text = formatted;
        }
      });
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _originDescController.dispose();
    _destinationController.dispose();
    _destinationDescController.dispose();
    _docNumberController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _netWeightController.dispose();
    _kmsController.dispose();
    _rateController.dispose();
    _advanceController.dispose();
    _fuelLitersController.dispose();
    _docNumberStatesController.dispose();
    _weightStatesController.dispose();
    _kmStatesController.dispose();
    _originStatesController.dispose();
    _destinationStatesController.dispose();
    super.dispose();
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;
    if (_isInProgress) {
      _docNumberStatesController.update(
        WidgetState.error,
        _docNumberController.text.trim().isEmpty,
      );
    }
    if (isAdmin) {
      _originStatesController.update(
        WidgetState.error,
        _originController.text.trim().isEmpty,
      );
      _destinationStatesController.update(
        WidgetState.error,
        _destinationController.text.trim().isEmpty,
      );
    }
    if (_isInProgress) {
      _weightStatesController.update(
        WidgetState.error,
        _netWeightController.text.trim().isEmpty,
      );
      _kmStatesController.update(
        WidgetState.error,
        _kmsController.text.trim().isEmpty,
      );
    }
  }

  bool _validateRequiredFields() {
    final hasDocNumber = !_isInProgress || _docNumberController.text.trim().isNotEmpty;
    final hasOrigin =
      !(isAdmin || _isPending) || _originController.text.trim().isNotEmpty;
    final hasDestination =
      !(isAdmin || _isPending) || _destinationController.text.trim().isNotEmpty;
    final hasClient =
      !(isAdmin || _isPending) ||
      (_selectedClient?.id ?? widget.trip.clientId) != null;
    final hasWeight = !_isInProgress || _netWeightController.text.trim().isNotEmpty;
    final hasKm = !_isInProgress || _kmsController.text.trim().isNotEmpty;
    final hasLoadOwner = !_isInProgress || (_selectedLoadOwner?.id ?? widget.trip.loadOwnerId) != null;
    final hasLoadType = !_isInProgress || (_selectedLoadType?.id ?? widget.trip.loadTypeId) != null;
    final hasEndDate = !_isFinalized || _endDate != null;

    setState(() {
      _showValidationErrors = true;
      if (_isInProgress) {
        _docNumberStatesController.update(WidgetState.error, !hasDocNumber);
      }
      if (isAdmin || _isPending) {
        _originStatesController.update(WidgetState.error, !hasOrigin);
        _destinationStatesController.update(
          WidgetState.error,
          !hasDestination,
        );
      }
      if (_isInProgress) {
        _weightStatesController.update(WidgetState.error, !hasWeight);
        _kmStatesController.update(WidgetState.error, !hasKm);
      }
    });

    return hasDocNumber &&
        hasOrigin &&
        hasDestination &&
        hasClient &&
        hasWeight &&
        hasKm &&
        hasLoadOwner &&
        hasLoadType &&
        hasEndDate;
  }

  void _updateTrip() async {
    if (!_validateRequiredFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá los campos requeridos para guardar cambios.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    var updateSucceeded = false;
    TripData? updatedTrip;

    final Map<String, dynamic> data;
    if (_isPending) {
      data = <String, dynamic>{
        'driver_id':
            _selectedDriver?.id ??
            widget.trip.driver?.id ??
            widget.trip.driverId,
        'origin': _originController.text,
        if (_originDescController.text.trim().isNotEmpty)
          'origin_description': _originDescController.text.trim(),
        'destination': _destinationController.text,
        if (_destinationDescController.text.trim().isNotEmpty)
          'destination_description': _destinationDescController.text.trim(),
        'client_id': _selectedClient?.id ?? widget.trip.clientId,
        'start_date': _startDate!.toIso8601String().split('T')[0],
      };
    } else {
      data = <String, dynamic>{
        'document_type': documentTypeToApiValue(_docType),
        'document_number': _docNumberController.text,
        'driver_id':
            _selectedDriver?.id ??
            widget.trip.driver?.id ??
            widget.trip.driverId,
        'load_type_id':
            _selectedLoadType?.id ??
            widget.trip.loadType?.id ??
            widget.trip.loadTypeId,
        'origin': isAdmin ? _originController.text : widget.trip.origin,
        if (isAdmin && _originDescController.text.trim().isNotEmpty)
          'origin_description': _originDescController.text.trim(),
        'destination':
            isAdmin ? _destinationController.text : widget.trip.destination,
        if (isAdmin && _destinationDescController.text.trim().isNotEmpty)
          'destination_description': _destinationDescController.text.trim(),
        if (isAdmin) 'client_id': _selectedClient?.id ?? widget.trip.clientId,
        'start_date': _startDate!.toIso8601String().split('T')[0],
        if (_endDate != null)
          'end_date': _endDate!.toIso8601String().split('T')[0],
        'load_owner_id':
            _selectedLoadOwner?.id ??
            widget.trip.loadOwner?.id ??
            widget.trip.loadOwnerId,
        'calculated_per_km': _calculatedPerKm,
        'estimated_kms': parseCurrency(_kmsController.text),
        'load_weight_on_load': parseCurrency(_netWeightController.text),
        if (_rateController.text.trim().isNotEmpty)
          'rate': parseCurrency(_rateController.text),
        'fuel_on_client': _fuelDelivered,
        'fuel_liters': _fuelDelivered
            ? (double.tryParse(_fuelLitersController.text) ?? 0.0)
            : 0.0,
        if (_clientAdvancePayment && _advanceController.text.isNotEmpty)
          'client_advance_payment': parseCurrency(_advanceController.text),
      };
    }

    final currentContext = context;
    try {
      updatedTrip = await TripService.updateTrip(
        tripId: widget.trip.id,
        data: data,
      );
      updateSucceeded = true;
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('Error al guardar cambios: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        if (updateSucceeded) {
          // ignore: use_build_context_synchronously
          Navigator.of(currentContext).pop(updatedTrip);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Viaje')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: origen → destino
              Text(widget.trip.route, style: textTheme.titleLarge),

              gap12,

              if (!_isPending) ...[

              // ----- Documento + Número de documento -----
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Documento', style: textTheme.bodySmall),
                        DocumentTypeSelector(
                          selected: _docType,
                          onChanged: (newType) {
                            setState(() {
                              _docType = newType;
                              // cambia dinámicamente el maxLength del input
                              _docNumberController.text = "";
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  gapW8,

                  // Número de documento
                  Expanded(
                    flex: 1,
                    child: TextField(
                      enabled: !_isLoading,
                      controller: _docNumberController,
                      statesController: _docNumberStatesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: _docType == DocumentType.ctg ? 11 : 13,
                      decoration: InputDecoration(
                        labelText: "Nro. de documento",
                        border: OutlineInputBorder(),
                        counterText: "", // oculta contador si querés
                        errorText: _showValidationErrors &&
                          _isInProgress &&
                                _docNumberController.text.trim().isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                    ),
                  ),
                ],
              ),

              gap12,

              ], // end if (!_isPending)

              // Campos editables de alta (admin o viaje pendiente)
              if (isAdmin || _isPending) ...[
                TextField(
                  enabled: !_isLoading,
                  controller: _originController,
                  statesController: _originStatesController,
                  decoration: InputDecoration(
                    labelText: 'Origen',
                    border: const OutlineInputBorder(),
                    errorText: _showValidationErrors &&
                            _originController.text.trim().isEmpty
                        ? 'Campo requerido'
                        : null,
                  ),
                ),
                gap12,
                TextField(
                  enabled: !_isLoading,
                  controller: _originDescController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción Origen',
                    border: OutlineInputBorder(),
                  ),
                ),
                gap12,
                TextField(
                  enabled: !_isLoading,
                  controller: _destinationController,
                  statesController: _destinationStatesController,
                  decoration: InputDecoration(
                    labelText: 'Destino',
                    border: const OutlineInputBorder(),
                    errorText: _showValidationErrors &&
                            _destinationController.text.trim().isEmpty
                        ? 'Campo requerido'
                        : null,
                  ),
                ),
                gap12,
                TextField(
                  enabled: !_isLoading,
                  controller: _destinationDescController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción Destino',
                    border: OutlineInputBorder(),
                  ),
                ),
                gap12,
                FutureBuilder<List<ClientData>>(
                  future: _clientsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Text('Error al cargar clientes');
                    }

                    final clients = snapshot.data ?? [];
                    ClientData? selectedClient;
                    if (widget.trip.client != null) {
                      try {
                        selectedClient = clients.firstWhere(
                          (client) => client.id == widget.trip.client!.id,
                        );
                      } catch (e) {
                        // Si no se encuentra, dejar null
                      }
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return DropdownMenu<ClientData>(
                          enabled: !_isLoading,
                          width: constraints.maxWidth,
                          label: const Text('Cliente'),
                          errorText: _showValidationErrors &&
                              (_selectedClient?.id ?? widget.trip.clientId) == null
                              ? 'Campo requerido'
                              : null,
                          initialSelection:
                              _selectedClient ?? selectedClient,
                          dropdownMenuEntries: clients
                              .map(
                                (client) => DropdownMenuEntry(
                                  value: client,
                                  label: client.name,
                                ),
                              )
                              .toList(),
                          onSelected: (value) {
                            setState(() {
                              _selectedClient = value;
                              _updateValidationStates();
                            });
                          },
                        );
                      },
                    );
                  },
                ),
                gap12,
                FutureBuilder<List<DriverData>>(
                  future: _driversFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error loading drivers');
                    }
                    final drivers = snapshot.data ?? [];

                    // Encontrar el chofer seleccionado en la lista de choferes
                    DriverData? selectedDriver = _selectedDriver;
                    if (_selectedDriver != null) {
                      selectedDriver = drivers.firstWhere(
                        (d) => d.id == _selectedDriver!.id,
                        orElse: () => _selectedDriver!,
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return DropdownMenu<DriverData>(
                          enabled: !_isLoading,
                          width: constraints.maxWidth,
                          label: const Text('Chofer asignado'),
                          initialSelection: selectedDriver,
                          dropdownMenuEntries: drivers
                              .map(
                                (driver) => DropdownMenuEntry(
                                  value: driver,
                                  label: driver.fullName,
                                ),
                              )
                              .toList(),
                          onSelected: (value) {
                            setState(() {
                              _selectedDriver = value;
                            });
                          },
                        );
                      },
                    );
                  },
                ),

                gap12,
              ],

              // Fecha de inicio (+ Fecha de fin si no es Pendiente)
              if (_isPending)
                TextField(
                  enabled: !_isLoading,
                  controller: _startDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de inicio',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  onTap: _isLoading ? null : () => _pickDate(isStart: true),
                )
              else
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        enabled: !_isLoading,
                        controller: _startDateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Fecha de inicio',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        onTap:
                            _isLoading ? null : () => _pickDate(isStart: true),
                      ),
                    ),
                    gapW12,
                    Expanded(
                      flex: 1,
                      child: TextField(
                        enabled: !_isLoading && _isFinalized,
                        controller: _endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha de fin',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                          errorText: _showValidationErrors &&
                                  _isFinalized &&
                                  _endDate == null
                              ? 'Campo requerido'
                              : null,
                        ),
                        onTap: _isLoading || !_isFinalized
                            ? null
                            : () => _pickDate(isStart: false),
                      ),
                    ),
                  ],
                ),

              gap12,

              if (!_isPending) ...[

              // Peso neto + Km a recorrer
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      enabled: !_isLoading,
                      controller: _kmsController,
                      statesController: _kmStatesController,
                      decoration: InputDecoration(
                        labelText: 'Km a recorrer',
                        border: OutlineInputBorder(),
                        errorText: _showValidationErrors &&
                          _isInProgress &&
                                _kmsController.text.trim().isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        CurrencyTextInputFormatter.currency(
                          locale: 'es_AR',
                          symbol: '',
                          decimalDigits: 2,
                          enableNegative: false,
                        ),
                      ],
                    ),
                  ),
                  gapW12,
                  Expanded(
                    flex: 1,
                    child: TextField(
                      enabled: !_isLoading,
                      controller: _netWeightController,
                      statesController: _weightStatesController,
                      decoration: InputDecoration(
                        labelText: 'Peso de carga',
                        suffixText: ' t',
                        border: OutlineInputBorder(),
                        errorText: _showValidationErrors &&
                          _isInProgress &&
                                _netWeightController.text.trim().isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        CurrencyTextInputFormatter.currency(
                          locale: 'es_AR',
                          symbol: '',
                          decimalDigits: 2,
                          enableNegative: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              gap12,

              ], // end if (!_isPending)

              if (!_isPending) ...[

              FutureBuilder<List<LoadOwnerData>>(
                future: _loadOwnersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text('Error al cargar dadores');
                  }

                  final loadOwners = snapshot.data ?? [];
                  LoadOwnerData? selectedLoadOwner;
                  if (widget.trip.loadOwner != null) {
                    try {
                      selectedLoadOwner = loadOwners.firstWhere(
                        (owner) => owner.id == widget.trip.loadOwner!.id,
                      );
                    } catch (e) {
                      // Si no se encuentra, dejar null
                    }
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return DropdownMenu<LoadOwnerData>(
                        enabled: !_isLoading,
                        width: constraints.maxWidth,
                        label: const Text('Dador de Carga'),
                        errorText: _showValidationErrors &&
                          _isInProgress &&
                          (_selectedLoadOwner?.id ?? widget.trip.loadOwnerId) == null
                            ? 'Campo requerido'
                            : null,
                        initialSelection: selectedLoadOwner,
                        dropdownMenuEntries: loadOwners
                            .map(
                              (owner) => DropdownMenuEntry(
                                value: owner,
                                label: owner.name,
                              ),
                            )
                            .toList(),
                        onSelected: (value) {
                          setState(() {
                            _selectedLoadOwner = value;
                            _updateValidationStates();
                          });
                        },
                      );
                    },
                  );
                },
              ),

              gap12,

              // Tipo de carga
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<List<LoadTypeData>>(
                    future: _loadTypesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(  
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Text(
                          'Error cargando tipos de carga',
                        );
                      }

                      final loadTypes = snapshot.data ?? [];

                      // Buscar el tipo de carga seleccionado por ID
                      LoadTypeData? selectedLoadType;
                      if (widget.trip.loadType != null) {
                        try {
                          selectedLoadType = loadTypes.firstWhere(
                            (lt) => lt.id == widget.trip.loadType!.id,
                          );
                        } catch (e) {
                          // Si no se encuentra, dejar null
                        }
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return DropdownMenu<LoadTypeData>(
                            enabled: !_isLoading,
                            width: constraints.maxWidth,
                            label: const Text('Tipo de carga'),
                            errorText: _showValidationErrors &&
                                  _isInProgress &&
                                  (_selectedLoadType?.id ?? widget.trip.loadTypeId) == null
                                ? 'Campo requerido'
                                : null,
                            initialSelection: selectedLoadType,
                            dropdownMenuEntries: loadTypes
                                .map(
                                  (loadType) => DropdownMenuEntry(
                                    value: loadType,
                                    label: loadType.name,
                                  ),
                                )
                                .toList(),
                            onSelected: (value) {
                              setState(() {
                                _selectedLoadType = value;
                                if (value != null) {
                                  _calculatedPerKm =
                                      value.defaultCalculatedPerKm;
                                }
                                _updateValidationStates();
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),

              gap4,

              ], // end if (!_isPending)

              if (!_isPending) ...[

              // Tipo de calculo
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tipo de cálculo'),
                subtitle: Text(
                  _calculatedPerKm
                      ? 'Por kilómetro'
                      : 'Por tonelada',
                ),
                value: _calculatedPerKm,
                onChanged: (value) {
                  setState(() => _calculatedPerKm = value);
                },
              ),

              gap12,

              // Tarifa
              TextField(
                enabled: !_isLoading,
                controller: _rateController,
                decoration: InputDecoration(
                  labelText: _calculatedPerKm
                      ? 'Tarifa por Kilómetro'
                      : 'Tarifa por Tonelada',
                  border: const OutlineInputBorder(),
                  prefixText: r'$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  CurrencyTextInputFormatter.currency(
                    locale: 'es_AR',
                    symbol: '',
                    decimalDigits: 2,
                    enableNegative: false,
                  ),
                ],
              ),

              gap12,

              ], // end if (!_isPending)

              if (!_isPending) ...[

              // Vale de combustible entregado + Adelanto del cliente
              CheckboxTextField(
                enabled: !_isLoading,
                value: _fuelDelivered,
                onChanged: (value) {
                  setState(() {
                    _fuelDelivered = value ?? false;
                  });
                },
                controller: _fuelLitersController,
                checkboxLabel: 'Vale de Combustible entregado por el cliente',
                textFieldLabel: 'Litros del Vale',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),

              CheckboxTextField(
                value: _clientAdvancePayment,
                enabled: !_isLoading,
                onChanged: (value) {
                  setState(() {
                    _clientAdvancePayment = value ?? false;
                  });
                },
                controller: _advanceController,
                checkboxLabel: 'Adelanto del cliente recibido',
                textFieldLabel: 'Importe del Adelanto',
                keyboardType: TextInputType.number,
                prefixText: r'$ ',
                inputFormatters: [
                  CurrencyTextInputFormatter.currency(
                    locale: 'es_AR',
                    symbol: '',
                    decimalDigits: 2,
                    enableNegative: false,
                  ),
                ],
              ),

              gap16,

              ], // end if (!_isPending)

              // Botón principal: Guardar cambios
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                // TODO: al navegar se sigue viendo la data antigua, habría que actualizar el viaje en las páginas anteriores también
                onPressed: _isLoading ? null : _updateTrip,
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
                    : const Icon(Icons.check),
                label: Text(_isLoading ? 'Guardando...' : 'Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
