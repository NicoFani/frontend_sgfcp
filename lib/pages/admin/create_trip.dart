import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class CreateTripPageAdmin extends StatefulWidget {
  const CreateTripPageAdmin({super.key});

  static const String routeName = '/admin/create-trip';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const CreateTripPageAdmin());
  }

  @override
  State<CreateTripPageAdmin> createState() => _CreateTripPageAdminState();
}

class _CreateTripPageAdminState extends State<CreateTripPageAdmin> {
  DateTime? _startDate;
  final List<String> _selectedDrivers = [];

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _clientController.dispose();
    _startDateController.dispose();
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

  void _createTrip() {
    // TODO: Validar y crear en el backend
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viaje creado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final availableDrivers = [
      'Carlos Sainz',
      'Alexander Albon',
      'Fernando Alonso',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Viaje'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Localidad de origen
              TextField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Localidad de origen',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Localidad de destino
              TextField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Localidad de destino',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Cliente
              DropdownButtonFormField<String>(
                value: null,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  hintText: 'Copelleti',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Copelleti', child: Text('Copelleti')),
                  DropdownMenuItem(value: 'Cliente 2', child: Text('Cliente 2')),
                  DropdownMenuItem(value: 'Cliente 3', child: Text('Cliente 3')),
                ],
                onChanged: (value) {
                  // TODO: Actualizar cliente seleccionado
                },
              ),

              gap12,

              // Fecha de inicio
              TextField(
                controller: _startDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha de inicio',
                  hintText: '11/09/2025',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onTap: _pickStartDate,
              ),

              gap16,

              // Choferes
              Text('Choferes', style: textTheme.titleMedium),
              gap8,

              // Lista de choferes con checkboxes
              ...availableDrivers.map((driver) {
                final isSelected = _selectedDrivers.contains(driver);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(driver),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedDrivers.add(driver);
                      } else {
                        _selectedDrivers.remove(driver);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              }),

              gap24,

              // Botón Crear viaje
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _createTrip,
                icon: const Icon(Symbols.route),
                label: const Text('Crear viaje'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
