import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

class CreateDriverPageAdmin extends StatefulWidget {
  const CreateDriverPageAdmin({super.key});

  static const String routeName = '/admin/create-driver';

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CreateDriverPageAdmin(),
    );
  }

  @override
  State<CreateDriverPageAdmin> createState() => _CreateDriverPageAdminState();
}

class _CreateDriverPageAdminState extends State<CreateDriverPageAdmin> {
  final cuilMaxLength = 11;
  final cvuMaxLength = 22;
  final phoneMaxLength = 10;
  final cuilDisplayMaxLength = 13;
  final phoneDisplayMaxLength = 12;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cuilController = TextEditingController();
  final TextEditingController _cvuController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _showValidationErrors = false;

  final WidgetStatesController _emailStatesController =
    WidgetStatesController();
  final WidgetStatesController _nameStatesController =
    WidgetStatesController();
  final WidgetStatesController _lastNameStatesController =
    WidgetStatesController();
  final WidgetStatesController _cuilStatesController =
    WidgetStatesController();
  final WidgetStatesController _cvuStatesController =
    WidgetStatesController();
  final WidgetStatesController _phoneStatesController =
    WidgetStatesController();

  @override
  void initState() {
  super.initState();
  _emailController.addListener(_updateValidationStates);
  _nameController.addListener(_updateValidationStates);
  _lastNameController.addListener(_updateValidationStates);
  _cuilController.addListener(_updateValidationStates);
  _cvuController.addListener(_updateValidationStates);
  _phoneController.addListener(_updateValidationStates);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _cuilController.dispose();
    _cvuController.dispose();
    _phoneController.dispose();
    _emailStatesController.dispose();
    _nameStatesController.dispose();
    _lastNameStatesController.dispose();
    _cuilStatesController.dispose();
    _cvuStatesController.dispose();
    _phoneStatesController.dispose();
    super.dispose();
  }

  bool _isExactDigits(String value, int length) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length == length && RegExp(r'^\d+$').hasMatch(digits);
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;
    _emailStatesController.update(
      WidgetState.error,
      !isValidEmail(_emailController.text),
    );
    _nameStatesController.update(
      WidgetState.error,
      _nameController.text.trim().isEmpty,
    );
    _lastNameStatesController.update(
      WidgetState.error,
      _lastNameController.text.trim().isEmpty,
    );
    _cuilStatesController.update(
      WidgetState.error,
      !_isExactDigits(_cuilController.text, cuilMaxLength),
    );
    _cvuStatesController.update(
      WidgetState.error,
      !_isExactDigits(_cvuController.text, cvuMaxLength),
    );
    _phoneStatesController.update(
      WidgetState.error,
      !_isExactDigits(_phoneController.text, phoneMaxLength),
    );
  }

  bool _validateRequiredFields() {
    final hasEmail = isValidEmail(_emailController.text);
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasLastName = _lastNameController.text.trim().isNotEmpty;
    final hasCuil = _isExactDigits(_cuilController.text, cuilMaxLength);
    final hasCvu = _isExactDigits(_cvuController.text, cvuMaxLength);
    final hasPhone = _isExactDigits(_phoneController.text, phoneMaxLength);

    setState(() {
      _showValidationErrors = true;
      _emailStatesController.update(WidgetState.error, !hasEmail);
      _nameStatesController.update(WidgetState.error, !hasName);
      _lastNameStatesController.update(WidgetState.error, !hasLastName);
      _cuilStatesController.update(WidgetState.error, !hasCuil);
      _cvuStatesController.update(WidgetState.error, !hasCvu);
      _phoneStatesController.update(WidgetState.error, !hasPhone);
    });

    return hasEmail &&
        hasName &&
        hasLastName &&
        hasCuil &&
        hasCvu &&
        hasPhone;
  }

  void _createDriver() async {
    if (!_validateRequiredFields()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DriverService.createDriverComplete(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        surname: _lastNameController.text.trim(),
        cuil: _digitsOnly(_cuilController.text),
        cvu: _digitsOnly(_cvuController.text),
        phoneNumber: _digitsOnly(_phoneController.text),
      );

      if (mounted) {
        Navigator.of(
          context,
        ).pop(true); // Return true to indicate driver was created
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chofer creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear chofer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear nuevo chofer')),
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
                statesController: _emailStatesController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'juan@gmail.com',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          !isValidEmail(_emailController.text)
                      ? 'Email invalido'
                      : null,
                ),
              ),

              gap12,

              // Nombre(s)
              TextField(
                controller: _nameController,
                statesController: _nameStatesController,
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
                statesController: _lastNameStatesController,
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
                inputFormatters: [CuilInputFormatter()],
                statesController: _cuilStatesController,
                maxLength: cuilDisplayMaxLength,
                decoration: InputDecoration(
                  labelText: 'CUIL',
                  hintText: '27-28033514-8',
                  counterText: '',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          !_isExactDigits(_cuilController.text, cuilMaxLength)
                      ? 'Debe tener $cuilMaxLength digitos'
                      : null,
                ),
              ),

              gap12,

              // CVU
              TextField(
                controller: _cvuController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                statesController: _cvuStatesController,
                maxLength: cvuMaxLength,
                decoration: InputDecoration(
                  labelText: 'CVU',
                  hintText: '0000031547612579452356',
                  counterText: '',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          !_isExactDigits(_cvuController.text, cvuMaxLength)
                      ? 'Debe tener $cvuMaxLength dígitos'
                      : null,
                ),
              ),

              gap12,

              // Número de teléfono
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [PhoneInputFormatter()],
                statesController: _phoneStatesController,
                maxLength: phoneDisplayMaxLength,
                decoration: InputDecoration(
                  labelText: 'Número de teléfono',
                  hintText: '3462 37-8485',
                  counterText: '',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          !_isExactDigits(_phoneController.text, phoneMaxLength)
                      ? 'Debe tener $phoneMaxLength dígitos'
                      : null,
                ),
              ),

              gap24,

              // Botón Crear chofer
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isLoading ? null : _createDriver,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.person_add),
                label: Text(_isLoading ? 'Creando...' : 'Crear chofer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
