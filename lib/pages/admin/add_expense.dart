import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/expense_type.dart';
import 'package:frontend_sgfcp/widgets/expense_subtype_dropdown.dart';
import 'package:frontend_sgfcp/widgets/labeled_switch.dart';

class AddExpensePageAdmin extends StatefulWidget {
  const AddExpensePageAdmin({super.key});

  static const String routeName = '/admin/add-expense';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const AddExpensePageAdmin());
  }

  @override
  State<AddExpensePageAdmin> createState() => _AddExpensePageAdminState();
}

class _AddExpensePageAdminState extends State<AddExpensePageAdmin> {
  DateTime? _date;
  bool _accountingPaid = false;
  ExpenseType _expenseType = ExpenseType.peaje;
  String? _subtype;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _litersController.dispose();
    _municipalityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _date = picked;
        final locale = Localizations.localeOf(context).toString();
        _dateController.text = DateFormat('dd/MM/yyyy', locale).format(picked);
      });
    }
  }

  void _saveExpense() {
    // TODO: Validar y guardar en el backend
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gasto cargado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final peajeOptions = [
      'Peaje de ruta',
      'Derecho de Ingreso a establecimiento',
    ];
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
      appBar: AppBar(title: const Text('Cargar Gasto')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón tomar foto
              FilledButton.tonalIcon(
                onPressed: () {
                  // TODO: Tomar foto del comprobante
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidad de foto en desarrollo'),
                    ),
                  );
                },
                icon: const Icon(Symbols.add_a_photo),
                label: const Text('Tomar foto del comprobante'),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.secondaryContainer,
                  foregroundColor: colors.onSecondaryContainer,
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
                    width: constraints.maxWidth,
                    label: const Text('Tipo de gasto'),
                    initialSelection: _expenseType,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: ExpenseType.peaje,
                        label: 'Peaje',
                      ),
                      DropdownMenuEntry(
                        value: ExpenseType.viaticos,
                        label: 'Viáticos',
                      ),
                      DropdownMenuEntry(
                        value: ExpenseType.reparaciones,
                        label: 'Reparaciones',
                      ),
                      DropdownMenuEntry(
                        value: ExpenseType.combustible,
                        label: 'Combustible',
                      ),
                      DropdownMenuEntry(
                        value: ExpenseType.multa,
                        label: 'Multa',
                      ),
                    ],
                    onSelected: (value) {
                      if (value == null) return;
                      setState(() {
                        _expenseType = value;
                        _subtype = null;
                      });
                    },
                  );
                },
              ),

              gap12,

              // Fecha + Importe
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      onTap: _pickDate,
                    ),
                  ),
                  gapW12,
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Importe',
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

              // Subtipo (si aplica)
              if (_expenseType == ExpenseType.peaje ||
                  _expenseType == ExpenseType.reparaciones) ...[
                LayoutBuilder(
                  builder: (context, constraints) => ExpenseSubtypeDropdown(
                    label: label,
                    options: subtypeOptions,
                    value: _subtype,
                    onChanged: (v) => setState(() => _subtype = v),
                  ),
                ),
                gap12,
              ],

              // Switch: ¿Pagó contaduría?
              LabeledSwitch(
                label: '¿Pagó contaduría?',
                value: _accountingPaid,
                onChanged: (v) => setState(() => _accountingPaid = v),
              ),

              gap24,

              // Botón Cargar gasto
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _saveExpense,
                icon: const Icon(Symbols.garage_money),
                label: const Text('Cargar gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
