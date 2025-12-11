import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class EditVehiclePageAdmin extends StatefulWidget {
  final String brand;
  final String model;
  final String plate;

  const EditVehiclePageAdmin({
    super.key,
    required this.brand,
    required this.model,
    required this.plate,
  });

  static const String routeName = '/admin/edit-vehicle';

  static Route route({
    required String brand,
    required String model,
    required String plate,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => EditVehiclePageAdmin(
        brand: brand,
        model: model,
        plate: plate,
      ),
    );
  }

  @override
  State<EditVehiclePageAdmin> createState() => _EditVehiclePageAdminState();
}

class _EditVehiclePageAdminState extends State<EditVehiclePageAdmin> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  String? _selectedDriver;

  @override
  void initState() {
    super.initState();
    // TODO: Obtener datos reales del backend
    _brandController.text = widget.brand;
    _modelController.text = widget.model;
    _yearController.text = '2021';
    _plateController.text = widget.plate;
    _selectedDriver = 'Alexander Albon';
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vehículo actualizado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // TODO: Obtener lista real de choferes del backend
    final drivers = [
      'Alexander Albon',
      'Carlos Sainz',
      'Fernando Alonso',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar datos del vehículo'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Marca
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Modelo
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Año
              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Año',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Patente
              TextField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Patente',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Chofer asignado
              DropdownButtonFormField<String>(
                value: _selectedDriver,
                decoration: const InputDecoration(
                  labelText: 'Chofer asignado',
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
