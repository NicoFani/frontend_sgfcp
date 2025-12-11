import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class EditAccountPageAdmin extends StatefulWidget {
  const EditAccountPageAdmin({super.key});

  static const String routeName = '/admin/edit-account';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const EditAccountPageAdmin());
  }

  @override
  State<EditAccountPageAdmin> createState() => _EditAccountPageAdminState();
}

class _EditAccountPageAdminState extends State<EditAccountPageAdmin> {
  // TODO: Obtener datos reales del backend
  final TextEditingController _nameController = TextEditingController(text: 'Omar');
  final TextEditingController _lastNameController = TextEditingController(text: 'José');
  final TextEditingController _emailController = TextEditingController(text: 'omar@gmail.com');

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // TODO: Validar y guardar cambios en el backend
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar datos de la cuenta'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
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
