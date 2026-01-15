import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class FinishTripPageAdmin extends StatefulWidget {
  const FinishTripPageAdmin({super.key});

  static const String routeName = '/admin/finish-trip';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const FinishTripPageAdmin());
  }

  @override
  State<FinishTripPageAdmin> createState() => _FinishTripPageAdminState();
}

class _FinishTripPageAdminState extends State<FinishTripPageAdmin> {
  DateTime? _endDate;

  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _netWeightController = TextEditingController();

  @override
  void dispose() {
    _endDateController.dispose();
    _netWeightController.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;

        final locale = Localizations.localeOf(context).toString();
        _endDateController.text = DateFormat('dd/MM/yyyy', locale).format(picked);
      });
    }
  }

  void _finishTrip() {
    // TODO: Validar y guardar en el backend
    // Por ahora solo navegamos de vuelta mostrando la versión finalizada
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viaje finalizado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Viaje'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: origen → destino
              Text(
                'Mattaldi → San Lorenzo',
                style: textTheme.titleLarge,
              ),

              gap16,

              // Fecha de fin + Peso neto de descarga
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _endDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de fin',
                        labelStyle: TextStyle(fontSize: 12),
                        floatingLabelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      onTap: _pickEndDate,
                    ),
                  ),
                  gapW12,
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _netWeightController,
                      decoration: const InputDecoration(
                        labelText: 'Peso neto de descarga (kg)',
                        labelStyle: TextStyle(fontSize: 12),
                        floatingLabelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                onPressed: _finishTrip,
                icon: const Icon(Symbols.where_to_vote),
                label: const Text('Finalizar viaje'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
