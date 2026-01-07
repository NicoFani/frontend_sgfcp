import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class CreateVehiclePageAdmin extends StatefulWidget {
  const CreateVehiclePageAdmin({super.key});

  static const String routeName = '/admin/create-vehicle';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const CreateVehiclePageAdmin());
  }

  @override
  State<CreateVehiclePageAdmin> createState() => _CreateVehiclePageAdminState();
}

class _CreateVehiclePageAdminState extends State<CreateVehiclePageAdmin> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  String? _selectedDriver;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _createVehicle() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vehículo creado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Obtener lista real de choferes del backend
    final drivers = [
      'Alexander Albon',
      'Carlos Sainz',
      'Fernando Alonso',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alta de vehículo'),
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

              gap16,

              // Botón Dar vehículo de alta
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _createVehicle,
                icon: const Icon(Symbols.check),
                label: const Text('Dar vehículo de alta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
