import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/widgets/document_type_selector.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/models/load_owner_data.dart';
import 'package:frontend_sgfcp/models/load_type_data.dart';

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
  DateTime? _startDate;
  bool _isLoading = false;
  bool _fuelDelivered = false; // Checkbox para vale de combustible
  LoadOwnerData? _selectedLoadOwner; // Dador de carga seleccionado
  int? _selectedLoadTypeId; // Tipo de carga seleccionado
  bool _calculatedPerKm = false; // Tipo de cálculo

  // Controllers para el selector de tipo de documento y datepicker
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _transportCodeController =
      TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _tariffController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _fuelController = TextEditingController();

  @override
  void dispose() {
    _docNumberController.dispose();
    _startDateController.dispose();
    _transportCodeController.dispose();
    _weightController.dispose();
    _kmController.dispose();
    _tariffController.dispose();
    _advanceController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  // Datepicker para seleccionar fecha de inicio
  Future<void> _pickStartDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
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
      });
    }
  }

  void _startTrip() async {
    setState(() => _isLoading = true);

    try {
      final data = {
        'state_id': 'En curso',
        if (_docNumberController.text.isNotEmpty)
          'document_number': _docNumberController.text,
        if (_docType == DocumentType.ctg)
          'document_type': 'CTG'
        else
          'document_type': 'Remito',
        if (_weightController.text.isNotEmpty)
          'load_weight_on_load': double.tryParse(_weightController.text),
        if (_kmController.text.isNotEmpty)
          'estimated_kms': double.tryParse(_kmController.text),
        if (_selectedLoadOwner != null) 'load_owner_id': _selectedLoadOwner!.id,
        if (_selectedLoadTypeId != null) 'load_type_id': _selectedLoadTypeId,
        'calculated_per_km': _calculatedPerKm,
        if (_tariffController.text.isNotEmpty)
          'rate': double.tryParse(_tariffController.text),
        // Incluir combustible solo si fue entregado
        if (_fuelDelivered && _fuelController.text.isNotEmpty)
          'fuel_liters': double.tryParse(_fuelController.text),
        'fuel_on_client': _fuelDelivered,
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
                      controller: _docNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: _docType == DocumentType.ctg ? 11 : 13,
                      decoration: const InputDecoration(
                        labelText: "Nro. de documento",
                        border: OutlineInputBorder(),
                        counterText: "", // oculta contador si querés
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
                      decoration: const InputDecoration(
                        labelText: 'Peso de Carga (Tn)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  gapW12,
                  Expanded(
                    flex: 1,
                    child: TextField(
                      enabled: !_isLoading,
                      controller: _kmController,
                      decoration: const InputDecoration(
                        labelText: 'Kilómetros a Recorrer',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),

              gap12,

              // Tipo de Carga
              FutureBuilder<List<LoadTypeData>>(
                future: LoadTypeService.getLoadTypes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DropdownButtonFormField<int>(
                      value: null,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Carga',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: const [],
                      onChanged: null,
                    );
                  }

                  if (snapshot.hasError) {
                    return DropdownButtonFormField<int>(
                      value: null,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Carga',
                        border: OutlineInputBorder(),
                        errorText: 'Error al cargar tipos',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: const [],
                      onChanged: null,
                    );
                  }

                  final loadTypes = snapshot.data ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedLoadTypeId,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Carga',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: loadTypes
                            .map(
                              (loadType) => DropdownMenuItem(
                                value: loadType.id,
                                child: Text(loadType.name),
                              ),
                            )
                            .toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedLoadTypeId = value;
                                  // Establecer el calculatedPerKm por defecto según el tipo
                                  final selectedType = loadTypes.firstWhere(
                                    (lt) => lt.id == value,
                                  );
                                  _calculatedPerKm =
                                      selectedType.defaultCalculatedPerKm;
                                });
                              },
                      ),
                      gap12,
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tipo de cálculo'),
                        subtitle: Text(
                          _calculatedPerKm ? 'Por Kilómetro' : 'Por Tonelada',
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

              gap12,

              // Dador de Carga + Tarifa por Tonelada
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: FutureBuilder<List<LoadOwnerData>>(
                      future: LoadOwnerService.getLoadOwners(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return DropdownButtonFormField<LoadOwnerData>(
                            value: null,
                            decoration: const InputDecoration(
                              labelText: 'Dador de Carga',
                              border: OutlineInputBorder(),
                            ),
                            items: const [],
                            onChanged: null,
                          );
                        }

                        if (snapshot.hasError) {
                          return DropdownButtonFormField<LoadOwnerData>(
                            value: null,
                            decoration: const InputDecoration(
                              labelText: 'Dador de Carga',
                              border: OutlineInputBorder(),
                              errorText: 'Error al cargar dadores',
                            ),
                            items: const [],
                            onChanged: null,
                          );
                        }

                        final loadOwners = snapshot.data ?? [];
                        return DropdownButtonFormField<LoadOwnerData>(
                          value: _selectedLoadOwner,
                          decoration: const InputDecoration(
                            labelText: 'Dador de Carga',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: loadOwners
                              .map(
                                (owner) => DropdownMenuItem(
                                  value: owner,
                                  child: Text(owner.name),
                                ),
                              )
                              .toList(),
                          onChanged: !_isLoading
                              ? (value) {
                                  setState(() {
                                    _selectedLoadOwner = value;
                                  });
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                  gapW12,
                  Expanded(
                    flex: 1,
                    child: TextField(
                      enabled: !_isLoading,
                      controller: _tariffController,
                      decoration: InputDecoration(
                        labelText: widget.trip.calculatedPerKm
                            ? 'Tarifa por Kilómetro'
                            : 'Tarifa por Tonelada',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),

              gap12,

              // Checkbox: Vale de Combustible entregado por el cliente
              Row(
                children: [
                  Checkbox(
                    value: _fuelDelivered,
                    onChanged: !_isLoading
                        ? (value) {
                            setState(() {
                              _fuelDelivered = value ?? false;
                            });
                          }
                        : null,
                  ),
                  const Expanded(
                    child: Text('Vale de Combustible entregado por el cliente'),
                  ),
                ],
              ),

              // Litros del Vale (solo se muestra si _fuelDelivered es true)
              if (_fuelDelivered) ...[
                gap8,
                TextField(
                  enabled: !_isLoading,
                  controller: _fuelController,
                  decoration: const InputDecoration(
                    labelText: 'Litros del Vale',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],

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
