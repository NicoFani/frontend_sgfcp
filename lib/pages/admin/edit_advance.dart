import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class EditAdvancePageAdmin extends StatefulWidget {
  final String driverName;
  final DateTime date;
  final double amount;

  const EditAdvancePageAdmin({
    super.key,
    required this.driverName,
    required this.date,
    required this.amount,
  });

  static const String routeName = '/admin/edit-advance';

  static Route route({
    required String driverName,
    required DateTime date,
    required double amount,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => EditAdvancePageAdmin(
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
  String? _selectedDriver;
  DateTime? _date;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar con los datos existentes
    _selectedDriver = widget.driverName;
    _date = widget.date;
    _dateController.text = DateFormat('dd/MM/yyyy').format(widget.date);
    _amountController.text = widget.amount.toStringAsFixed(3).replaceAll('.', ',');
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
      lastDate: DateTime(now.year + 5),
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
        content: const Text('Funcionalidad de cambio de comprobante'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    // TODO: Validar y guardar cambios en el backend
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adelanto actualizado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Obtener lista real de choferes del backend
    final drivers = [
      'Alexander Albon',
      'Carlos Sainz',
      'Fernando Alonso',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar adelanto'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chofer
              DropdownButtonFormField<String>(
                value: _selectedDriver,
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
                    value: driver,
                    child: Text(driver),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDriver = value;
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                onPressed: _saveChanges,
                icon: const Icon(Symbols.check),
                label: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
