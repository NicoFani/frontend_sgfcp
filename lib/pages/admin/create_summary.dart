import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';

import 'package:frontend_sgfcp/services/driver_service.dart';

class GenerateSummary extends StatefulWidget {
  const GenerateSummary({super.key});

  static const String routeName = '/admin/generate-summary';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const GenerateSummary());
  }

  @override
  State<GenerateSummary> createState() => _GenerateSummaryState();
}

class _GenerateSummaryState extends State<GenerateSummary> {
  DateTime? _startDate;
  final List<int> _selectedDriverIds = [];
  int? _selectedClientId;
  bool _isLoading = false;

  // Controllers
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _originDescController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _destinationDescController =
      TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

  @override
  void dispose() {
    _originController.dispose();
    _originDescController.dispose();
    _destinationController.dispose();
    _destinationDescController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _pickPeriod() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        final locale = Localizations.localeOf(context).toString();
        _startDateController.text = DateFormat(
          'dd/MM/yyyy',
          locale,
        ).format(picked);
      });
    }
  }

  void _generateSummary() async {
    // Validaciones
    if (_originController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa la localidad de origen'),
        ),
      );
      return;
    }

    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa la localidad de destino'),
        ),
      );
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona la fecha de inicio'),
        ),
      );
      return;
    }

    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un cliente')),
      );
      return;
    }

    if (_selectedDriverIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona al menos un chofer'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implementar la llamada a la API para generar el resumen
      // await ApiService.createTrip(
      //   origin: _originController.text,
      //   originDescription: _originDescController.text.isNotEmpty
      //       ? _originDescController.text
      //       : null,
      //   destination: _destinationController.text,
      //   destinationDescription: _destinationDescController.text.isNotEmpty
      //       ? _destinationDescController.text
      //       : null,
      //   startDate: _startDate!,
      //   clientId: _selectedClientId!,
      //   driverIds: _selectedDriverIds,
      // );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resumen generado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar resumen: $e'),
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Generar resumen')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Periodo
              TextField(
                controller: _startDateController,
                readOnly: true,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Fecha Inicio',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                onTap: _isLoading ? null : _pickPeriod,
              ),
                            gap16,

              // Choferes
              Text('Choferes', style: textTheme.titleMedium),
              gap8,

              FutureBuilder<List<DriverData>>(
                future: DriverService.getDrivers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error al cargar choferes: ${snapshot.error}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.error,
                      ),
                    );
                  }

                  final drivers = snapshot.data ?? [];

                  if (drivers.isEmpty) {
                    return Text(
                      'No hay choferes disponibles',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    );
                  }

                  return Column(
                    children: drivers.map((driver) {
                      final isSelected = _selectedDriverIds.contains(driver.id);
                      return CheckboxListTile(
                        enabled: !_isLoading,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(vertical: -4),
                        title: Text(driver.fullName),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedDriverIds.add(driver.id);
                            } else {
                              _selectedDriverIds.remove(driver.id);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  );
                },
              ),
              gap24,

              // Botón Generar resumen
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: _isLoading ? null : _generateSummary,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.receipt_long),
                label: Text(_isLoading ? 'Generando...' : 'Generar resumen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
