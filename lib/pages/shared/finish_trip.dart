import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

import 'package:frontend_sgfcp/services/trip_service.dart';

class FinishTripPage extends StatefulWidget {
  final TripData trip;

  const FinishTripPage({super.key, required this.trip});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/finish_trip';

  /// Helper to create a route to this page
  static Route route({required TripData trip}) {
    return MaterialPageRoute<void>(builder: (_) => FinishTripPage(trip: trip));
  }

  @override
  State<FinishTripPage> createState() => _FinishTripPageState();
}

class _FinishTripPageState extends State<FinishTripPage> {
  DateTime? _endDate;
  bool _isLoading = false;
  bool _showValidationErrors = false;
  bool _didInitDateText = false;

  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final WidgetStatesController _dateStatesController =
      WidgetStatesController();
  final WidgetStatesController _weightStatesController =
      WidgetStatesController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endDate = widget.trip.startDate.isAfter(now)
        ? widget.trip.startDate
        : now;
    _weightController.addListener(_updateValidationStates);
  }

  @override
  void dispose() {
    _endDateController.dispose();
    _weightController.dispose();
    _dateStatesController.dispose();
    _weightStatesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitDateText || _endDate == null) return;
    final locale = Localizations.localeOf(context).toString();
    _endDateController.text = DateFormat(
      'dd/MM/yyyy',
      locale,
    ).format(_endDate!);
    _didInitDateText = true;
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: widget.trip.startDate,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        final locale = Localizations.localeOf(context).toString();
        _endDateController.text = DateFormat(
          'dd/MM/yyyy',
          locale,
        ).format(picked);
        _updateValidationStates();
      });
    }
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;
    _dateStatesController.update(WidgetState.error, _endDate == null);
    _weightStatesController.update(
      WidgetState.error,
      _weightController.text.trim().isEmpty,
    );
  }

  bool _validateRequiredFields() {
    final hasDate = _endDate != null;
    final hasWeight = _weightController.text.trim().isNotEmpty;

    setState(() {
      _showValidationErrors = true;
      _dateStatesController.update(WidgetState.error, !hasDate);
      _weightStatesController.update(WidgetState.error, !hasWeight);
    });

    return hasDate && hasWeight;
  }

  void _finishTrip() async {
    if (!_validateRequiredFields()) {
      return;
    }

    // Validar que el peso de descarga no sea mayor al peso de carga
    final weightInTons = parseCurrency(_weightController.text);
    final loadWeightInTons = widget.trip.loadWeightOnLoad;

    if (weightInTons > loadWeightInTons) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El peso de descarga (${weightInTons.toStringAsFixed(2)} Tn) no puede ser mayor '
            'al peso de carga (${loadWeightInTons.toStringAsFixed(2)} Tn)',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final weightInTons = parseCurrency(_weightController.text);

      await TripService.updateTrip(
        tripId: widget.trip.id,
        data: {
          'state_id': 'Finalizado',
          'end_date': _endDate!.toIso8601String().split('T')[0],
          'load_weight_on_unload': weightInTons,
        },
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viaje finalizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al finalizar viaje: $e'),
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
      appBar: AppBar(title: const Text('Finalizar Viaje')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: origen → destino
              Text(widget.trip.route, style: textTheme.titleLarge),

              gap12,

              // Fecha de fin + Peso neto de descarga
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      enabled: !_isLoading,
                      controller: _endDateController,
                      statesController: _dateStatesController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha de fin',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                        ),
                        errorText: _showValidationErrors && _endDate == null
                            ? 'Campo requerido'
                            : null,
                      ),
                      onTap: _isLoading ? null : _pickEndDate,
                    ),
                  ),
                  gapW12,
                  Expanded(
                    flex: 1,
                    child: TextField(
                      enabled: !_isLoading,
                      controller: _weightController,
                      statesController: _weightStatesController,
                      decoration: InputDecoration(
                        labelText: 'Peso neto descarga',
                        suffixText: ' t',
                        border: OutlineInputBorder(),
                        errorText: _showValidationErrors &&
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
                ],
              ),

              gap16,

              // Botón principal: Finalizar viaje
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isLoading ? null : _finishTrip,
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
                    : const Icon(Symbols.where_to_vote),
                label: Text(_isLoading ? 'Finalizando...' : 'Finalizar viaje'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
