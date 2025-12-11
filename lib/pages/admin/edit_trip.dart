import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/widgets/document_type_selector.dart';

class EditTripPageAdmin extends StatefulWidget {
  const EditTripPageAdmin({super.key});

  static const String routeName = '/admin/edit-trip';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const EditTripPageAdmin());
  }

  @override
  State<EditTripPageAdmin> createState() => _EditTripPageAdminState();
}

class _EditTripPageAdminState extends State<EditTripPageAdmin> {
  DocumentType _docType = DocumentType.ctg;
  String? _cargoType = 'Maíz';
  String? _selectedDriver = 'Alexander Albon';
  DateTime? _startDate;
  bool _clientPaysGas = false;

  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _transportCodeController = TextEditingController();
  final TextEditingController _loadOwnerController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _netWeightController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _tarifController = TextEditingController();
  final TextEditingController _advanceAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Datos precargados de ejemplo
    _docNumberController.text = '';
    _transportCodeController.text = 'Input';
    _loadOwnerController.text = 'Input';
    _clientController.text = 'Input';
    _netWeightController.text = '30.000';
    _startDateController.text = '11/09/2025';
    _kmController.text = '420';
    _tarifController.text = '38.000';
    _advanceAmountController.text = '80.000';
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    _transportCodeController.dispose();
    _loadOwnerController.dispose();
    _clientController.dispose();
    _netWeightController.dispose();
    _startDateController.dispose();
    _kmController.dispose();
    _tarifController.dispose();
    _advanceAmountController.dispose();
    super.dispose();
  }

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
        _startDateController.text = DateFormat('dd/MM/yyyy', locale).format(picked);
      });
    }
  }

  void _saveChanges() {
    // TODO: Validar y guardar en el backend
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios guardados correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Viaje'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: origen → destino
              Text(
                'Mattaldi → San Lorenzo',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              gap16,

              // Documento
              Text('Documento', style: textTheme.bodySmall),
              gap4,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DocumentTypeSelector(
                    selected: _docType,
                    onChanged: (newType) {
                      setState(() {
                        _docType = newType;
                        _docNumberController.text = "";
                      });
                    },
                  ),
                  gapW12,
                  Expanded(
                    child: TextField(
                      controller: _docNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: _docType == DocumentType.ctg ? 11 : 13,
                      decoration: const InputDecoration(
                        labelText: 'Número de documento',
                        border: OutlineInputBorder(),
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              gap12,

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
                items: const [
                  DropdownMenuItem(value: 'Alexander Albon', child: Text('Alexander Albon')),
                  DropdownMenuItem(value: 'Carlos Sainz', child: Text('Carlos Sainz')),
                  DropdownMenuItem(value: 'Fernando Alonso', child: Text('Fernando Alonso')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDriver = value;
                  });
                },
              ),

              gap12,

              // Código del transporte
              TextField(
                controller: _transportCodeController,
                decoration: const InputDecoration(
                  labelText: 'Código del transporte',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Dador de carga
              TextField(
                controller: _loadOwnerController,
                decoration: const InputDecoration(
                  labelText: 'Dador de carga',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Cliente
              TextField(
                controller: _clientController,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Tipo de carga + Peso neto
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _cargoType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de carga',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Maíz', child: Text('Maíz')),
                        DropdownMenuItem(value: 'Soja', child: Text('Soja')),
                        DropdownMenuItem(value: 'Trigo', child: Text('Trigo')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _cargoType = value;
                        });
                      },
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: TextField(
                      controller: _netWeightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Peso neto (kg)',
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

              gap12,

              // Fecha de inicio + Km a recorrer
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de inicio',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onTap: _pickStartDate,
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: TextField(
                      controller: _kmController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Km a recorrer',
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

              gap12,

              // Tarifa
              TextField(
                controller: _tarifController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tarifa',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap16,

              // Switch: ¿El cliente paga el combustible?
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '¿El cliente paga el combustible?',
                  style: textTheme.bodyMedium,
                ),
                value: _clientPaysGas,
                onChanged: (value) {
                  setState(() {
                    _clientPaysGas = value;
                  });
                },
              ),

              gap12,

              // Adelanto del cliente
              Text(
                'Si el cliente realizó un adelanto, ingrese el importe del adelanto',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              gap8,
              TextField(
                controller: _advanceAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Importe del adelanto',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap24,

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
