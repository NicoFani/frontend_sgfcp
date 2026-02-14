import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

import 'package:frontend_sgfcp/services/advance_payment_service.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';

class AddAdvancePaymentPage extends StatefulWidget {
  const AddAdvancePaymentPage({super.key});

  static const String routeName = '/admin/load-advance';

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const AddAdvancePaymentPage(),
    );
  }

  @override
  State<AddAdvancePaymentPage> createState() => _AddAdvancePaymentPageState();
}

class _AddAdvancePaymentPageState extends State<AddAdvancePaymentPage> {
  int? _selectedDriverId;
  // ignore: unused_field
  String? _selectedDriverName;
  DateTime _date = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late Future<List<DriverData>> _driversFuture;
  bool _isLoading = false;

  // Archivo adjunto
  Uint8List? _receiptFileBytes;
  String? _receiptFileName;

  // Validation controllers
  final WidgetStatesController _driverStatesController =
      WidgetStatesController();
  final WidgetStatesController _dateStatesController = WidgetStatesController();
  final WidgetStatesController _amountStatesController =
      WidgetStatesController();
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _driversFuture = DriverService.getDrivers();
    _dateController.text = formatDate(_date);

    // Add validation listeners
    _amountController.addListener(_updateValidationStates);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _driverStatesController.dispose();
    _dateStatesController.dispose();
    _amountStatesController.dispose();
    super.dispose();
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;

    setState(() {
      // Driver validation
      if (_selectedDriverId == null) {
        _driverStatesController.update(WidgetState.error, true);
      } else {
        _driverStatesController.update(WidgetState.error, false);
      }

      // Date validation
      if (_dateController.text.isEmpty) {
        _dateStatesController.update(WidgetState.error, true);
      } else {
        _dateStatesController.update(WidgetState.error, false);
      }

      // Amount validation
      final amountText = _amountController.text.trim();
      if (amountText.isEmpty) {
        _amountStatesController.update(WidgetState.error, true);
      } else {
        try {
          final amount = parseCurrency(amountText);
          if (amount <= 0) {
            _amountStatesController.update(WidgetState.error, true);
          } else {
            _amountStatesController.update(WidgetState.error, false);
          }
        } catch (e) {
          _amountStatesController.update(WidgetState.error, true);
        }
      }
    });
  }

  bool _validateRequiredFields() {
    bool isValid = true;

    // Driver validation
    if (_selectedDriverId == null) {
      _driverStatesController.update(WidgetState.error, true);
      isValid = false;
    } else {
      _driverStatesController.update(WidgetState.error, false);
    }

    // Date validation
    if (_dateController.text.isEmpty) {
      _dateStatesController.update(WidgetState.error, true);
      isValid = false;
    } else {
      _dateStatesController.update(WidgetState.error, false);
    }

    // Amount validation
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _amountStatesController.update(WidgetState.error, true);
      isValid = false;
    } else {
      try {
        final amount = parseCurrency(amountText);
        if (amount <= 0) {
          _amountStatesController.update(WidgetState.error, true);
          isValid = false;
        } else {
          _amountStatesController.update(WidgetState.error, false);
        }
      } catch (e) {
        _amountStatesController.update(WidgetState.error, true);
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _date = picked;
        _dateController.text = formatDate(picked);
        _updateValidationStates();
      });
    }
  }

  Future<void> _pickReceipt() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _receiptFileBytes = result.files.single.bytes;
          _receiptFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeReceipt() {
    setState(() {
      _receiptFileBytes = null;
      _receiptFileName = null;
    });
  }

  Future<void> _loadAdvance() async {
    setState(() {
      _showValidationErrors = true;
    });

    if (!_validateRequiredFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = parseCurrency(_amountController.text);

      await AdvancePaymentService.createAdvancePayment(
        driverId: _selectedDriverId!,
        date: _date,
        amount: amount,
        receiptFileBytes: _receiptFileBytes,
        receiptFileName: _receiptFileName,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adelanto cargado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargar Adelanto')),
      body: SafeArea(
        child: FutureBuilder<List<DriverData>>(
          future: _driversFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    gap16,
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _driversFuture = DriverService.getDrivers();
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final drivers = snapshot.data ?? [];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chofer
                  DropdownMenu<int>(
                    expandedInsets: EdgeInsets.zero,
                    initialSelection: _selectedDriverId,
                    label: const Text('Chofer'),
                    errorText:
                        _showValidationErrors && _selectedDriverId == null
                        ? 'Selecciona un chofer'
                        : null,
                    dropdownMenuEntries: drivers.map((driver) {
                      return DropdownMenuEntry<int>(
                        value: driver.id,
                        label: '${driver.firstName} ${driver.lastName}',
                      );
                    }).toList(),
                    onSelected: (value) {
                      setState(() {
                        _selectedDriverId = value;
                        if (value != null) {
                          _selectedDriverName = drivers
                              .firstWhere((d) => d.id == value)
                              .firstName;
                        }
                        _updateValidationStates();
                      });
                    },
                  ),

                  gap12,

                  // Fecha e Importe en la misma fila
                  Row(
                    children: [
                      // Fecha
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          readOnly: true,
                          statesController: _dateStatesController,
                          decoration: InputDecoration(
                            labelText: 'Fecha',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            errorText:
                                _showValidationErrors &&
                                    _dateController.text.isEmpty
                                ? 'Selecciona una fecha'
                                : null,
                          ),
                          onTap: _pickDate,
                        ),
                      ),

                      gapW12,

                      // Importe
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          statesController: _amountStatesController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            CurrencyTextInputFormatter.currency(
                              locale: 'es_AR',
                              symbol: '',
                              decimalDigits: 2,
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Importe',
                            prefixText: r'$ ',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            errorText: _showValidationErrors
                                ? () {
                                    final text = _amountController.text.trim();
                                    if (text.isEmpty) {
                                      return 'Ingresa un importe';
                                    }
                                    try {
                                      final amount = parseCurrency(text);
                                      if (amount <= 0) {
                                        return 'Debe ser mayor a 0';
                                      }
                                    } catch (e) {
                                      return 'Importe inválido';
                                    }
                                    return null;
                                  }()
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  gap12,

                  // Botón Adjuntar comprobante o mostrar archivo adjunto
                  if (_receiptFileBytes == null)
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: _pickReceipt,
                      icon: const Icon(Symbols.receipt_long),
                      label: const Text('Adjuntar comprobante'),
                    )
                  else
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.attach_file,
                          color: Colors.green,
                        ),
                        title: Text(
                          _receiptFileName ?? 'Archivo adjunto',
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${(_receiptFileBytes!.length / 1024).toStringAsFixed(1)} KB',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _removeReceipt,
                          tooltip: 'Quitar',
                        ),
                      ),
                    ),

                  gap12,

                  // Botón Cargar adelanto
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _isLoading ? null : _loadAdvance,
                    icon: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Symbols.mintmark),
                    label: const Text('Cargar adelanto'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
