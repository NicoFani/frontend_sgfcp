import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

class EditDriverDataPage extends StatefulWidget {
  const EditDriverDataPage({super.key, required this.driverId});

  final int driverId;

  static const String routeName = '/admin/edit-driver-data';

  static Route route({required int driverId}) {
    return MaterialPageRoute<void>(
      builder: (_) => EditDriverDataPage(driverId: driverId),
    );
  }

  @override
  State<EditDriverDataPage> createState() => _EditDriverDataPageState();
}

class _EditDriverDataPageState extends State<EditDriverDataPage> {
  final cuilMaxLength = 11;
  final cvuMaxLength = 22;
  final phoneMaxLength = 10;
  final cuilDisplayMaxLength = 13;
  final phoneDisplayMaxLength = 12;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cuilController = TextEditingController();
  final TextEditingController _cvuController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showValidationErrors = false;

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
    _loadDriverData();
    _nameController.addListener(_updateValidationStates);
    _lastNameController.addListener(_updateValidationStates);
    _cuilController.addListener(_updateValidationStates);
    _cvuController.addListener(_updateValidationStates);
    _phoneController.addListener(_updateValidationStates);
  }

  Future<void> _loadDriverData() async {
    try {
      final driver = await DriverService.getDriverById(
        driverId: widget.driverId,
      );

      setState(() {
        _nameController.text = driver.firstName;
        _lastNameController.text = driver.lastName;
        _cuilController.text = formatCuil(driver.cuil ?? '');
        _cvuController.text = driver.cbu ?? '';
        _phoneController.text = formatPhone(driver.phoneNumber ?? '');
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _cuilController.dispose();
    _cvuController.dispose();
    _phoneController.dispose();
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
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasLastName = _lastNameController.text.trim().isNotEmpty;
    final hasCuil = _isExactDigits(_cuilController.text, cuilMaxLength);
    final hasCvu = _isExactDigits(_cvuController.text, cvuMaxLength);
    final hasPhone = _isExactDigits(_phoneController.text, phoneMaxLength);

    setState(() {
      _showValidationErrors = true;
      _nameStatesController.update(WidgetState.error, !hasName);
      _lastNameStatesController.update(WidgetState.error, !hasLastName);
      _cuilStatesController.update(WidgetState.error, !hasCuil);
      _cvuStatesController.update(WidgetState.error, !hasCvu);
      _phoneStatesController.update(WidgetState.error, !hasPhone);
    });

    return hasName && hasLastName && hasCuil && hasCvu && hasPhone;
  }

  void _saveChanges() async {
    if (!_validateRequiredFields()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await DriverService.updateDriverBasicData(
        driverId: widget.driverId,
        name: _nameController.text.trim(),
        surname: _lastNameController.text.trim(),
        cuil: _digitsOnly(_cuilController.text),
        cvu: _digitsOnly(_cvuController.text),
        phoneNumber: _digitsOnly(_phoneController.text),
      );

      if (mounted) {
        Navigator.of(
          context,
        ).pop(true); // Return true to indicate data was updated
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
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar datos personales')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar datos personales')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre(s)
              TextField(
                controller: _nameController,
                statesController: _nameStatesController,
                decoration: InputDecoration(
                  labelText: 'Nombre(s)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          _nameController.text.trim().isEmpty
                      ? 'Campo requerido'
                      : null,
                ),
              ),

              gap12,

              // Apellido(s)
              TextField(
                controller: _lastNameController,
                statesController: _lastNameStatesController,
                decoration: InputDecoration(
                  labelText: 'Apellido(s)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: _showValidationErrors &&
                          _lastNameController.text.trim().isEmpty
                      ? 'Campo requerido'
                      : null,
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
                  border: OutlineInputBorder(),
                  counterText: '',
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
                  border: OutlineInputBorder(),
                  counterText: '',
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
                  border: OutlineInputBorder(),
                  counterText: '',
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

              // Botón Guardar cambios
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isSaving ? null : _saveChanges,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.check),
                label: Text(_isSaving ? 'Guardando...' : 'Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
