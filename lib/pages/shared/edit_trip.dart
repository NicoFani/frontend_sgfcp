import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/widgets/document_type_selector.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/shared/trip.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';


class EditTripPage extends StatefulWidget {
  const EditTripPage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/edit_trip';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const EditTripPage());
  }
  @override
  State<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {

  DocumentType _docType = DocumentType.ctg;
  String? _cargoType;
  DateTime? _startDate;
  
  // Controllers para el selector de tipo de documento y datepicker
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final bool isAdmin =
    (TokenStorage.user != null && TokenStorage.user!['is_admin'] == true);
  
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
                'Mattaldi → San Lorenzo',
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<DriverData>(
                      width: constraints.maxWidth,
                      label: const Text('Chofer asignado'),
                      // initialSelection: _expenseType,
                      dropdownMenuEntries: const [
                        // DropdownMenuEntry(value: , label: ,),
                        // DropdownMenuEntry(value: ExpenseType.viaticos, label: 'Viáticos',),
                        // DropdownMenuEntry(value: ExpenseType.reparaciones, label: 'Reparaciones',),
                        // DropdownMenuEntry(value: ExpenseType.combustible, label: 'Combustible',),
                        // DropdownMenuEntry(value: ExpenseType.multa, label: 'Multa',),
                      ],
                      onSelected: (value) {
                        if (value == null) return;
                        setState(() {
                          // _expenseType = value;
                          // _subtype = null; // resetear subtipo al cambiar tipo
                        });
                      },
                    );
                  },
                ),

                gap12,
              ],

              // Código del transporte
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Código del transporte',
                  border: OutlineInputBorder(),
                ),
              ),

              gap12,

              // Dador de carga
              TextField(
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
                onPressed: () {
                  Navigator.of(context).push(TripPage.route());
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