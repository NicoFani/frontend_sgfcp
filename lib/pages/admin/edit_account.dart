import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/user.dart';
import 'package:frontend_sgfcp/services/auth_service.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

class EditAccountPageAdmin extends StatefulWidget {
  final User user;

  const EditAccountPageAdmin({super.key, required this.user});

  static const String routeName = '/admin/edit-account';

  static Route route({required User user}) {
    return MaterialPageRoute<void>(
      builder: (_) => EditAccountPageAdmin(user: user),
    );
  }

  @override
  State<EditAccountPageAdmin> createState() => _EditAccountPageAdminState();
}

class _EditAccountPageAdminState extends State<EditAccountPageAdmin> {
  final fieldsMaxLength = 24;

  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  // Validation controllers
  final WidgetStatesController _nameStatesController = WidgetStatesController();
  final WidgetStatesController _lastNameStatesController = WidgetStatesController();
  final WidgetStatesController _emailStatesController = WidgetStatesController();
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);

    // Add validation listeners
    _nameController.addListener(_updateValidationStates);
    _lastNameController.addListener(_updateValidationStates);
    _emailController.addListener(_updateValidationStates);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _nameStatesController.dispose();
    _lastNameStatesController.dispose();
    _emailStatesController.dispose();
    super.dispose();
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;

    setState(() {
      _nameStatesController.update(
        WidgetState.error,
        _nameController.text.trim().isEmpty,
      );
      _lastNameStatesController.update(
        WidgetState.error,
        _lastNameController.text.trim().isEmpty,
      );
      _emailStatesController.update(
        WidgetState.error,
        !isValidEmail(_emailController.text),
      );
    });
  }

  bool _validateRequiredFields() {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasLastName = _lastNameController.text.trim().isNotEmpty;
    final hasEmail = isValidEmail(_emailController.text);

    setState(() {
      _showValidationErrors = true;
      _nameStatesController.update(WidgetState.error, !hasName);
      _lastNameStatesController.update(WidgetState.error, !hasLastName);
      _emailStatesController.update(WidgetState.error, !hasEmail);
    });

    return hasName && hasLastName && hasEmail;
  }

  Future<void> _saveChanges() async {
    if (!_validateRequiredFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.updateUser(
        userId: widget.user.id,
        name: _nameController.text,
        surname: _lastNameController.text,
        email: _emailController.text,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos actualizados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

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
                statesController: _nameStatesController,
                maxLength: fieldsMaxLength,
                decoration: InputDecoration(
                  labelText: 'Nombre(s)',
                  border: const OutlineInputBorder(),
                  counterText: '', // Ocultar contador de caracteres
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          _nameController.text.trim().isEmpty
                      ? 'Ingresa un nombre'
                      : null,
                ),
              ),

              gap12,

              // Apellido(s)
              TextField(
                controller: _lastNameController,
                statesController: _lastNameStatesController,
                maxLength: fieldsMaxLength,
                decoration: InputDecoration(
                  labelText: 'Apellido(s)',
                  border: const OutlineInputBorder(),
                  counterText: '', // Ocultar contador de caracteres
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          _lastNameController.text.trim().isEmpty
                      ? 'Ingresa un apellido'
                      : null,
                ),
              ),

              gap12,

              // Email
              TextField(
                controller: _emailController,
                statesController: _emailStatesController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          !isValidEmail(_emailController.text)
                      ? 'Email inválido'
                      : null,
                ),
              ),

              gap16,

              // Botón Guardar cambios
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isLoading ? null : _saveChanges,
                icon: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.check),
                label: Text(_isLoading ? 'Guardando...' : 'Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
