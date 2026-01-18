import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/widgets/document_type_selector.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';


class EditTripPage extends StatefulWidget {
  final TripData trip;

  const EditTripPage({super.key, required this.trip});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/edit_trip';

  /// Helper to create a route to this page
  static Route route({required TripData trip}) {
    return MaterialPageRoute<void>(
      builder: (_) => EditTripPage(trip: trip),
    );
  }
  @override
  State<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {

  late Future<List<DriverData>> _driversFuture;

  DocumentType _docType = DocumentType.ctg;
  String? _cargoType;
  DateTime? _startDate;
  DriverData? _selectedDriver;
  
  // Controllers
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _transportCodeController = TextEditingController();
  final TextEditingController _loadOwnerController = TextEditingController();
  final TextEditingController _netWeightController = TextEditingController();
  final TextEditingController _kmsController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _fuelLitersController = TextEditingController();

  final bool isAdmin =
    (TokenStorage.user != null && TokenStorage.user!['is_admin'] == true);
  
  @override
  void initState() {
    super.initState();
    _driversFuture = DriverService.getDrivers();

    // Populate data
    _docType = _mapStringToDocumentType(widget.trip.documentType);
    _docNumberController.text = widget.trip.documentNumber;
    _startDate = widget.trip.startDate;
    _selectedDriver = widget.trip.driver;
    _cargoType = 'Maíz'; // assuming, or add to model
    _netWeightController.text = widget.trip.loadWeightOnLoad.toString();
    _kmsController.text = widget.trip.estimatedKms.toString();
    _rateController.text = widget.trip.ratePerTon.toString();
    _fuelLitersController.text = widget.trip.fuelLiters.toString();

    final locale = Localizations.localeOf(context).toString();
    _startDateController.text = DateFormat('dd/MM/yyyy', locale).format(_startDate!);
  }

  DocumentType _mapStringToDocumentType(String type) {
    switch (type) {
      case 'CTG':
        return DocumentType.ctg;
      case 'remito':
        return DocumentType.remito;
      default:
        return DocumentType.ctg;
    }
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
        _startDateController.text =
            DateFormat('dd/MM/yyyy', locale).format(picked);
      });
    }
  }


  @override
  void dispose() {
    _docNumberController.dispose();
    _startDateController.dispose();
    _transportCodeController.dispose();
    _loadOwnerController.dispose();
    _netWeightController.dispose();
    _kmsController.dispose();
    _rateController.dispose();
    _advanceController.dispose();
    _fuelLitersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Viaje'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: origen → destino
              Text(
                widget.trip.route,
                style: textTheme.titleLarge,
              ),

              gap12,

              // ----- Documento + Número de documento -----
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Documento', style: textTheme.bodySmall,),
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

              // Chofer asignado
              if (isAdmin) ...[
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
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return DropdownMenu<DriverData>(
                          width: constraints.maxWidth,
                          label: const Text('Chofer asignado'),
                          initialSelection: _selectedDriver,
                          dropdownMenuEntries: drivers.map((driver) =>
                            DropdownMenuEntry(value: driver, label: driver.fullName),
                          ).toList(),
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

              // Código del transporte
              TextField(
                controller: _transportCodeController,
                decoration: const InputDecoration(
                  labelText: 'Código del transporte',
                  border: OutlineInputBorder(),
                ),
              ),

              gap12,

              // Dador de carga
              TextField(
                controller: _loadOwnerController,
                decoration: const InputDecoration(
                  labelText: 'Dador de carga',
                  border: OutlineInputBorder(),
                ),
              ),

              gap12,

              // Tipo de carga + Peso neto
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return DropdownMenu<String>(
                          width: constraints.maxWidth, // mismo ancho que tendría un TextField
                          label: const Text('Tipo de carga'),
                          initialSelection: _cargoType,
                          // TODO: obtener tipos de carga desde backend
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 'Maíz', label: 'Maíz'),
                            DropdownMenuEntry(value: 'Soja', label: 'Soja'),
                            DropdownMenuEntry(value: 'Trigo', label: 'Trigo'),
                          ],
                          onSelected: (value) {
                            setState(() {
                              _cargoType = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  gapW12,
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _netWeightController,
                      decoration: const InputDecoration(
                        labelText: 'Peso neto (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),

              gap12,

              // Fecha de inicio + Km a recorrer
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de inicio',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      onTap: _pickStartDate,
                    ),
                  ),
                  gapW12,
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _kmsController,
                      decoration: const InputDecoration(
                        labelText: 'Km a recorrer',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),

              gap12,

              // Tarifa
              TextField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Tarifa',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),

              gap12,

              // Adelanto del cliente
              Text(
                'Si el cliente realizó un adelanto, ingrese el importe.',
                style: textTheme.bodyMedium,
              ),
              gap8,
              TextField(
                controller: _advanceController,
                decoration: const InputDecoration(
                  labelText: 'Importe del adelanto',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),

              gap12,

              // Vale de combustible
              Text(
                'Si el cliente entregó un vale de combustible, ingrese los litros de carga.',
                style: textTheme.bodyMedium,
              ),
              gap8,
              TextField(
                controller: _fuelLitersController,
                decoration: const InputDecoration(
                  labelText: 'Litros del vale',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),

              gap16,

              // Botón principal: Comenzar viaje
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () async {
                  final data = <String, dynamic>{
                    'document_type': _docType.name.toUpperCase(),
                    'document_number': _docNumberController.text,
                    'driver_id': _selectedDriver?.id ?? widget.trip.driver.id,
                    'origin': widget.trip.origin, // assuming not changing
                    'destination': widget.trip.destination,
                    'start_date': _startDate!.toIso8601String().split('T')[0],
                    'estimated_kms': double.tryParse(_kmsController.text) ?? 0.0,
                    'load_weight_on_load': double.tryParse(_netWeightController.text) ?? 0.0,
                    'rate_per_ton': double.tryParse(_rateController.text) ?? 0.0,
                    'fuel_liters': double.tryParse(_fuelLitersController.text) ?? 0.0,
                    // add other fields if needed
                  };

                  final currentContext = context;
                  try {
                    await TripService.updateTrip(tripId: widget.trip.id, data: data);
                  } catch (e) {
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        SnackBar(content: Text('Error al guardar cambios: $e')),
                      );
                    }
                    return;
                  }
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(currentContext).pop();
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}