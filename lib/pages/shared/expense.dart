import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_sgfcp/widgets/expense_subtype_dropdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/expense_type.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/services/expense_service.dart';
import 'package:frontend_sgfcp/services/receipt_storage_service.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

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
  bool _isUploadingReceipt = false;
  bool _showValidationErrors = false;

  ExpenseType _expenseType = ExpenseType.peaje;
  String? _subtype;
  XFile? _receiptFile;

  // Controllers
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();

  final WidgetStatesController _amountStatesController =
      WidgetStatesController();
  final WidgetStatesController _litersStatesController =
      WidgetStatesController();
  final WidgetStatesController _municipalityStatesController =
      WidgetStatesController();

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _startDateController.text = formatDate(_startDate!);
    _amountController.addListener(_updateValidationStates);
    _litersController.addListener(_updateValidationStates);
    _municipalityController.addListener(_updateValidationStates);
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _amountController.dispose();
    _litersController.dispose();
    _municipalityController.dispose();
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

  Future<void> _saveExpense() async {
    if (!_validateRequiredFields()) {
      return;
    }

    final amount = parseCurrency(_amountController.text);

    setState(() => _isLoading = true);

    try {
      final user = TokenStorage.user;
      if (user == null || user['id'] == null) {
        throw Exception('No se encontró el ID del chofer');
      }
      final driverId = user['id'] as int;

      String? receiptPath;
      if (_receiptFile != null) {
        setState(() => _isUploadingReceipt = true);
        try {
          receiptPath = await ReceiptStorageService.uploadReceipt(
            file: _receiptFile!,
            driverId: driverId,
            tripId: widget.trip.id,
          );
        } finally {
          if (mounted) {
            setState(() => _isUploadingReceipt = false);
          }
        }
      }

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
        receiptUrl: receiptPath,
        fuelLiters: _expenseType == ExpenseType.combustible
            ? double.tryParse(_litersController.text)
            : null,
        fineMunicipality: _expenseType == ExpenseType.multa
            ? _municipalityController.text
            : null,
        repairType: _expenseType == ExpenseType.reparaciones ? _subtype : null,
        tollType: _expenseType == ExpenseType.peaje ? _subtype : null,
        paidByAdmin: (_expenseType == ExpenseType.peaje ||
                _expenseType == ExpenseType.reparaciones)
            ? _accountingPaid
            : null,
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

    final peajeOptions = [
      'Peaje de ruta',
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
                onPressed: _showReceiptPicker,
                icon: const Icon(Symbols.add_a_photo),
                label: const Text('Adjuntar foto del comprobante'),
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
                  'Comprobante adjunto: ${_receiptFile!.name}',
                  style: textTheme.bodyMedium,
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
                  label: const Text('Quitar comprobante'),
                ),
                gap12,
              ],

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
                enabled: !_isLoading,
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

              gap12,

              // Combustible → input de litros cargados
              if (_expenseType == ExpenseType.combustible) ...[
                TextField(
                  controller: _litersController,
                  enabled: !_isLoading,
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
                  enabled: !_isLoading,
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

              // Botón principal: Cargar gasto
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isLoading ? null : _saveExpense,
                icon: _isLoading || _isUploadingReceipt
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
                label: Text(
                  _isLoading || _isUploadingReceipt
                      ? 'Cargando...'
                      : 'Cargar gasto',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
