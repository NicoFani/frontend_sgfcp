import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/api_service.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';

class EditAdvancePageAdmin extends StatefulWidget {
  final int advancePaymentId;
  final int driverId;
  final String driverName;
  final DateTime date;
  final double amount;

  const EditAdvancePageAdmin({
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
      builder: (_) => EditAdvancePageAdmin(
        advancePaymentId: advancePaymentId,
        driverId: driverId,
        driverName: driverName,
        date: date,
        amount: amount,
      ),
    );
  }

  @override
  State<EditAdvancePageAdmin> createState() => _EditAdvancePageAdminState();
}

class _EditAdvancePageAdminState extends State<EditAdvancePageAdmin> {
  int? _selectedDriverId;
  DateTime? _date;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late Future<List<DriverData>> _driversFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _driversFuture = ApiService.getDrivers();

    // Inicializar con los datos existentes
    _selectedDriverId = widget.driverId;
    _date = widget.date;
    _dateController.text = DateFormat('dd/MM/yyyy').format(widget.date);
    _amountController.text = widget.amount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
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
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
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

  bool _validateForm() {
    if (_selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un chofer'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (_date == null || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un importe'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      if (amount <= 0) {
        throw Exception();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El importe debe ser un número válido mayor a 0'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _saveChanges() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));

      await ApiService.updateAdvancePayment(
        advancePaymentId: widget.advancePaymentId,
        driverId: _selectedDriverId!,
        date: _date!,
        amount: amount,
      );

      if (mounted) {
        Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('Editar adelanto')),
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
                          _driversFuture = ApiService.getDrivers();
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
                  DropdownButtonFormField<int>(
                    value: _selectedDriverId,
                    decoration: const InputDecoration(
                      labelText: 'Chofer',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: drivers.map((driver) {
                      return DropdownMenuItem(
                        value: driver.id,
                        child: Text('${driver.firstName} ${driver.lastName}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDriverId = value;
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
                          decoration: const InputDecoration(
                            labelText: 'Fecha',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onTap: _pickDate,
                        ),
                      ),

                      gapW12,

                      // Importe
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Importe',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  gap16,

                  // Botón Cambiar comprobante
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.secondaryContainer,
                      foregroundColor: colors.onSecondaryContainer,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _showReceiptDialog,
                    icon: const Icon(Symbols.receipt_long),
                    label: const Text('Cambiar comprobante'),
                  ),

                  const Spacer(),

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
