import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_sgfcp/widgets/expense_subtype_dropdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/expense_type.dart';
import 'package:frontend_sgfcp/models/expense_data.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';

import 'package:frontend_sgfcp/widgets/labeled_switch.dart';
import 'package:frontend_sgfcp/services/expense_service.dart';
import 'package:frontend_sgfcp/services/trip_service.dart';
import 'package:frontend_sgfcp/services/receipt_storage_service.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

class EditExpensePage extends StatefulWidget {
  final ExpenseData expense;
  final TripData? trip;

  const EditExpensePage({super.key, required this.expense, this.trip});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/edit_expense';

  /// Helper to create a route to this page
  static Route route({required ExpenseData expense, TripData? trip}) {
    return MaterialPageRoute<void>(
      builder: (_) => EditExpensePage(expense: expense, trip: trip),
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
  bool _isLoading = false;
  bool _isUploadingReceipt = false;

  ExpenseType _expenseType = ExpenseType.reparaciones;
  String? _subtype;
  XFile? _receiptFile;
  String? _currentReceiptUrl;

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
    if (widget.trip != null) {
      _tripFuture = Future.value(widget.trip!);
    } else if (widget.expense.tripId != null) {
      _tripFuture = TripService.getTrip(tripId: widget.expense.tripId!);
    } else {
      _tripFuture = Future.error('Gasto sin viaje asociado');
    }

    // Populate data
    _startDate = DateTime.now();
    _accountingPaid = widget.expense.accountingPaid ?? false;
    _expenseType = _mapTypeToExpenseType(widget.expense.type);
    _subtype = _getSubtype(widget.expense);
    _currentReceiptUrl = widget.expense.receiptUrl;

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
    final normalized = type
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();

    switch (normalized) {
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
    final normalized = expense.type
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();

    if (normalized == 'peaje') {
      final toll = expense.tollType;
      if (toll == null || toll.trim().isEmpty) return null;

      final normalizedToll = toll
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .trim();

      if (normalizedToll.contains('ruta') ||
          normalizedToll.contains('peaje de ruta')) {
        return 'Peaje de ruta';
      }
      if (normalizedToll.contains('portuaria')) {
        return 'Tasa portuaria';
      }
      if (normalizedToll.contains('ingreso')) {
        return 'Derecho de Ingreso a establecimiento';
      }

      return toll;
    }
    if (normalized == 'reparaciones') return expense.repairType;
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

  String _mapExpenseTypeToBackend(ExpenseType type) {
    switch (type) {
      case ExpenseType.peaje:
        return 'Peaje';
      case ExpenseType.viaticos:
        return 'Viáticos';
      case ExpenseType.reparaciones:
        return 'Reparaciones';
      case ExpenseType.combustible:
        return 'Combustible';
      case ExpenseType.multa:
        return 'Multa';
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
    final hasLiters =
        _expenseType != ExpenseType.combustible ||
        _litersController.text.trim().isNotEmpty;
    final hasMunicipality =
        _expenseType != ExpenseType.multa ||
        _municipalityController.text.trim().isNotEmpty;
    final hasSubtype =
        (_expenseType != ExpenseType.peaje &&
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

  Future<void> _showReceiptPicker() async {
    if (_isLoading || _isUploadingReceipt) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickReceipt(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickReceipt(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickReceipt(ImageSource source) async {
    final picker = ImagePicker();
    final effectiveSource = kIsWeb && source == ImageSource.camera
        ? ImageSource.gallery
        : source;

    final picked = await picker.pickImage(
      source: effectiveSource,
      imageQuality: 85,
      maxWidth: 1920,
    );

    if (picked != null) {
      setState(() {
        _receiptFile = picked;
      });
    }
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

          final peajeOptions = [
            'Peaje de ruta',
            'Tasa portuaria',
            'Derecho de Ingreso a establecimiento',
          ];
          final reparacionOptions = ['Neumáticos', 'Motor', 'Chapa y pintura'];

          List<String> subtypeOptions;
          String label;

          switch (_expenseType) {
            case ExpenseType.peaje:
              label = 'Peaje/Playa';
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
                    onPressed: _isLoading || _isUploadingReceipt
                        ? null
                        : _showReceiptPicker,
                    icon: const Icon(Symbols.add_a_photo),
                    label: Text(
                      _receiptFile != null || _currentReceiptUrl != null
                          ? 'Cambiar foto del comprobante'
                          : 'Adjuntar foto del comprobante',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),

                  gap20,

                  if (_receiptFile != null) ...[
                    Text(
                      'Nueva foto adjunta: ${_receiptFile!.name}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    gap12,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FutureBuilder<Uint8List>(
                        future: _receiptFile!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 140,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return Image.memory(
                            snapshot.data!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    gap12,
                    TextButton.icon(
                      onPressed: _isLoading || _isUploadingReceipt
                          ? null
                          : () => setState(() => _receiptFile = null),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Quitar nueva foto'),
                    ),
                    gap12,
                  ] else if (_currentReceiptUrl != null) ...[
                    Text('Comprobante actual:', style: textTheme.bodyMedium),
                    gap12,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _currentReceiptUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            width: double.infinity,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    gap12,
                  ],

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

                  // Fecha
                  TextField(
                    controller: _startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                      errorText: _showValidationErrors && _startDate == null
                          ? 'Campo requerido'
                          : null,
                    ),
                    onTap: _pickStartDate,
                  ),

                  gap12,

                  TextField(
                    controller: _amountController,
                    statesController: _amountStatesController,
                    decoration: InputDecoration(
                      labelText: 'Importe',
                      border: OutlineInputBorder(),
                      prefixText: r'$ ',
                      errorText:
                          _showValidationErrors &&
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

                  gap12,

                  // Combustible → input de litros cargados
                  if (_expenseType == ExpenseType.combustible) ...[
                    TextField(
                      controller: _litersController,
                      statesController: _litersStatesController,
                      decoration: InputDecoration(
                        labelText: 'Litros cargados',
                        border: OutlineInputBorder(),
                        errorText:
                            _showValidationErrors &&
                                _expenseType == ExpenseType.combustible &&
                                _litersController.text.trim().isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                        errorText:
                            _showValidationErrors &&
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
                        errorText:
                            _showValidationErrors &&
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

                  if (_expenseType == ExpenseType.peaje ||
                      _expenseType == ExpenseType.reparaciones) ...[
                    LabeledSwitch(
                      label: '¿Pagó contaduría?',
                      value: _accountingPaid,
                      onChanged: (v) => setState(() => _accountingPaid = v),
                    ),
                    gap16,
                  ] else
                    gap16,

                  // Botón principal: Guardar cambios
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _isLoading || _isUploadingReceipt
                        ? null
                        : () async {
                            if (!_validateRequiredFields()) {
                              return;
                            }

                            setState(() => _isLoading = true);

                            try {
                              String? receiptPath = _currentReceiptUrl;

                              // Si hay una nueva foto, subirla
                              if (_receiptFile != null) {
                                final user = TokenStorage.user;
                                if (user == null || user['id'] == null) {
                                  throw Exception(
                                    'No se encontró el ID del chofer',
                                  );
                                }
                                final driverId = user['id'] as int;

                                setState(() => _isUploadingReceipt = true);
                                try {
                                  receiptPath =
                                      await ReceiptStorageService.uploadReceipt(
                                        file: _receiptFile!,
                                        driverId: driverId,
                                        tripId: trip.id,
                                      );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isUploadingReceipt = false);
                                  }
                                }
                              }

                              final amount = parseCurrency(
                                _amountController.text,
                              );
                              final data = <String, dynamic>{
                                'expense_type': _mapExpenseTypeToBackend(
                                  _expenseType,
                                ),
                                'date': _startDate!.toIso8601String().split(
                                  'T',
                                )[0],
                                'amount': amount,
                                'paid_by_admin':
                                    (_expenseType == ExpenseType.peaje ||
                                        _expenseType ==
                                            ExpenseType.reparaciones)
                                    ? _accountingPaid
                                    : null,
                              };

                              // Agregar receipt_url solo si hay una
                              if (receiptPath != null) {
                                data['receipt_url'] = receiptPath;
                              }

                              if (_descriptionController.text
                                  .trim()
                                  .isNotEmpty) {
                                data['description'] = _descriptionController
                                    .text
                                    .trim();
                              }

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
                                } else if (_expenseType ==
                                    ExpenseType.reparaciones) {
                                  data['repair_type'] = _subtype;
                                }
                              }

                              await ExpenseService.updateExpense(
                                expenseId: widget.expense.id,
                                data: data,
                              );

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Gasto actualizado correctamente',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al guardar cambios: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
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
