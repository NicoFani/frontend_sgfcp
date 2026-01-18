import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/truck_data.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/truck_service.dart';

class DocumentationUpdatePage extends StatefulWidget {
  final String type; // "driver" or "truck"
  final dynamic entity; // DriverData or TruckData
  final String documentType; // e.g., "driverLicense", "medicalExam", "service", "vtv", "plate"

  const DocumentationUpdatePage({
    super.key,
    required this.type,
    required this.entity,
    required this.documentType,
  });

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/documentation_update';

  /// Helper to create a route to this page
  static Route route({
    required String type,
    required dynamic entity,
    required String documentType,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => DocumentationUpdatePage(
        type: type,
        entity: entity,
        documentType: documentType,
      ),
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
    if (widget.type == 'driver') {
      final driver = widget.entity as DriverData;
      if (widget.documentType == 'driverLicense') {
        _expirationDate = driver.driverLicenseDueDate;
      } else if (widget.documentType == 'medicalExam') {
        _expirationDate = driver.medicalExamDueDate;
      }
    } else if (widget.type == 'truck') {
      final truck = widget.entity as TruckData;
      if (widget.documentType == 'service') {
        _expirationDate = truck.serviceDueDate;
      } else if (widget.documentType == 'vtv') {
        _expirationDate = truck.vtvDueDate;
      } else if (widget.documentType == 'plate') {
        _expirationDate = truck.plateDueDate;
      }
    }

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
      if (widget.type == 'driver') {
        final driver = widget.entity as DriverData;
        await DriverService.updateDriver(
          driverId: driver.id,
          driverLicenseDueDate: widget.documentType == 'driverLicense'
              ? _expirationDate
              : null,
          medicalExamDueDate: widget.documentType == 'medicalExam'
              ? _expirationDate
              : null,
        );
      } else if (widget.type == 'truck') {
        final truck = widget.entity as TruckData;
        await TruckService.updateTruck(
          truckId: truck.id,
          serviceDueDate: widget.documentType == 'service'
              ? _expirationDate
              : null,
          vtvDueDate: widget.documentType == 'vtv'
              ? _expirationDate
              : null,
          plateDueDate: widget.documentType == 'plate'
              ? _expirationDate
              : null,
        );
      }

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
    switch (widget.documentType) {
      case 'driverLicense':
        return 'Licencia de conducir';
      case 'medicalExam':
        return 'Examen médico';
      case 'service':
        return 'Service';
      case 'vtv':
        return 'VTV';
      case 'plate':
        return 'Placa';
      default:
        return 'Documento';
    }
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
