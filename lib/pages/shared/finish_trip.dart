import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';

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

  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final FocusNode _dateFocusNode = FocusNode();

  @override
  void dispose() {
    _endDateController.dispose();
    _weightController.dispose();
    _dateFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();

    // Si la fecha de inicio del viaje es posterior a hoy, usar esa como inicial
    // De lo contrario, usar hoy o la fecha ya seleccionada
    DateTime initialDate;
    if (_endDate != null) {
      initialDate = _endDate!;
    } else if (widget.trip.startDate.isAfter(now)) {
      initialDate = widget.trip.startDate;
    } else {
      initialDate = now;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
      });
    }
  }

  void _finishTrip() async {
    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona la fecha de fin')),
      );
      return;
    }

    if (_weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el peso neto de descarga'),
        ),
      );
      return;
    }

    // Validar que el peso de descarga no sea mayor al peso de carga
    final weightInTons = double.tryParse(_weightController.text) ?? 0;
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
      final weightInTons = double.tryParse(_weightController.text) ?? 0;

      await TripService.updateTrip(
        tripId: widget.trip.id,
        data: {
          'state_id': 'Finalizado',
          'end_date': _endDate!.toIso8601String().split('T')[0],
          'load_weight_on_unload': weightInTons,
        },
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
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
                    child: InkWell(
                      onTap: _isLoading ? null : _pickEndDate,
                      borderRadius: BorderRadius.circular(4),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de fin',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          _endDateController.text.isEmpty
                              ? ''
                              : _endDateController.text,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  gapW12,
                  Expanded(
                    flex: 1,
                    child: TextField(
                      enabled: !_isLoading,
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Peso neto descarga (Tn)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
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
