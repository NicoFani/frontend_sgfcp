import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class CreateDriverPageAdmin extends StatefulWidget {
  const CreateDriverPageAdmin({super.key});

  static const String routeName = '/admin/create-driver';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const CreateDriverPageAdmin());
  }

  @override
  State<CreateDriverPageAdmin> createState() => _CreateDriverPageAdminState();
}

class _CreateDriverPageAdminState extends State<CreateDriverPageAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cuilController = TextEditingController();
  final TextEditingController _cvuController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _cuilController.dispose();
    _cvuController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _createDriver() {
    // TODO: Validar y crear en el backend
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chofer creado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear nuevo chofer'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'juan@gmail.com',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap12,

              // Nombre(s)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre(s)',
                  hintText: 'Juan Antonio',
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
                  hintText: 'Rodriguez',
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
                  hintText: '27-28033514-8',
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
                  hintText: '0000031547612579452356',
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
                  hintText: '3462 37-8485',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              gap24,

              // Botón Crear chofer
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _createDriver,
                icon: const Icon(Symbols.person_add),
                label: const Text('Crear chofer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
