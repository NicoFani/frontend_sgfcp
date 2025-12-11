import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class CreateClientProviderPageAdmin extends StatefulWidget {
  const CreateClientProviderPageAdmin({super.key});

  static const String routeName = '/admin/create-client-provider';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const CreateClientProviderPageAdmin());
  }

  @override
  State<CreateClientProviderPageAdmin> createState() => _CreateClientProviderPageAdminState();
}

class _CreateClientProviderPageAdminState extends State<CreateClientProviderPageAdmin> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedType = 'Cliente';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    // TODO: Validar y guardar en el backend
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_selectedType creado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              'Crear cliente o dador',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            gap20,

            // Campo de nombre
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),

            gap16,

            // Radio buttons
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cliente'),
              value: 'Cliente',
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),

            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dador'),
              value: 'Dador',
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),

            gap20,

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                gapW8,
                FilledButton(
                  onPressed: _save,
                  child: const Text('Guardar cambios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
