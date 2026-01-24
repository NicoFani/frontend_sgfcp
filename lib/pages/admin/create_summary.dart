import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/payroll_period_data.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/payroll_period_service.dart';
import 'package:frontend_sgfcp/services/payroll_summary_service.dart';
import 'package:frontend_sgfcp/pages/admin/summary_detail.dart';

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
  int? _selectedPeriodId;
  int? _selectedDriverId;
  bool _isLoading = false;

  Future<void> _generateSummary() async {
    // Validaciones
    if (_selectedPeriodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un período')),
      );
      return;
    }

    if (_selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un chofer')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Generar el resumen
      final summary = await PayrollSummaryService.generateSummary(
        periodId: _selectedPeriodId!,
        driverId: _selectedDriverId!,
      );

      if (mounted) {
        // Navegar al detalle del resumen generado
        Navigator.of(
          context,
        ).pushReplacement(SummaryDetailPage.route(summaryId: summary.id));
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
              // Dropdown de Períodos
              Text('Período', style: textTheme.titleMedium),
              gap8,
              FutureBuilder<List<PayrollPeriodData>>(
                future: PayrollPeriodService.getAllPeriods(),
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
                      'Error al cargar períodos: ${snapshot.error}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.error,
                      ),
                    );
                  }

                  final periods = snapshot.data ?? [];

                  if (periods.isEmpty) {
                    return Text(
                      'No hay períodos disponibles',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    );
                  }

                  return DropdownButtonFormField<int>(
                    value: _selectedPeriodId,
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar período',
                      border: OutlineInputBorder(),
                    ),
                    items: periods.map((period) {
                      return DropdownMenuItem<int>(
                        value: period.id,
                        child: Text(period.periodLabel),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedPeriodId = value;
                            });
                          },
                  );
                },
              ),
              gap16,

              // Dropdown de Choferes
              Text('Chofer', style: textTheme.titleMedium),
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

                  return DropdownButtonFormField<int>(
                    value: _selectedDriverId,
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar chofer',
                      border: OutlineInputBorder(),
                    ),
                    items: drivers.map((driver) {
                      return DropdownMenuItem<int>(
                        value: driver.id,
                        child: Text(driver.fullName),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedDriverId = value;
                            });
                          },
                  );
                },
              ),
              gap24,

              // Botón Generar resumen
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
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
