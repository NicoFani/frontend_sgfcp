import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/widgets/expense_subtype_dropdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/expense_type.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/services/expense_service.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';

import 'package:frontend_sgfcp/widgets/labeled_switch.dart';

class ExpensePage extends StatefulWidget {
  final TripData trip;

  const ExpensePage({super.key, required this.trip});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/expense';

  /// Helper to create a route to this page
  static Route route({required TripData trip}) {
    return MaterialPageRoute<void>(builder: (_) => ExpensePage(trip: trip));
  }

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  DateTime? _startDate;
  bool _accountingPaid = false;
  bool _isLoading = false;

  ExpenseType _expenseType = ExpenseType.reparaciones;
  String? _subtype;

  // Controllers
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();

  @override
  void dispose() {
    _startDateController.dispose();
    _amountController.dispose();
    _litersController.dispose();
    _municipalityController.dispose();
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
        _startDateController.text = DateFormat(
          'dd/MM/yyyy',
          locale,
        ).format(picked);
      });
    }
  }

  Future<void> _saveExpense() async {
    // Validaciones
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una fecha')),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el importe')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El importe debe ser un número válido')),
      );
      return;
    }

    // Validaciones específicas por tipo
    if (_expenseType == ExpenseType.combustible &&
        _litersController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa los litros cargados')),
      );
      return;
    }

    if (_expenseType == ExpenseType.multa &&
        _municipalityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el municipio')),
      );
      return;
    }

    if ((_expenseType == ExpenseType.peaje ||
            _expenseType == ExpenseType.reparaciones) &&
        _subtype == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona el subtipo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = TokenStorage.user;
      if (user == null || user['id'] == null) {
        throw Exception('No se encontró el ID del chofer');
      }
      final driverId = user['id'] as int;

      // Mapear el tipo de gasto al formato que espera el backend
      String expenseTypeForBackend;
      switch (_expenseType) {
        case ExpenseType.peaje:
          expenseTypeForBackend = 'Peaje';
          break;
        case ExpenseType.viaticos:
          expenseTypeForBackend = 'Viáticos';
          break;
        case ExpenseType.reparaciones:
          expenseTypeForBackend = 'Reparaciones';
          break;
        case ExpenseType.combustible:
          expenseTypeForBackend = 'Combustible';
          break;
        case ExpenseType.multa:
          expenseTypeForBackend = 'Multa';
          break;
      }

      await ExpenseService.createExpense(
        driverId: driverId,
        tripId: widget.trip.id,
        expenseType: expenseTypeForBackend,
        date: _startDate!,
        amount: amount,
        fuelLiters: _expenseType == ExpenseType.combustible
            ? double.tryParse(_litersController.text)
            : null,
        fineMunicipality: _expenseType == ExpenseType.multa
            ? _municipalityController.text
            : null,
        repairType: _expenseType == ExpenseType.reparaciones ? _subtype : null,
        tollType: _expenseType == ExpenseType.peaje ? _subtype : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto cargado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar gasto: $e'),
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
      appBar: AppBar(title: const Text('Cargar gasto')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: origen → destino
              Text(widget.trip.route, style: textTheme.titleLarge),

              gap20,

              FilledButton.tonalIcon(
                onPressed: () {
                  // TODO: AI tool to take photo of receipt
                },
                icon: const Icon(Symbols.add_a_photo),
                label: const Text('Tomar foto del comprobante'),
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
                      controller: _amountController,
                      enabled: !_isLoading,
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

              // Combustible → input de litros cargados
              if (_expenseType == ExpenseType.combustible) ...[
                TextField(
                  controller: _litersController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Litros cargados',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                gap12,
              ],

              // Multa → input de municipio
              if (_expenseType == ExpenseType.multa) ...[
                TextField(
                  controller: _municipalityController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Municipio',
                    border: OutlineInputBorder(),
                  ),
                ),
                gap12,
              ],

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

              gap16,

              // Botón principal: Cargar gasto
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isLoading ? null : _saveExpense,
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
                    : const Icon(Symbols.garage_money),
                label: Text(_isLoading ? 'Cargando...' : 'Cargar gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
