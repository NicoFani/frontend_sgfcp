import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';

enum DocumentType { driverLicense, medicalExam }

class DocumentationUpdatePage extends StatefulWidget {
  final DriverData driver;
  final DocumentType documentType;

  const DocumentationUpdatePage({
    super.key,
    required this.driver,
    required this.documentType,
  });

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/documentation_update';

  /// Helper to create a route to this page
  static Route route({
    required DriverData driver,
    required DocumentType documentType,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          DocumentationUpdatePage(driver: driver, documentType: documentType),
    );
  }

  @override
  State<DocumentationUpdatePage> createState() =>
      _DocumentationUpdatePageState();
}

class _DocumentationUpdatePageState extends State<DocumentationUpdatePage> {
  DateTime? _expirationDate;
  final TextEditingController _expirationDateController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializar con la fecha actual del documento
    _expirationDate = widget.documentType == DocumentType.driverLicense
        ? widget.driver.driverLicenseDueDate
        : widget.driver.medicalExamDueDate;

    if (_expirationDate != null) {
      _expirationDateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(_expirationDate!);
    }
  }

  @override
  void dispose() {
    _expirationDateController.dispose();
    super.dispose();
  }

  // Datepicker para seleccionar fecha de vencimiento
  Future<void> _pickExpirationDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        _expirationDate = picked;
        _expirationDateController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(picked);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Actualizar el driver con la nueva fecha
      await DriverService.updateDriver(
        driverId: widget.driver.id,
        driverLicenseDueDate: widget.documentType == DocumentType.driverLicense
            ? _expirationDate
            : null,
        medicalExamDueDate: widget.documentType == DocumentType.medicalExam
            ? _expirationDate
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fecha actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la página anterior
        Navigator.of(context).pop(true); // true indica que hubo cambios
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
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

  String get _documentTitle {
    return widget.documentType == DocumentType.driverLicense
        ? 'Licencia de conducir'
        : 'Examen médico';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Actualizar $_documentTitle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del documento
              Text(
                'Actualizar fecha de vencimiento de $_documentTitle',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              gap24,

              // Fecha de vencimiento
              TextField(
                controller: _expirationDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha de vencimiento',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                onTap: _pickExpirationDate,
              ),

              gap24,

              // Botón principal
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isLoading ? null : _saveChanges,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isLoading ? 'Guardando...' : 'Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
