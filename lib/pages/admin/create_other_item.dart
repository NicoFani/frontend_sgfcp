import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:frontend_sgfcp/models/other_items_type.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/payroll_period_data.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/payroll_period_service.dart';
import 'package:frontend_sgfcp/services/payroll_other_item_service.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';
import 'package:frontend_sgfcp/widgets/month_picker.dart';
import 'package:intl/intl.dart';

class CreateOtherItemPage extends StatefulWidget {
  const CreateOtherItemPage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = 'admin/create-other-item';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<bool>(builder: (_) => const CreateOtherItemPage());
  }

  @override
  State<CreateOtherItemPage> createState() => _CreateOtherItemPageState();
}

class _CreateOtherItemPageState extends State<CreateOtherItemPage> {
  OtherItemsType _otherItemsType = OtherItemsType.ajuste;
  DriverData? _selectedDriver;
  PayrollPeriodData? _selectedPeriod;
  bool _isAdjustmentPositive = true;

  // Controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();

  // Datos cargados
  List<DriverData> _drivers = [];
  List<PayrollPeriodData> _periods = [];
  bool _isLoading = true;

  // Validation controllers
  final WidgetStatesController _driverStatesController = WidgetStatesController();
  final WidgetStatesController _periodStatesController = WidgetStatesController();
  final WidgetStatesController _otherItemStatesController = WidgetStatesController();
  final WidgetStatesController _amountStatesController = WidgetStatesController();
  final WidgetStatesController _descriptionStatesController = WidgetStatesController();
  final WidgetStatesController _referenceStatesController = WidgetStatesController();
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Add validation listeners
    _amountController.addListener(_updateValidationStates);
    _descriptionController.addListener(_updateValidationStates);
    _referenceController.addListener(_updateValidationStates);
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
    _periodController.dispose();
    _driverStatesController.dispose();
    _periodStatesController.dispose();
    _otherItemStatesController.dispose();
    _amountStatesController.dispose();
    _descriptionStatesController.dispose();
    _referenceStatesController.dispose();
    super.dispose();
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;

    setState(() {
      _driverStatesController.update(
        WidgetState.error,
        _selectedDriver == null,
      );
      _periodStatesController.update(
        WidgetState.error,
        _selectedPeriod == null,
      );
      _otherItemStatesController.update(
        WidgetState.error,
        false, // Always valid since we have a default
      );
      _amountStatesController.update(
        WidgetState.error,
        _amountController.text.trim().isEmpty,
      );
      _descriptionStatesController.update(
        WidgetState.error,
        _descriptionController.text.trim().isEmpty,
      );

      // Reference required only for multa
      if (_otherItemsType == OtherItemsType.multa) {
        _referenceStatesController.update(
          WidgetState.error,
          _referenceController.text.trim().isEmpty,
        );
      } else {
        _referenceStatesController.update(WidgetState.error, false);
      }
    });
  }

  bool _validateRequiredFields() {
    final hasDriver = _selectedDriver != null;
    final hasPeriod = _selectedPeriod != null;
    final hasAmount = _amountController.text.trim().isNotEmpty;
    final hasDescription = _descriptionController.text.trim().isNotEmpty;
    final hasReference = _otherItemsType == OtherItemsType.multa
        ? _referenceController.text.trim().isNotEmpty
        : true;

    setState(() {
      _showValidationErrors = true;
      _driverStatesController.update(WidgetState.error, !hasDriver);
      _periodStatesController.update(WidgetState.error, !hasPeriod);
      _amountStatesController.update(WidgetState.error, !hasAmount);
      _descriptionStatesController.update(WidgetState.error, !hasDescription);
      if (_otherItemsType == OtherItemsType.multa) {
        _referenceStatesController.update(WidgetState.error, !hasReference);
      }
    });

    return hasDriver && hasPeriod && hasAmount && hasDescription && hasReference;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cargar otros conceptos')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de Chofer
              DropdownMenu<DriverData>(
                expandedInsets: EdgeInsets.zero,
                label: const Text('Chofer'),
                initialSelection: _selectedDriver,
                errorText: _showValidationErrors && _selectedDriver == null
                    ? 'Selecciona un chofer'
                    : null,
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
                    _updateValidationStates();
                  });
                },
              ),

              gap12,

              // Selector de Período
              TextField(
                controller: _periodController,
                readOnly: true,
                statesController: _periodStatesController,
                decoration: InputDecoration(
                  labelText: 'Período',
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                  errorText: _showValidationErrors && _selectedPeriod == null
                      ? 'Selecciona un período'
                      : null,
                ),
                onTap: () => _pickPeriodMonth(),
              ),

              gap12,

              // Concepto
              DropdownMenu<OtherItemsType>(
                expandedInsets: EdgeInsets.zero,
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
                    _isAdjustmentPositive = true;
                    _updateValidationStates();
                  });
                },
              ),

              gap12,

              if (_otherItemsType == OtherItemsType.ajuste) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text('Tipo de ajuste', style: Theme.of(context).textTheme.bodyLarge,),
                    gap8,
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Suma')),
                        ButtonSegment(value: false, label: Text('Resta')),
                      ],
                      selected: {_isAdjustmentPositive},
                      onSelectionChanged: (value) {
                        setState(() {
                          _isAdjustmentPositive = value.first;
                        });
                      },
                    ),
                  ],
                ),
                gap12,
              ],

              // Importe
              TextField(
                controller: _amountController,
                statesController: _amountStatesController,
                decoration: InputDecoration(
                  labelText: 'Importe',
                  prefixText: r'$ ',
                  border: const OutlineInputBorder(),
                  errorText: _showValidationErrors &&
                          _amountController.text.trim().isEmpty
                      ? 'Ingresa un importe'
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
                  ),
                ],
              ),

              gap12,

              // Descripción
              TextField(
                controller: _descriptionController,
                statesController: _descriptionStatesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  errorText: _showValidationErrors &&
                          _descriptionController.text.trim().isEmpty
                      ? 'Ingresa una descripción'
                      : null,
                ),
              ),

              // Multa → input de referencia (municipio, infracción, etc)
              if (_otherItemsType == OtherItemsType.multa) ...[
                gap12,
                TextField(
                  controller: _referenceController,
                  statesController: _referenceStatesController,
                  decoration: InputDecoration(
                    labelText: 'Referencia (Municipio, infracción, etc)',
                    border: const OutlineInputBorder(),
                    errorText: _showValidationErrors &&
                            _referenceController.text.trim().isEmpty
                        ? 'Ingresa una referencia'
                        : null,
                  ),
                ),
              ],

              gap16,

              // Botón para guardar
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _submitForm,
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
    if (!_validateRequiredFields()) {
      return;
    }

    try {
      final itemType = _otherItemsType.toBackendString();
      final rawAmount = parseCurrency(_amountController.text);
      double amount;

      if (_otherItemsType == OtherItemsType.ajuste) {
        amount = _isAdjustmentPositive ? rawAmount.abs() : -rawAmount.abs();
      } else if (_otherItemsType == OtherItemsType.bonificacionExtra) {
        amount = rawAmount.abs();
      } else {
        // Multa y cargo extra siempre restan
        amount = -rawAmount.abs();
      }

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

        // Navigate back with success
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _pickPeriodMonth() async {
    if (_periods.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay períodos disponibles')),
        );
      }
      return;
    }

    final sortedPeriods = [..._periods]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final firstDate = DateTime(
      sortedPeriods.first.startDate.year,
      sortedPeriods.first.startDate.month,
    );
    final lastDate = DateTime(
      sortedPeriods.last.startDate.year,
      sortedPeriods.last.startDate.month,
    );

    final now = DateTime.now();
    var initial = _selectedPeriod == null
        ? DateTime(now.year, now.month)
        : DateTime(
            _selectedPeriod!.startDate.year,
            _selectedPeriod!.startDate.month,
          );

    if (initial.isBefore(firstDate)) {
      initial = firstDate;
    } else if (initial.isAfter(lastDate)) {
      initial = lastDate;
    }

    final picked = await showMonthPicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) return;

    PayrollPeriodData? match;
    for (final p in sortedPeriods) {
      if (p.startDate.year == picked.year &&
          p.startDate.month == picked.month) {
        match = p;
        break;
      }
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = DateFormat.yMMMM(locale).format(picked);

    if (match == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay un período para ese mes'),
          ),
        );
      }
      setState(() {
        _selectedPeriod = null;
        _periodController.clear();
        _updateValidationStates();
      });
      return;
    }

    setState(() {
      _selectedPeriod = match;
      _periodController.text = label[0].toUpperCase() + label.substring(1);
      _updateValidationStates();
    });
  }
}
