import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import 'package:frontend_sgfcp/widgets/document_type_selector.dart';
import 'package:frontend_sgfcp/widgets/checkbox_text_field.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/models/load_owner_data.dart';
import 'package:frontend_sgfcp/models/load_type_data.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';
import 'package:frontend_sgfcp/utils/document_type_mapper.dart';

import 'package:frontend_sgfcp/services/load_owner_service.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';
import 'package:frontend_sgfcp/services/load_type_service.dart';

class StartTripPage extends StatefulWidget {
  final TripData trip;

  const StartTripPage({super.key, required this.trip});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/start_trip';

  /// Helper to create a route to this page
  static Route route({required TripData trip}) {
    return MaterialPageRoute<void>(builder: (_) => StartTripPage(trip: trip));
  }

  @override
  State<StartTripPage> createState() => _StartTripPageState();
}

class _StartTripPageState extends State<StartTripPage> {
  DocumentType _docType = DocumentType.ctg;
  bool _isLoading = false;
  bool _showValidationErrors = false;
  bool _fuelDelivered = false; // Checkbox para vale de combustible
  bool _clientAdvancePayment = false; // Checkbox para adelanto del cliente
  LoadOwnerData? _selectedLoadOwner; // Dador de carga seleccionado
  int? _selectedLoadTypeId; // Tipo de carga seleccionado
  bool _calculatedPerKm = false; // Tipo de cálculo
  late final Future<List<LoadOwnerData>> _loadOwnersFuture;
  late final Future<List<LoadTypeData>> _loadTypesFuture;

  // Controllers para el selector de tipo de documento y datepicker
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _tariffController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _clientAdvancePaymentController =
      TextEditingController();
  final TextEditingController _fuelController = TextEditingController();

  final WidgetStatesController _docNumberStatesController =
      WidgetStatesController();
  final WidgetStatesController _weightStatesController =
      WidgetStatesController();
  final WidgetStatesController _kmStatesController = WidgetStatesController();

  @override
  void initState() {
    super.initState();
    _loadOwnersFuture = LoadOwnerService.getLoadOwners();
    _loadTypesFuture = LoadTypeService.getLoadTypes();

    _docNumberController.addListener(_updateValidationStates);
    _weightController.addListener(_updateValidationStates);
    _kmController.addListener(_updateValidationStates);
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    _startDateController.dispose();
    _weightController.dispose();
    _kmController.dispose();
    _tariffController.dispose();
    _advanceController.dispose();
    _fuelController.dispose();
    _clientAdvancePaymentController.dispose();
    _docNumberStatesController.dispose();
    _weightStatesController.dispose();
    _kmStatesController.dispose();
    super.dispose();
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;
    _docNumberStatesController.update(
      WidgetState.error,
      _docNumberController.text.trim().isEmpty,
    );
    _weightStatesController.update(
      WidgetState.error,
      _weightController.text.trim().isEmpty,
    );
    _kmStatesController.update(
      WidgetState.error,
      _kmController.text.trim().isEmpty,
    );
  }

  bool _validateRequiredFields() {
    final hasDocNumber = _docNumberController.text.trim().isNotEmpty;
    final hasWeight = _weightController.text.trim().isNotEmpty;
    final hasKm = _kmController.text.trim().isNotEmpty;
    final hasLoadOwner = _selectedLoadOwner != null;
    final hasLoadType = _selectedLoadTypeId != null;

    setState(() {
      _showValidationErrors = true;
      _docNumberStatesController.update(WidgetState.error, !hasDocNumber);
      _weightStatesController.update(WidgetState.error, !hasWeight);
      _kmStatesController.update(WidgetState.error, !hasKm);
    });

    return hasDocNumber && hasWeight && hasKm && hasLoadOwner && hasLoadType;
  }

  void _startTrip() async {
    if (!_validateRequiredFields()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'state_id': 'En curso',
        if (_docNumberController.text.isNotEmpty)
          'document_number': _docNumberController.text,
        'document_type': documentTypeToApiValue(_docType),
        if (_weightController.text.isNotEmpty)
          'load_weight_on_load': parseCurrency(_weightController.text),
        if (_kmController.text.isNotEmpty)
          'estimated_kms': parseCurrency(_kmController.text),
        if (_selectedLoadOwner != null) 'load_owner_id': _selectedLoadOwner!.id,
        if (_selectedLoadTypeId != null) 'load_type_id': _selectedLoadTypeId,
        'calculated_per_km': _calculatedPerKm,
        if (_tariffController.text.isNotEmpty)
          'rate': parseCurrency(_tariffController.text),
        // Incluir combustible solo si fue entregado
        if (_fuelDelivered && _fuelController.text.isNotEmpty)
          'fuel_liters': parseCurrency(_fuelController.text),
        'fuel_on_client': _fuelDelivered,
        if (_clientAdvancePayment &&
            _clientAdvancePaymentController.text.isNotEmpty)
          'client_advance_payment': parseCurrency(
            _clientAdvancePaymentController.text,
          ),
      };

      await TripService.updateTrip(tripId: widget.trip.id, data: data);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viaje comenzado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al comenzar viaje: $e'),
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Comenzar Viaje')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: origen → destino
              Text(widget.trip.route, style: textTheme.titleLarge),

              gap12,

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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: _docType == DocumentType.ctg ? 11 : 13,
                      decoration: InputDecoration(
                        labelText: "Nro. de documento",
                        border: OutlineInputBorder(),
                        counterText: "", // oculta contador si querés
                        errorText:
                            _showValidationErrors &&
                                _docNumberController.text.trim().isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                    ),
                  ),
                ],
              ),

              gap12,

              // Peso neto + Km a recorrer
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      enabled: !_isLoading,
                      controller: _weightController,
                      statesController: _weightStatesController,
                      decoration: InputDecoration(
                        labelText: 'Peso de Carga',
                        border: OutlineInputBorder(),
                        suffixText: ' t',
                        errorText:
                            _showValidationErrors &&
                                _weightController.text.trim().isEmpty
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
                      controller: _kmController,
                      statesController: _kmStatesController,
                      decoration: InputDecoration(
                        labelText: 'Kilómetros a Recorrer',
                        border: OutlineInputBorder(),
                        suffixText: ' km',
                        errorText:
                            _showValidationErrors &&
                                _kmController.text.trim().isEmpty
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

              // Dador de carga
              FutureBuilder<List<LoadOwnerData>>(
                future: _loadOwnersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Text('Error al cargar dadores');
                  }

                  final loadOwners = snapshot.data ?? [];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return DropdownMenu<LoadOwnerData>(
                        width: constraints.maxWidth,
                        label: const Text('Dador de Carga'),
                        errorText:
                            _showValidationErrors && _selectedLoadOwner == null
                            ? 'Campo requerido'
                            : null,
                        initialSelection: _selectedLoadOwner,
                        dropdownMenuEntries: loadOwners
                            .map(
                              (owner) => DropdownMenuEntry(
                                value: owner,
                                label: owner.name,
                              ),
                            )
                            .toList(),
                        onSelected: _isLoading
                            ? null
                            : (value) {
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

              // Tipo de Carga
              FutureBuilder<List<LoadTypeData>>(
                future: _loadTypesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Text('Error al cargar tipos');
                  }

                  final loadTypes = snapshot.data ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return DropdownMenu<LoadTypeData>(
                            width: constraints.maxWidth,
                            label: const Text('Tipo de Carga'),
                            errorText:
                                _showValidationErrors &&
                                    _selectedLoadTypeId == null
                                ? 'Campo requerido'
                                : null,
                            initialSelection: _selectedLoadTypeId == null
                                ? null
                                : loadTypes.firstWhere(
                                    (lt) => lt.id == _selectedLoadTypeId,
                                    orElse: () => loadTypes.first,
                                  ),
                            dropdownMenuEntries: loadTypes
                                .map(
                                  (loadType) => DropdownMenuEntry(
                                    value: loadType,
                                    label: loadType.name,
                                  ),
                                )
                                .toList(),
                            onSelected: _isLoading
                                ? null
                                : (value) {
                                    if (value == null) return;
                                    setState(() {
                                      _selectedLoadTypeId = value.id;
                                      _calculatedPerKm =
                                          value.defaultCalculatedPerKm;
                                      _updateValidationStates();
                                    });
                                  },
                          );
                        },
                      ),

                      gap4,

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Tipo de cálculo',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        subtitle: Text(
                          _calculatedPerKm ? 'Por kilómetro' : 'Por tonelada',
                        ),
                        value: _calculatedPerKm,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() => _calculatedPerKm = value);
                              },
                      ),
                    ],
                  );
                },
              ),

              gap4,

              // Tarifa por Tonelada
              TextField(
                enabled: !_isLoading,
                controller: _tariffController,
                decoration: InputDecoration(
                  labelText: _calculatedPerKm
                      ? 'Tarifa por Kilómetro'
                      : 'Tarifa por Tonelada',
                  border: const OutlineInputBorder(),
                  prefixText: r'$ ',
                ),
                keyboardType: TextInputType.number,
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

              // Vale de compustible
              CheckboxTextField(
                enabled: !_isLoading,
                value: _fuelDelivered,
                onChanged: !_isLoading
                    ? (value) {
                        setState(() {
                          _fuelDelivered = value ?? false;
                          if (!_fuelDelivered) {
                            _fuelController.clear();
                          }
                        });
                      }
                    : null,
                controller: _fuelController,
                checkboxLabel: 'Vale de Combustible entregado por el cliente',
                textFieldLabel: 'Litros del Vale',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              // Adelanto del cliente
              CheckboxTextField(
                enabled: !_isLoading,
                value: _clientAdvancePayment,
                onChanged: !_isLoading
                    ? (value) {
                        setState(() {
                          _clientAdvancePayment = value ?? false;
                          if (!_clientAdvancePayment) {
                            _clientAdvancePaymentController.clear();
                          }
                        });
                      }
                    : null,
                controller: _clientAdvancePaymentController,
                checkboxLabel: 'Adelanto del cliente recibido',
                textFieldLabel: 'Importe del Adelanto',
                prefixText: r'$ ',
                keyboardType: TextInputType.number,
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

              // Botón principal: Comenzar viaje
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isLoading ? null : _startTrip,
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
                label: Text(_isLoading ? 'Iniciando...' : 'Comenzar viaje'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
