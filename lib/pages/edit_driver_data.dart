import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class EditDriverDataPage extends StatefulWidget {
  const EditDriverDataPage({
    super.key,
    required this.driverName,
  });

  final String driverName;

  static const String routeName = '/admin/edit-driver-data';

  static Route route({required String driverName}) {
    return MaterialPageRoute<void>(
      builder: (_) => EditDriverDataPage(driverName: driverName),
    );
  }

  @override
  State<EditDriverDataPage> createState() => _EditDriverDataPageState();
}

class _EditDriverDataPageState extends State<EditDriverDataPage> {
  // TODO: Obtener datos reales del backend basado en widget.driverName
  final TextEditingController _nameController = TextEditingController(text: 'Juan Antonio');
  final TextEditingController _lastNameController = TextEditingController(text: 'Rodriguez');
  final TextEditingController _cuilController = TextEditingController(text: '27-28033514-8');
  final TextEditingController _cvuController = TextEditingController(text: '0000031547612579452356');
  final TextEditingController _phoneController = TextEditingController(text: '3462 37-8485');

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _cuilController.dispose();
    _cvuController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // TODO: Guardar cambios en el backend
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos actualizados correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar datos personales'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre(s)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre(s)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Apellido(s)
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido(s)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // CUIL
              TextField(
                controller: _cuilController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CUIL',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // CVU
              TextField(
                controller: _cvuController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CVU',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Número de teléfono
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Número de teléfono',
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
