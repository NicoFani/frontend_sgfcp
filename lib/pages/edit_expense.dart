import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/widgets/expense_subtype_dropdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/expense_type.dart';

import 'package:frontend_sgfcp/pages/trip.dart';
import 'package:frontend_sgfcp/widgets/labeled_switch.dart';

class EditExpensePage extends StatefulWidget {
  const EditExpensePage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/edit_expense';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const EditExpensePage());
  }
  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {

  DateTime? _startDate;
  bool _accountingPaid = false;

  ExpenseType _expenseType = ExpenseType.reparaciones;
  String? _subtype; // será el tipo de peaje o tipo de reparación según el caso

  
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
    final textTheme = Theme.of(context).textTheme;

    final peajeOptions = ['Tasa portuaria', 'Ruta'];
    final reparacionOptions = ['Neumáticos', 'Motor', 'Chapa y pintura'];

    List<String> subtypeOptions;
    String label;

    switch (_expenseType) {
      case ExpenseType.peaje:
        label = 'Tipo de peaje';
        subtypeOptions = peajeOptions;
        break;
      case ExpenseType.reparaciones:
        label = 'Tipo de reparación';
        subtypeOptions = reparacionOptions;
        break;
      default:
        label = 'Tipo';
        subtypeOptions = const [];
    }

    return Scaffold(
      appBar: AppBar(
      title: const Text('Editar gasto'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('¿Eliminar gasto?'),
                  content: const Text(
                    '¿Estás seguro de que querés eliminar este gasto? '
                    'Esta acción no se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                );
              },
            );

            if (confirmed == true) {
              // TODO: lógica real de eliminación
              // Por ejemplo: llamar a la API y luego:
              Navigator.of(context).pop(); // volver a la pantalla anterior
            }
          },
        ),
      ],
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

              gap20,

              FilledButton.tonalIcon(
                onPressed: () {
                  // TODO: AI tool to take photo of receipt
                },
                icon: const Icon(Symbols.add_a_photo),
                label: const Text('Tomar nueva foto del comprobante'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              gap20,

              // Tipo de gasto
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<ExpenseType>(
                    enabled: false,
                    width: constraints.maxWidth,
                    label: const Text('Tipo de gasto'),
                    initialSelection: _expenseType,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: ExpenseType.peaje, label: 'Peaje',),
                      DropdownMenuEntry(value: ExpenseType.viaticos, label: 'Viáticos',),
                      DropdownMenuEntry(value: ExpenseType.reparaciones, label: 'Reparaciones',),
                      DropdownMenuEntry(value: ExpenseType.combustible, label: 'Combustible',),
                      DropdownMenuEntry(value: ExpenseType.multa, label: 'Multa',),
                    ],
                    onSelected: (value) {
                      if (value == null) return;
                      setState(() {
                        _expenseType = value;
                        _subtype = null; // resetear subtipo al cambiar tipo
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
                    flex: 3,
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
                    flex: 2,
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

              // Combustible → input de litros cargados
              if (_expenseType == ExpenseType.combustible) ...[
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Litros cargados',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                gap12,
              ],

              // Multa → input de municipio
              if (_expenseType == ExpenseType.multa) ...[
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Municipio',
                    border: OutlineInputBorder(),
                  ),
                ),
                gap12,
              ],

             // Subtipo (si aplica)
              if (_expenseType == ExpenseType.peaje || _expenseType == ExpenseType.reparaciones) ...[
                LayoutBuilder(builder: (context, constraints) => ExpenseSubtypeDropdown(
                  label: label,
                  options: subtypeOptions,
                  value: _subtype,
                  onChanged: (v) => setState(() => _subtype = v),
                ),),
                gap12,
              ],


              // Switch: ¿Pagó contaduría?
              LabeledSwitch(
                label: '¿Pagó contaduría?',
                value: _accountingPaid,
                onChanged: (v) => setState(() => _accountingPaid = v),
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
