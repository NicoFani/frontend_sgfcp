import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class LoadAdvancePageAdmin extends StatefulWidget {
  const LoadAdvancePageAdmin({super.key});

  static const String routeName = '/admin/load-advance';

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const LoadAdvancePageAdmin(),
    );
  }

  @override
  State<LoadAdvancePageAdmin> createState() => _LoadAdvancePageAdminState();
}

class _LoadAdvancePageAdminState extends State<LoadAdvancePageAdmin> {
  String? _selectedDriver;
  DateTime? _date;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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
        title: const Text('Adjuntar comprobante'),
        content: const Text('Funcionalidad de carga de comprobante'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _loadAdvance() {
    // TODO: Validar y guardar en el backend
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adelanto cargado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Obtener lista real de choferes del backend
    final drivers = ['Alexander Albon', 'Carlos Sainz', 'Fernando Alonso'];

    return Scaffold(
      appBar: AppBar(title: const Text('Adelanto')),
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
                  return DropdownMenuItem(value: driver, child: Text(driver));
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

              // Botón Adjuntar comprobante
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.secondaryContainer,
                  foregroundColor: colors.onSecondaryContainer,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _showReceiptDialog,
                icon: const Icon(Symbols.receipt_long),
                label: const Text('Adjuntar comprobante'),
              ),

              const Spacer(),

              // Botón Cargar adelanto
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _loadAdvance,
                icon: const Icon(Symbols.attach_money),
                label: const Text('Cargar adelanto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
