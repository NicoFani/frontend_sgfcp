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
  late String _entityType; // Solo para lectura, no se puede cambiar
  bool _isLoading = false;
  final nameLengthLimit = 36;

  // Validation controller
  final WidgetStatesController _nameStatesController = WidgetStatesController();
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _entityType = widget.initialType ?? 'Cliente';

    // Add validation listener
    _nameController.addListener(_updateValidationStates);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameStatesController.dispose();
    super.dispose();
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;

    setState(() {
      _nameStatesController.update(
        WidgetState.error,
        _nameController.text.trim().isEmpty,
      );
    });
  }

  bool _validateRequiredFields() {
    final hasName = _nameController.text.trim().isNotEmpty;

    setState(() {
      _showValidationErrors = true;
      _nameStatesController.update(WidgetState.error, !hasName);
    });

    return hasName;
  }

  Future<void> _save() async {
    if (!_validateRequiredFields()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isEdit) {
        // Modo edición: solo actualizar nombre
        if (_entityType == 'Cliente') {
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

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$_entityType actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Modo creación
        if (_entityType == 'Cliente') {
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
              content: Text('$_entityType creado correctamente'),
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
        content: Text('¿Estás seguro de eliminar este $_entityType?'),
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
      if (_entityType == 'Cliente') {
        await ClientService.deleteClient(clientId: widget.entityId!);
      } else {
        await LoadOwnerService.deleteLoadOwner(loadOwnerId: widget.entityId!);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_entityType eliminado correctamente'),
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
              statesController: _nameStatesController,
              maxLength: nameLengthLimit,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: const OutlineInputBorder(),
                counterText: '', // Ocultar contador de caracteres
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                errorText: _showValidationErrors &&
                        _nameController.text.trim().isEmpty
                    ? 'El nombre es obligatorio'
                    : null,
              ),
            ),

            gap16,

            // Radio buttons solo en modo creación
            if (!widget.isEdit) ...[
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cliente'),
                value: 'Cliente',
                groupValue: _entityType,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _entityType = value!;
                        });
                      },
              ),

              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dador'),
                value: 'Dador',
                groupValue: _entityType,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _entityType = value!;
                        });
                      },
              ),

              gap16,
            ],

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
