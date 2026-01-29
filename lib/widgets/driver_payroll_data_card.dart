import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/services/driver_commission_service.dart';
import 'package:frontend_sgfcp/services/driver_guaranteed_minimum_service.dart';

enum PayrollType { commission, minimumGuaranteed }

class DriverPayrollDataCard extends StatefulWidget {
  final String title;
  final String valueLabel;
  final String valueText;
  final String startDateLabel;
  final DateTime? startDate;
  final String endDateLabel;
  final DateTime? endDate;
  final bool canNavigatePrevious;
  final bool canNavigateNext;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;
  final int driverId;
  final PayrollType payrollType;
  final VoidCallback? onDataSaved;

  const DriverPayrollDataCard({
    super.key,
    required this.title,
    required this.valueLabel,
    required this.valueText,
    required this.startDateLabel,
    this.startDate,
    required this.endDateLabel,
    this.endDate,
    this.canNavigatePrevious = true,
    this.canNavigateNext = true,
    this.onPreviousPressed,
    this.onNextPressed,
    required this.driverId,
    required this.payrollType,
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

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.valueText);
    _startDateController = TextEditingController(text: _formatDate(widget.startDate));
    _endDateController = TextEditingController(text: _formatDate(widget.endDate));
    _endDateStatesController = WidgetStatesController();
    _updateEndDateState();
  }

  @override
  void didUpdateWidget(DriverPayrollDataCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueText != widget.valueText) {
      _valueController.text = widget.valueText;
    }
    if (oldWidget.startDate != widget.startDate) {
      _startDateController.text = _formatDate(widget.startDate);
    }
    if (oldWidget.endDate != widget.endDate) {
      _endDateController.text = _formatDate(widget.endDate);
    }
    if (oldWidget.canNavigateNext != widget.canNavigateNext) {
      _updateEndDateState();
    }
  }

  void _updateEndDateState() {
    if (!widget.canNavigateNext) {
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

  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }

  void _exitEditMode() {
    setState(() {
      _isEditMode = false;
    });
  }

  void _handleCancel() {
    setState(() {
      _valueController.text = widget.valueText;
      _startDateController.text = _formatDate(widget.startDate);
      _isEditMode = false;
      _isCreating = false;
      _newStartDate = null;
    });
  }

  Future<void> _handleStartDateTap() async {
    if (!_isEditMode) return;

    final now = DateTime.now();
    final firstAvailableDate = widget.startDate?.add(const Duration(days: 1)) ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstAvailableDate,
      lastDate: DateTime(now.year + 5),
      helpText: 'Elegir fecha de inicio',
    );

    if (picked != null) {
      setState(() {
        _newStartDate = picked;
        _startDateController.text = _formatDate(picked);
        _isCreating = true;
        _valueController.clear();
      });
    }
  }

  void _handleSave() {
    // TODO: Implement API call logic here
    _exitEditMode();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                Text(
                  widget.title,
                  style: textTheme.titleMedium,
                ),
                Row(
                  children: [
                    // Edit button - only show when NOT in edit mode
                    if (!_isEditMode)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: _enterEditMode,
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
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check),
                        color: colors.primary,
                        onPressed: _isSaving ? null : _handleSave,
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
                onPressed: widget.canNavigatePrevious ? widget.onPreviousPressed : null,
                color: widget.canNavigatePrevious ? colors.secondary : colors.outline,
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
                onPressed: widget.canNavigateNext ? widget.onNextPressed : null,
                color: widget.canNavigateNext ? colors.secondary : colors.outline,
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
                  readOnly: !_isEditMode,
                  onTap: _handleStartDateTap,
                  decoration: InputDecoration(
                    labelText: widget.startDateLabel,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today)
                  ),
                ),
              ),
              gapW12,
              // End date field
              Expanded(
                child: TextField(
                  controller: _endDateController,
                  readOnly: true,
                  enabled: widget.canNavigateNext,
                  statesController: _endDateStatesController,
                  decoration: InputDecoration(
                    labelText: widget.endDateLabel,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today)
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
