import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/payroll_period_data.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/payroll_period_service.dart';
import 'package:frontend_sgfcp/services/payroll_summary_service.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:frontend_sgfcp/pages/admin/summary_detail.dart';
import 'package:frontend_sgfcp/widgets/month_picker.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _periodController = TextEditingController();

  late Future<List<DriverData>> _driversFuture;
  late Future<List<PayrollPeriodData>> _periodsFuture;

  // Validation controllers
  final WidgetStatesController _periodStatesController =
      WidgetStatesController();
  final WidgetStatesController _driverStatesController =
      WidgetStatesController();
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _driversFuture = DriverService.getDrivers();
    _periodsFuture = PayrollPeriodService.getAllPeriods();
  }

  Future<void> _generateSummary() async {
    setState(() {
      _showValidationErrors = true;
    });

    // Validaciones
    if (_selectedPeriodId == null || _selectedDriverId == null) {
      _updateValidationStates();
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
        // Navegar al detalle del resumen generado y luego volver con resultado exitoso
        await Navigator.of(
          context,
        ).push(SummaryDetailPage.route(summaryId: summary.id));
        // Volver a la página anterior indicando que se creó un resumen
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        // Mostrar solo el mensaje específico sin prefijos genéricos
        String errorMessage;
        if (e is ApiException && e.details != null) {
          errorMessage = e.details!;
        } else {
          errorMessage = e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _periodController.dispose();
    _periodStatesController.dispose();
    _driverStatesController.dispose();
    super.dispose();
  }

  void _updateValidationStates() {
    if (!_showValidationErrors) return;

    setState(() {
      _periodStatesController.update(
        WidgetState.error,
        _selectedPeriodId == null,
      );
      _driverStatesController.update(
        WidgetState.error,
        _selectedDriverId == null,
      );
    });
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
                future: _periodsFuture,
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

                  final sortedPeriods = [...periods]
                    ..sort((a, b) => a.startDate.compareTo(b.startDate));
                  final firstDate = DateTime(
                    sortedPeriods.first.startDate.year,
                    sortedPeriods.first.startDate.month,
                  );
                  final lastDate = DateTime(
                    sortedPeriods.last.startDate.year,
                    sortedPeriods.last.startDate.month,
                  );

                  _initializePeriodController(sortedPeriods);

                  return TextFormField(
                    controller: _periodController,
                    readOnly: true,
                    statesController: _periodStatesController,
                    decoration: InputDecoration(
                      labelText: 'Seleccionar período',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                      errorText:
                          _showValidationErrors && _selectedPeriodId == null
                          ? 'Selecciona un período'
                          : null,
                    ),
                    onTap: _isLoading
                        ? null
                        : () => _pickPeriodMonth(
                            sortedPeriods,
                            firstDate,
                            lastDate,
                          ),
                  );
                },
              ),

              gap16,

              // Dropdown de Choferes
              Text('Chofer', style: textTheme.titleMedium),
              gap8,
              FutureBuilder<List<DriverData>>(
                future: _driversFuture,
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

                  return DropdownMenu<int>(
                    expandedInsets: EdgeInsets.zero,
                    initialSelection: _selectedDriverId,
                    label: const Text('Seleccionar chofer'),
                    errorText:
                        _showValidationErrors && _selectedDriverId == null
                        ? 'Selecciona un chofer'
                        : null,
                    dropdownMenuEntries: drivers
                        .map(
                          (driver) => DropdownMenuEntry<int>(
                            value: driver.id,
                            label: driver.fullName,
                          ),
                        )
                        .toList(),
                    onSelected: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedDriverId = value;
                              _updateValidationStates();
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

  void _initializePeriodController(List<PayrollPeriodData> sortedPeriods) {
    if (_selectedPeriodId != null && _periodController.text.isEmpty) {
      final selected = sortedPeriods.firstWhere(
        (p) => p.id == _selectedPeriodId,
      );
      final locale = Localizations.localeOf(context).toLanguageTag();
      final label = DateFormat.yMMMM(
        locale,
      ).format(DateTime(selected.startDate.year, selected.startDate.month));
      _periodController.text = label[0].toUpperCase() + label.substring(1);
    }
  }

  Future<void> _pickPeriodMonth(
    List<PayrollPeriodData> sortedPeriods,
    DateTime firstDate,
    DateTime lastDate,
  ) async {
    final now = DateTime.now();
    PayrollPeriodData? selectedPeriod;
    if (_selectedPeriodId != null) {
      for (final p in sortedPeriods) {
        if (p.id == _selectedPeriodId) {
          selectedPeriod = p;
          break;
        }
      }
    }

    var initial = selectedPeriod == null
        ? DateTime(now.year, now.month)
        : DateTime(
            selectedPeriod.startDate.year,
            selectedPeriod.startDate.month,
          );

    if (initial.isBefore(firstDate)) {
      initial = firstDate;
    } else if (initial.isAfter(lastDate)) {
      initial = lastDate;
    }

    final picked = await showMonthPicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) return;

    PayrollPeriodData? match;
    for (final p in sortedPeriods) {
      if (p.startDate.year == picked.year &&
          p.startDate.month == picked.month) {
        match = p;
        break;
      }
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = DateFormat.yMMMM(locale).format(picked);

    if (match == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay un período para ese mes')),
        );
      }
      setState(() {
        _selectedPeriodId = null;
        _periodController.clear();
        _updateValidationStates();
      });
    }

    setState(() {
      _selectedPeriodId = match?.id;
      _periodController.text = label[0].toUpperCase() + label.substring(1);
      _updateValidationStates();
    });
  }
}
