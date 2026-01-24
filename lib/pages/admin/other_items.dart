import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/other_items_type.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/payroll_period_data.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/payroll_period_service.dart';
import 'package:frontend_sgfcp/services/payroll_other_item_service.dart';
import 'package:frontend_sgfcp/pages/shared/trip.dart';

class OtherItemsPage extends StatefulWidget {
  const OtherItemsPage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = 'admin/other-items';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const OtherItemsPage());
  }

  @override
  State<OtherItemsPage> createState() => _OtherItemsPageState();
}

class _OtherItemsPageState extends State<OtherItemsPage> {
  OtherItemsType _otherItemsType = OtherItemsType.ajuste;
  DriverData? _selectedDriver;
  PayrollPeriodData? _selectedPeriod;

  // Controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  // Datos cargados
  List<DriverData> _drivers = [];
  List<PayrollPeriodData> _periods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final drivers = await DriverService.getDrivers();
      final periods = await PayrollPeriodService.getAllPeriods();

      setState(() {
        _drivers = drivers;
        _periods = periods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando datos: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Otros conceptos')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de Chofer
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<DriverData>(
                    width: constraints.maxWidth,
                    label: const Text('Chofer'),
                    initialSelection: _selectedDriver,
                    dropdownMenuEntries: _drivers
                        .map(
                          (driver) => DropdownMenuEntry(
                            value: driver,
                            label: driver.fullName,
                          ),
                        )
                        .toList(),
                    onSelected: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedDriver = value;
                      });
                    },
                  );
                },
              ),

              gap12,

              // Selector de Período
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<PayrollPeriodData>(
                    width: constraints.maxWidth,
                    label: const Text('Período'),
                    initialSelection: _selectedPeriod,
                    dropdownMenuEntries: _periods
                        .map(
                          (period) => DropdownMenuEntry(
                            value: period,
                            label: period.periodLabel,
                          ),
                        )
                        .toList(),
                    onSelected: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedPeriod = value;
                      });
                    },
                  );
                },
              ),

              gap12,

              // Concepto
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<OtherItemsType>(
                    width: constraints.maxWidth,
                    label: const Text('Concepto'),
                    initialSelection: _otherItemsType,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: OtherItemsType.ajuste,
                        label: 'Ajuste',
                      ),
                      DropdownMenuEntry(
                        value: OtherItemsType.multa,
                        label: 'Multa',
                      ),
                      DropdownMenuEntry(
                        value: OtherItemsType.bonificacionExtra,
                        label: 'Bonificación Extra',
                      ),
                      DropdownMenuEntry(
                        value: OtherItemsType.cargoExtra,
                        label: 'Cargo Extra',
                      ),
                    ],
                    onSelected: (value) {
                      if (value == null) return;
                      setState(() {
                        _otherItemsType = value;
                      });
                    },
                  );
                },
              ),

              gap12,

              // Importe
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Importe',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              gap12,

              // Descripción
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              // Multa → input de referencia (municipio, infracción, etc)
              if (_otherItemsType == OtherItemsType.multa) ...[
                gap12,
                TextField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Referencia (Municipio, infracción, etc)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              gap16,

              // Botón para guardar
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _selectedDriver == null || _selectedPeriod == null
                    ? null
                    : _submitForm,
                icon: const Icon(Symbols.request_quote),
                label: const Text('Cargar concepto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_selectedDriver == null || _selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar chofer y período')),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Debe ingresar un importe')));
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe ingresar una descripción')),
      );
      return;
    }

    try {
      final itemType = _otherItemsType.toBackendString();
      final amount = double.parse(_amountController.text);

      await PayrollOtherItemService.createOtherItem(
        driverId: _selectedDriver!.id,
        periodId: _selectedPeriod!.id,
        itemType: itemType,
        description: _descriptionController.text,
        amount: amount,
        reference: _otherItemsType == OtherItemsType.multa
            ? _referenceController.text
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Concepto cargado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar formulario
        _descriptionController.clear();
        _amountController.clear();
        _referenceController.clear();

        setState(() {
          _selectedDriver = null;
          _selectedPeriod = null;
          _otherItemsType = OtherItemsType.ajuste;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
