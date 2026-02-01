import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/driver_commission_service.dart';
import 'package:frontend_sgfcp/services/driver_guaranteed_minimum_service.dart';
import 'package:frontend_sgfcp/models/driver_commission_history.dart';
import 'package:frontend_sgfcp/models/minimum_guaranteed_history.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

enum PayrollType { commission, minimumGuaranteed }

class DriverPayrollDataCard extends StatefulWidget {
  final String title;
  final String valueLabel;
  final String startDateLabel;
  final String endDateLabel;
  final int driverId;
  final PayrollType payrollType;
  final List<DriverCommissionHistory>? commissionHistory;
  final List<MinimumGuaranteedHistory>? minimumGuaranteedHistory;
  final VoidCallback? onDataSaved;

  const DriverPayrollDataCard({
    super.key,
    required this.title,
    required this.valueLabel,
    required this.startDateLabel,
    required this.endDateLabel,
    required this.driverId,
    required this.payrollType,
    this.commissionHistory,
    this.minimumGuaranteedHistory,
    this.onDataSaved,
  });

  @override
  State<DriverPayrollDataCard> createState() => _DriverPayrollDataCardState();
}

class _DriverPayrollDataCardState extends State<DriverPayrollDataCard> {
  late TextEditingController _valueController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late WidgetStatesController _endDateStatesController;
  bool _isEditMode = false;
  bool _isCreating = false;
  bool _isSaving = false;
  DateTime? _newStartDate;
  int _currentIndex = 0;

  List<dynamic> get _historyList {
    if (widget.payrollType == PayrollType.commission) {
      return widget.commissionHistory ?? [];
    } else {
      return widget.minimumGuaranteedHistory ?? [];
    }
  }

  dynamic get _currentRecord {
    if (_historyList.isEmpty) return null;
    return _historyList[_currentIndex];
  }

  String get _currentValue {
    if (_currentRecord == null) return '';
    if (widget.payrollType == PayrollType.commission) {
      // Convertir de decimal (0.18) a porcentaje (18) para mostrar
      final percentage =
          (_currentRecord as DriverCommissionHistory).commissionPercentage *
          100;
      return '${percentage.toStringAsFixed(2)}%';
    } else {
      final value =
          (_currentRecord as MinimumGuaranteedHistory).minimumGuaranteed;
      return formatCurrency(value);
    }
  }

  DateTime? get _currentStartDate {
    if (_currentRecord == null) return null;
    if (widget.payrollType == PayrollType.commission) {
      return (_currentRecord as DriverCommissionHistory).effectiveFrom;
    } else {
      return (_currentRecord as MinimumGuaranteedHistory).effectiveFrom;
    }
  }

  DateTime? get _currentEndDate {
    if (_currentRecord == null) return null;
    if (widget.payrollType == PayrollType.commission) {
      return (_currentRecord as DriverCommissionHistory).effectiveUntil;
    } else {
      return (_currentRecord as MinimumGuaranteedHistory).effectiveUntil;
    }
  }

  bool get _canNavigatePrevious => _currentIndex < _historyList.length - 1;
  bool get _canNavigateNext => _currentIndex > 0;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: _currentValue);
    _startDateController = TextEditingController(
      text: formatDate(_currentStartDate),
    );
    _endDateController = TextEditingController(
      text: formatDate(_currentEndDate),
    );
    _endDateStatesController = WidgetStatesController();
    _updateEndDateState();

    // Listen to value changes to update button state
    _valueController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(DriverPayrollDataCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset index if history list changed
    if (_historyList.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= _historyList.length) {
      _currentIndex = _historyList.length - 1;
    }

    _valueController.text = _currentValue;
    _startDateController.text = formatDate(_currentStartDate);
    _endDateController.text = formatDate(_currentEndDate);
    _updateEndDateState();
  }

  void _updateEndDateState() {
    if (!_canNavigateNext) {
      _endDateStatesController.update(WidgetState.disabled, true);
    } else {
      _endDateStatesController.update(WidgetState.disabled, false);
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _endDateStatesController.dispose();
    super.dispose();
  }

  void _navigatePrevious() {
    if (_canNavigatePrevious) {
      setState(() {
        _currentIndex++;
        _isEditMode = false;
        _isCreating = false;
        _isSaving = false;
        _newStartDate = null;
        _valueController.text = _currentValue;
        _startDateController.text = formatDate(_currentStartDate);
        _endDateController.text = formatDate(_currentEndDate);
        _updateEndDateState();
      });
    }
  }

  void _navigateNext() {
    if (_canNavigateNext) {
      setState(() {
        _currentIndex--;
        _isEditMode = false;
        _isCreating = false;
        _isSaving = false;
        _newStartDate = null;
        _valueController.text = _currentValue;
        _startDateController.text = formatDate(_currentStartDate);
        _endDateController.text = formatDate(_currentEndDate);
        _updateEndDateState();
      });
    }
  }

  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
      // Al editar, mantenemos _isCreating = false para actualizar el registro existente
      _isCreating = false;
      // Mantener el valor actual en el campo para que el usuario lo vea
      _valueController.text = _currentValue;
      // Las fechas permanecen bloqueadas y muestran los valores actuales
      _startDateController.text = formatDate(_currentStartDate);
      _endDateController.text = formatDate(_currentEndDate);
    });
  }

  void _enterCreateMode() {
    setState(() {
      _isEditMode = true;
      // Al crear, establecemos _isCreating = true
      _isCreating = true;
      // Limpiar el campo de valor
      _valueController.clear();
      // Para ambos tipos, la fecha se calculará automáticamente
      _startDateController.text = '(se calculará automáticamente)';
      _endDateController.text = '-';
      _newStartDate = null;
    });
  }

  void _handleCancel() {
    setState(() {
      _valueController.text = _currentValue;
      _startDateController.text = formatDate(_currentStartDate);
      _isEditMode = false;
      _isCreating = false;
      _newStartDate = null;
    });
  }

  Future<void> _handleStartDateTap() async {
    if (!_isEditMode) return;

    final now = DateTime.now();
    final firstAvailableDate =
        _currentStartDate?.add(const Duration(days: 1)) ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: now.isAfter(firstAvailableDate) ? now : firstAvailableDate,
      firstDate: firstAvailableDate,
      lastDate: DateTime(now.year + 5),
      helpText: 'Elegir fecha de inicio',
    );

    if (picked != null) {
      setState(() {
        _newStartDate = picked;
        _startDateController.text = formatDate(picked);
      });
    }
  }

  Future<void> _createEntry(double value) async {
    if (widget.payrollType == PayrollType.commission) {
      // Para comisiones, el backend calculará automáticamente effective_from
      // basándose en la comisión anterior del chofer
      await DriverCommissionService.createDriverCommission(
        driverId: widget.driverId,
        commissionPercentage: value,
        effectiveFrom: _newStartDate, // Puede ser null, el backend lo manejará
      );
    } else {
      // Para mínimo garantizado, también el backend calcula automáticamente
      await DriverGuaranteedMinimumService.createDriverGuaranteedMinimum(
        driverId: widget.driverId,
        amount: value,
        startDate: _newStartDate, // Puede ser null, el backend lo manejará
      );
    }
  }

  Future<void> _updateEntry(double value) async {
    if (widget.payrollType == PayrollType.commission) {
      final commissionId = (_currentRecord as DriverCommissionHistory).id;
      await DriverCommissionService.updateDriverCommission(
        driverId: widget.driverId,
        commissionId: commissionId,
        commissionPercentage: value,
      );
    } else {
      final minimumId = (_currentRecord as MinimumGuaranteedHistory).id;
      await DriverGuaranteedMinimumService.updateDriverGuaranteedMinimum(
        minimumId: minimumId,
        amount: value,
      );
    }
  }

  Future<void> _handleSave() async {
    final valueText = _valueController.text.trim();
    if (valueText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingrese un valor'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    final isCreating = _isCreating;

    try {
      double value;

      if (widget.payrollType == PayrollType.commission) {
        // Parse commission percentage (remove '%' if present)
        final percentageText = valueText
            .replaceAll('%', '')
            .replaceAll(',', '.');
        final percentageValue = double.parse(percentageText);
        // Convertir de porcentaje (18) a decimal (0.18) para enviar al backend
        value = percentageValue / 100;
      } else {
        // Parse minimum guaranteed amount
        value = parseCurrency(valueText);
      }

      if (isCreating) {
        await _createEntry(value);
      } else {
        await _updateEntry(value);
      }

      if (mounted) {
        final actionText = isCreating ? 'creado' : 'actualizado';
        final message = widget.payrollType == PayrollType.commission
            ? 'Comisión $actionText exitosamente'
            : 'Salario mínimo $actionText exitosamente';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      }

      // Notify parent to reload data
      widget.onDataSaved?.call();

      // Exit edit mode and reset state
      setState(() {
        _isEditMode = false;
        _isCreating = false;
        _newStartDate = null;
        _isSaving = false;
      });
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Show message when history is empty
    if (_historyList.isEmpty) {
      return Card.outlined(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: textTheme.titleMedium),
              gap12,
              Center(
                child: Text(
                  'No hay historial disponible',
                  style: textTheme.bodyMedium?.copyWith(color: colors.outline),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: textTheme.titleMedium),
                Row(
                  children: [
                    // Add button - only show when NOT in edit mode and showing current record
                    if (!_isEditMode && _currentIndex == 0)
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _enterCreateMode,
                        tooltip: 'Crear nuevo registro',
                      ),
                    // Edit button - only show when NOT in edit mode
                    if (!_isEditMode)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: _enterEditMode,
                        tooltip: 'Editar registro actual',
                      ),
                    // Cancel button - only show when in edit mode
                    if (_isEditMode)
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: colors.error,
                        onPressed: _handleCancel,
                      ),
                    // Save button - only show when in edit mode
                    if (_isEditMode)
                      IconButton(
                        icon: _isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        color: colors.primary,
                        onPressed:
                            (_isSaving || _valueController.text.trim().isEmpty)
                            ? null
                            : _handleSave,
                      ),
                  ],
                ),
              ],
            ),
            gap12,
            // Value row with navigation buttons
            Row(
              children: [
                // Previous button
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _canNavigatePrevious ? _navigatePrevious : null,
                  color: _canNavigatePrevious
                      ? colors.secondary
                      : colors.outline,
                ),
                // Value field
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    readOnly: !_isEditMode,
                    decoration: InputDecoration(
                      labelText: widget.valueLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                // Next button
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _canNavigateNext ? _navigateNext : null,
                  color: _canNavigateNext ? colors.secondary : colors.outline,
                ),
              ],
            ),
            gap12,
            // Date fields row
            Row(
              children: [
                // Start date field
                Expanded(
                  child: TextField(
                    controller: _startDateController,
                    readOnly: true,
                    enabled:
                        !_isEditMode, // Deshabilitar en modo edición para que se vea claramente que no es editable
                    decoration: InputDecoration(
                      labelText: widget.startDateLabel,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                gapW12,
                // End date field
                Expanded(
                  child: TextField(
                    controller: _endDateController,
                    readOnly: true,
                    enabled: _canNavigateNext,
                    statesController: _endDateStatesController,
                    decoration: InputDecoration(
                      labelText: widget.endDateLabel,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
