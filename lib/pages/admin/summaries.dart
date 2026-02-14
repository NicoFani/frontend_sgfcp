import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/admin/create_summary.dart';
import 'package:frontend_sgfcp/pages/admin/other_items.dart';
import 'package:frontend_sgfcp/pages/admin/summaries_settings.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/summary_data.dart';
import 'package:frontend_sgfcp/models/summary_row_data.dart';
import 'package:frontend_sgfcp/widgets/summary_list.dart';
import 'package:frontend_sgfcp/services/payroll_summary_service.dart';
import 'package:frontend_sgfcp/widgets/month_picker.dart';
import 'package:intl/intl.dart';

class SummariesPageAdmin extends StatefulWidget {
  const SummariesPageAdmin({super.key});

  static const String routeName = '/admin/summaries';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SummariesPageAdmin());
  }

  @override
  State<SummariesPageAdmin> createState() => _SummariesPageAdminState();
}

// Row data moved to models/summary_row_data.dart

class _SummariesPageAdminState extends State<SummariesPageAdmin> {
  List<SummaryRowData> _rows = [];
  bool _isLoading = true;
  final Set<String> _selectedDrivers = {};
  final Set<SummaryStatus> _selectedStatuses = {};
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final summaries = await PayrollSummaryService.getAllSummaries();

      setState(() {
        _rows = summaries.map((summary) {
          // Formatear periodo
          String period = 'N/A';
          if (summary.periodYear != null && summary.periodMonth != null) {
            final date = DateTime(summary.periodYear!, summary.periodMonth!);
            period = DateFormat.yMMMM('es').format(date);
            period = period[0].toUpperCase() + period.substring(1);
          }

          return SummaryRowData(
            summaryId: summary.id,
            id: summary.id.toString().padLeft(4, '0'),
            driver: summary.driverName ?? 'N/A',
            period: period,
            date: summary.createdAt ?? DateTime.now(),
            periodMonth: summary.periodMonth,
            periodYear: summary.periodYear,
            status: _getStatusFromString(summary.status),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar resúmenes: $e')),
        );
      }
    }
  }

  SummaryStatus _getStatusFromString(String status) {
    switch (status) {
      case 'approved':
        return SummaryStatus.approved;
      case 'pending_approval':
        return SummaryStatus.pendingApproval;
      case 'error':
        return SummaryStatus.calculationError;
      case 'draft':
        return SummaryStatus.draft;
      case 'calculation_pending':
        return SummaryStatus.calculationPending;
      default:
        return SummaryStatus.draft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = _selectedMonth == null
        ? 'Mes'
        : _capitalize(DateFormat.yMMMM(locale).format(_selectedMonth!));

    final filteredRows = _applyFilters();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resúmenes'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.settings),
            onPressed: () {
              Navigator.of(context).push(SummariesSettingsPageAdmin.route());
            },
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Primary actions
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Symbols.receipt_long),
                    label: const Text('Generar resumen'),
                    onPressed: () async {
                      final result = await Navigator.of(
                        context,
                      ).push(GenerateSummary.route());
                      // Si se creó un resumen exitosamente, refrescar la lista
                      if (result == true && mounted) {
                        _loadSummaries();
                      }
                    },
                  ),
                ),
                gap8,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Symbols.request_quote),
                    label: const Text('Cargar otros conceptos'),
                    onPressed: () =>
                        Navigator.of(context).push(OtherItemsPage.route()),
                  ),
                ),

                gap24,

                // Filters
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _openDriverFilterDialog,
                      icon: const Icon(Symbols.group, size: 16),
                      label: Text(
                        _selectedDrivers.isEmpty
                            ? 'Choferes'
                            : 'Choferes (${_selectedDrivers.length})',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      style: OutlinedButton.styleFrom(
                        // Hug content horizontally; keep compact height
                        fixedSize: const Size.fromHeight(36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openStatusFilterDialog,
                      icon: const Icon(Symbols.filter_alt, size: 16),
                      label: Text(
                        _selectedStatuses.isEmpty
                            ? 'Estado'
                            : 'Estado (${_selectedStatuses.length})',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      style: OutlinedButton.styleFrom(
                        // Hug content horizontally; keep compact height
                        fixedSize: const Size.fromHeight(36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickMonth,
                      icon: const Icon(Icons.calendar_today_outlined, size: 16),
                      label: Text(
                        monthLabel,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      style: OutlinedButton.styleFrom(
                        // Hug content horizontally; keep compact height
                        fixedSize: const Size.fromHeight(36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    TextButton(
                      onPressed: _hasAnyFilter
                          ? () {
                              setState(() {
                                _selectedDrivers.clear();
                                _selectedStatuses.clear();
                                _selectedMonth = null;
                              });
                            }
                          : null,
                      style: TextButton.styleFrom(
                        // Hug content horizontally; keep compact height
                        fixedSize: const Size.fromHeight(36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(
                        Icons.filter_alt_off_outlined,
                        size: 16,
                      ),
                    ),
                  ],
                ),

                gap12,

                // Summary list (header + rows)
                SummaryList(
                  rows: filteredRows,
                  onSummaryChanged: _loadSummaries,
                ),
              ],
            ),
    );
  }

  List<SummaryRowData> _applyFilters() {
    return _rows.where((row) {
      if (_selectedDrivers.isNotEmpty &&
          !_selectedDrivers.contains(row.driver)) {
        return false;
      }
      if (_selectedStatuses.isNotEmpty &&
          !_selectedStatuses.contains(row.status)) {
        return false;
      }
      if (_selectedMonth != null) {
        final rowYear = row.periodYear ?? row.date.year;
        final rowMonth = row.periodMonth ?? row.date.month;
        if (!(_selectedMonth!.year == rowYear &&
            _selectedMonth!.month == rowMonth)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  bool get _hasAnyFilter =>
      _selectedDrivers.isNotEmpty ||
      _selectedStatuses.isNotEmpty ||
      _selectedMonth != null;

  Future<void> _openDriverFilterDialog() async {
    final options = _rows.map((e) => e.driver).toSet().toList()..sort();
    final temp = {..._selectedDrivers};
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return AlertDialog(
              title: const Text('Filtrar por chofer'),
              content: SizedBox(
                width: 360,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final d in options)
                      CheckboxListTile(
                        value: temp.contains(d),
                        onChanged: (v) {
                          setLocalState(() {
                            if (v == true) {
                              temp.add(d);
                            } else {
                              temp.remove(d);
                            }
                          });
                        },
                        title: Text(d),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(
                      () => _selectedDrivers
                        ..clear()
                        ..addAll(temp),
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openStatusFilterDialog() async {
    final options = SummaryStatus.values;
    final temp = {..._selectedStatuses};
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final colors = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return AlertDialog(
              title: const Text('Filtrar por estado'),
              content: SizedBox(
                width: 360,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final s in options)
                      CheckboxListTile(
                        value: temp.contains(s),
                        onChanged: (v) {
                          setLocalState(() {
                            if (v == true) {
                              temp.add(s);
                            } else {
                              temp.remove(s);
                            }
                          });
                        },
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(s.icon, color: s.color(colors), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.label,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(
                      () => _selectedStatuses
                        ..clear()
                        ..addAll(temp),
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final initial = _selectedMonth ?? DateTime(now.year, now.month);
    final picked = await showMonthPicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
