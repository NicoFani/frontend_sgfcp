import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/other_items_type.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
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
  DateTime? _startDate;
  OtherItemsType _otherItemsType = OtherItemsType.ajuste;

  
  // Controllers para el selector de tipo de documento y datepicker
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  
  @override
  void dispose() {
    _docNumberController.dispose();
    _startDateController.dispose();
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
        _startDateController.text =
            DateFormat('dd/MM/yyyy', locale).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otros conceptos'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Concepto
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<OtherItemsType>(
                    width: constraints.maxWidth,
                    label: const Text('Concepto'),
                    initialSelection: _otherItemsType,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: OtherItemsType.ajuste, label: 'Ajuste',),
                      DropdownMenuEntry(value: OtherItemsType.multa, label: 'Multa',),
                      DropdownMenuEntry(value: OtherItemsType.bonificacionExtra, label: 'Bonificación Extra',),
                      DropdownMenuEntry(value: OtherItemsType.cargoExtra, label: 'Cargo Extra',),
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

              // Fecha de inicio + Importe
              Row(
                children: [
                  Expanded(
                    // flex: 3,
                    child: TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      onTap: _pickStartDate,
                    ),
                  ),
                  gapW12,
                  Expanded(
                    // flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Importe',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),

              gap12,

              // Descripción 
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),

              // Multa → input de municipio
              if (_otherItemsType == OtherItemsType.multa) ...[
                gap12,
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Municipio',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              gap16,

              // Botón principal: Comenzar viaje
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  Navigator.of(context).push(TripPage.route());
                },
                icon: const Icon(Symbols.request_quote),
                label: const Text('Cargar concepto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
