import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/client_service.dart';
import 'package:frontend_sgfcp/services/load_owner_service.dart';

class ClientProviderDialog extends StatefulWidget {
  final bool isEdit;
  final int? entityId; // ID del cliente o dador
  final String? initialName;
  final String? initialType; // 'Cliente' | 'Dador'

  const ClientProviderDialog({
    super.key,
    this.entityId,
    this.initialName,
    this.initialType,
  }) : isEdit = false;

  const ClientProviderDialog.edit({
    super.key,
    required this.entityId,
    required this.initialName,
    required this.initialType,
  }) : isEdit = true;

  static const String routeName = '/admin/create-client-provider';

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ClientProviderDialog(),
    );
  }

  static Route editRoute({
    required int entityId,
    required String initialName,
    required String initialType,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => ClientProviderDialog.edit(
        entityId: entityId,
        initialName: initialName,
        initialType: initialType,
      ),
    );
  }

  @override
  State<ClientProviderDialog> createState() => _ClientProviderDialogState();
}

class _ClientProviderDialogState extends State<ClientProviderDialog> {
  final TextEditingController _nameController = TextEditingController();
  late String _selectedType;
  late String _originalType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _selectedType = widget.initialType ?? 'Cliente';
    _originalType = widget.initialType ?? 'Cliente';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre es obligatorio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isEdit) {
        // Modo edición
        final typeChanged = _selectedType != _originalType;

        if (typeChanged) {
          // Cambio de tipo: convertir
          if (_originalType == 'Cliente' && _selectedType == 'Dador') {
            await ClientService.convertToLoadOwner(clientId: widget.entityId!);
          } else if (_originalType == 'Dador' && _selectedType == 'Cliente') {
            await LoadOwnerService.convertToClient(
              loadOwnerId: widget.entityId!,
            );
          }
        } else {
          // Solo actualizar nombre
          if (_selectedType == 'Cliente') {
            await ClientService.updateClient(
              clientId: widget.entityId!,
              name: _nameController.text.trim(),
            );
          } else {
            await LoadOwnerService.updateLoadOwner(
              loadOwnerId: widget.entityId!,
              name: _nameController.text.trim(),
            );
          }
        }

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                typeChanged
                    ? 'Convertido a $_selectedType correctamente'
                    : '$_selectedType actualizado correctamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Modo creación
        if (_selectedType == 'Cliente') {
          await ClientService.createClient(name: _nameController.text.trim());
        } else {
          await LoadOwnerService.createLoadOwner(
            name: _nameController.text.trim(),
          );
        }

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$_selectedType creado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar este $_selectedType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      if (_selectedType == 'Cliente') {
        await ClientService.deleteClient(clientId: widget.entityId!);
      } else {
        await LoadOwnerService.deleteLoadOwner(loadOwnerId: widget.entityId!);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_selectedType eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
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
              enabled: !_isLoading,
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
              onChanged: _isLoading
                  ? null
                  : (value) {
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
              onChanged: _isLoading
                  ? null
                  : (value) {
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
                  style: TextButton.styleFrom(foregroundColor: colors.error),
                  onPressed: _isLoading ? null : _delete,
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
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                gapW8,
                FilledButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(saveLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
