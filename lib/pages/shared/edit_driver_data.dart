import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cuilController = TextEditingController();
  final TextEditingController _cvuController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    try {
      final driver = await DriverService.getDriverById(
        driverId: widget.driverId,
      );

      setState(() {
        _nameController.text = driver.firstName;
        _lastNameController.text = driver.lastName;
        _cuilController.text = driver.cuil ?? '';
        _cvuController.text = driver.cbu ?? '';
        _phoneController.text = driver.phoneNumber ?? '';
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
    super.dispose();
  }

  void _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      await DriverService.updateDriverBasicData(
        driverId: widget.driverId,
        name: _nameController.text.trim(),
        surname: _lastNameController.text.trim(),
        cuil: _cuilController.text.trim().replaceAll('-', ''),
        cvu: _cvuController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
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
