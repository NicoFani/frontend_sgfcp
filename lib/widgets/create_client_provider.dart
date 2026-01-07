import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class ClientProviderDialog extends StatefulWidget {
  final bool isEdit;
  final String? initialName;
  final String? initialType; // 'Cliente' | 'Dador'
  final VoidCallback? onDelete;

  const ClientProviderDialog({
    super.key,
    this.initialName,
    this.initialType,
    this.onDelete,
  }) : isEdit = false;

  const ClientProviderDialog.edit({
    super.key,
    this.initialName,
    this.initialType,
    this.onDelete,
  }) : isEdit = true;

  static const String routeName = '/admin/create-client-provider';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const ClientProviderDialog());
  }

  static Route editRoute({
    String? initialName,
    String? initialType,
    VoidCallback? onDelete,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => ClientProviderDialog.edit(
        initialName: initialName,
        initialType: initialType,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<ClientProviderDialog> createState() => _ClientProviderDialogState();
}

class _ClientProviderDialogState extends State<ClientProviderDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedType = 'Cliente';

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

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
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final saveLabel = widget.isEdit ? 'Guardar cambios' : 'Guardar';

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              widget.isEdit ? 'Editar' : 'Crear cliente o dador',
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

            gap16,

            if (widget.isEdit) ...[
              // Botón Eliminar (solo en edición)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.error,
                  ),
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                ),
              ),

              gap12,
            ],

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
                  child: Text(saveLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
