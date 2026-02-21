import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/admin/create_other_item.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/other_item_row_data.dart';
import 'package:frontend_sgfcp/models/other_items_type.dart';
import 'package:frontend_sgfcp/widgets/other_items_list.dart';
import 'package:frontend_sgfcp/services/payroll_other_item_service.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/widgets/month_picker.dart';
import 'package:intl/intl.dart';

class OtherItemsPage extends StatefulWidget {
  const OtherItemsPage({super.key});

  static const String routeName = '/admin/other-items';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const OtherItemsPage());
  }

  @override
  State<OtherItemsPage> createState() => _OtherItemsPageState();
}

class _OtherItemsPageState extends State<OtherItemsPage> {
  List<OtherItemRowData> _rows = [];
  List<String> _allDriverNames = [];
  bool _isLoading = true;
  final Set<String> _selectedDrivers = {};
  final Set<OtherItemsType> _selectedItemTypes = {};
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadOtherItems();
  }

  Future<void> _loadOtherItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch drivers first to get names
      final drivers = await DriverService.getDrivers();
      final driverMap = {
        for (var driver in drivers) driver.id: driver.fullName
      };
      
      // Store all driver names for filter
      _allDriverNames = drivers.map((d) => d.fullName).toList()..sort();

      final response = await PayrollOtherItemService.getAllOtherItems(
        page: 1,
        perPage: 1000, // Load all items for now
      );

      final items = response['items'] as List<dynamic>;

      setState(() {
        _rows = items.map((item) {
          // Parse item type
          final itemTypeString = item['item_type'] as String;
          final itemType = OtherItemsTypeExtension.fromBackendString(itemTypeString);

          // Parse driver name from driver_id
          final driverId = item['driver_id'] as int?;
          final driverName = driverId != null ? (driverMap[driverId] ?? 'N/A') : 'N/A';

          // Parse amount
          final amount = item['amount'] is String
              ? double.parse(item['amount'])
              : (item['amount'] as num).toDouble();

          // Parse date
          final createdAt = item['created_at'] != null
              ? DateTime.parse(item['created_at'])
              : DateTime.now();

          // Parse period info if available
          int? periodMonth;
          int? periodYear;
          if (item['period_start_date'] != null) {
            final periodDate = DateTime.parse(item['period_start_date']);
            periodMonth = periodDate.month;
            periodYear = periodDate.year;
          }

          return OtherItemRowData(
            itemId: item['id'] as int,
            itemType: itemType,
            driver: driverName,
            amount: amount,
            description: item['description'] as String? ?? '',
            date: createdAt,
            periodMonth: periodMonth,
            periodYear: periodYear,
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
          SnackBar(content: Text('Error al cargar conceptos: $e')),
        );
      }
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
        title: const Text('Otros conceptos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Primary action
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Symbols.request_quote),
                    label: const Text('Cargar otros conceptos'),
                    onPressed: () async {
                      final result = await Navigator.of(
                        context,
                      ).push(CreateOtherItemPage.route());
                      // If an item was created successfully, refresh the list
                      if (result == true && mounted) {
                        _loadOtherItems();
                      }
                    },
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
                        fixedSize: const Size.fromHeight(36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openItemTypeFilterDialog,
                      icon: const Icon(Symbols.category, size: 16),
                      label: Text(
                        _selectedItemTypes.isEmpty
                            ? 'Tipo'
                            : 'Tipo (${_selectedItemTypes.length})',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      style: OutlinedButton.styleFrom(
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
                                _selectedItemTypes.clear();
                                _selectedMonth = null;
                              });
                            }
                          : null,
                      style: TextButton.styleFrom(
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

                // Other items list (header + rows)
                OtherItemsList(
                  rows: filteredRows,
                  onItemChanged: _loadOtherItems,
                ),
              ],
            ),
    );
  }

  List<OtherItemRowData> _applyFilters() {
    return _rows.where((row) {
      if (_selectedDrivers.isNotEmpty &&
          !_selectedDrivers.contains(row.driver)) {
        return false;
      }
      if (_selectedItemTypes.isNotEmpty &&
          !_selectedItemTypes.contains(row.itemType)) {
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
      _selectedItemTypes.isNotEmpty ||
      _selectedMonth != null;

  Future<void> _openDriverFilterDialog() async {
    // Use all drivers from the system, not just those with items
    final options = _allDriverNames;
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

  Future<void> _openItemTypeFilterDialog() async {
    final options = OtherItemsType.values;
    final temp = {..._selectedItemTypes};
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return AlertDialog(
              title: const Text('Filtrar por tipo de concepto'),
              content: SizedBox(
                width: 360,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final t in options)
                      CheckboxListTile(
                        value: temp.contains(t),
                        onChanged: (v) {
                          setLocalState(() {
                            if (v == true) {
                              temp.add(t);
                            } else {
                              temp.remove(t);
                            }
                          });
                        },
                        title: Text(t.label),
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
                      () => _selectedItemTypes
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
