import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

import 'package:frontend_sgfcp/services/advance_payment_service.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';

class EditAdvancePaymentPage extends StatefulWidget {
  final int advancePaymentId;
  final int driverId;
  final String driverName;
  final DateTime date;
  final double amount;

  const EditAdvancePaymentPage({
    super.key,
    required this.advancePaymentId,
    required this.driverId,
    required this.driverName,
    required this.date,
    required this.amount,
  });

  static const String routeName = '/admin/edit-advance';

  static Route route({
    required int advancePaymentId,
    required int driverId,
    required String driverName,
    required DateTime date,
    required double amount,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => EditAdvancePaymentPage(
        advancePaymentId: advancePaymentId,
        driverId: driverId,
        driverName: driverName,
        date: date,
        amount: amount,
      ),
    );
  }

  @override
  State<EditAdvancePaymentPage> createState() => _EditAdvancePaymentPageState();
}

class _EditAdvancePaymentPageState extends State<EditAdvancePaymentPage> {
  int? _selectedDriverId;
  DateTime? _date;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late Future<List<DriverData>> _driversFuture;
  bool _isLoading = false;

  // Validation controllers
  final WidgetStatesController _driverStatesController = WidgetStatesController();
  final WidgetStatesController _dateStatesController = WidgetStatesController();
  final WidgetStatesController _amountStatesController = WidgetStatesController();
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _driversFuture = DriverService.getDrivers();

    // Inicializar con los datos existentes
    _selectedDriverId = widget.driverId;
    _date = widget.date;
    _dateController.text = formatDate(widget.date);
    _amountController.text = formatCurrency(widget.amount, symbol: '', decimalDigits: 2);

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
      initialDate: _date ?? now,
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

  void _showReceiptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar comprobante'),
        content: const Text(
          'Funcionalidad de cambio de comprobante (próximamente)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }



  Future<void> _saveChanges() async {
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

      await AdvancePaymentService.updateAdvancePayment(
        advancePaymentId: widget.advancePaymentId,
        driverId: _selectedDriverId!,
        date: _date!,
        amount: amount,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adelanto actualizado correctamente'),
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar adelanto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('¿Eliminar adelanto?'),
                    content: const Text(
                      '¿Estás seguro de que querés eliminar este adelanto? '
                      'Esta acción no se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                        ),
                        onPressed: () async {
                          try {
                            await AdvancePaymentService.deleteAdvancePayment(
                              advancePaymentId: widget.advancePaymentId,
                            );

                            if (!mounted) return;

                            Navigator.of(dialogContext).pop(true);
                            Navigator.of(context).pop(true);
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al eliminar adelanto: $e'),
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
                    errorText: _showValidationErrors && _selectedDriverId == null
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
                            suffixIcon: const Icon(Icons.calendar_today_outlined),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            errorText: _showValidationErrors &&
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

                  // Botón Cambiar comprobante
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: _showReceiptDialog,
                    icon: const Icon(Symbols.receipt_long),
                    label: const Text('Cambiar comprobante'),
                  ),

                  gap16,

                  // Botón Guardar cambios
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _isLoading ? null : _saveChanges,
                    icon: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Symbols.check),
                    label: const Text('Guardar cambios'),
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
