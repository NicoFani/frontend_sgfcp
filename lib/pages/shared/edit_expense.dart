import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_sgfcp/widgets/expense_subtype_dropdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/expense_type.dart';
import 'package:frontend_sgfcp/models/expense_data.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';

import 'package:frontend_sgfcp/widgets/labeled_switch.dart';
import 'package:frontend_sgfcp/services/expense_service.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

class EditExpensePage extends StatefulWidget {
  final ExpenseData expense;

  const EditExpensePage({super.key, required this.expense});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/edit_expense';

  /// Helper to create a route to this page
  static Route route({required ExpenseData expense}) {
    return MaterialPageRoute<void>(
      builder: (_) => EditExpensePage(expense: expense),
    );
  }

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  late Future<TripData> _tripFuture;

  DateTime? _startDate;
  bool _accountingPaid = false;
  bool _didInitDateText = false;
  bool _showValidationErrors = false;

  ExpenseType _expenseType = ExpenseType.reparaciones;
  String? _subtype;

  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

    final WidgetStatesController _amountStatesController =
      WidgetStatesController();
    final WidgetStatesController _litersStatesController =
      WidgetStatesController();
    final WidgetStatesController _municipalityStatesController =
      WidgetStatesController();

  @override
  void initState() {
    super.initState();
    if (widget.expense.tripId != null) {
      _tripFuture = TripService.getTrip(tripId: widget.expense.tripId!);
    } else {
      _tripFuture = Future.error('Gasto sin viaje asociado');
    }

    // Populate data
    _startDate = widget.expense.createdAt;
    _accountingPaid = widget.expense.accountingPaid ?? false;
    _expenseType = _mapTypeToExpenseType(widget.expense.type);
    _subtype = _getSubtype(widget.expense);

    _amountController.addListener(_updateValidationStates);
    _litersController.addListener(_updateValidationStates);
    _municipalityController.addListener(_updateValidationStates);

    final currencyFormatter = CurrencyTextInputFormatter.currency(
      locale: 'es_AR',
      symbol: '',
      decimalDigits: 2,
      enableNegative: false,
    );
    _amountController.text = currencyFormatter.formatDouble(
      widget.expense.amount,
    );
    if (widget.expense.fuelLiters != null) {
      _litersController.text = widget.expense.fuelLiters!.toString();
    }
    if (widget.expense.fineMunicipality != null) {
      _municipalityController.text = widget.expense.fineMunicipality!;
    }
    if (widget.expense.description != null) {
      _descriptionController.text = widget.expense.description!;
    }

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitDateText || _startDate == null) return;
    final locale = Localizations.localeOf(context).toString();
    _startDateController.text = DateFormat(
      'dd/MM/yyyy',
      locale,
    ).format(_startDate!);
    _didInitDateText = true;
  }

  ExpenseType _mapTypeToExpenseType(String type) {
    switch (type) {
      case 'peaje':
        return ExpenseType.peaje;
      case 'reparaciones':
        return ExpenseType.reparaciones;
      case 'combustible':
        return ExpenseType.combustible;
      case 'multa':
        return ExpenseType.multa;
      case 'viaticos':
        return ExpenseType.viaticos;
      default:
        return ExpenseType.reparaciones;
    }
  }

  String? _getSubtype(ExpenseData expense) {
    if (expense.type == 'peaje') return expense.tollType;
    if (expense.type == 'reparaciones') return expense.repairType;
    return null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _litersController.dispose();
    _municipalityController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _amountStatesController.dispose();
    _litersStatesController.dispose();
    _municipalityStatesController.dispose();
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
        _updateValidationStates();
      });
    }
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;
    _amountStatesController.update(
      WidgetState.error,
      _amountController.text.trim().isEmpty,
    );
    _litersStatesController.update(
      WidgetState.error,
      _expenseType == ExpenseType.combustible &&
          _litersController.text.trim().isEmpty,
    );
    _municipalityStatesController.update(
      WidgetState.error,
      _expenseType == ExpenseType.multa &&
          _municipalityController.text.trim().isEmpty,
    );
  }

  bool _validateRequiredFields() {
    final hasDate = _startDate != null;
    final hasAmount = _amountController.text.trim().isNotEmpty;
    final hasLiters = _expenseType != ExpenseType.combustible ||
        _litersController.text.trim().isNotEmpty;
    final hasMunicipality = _expenseType != ExpenseType.multa ||
        _municipalityController.text.trim().isNotEmpty;
    final hasSubtype = (_expenseType != ExpenseType.peaje &&
            _expenseType != ExpenseType.reparaciones) ||
        _subtype != null;

    setState(() {
      _showValidationErrors = true;
      _amountStatesController.update(WidgetState.error, !hasAmount);
      _litersStatesController.update(WidgetState.error, !hasLiters);
      _municipalityStatesController.update(WidgetState.error, !hasMunicipality);
    });

    return hasDate && hasAmount && hasLiters && hasMunicipality && hasSubtype;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar gasto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await showDialog<bool>(
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
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                        ),
                        onPressed: () async {
                          try {
                            await ExpenseService.deleteExpense(
                              expenseId: widget.expense.id,
                            );
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al eliminar gasto: $e'),
                              ),
                            );
                          }
                        },
                        child: const Text('Eliminar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<TripData>(
        future: _tripFuture,
        builder: (context, tripSnapshot) {
          if (tripSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tripSnapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  gap8,
                  Text('Error al cargar el viaje'),
                  gap8,
                  Text(tripSnapshot.error.toString()),
                ],
              ),
            );
          }

          final trip = tripSnapshot.data!;

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

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: origen → destino
                  Text(trip.route, style: textTheme.titleLarge),

                  gap20,

                  FilledButton.tonalIcon(
                    onPressed: () {
                      // TODO: receipt image handler, show current receipt if exists and option to change it
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
                        enabled: true,
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
                            _updateValidationStates();
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
                          decoration: InputDecoration(
                            labelText: 'Fecha',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                            errorText: _showValidationErrors &&
                                    _startDate == null
                                ? 'Campo requerido'
                                : null,
                          ),
                          onTap: _pickStartDate,
                        ),
                      ),
                      gapW12,
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _amountController,
                          statesController: _amountStatesController,
                          decoration: InputDecoration(
                            labelText: 'Importe',
                            border: OutlineInputBorder(),
                            prefixText: r'$ ',
                            errorText: _showValidationErrors &&
                                    _amountController.text.trim().isEmpty
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

                  gap12,

                  // Combustible → input de litros cargados
                  if (_expenseType == ExpenseType.combustible) ...[
                    TextField(
                      controller: _litersController,
                      statesController: _litersStatesController,
                      decoration: InputDecoration(
                        labelText: 'Litros cargados',
                        border: OutlineInputBorder(),
                        errorText: _showValidationErrors &&
                                _expenseType == ExpenseType.combustible &&
                                _litersController.text.trim().isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    gap12,
                  ],

                  // Multa → input de municipio
                  if (_expenseType == ExpenseType.multa) ...[
                    TextField(
                      controller: _municipalityController,
                      statesController: _municipalityStatesController,
                      decoration: InputDecoration(
                        labelText: 'Municipio',
                        border: OutlineInputBorder(),
                        errorText: _showValidationErrors &&
                                _expenseType == ExpenseType.multa &&
                                _municipalityController.text.trim().isEmpty
                            ? 'Campo requerido'
                            : null,
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
                        errorText: _showValidationErrors &&
                                (_expenseType == ExpenseType.peaje ||
                                    _expenseType == ExpenseType.reparaciones) &&
                                _subtype == null
                            ? 'Campo requerido'
                            : null,
                        onChanged: (v) {
                          setState(() {
                            _subtype = v;
                            _updateValidationStates();
                          });
                        },
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

                  // Botón principal: Guardar cambios
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () async {
                      if (!_validateRequiredFields()) {
                        return;
                      }

                      final amount = parseCurrency(
                        _amountController.text,
                      );
                      final data = <String, dynamic>{
                        'expense_type': _expenseType.name,
                        'date': _startDate!.toIso8601String().split('T')[0],
                        'amount': amount,
                        'description': _descriptionController.text.isNotEmpty
                            ? _descriptionController.text
                            : null,
                        'paid_by_admin': _accountingPaid,
                      };

                      if (_expenseType == ExpenseType.combustible) {
                        data['fuel_liters'] = double.tryParse(
                          _litersController.text,
                        );
                      }
                      if (_expenseType == ExpenseType.multa) {
                        data['fine_municipality'] =
                            _municipalityController.text;
                      }
                      if (_subtype != null) {
                        if (_expenseType == ExpenseType.peaje) {
                          data['toll_type'] = _subtype;
                        } else if (_expenseType == ExpenseType.reparaciones) {
                          data['repair_type'] = _subtype;
                        }
                      }

                      try {
                        await ExpenseService.updateExpense(
                          expenseId: widget.expense.id,
                          data: data,
                        );
                        if (mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al guardar cambios: $e'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Guardar cambios'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
