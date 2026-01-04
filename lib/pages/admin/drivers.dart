import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/driver_detail.dart';
import 'package:frontend_sgfcp/pages/admin/load_advance.dart';
import 'package:frontend_sgfcp/pages/admin/edit_advance.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/services/api_service.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/advance_payment_data.dart';

class DriversPageAdmin extends StatefulWidget {
  const DriversPageAdmin({super.key});

  static const String routeName = '/admin/drivers';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const DriversPageAdmin());
  }

  @override
  State<DriversPageAdmin> createState() => _DriversPageAdminState();
}

class _DriversPageAdminState extends State<DriversPageAdmin> {
  late Future<List<DriverData>> _driversFuture;
  late Future<List<AdvancePaymentData>> _advancesFuture;
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _driversFuture = ApiService.getDrivers();
    _advancesFuture = ApiService.getAdvancePayments();
  }

  List<AdvancePaymentData> _filterAdvancesByDateRange(
    List<AdvancePaymentData> advances,
  ) {
    return advances.where((advance) {
      return advance.date.isAfter(
            _selectedDateRange.start.subtract(const Duration(days: 1)),
          ) &&
          advance.date.isBefore(
            _selectedDateRange.end.add(const Duration(days: 1)),
          );
    }).toList();
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormatter = DateFormat('dd/MM/yyyy', 'es_ES');
    final selectedRangeText =
        '${dateFormatter.format(_selectedDateRange.start)} - ${dateFormatter.format(_selectedDateRange.end)}';

    return FutureBuilder<List<DriverData>>(
      future: _driversFuture,
      builder: (context, driversSnapshot) {
        return FutureBuilder<List<AdvancePaymentData>>(
          future: _advancesFuture,
          builder: (context, advancesSnapshot) {
            if (driversSnapshot.connectionState == ConnectionState.waiting ||
                advancesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (driversSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${driversSnapshot.error}'),
                    gap16,
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _driversFuture = ApiService.getDrivers();
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (advancesSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${advancesSnapshot.error}'),
                    gap16,
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _advancesFuture = ApiService.getAdvancePayments();
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final drivers = driversSnapshot.data ?? [];
            final allAdvances = advancesSnapshot.data ?? [];
            final filteredAdvances = _filterAdvancesByDateRange(allAdvances);

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Lista de choferes
                      if (drivers.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No hay choferes cargados',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        ...drivers.map(
                          (driver) => _DriverListItem(
                            driver: driver,
                            onTap: () {
                              Navigator.of(context).push(
                                DriverDetailPageAdmin.route(
                                  driverId: driver.id,
                                  driverName:
                                      '${driver.firstName} ${driver.lastName}',
                                ),
                              );
                            },
                          ),
                        ),

                      gap24,

                      // Sección Adelantos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Adelantos', style: textTheme.titleLarge),
                        ],
                      ),

                      gap12,

                      // Botón Cargar adelanto
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).push(LoadAdvancePageAdmin.route());
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Symbols.payments),
                        label: const Text('Cargar adelanto'),
                      ),

                      gap16,

                      // Selector de rango de fechas
                      Row(
                        children: [
                          Text(selectedRangeText, style: textTheme.bodyMedium),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () {
                              _showDateRangePicker(context);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.secondaryContainer,
                              foregroundColor: colors.onSecondaryContainer,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Symbols.calendar_today, size: 18),
                            label: const Text('Elegir período'),
                          ),
                        ],
                      ),

                      gap16,

                      // Lista de adelantos
                      if (filteredAdvances.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No hay adelantos en este período',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        ...filteredAdvances.map((advance) {
                          final driver = drivers.firstWhere(
                            (d) => d.id == advance.driverId,
                            orElse: () => DriverData(
                              id: -1,
                              firstName: 'Chofer',
                              lastName: 'desconocido',
                            ),
                          );

                          return _AdvanceListItem(
                            advance: advance,
                            driverName:
                                '${driver.firstName} ${driver.lastName}',
                            onTap: () {
                              Navigator.of(context).push(
                                EditAdvancePageAdmin.route(
                                  advancePaymentId: advance.id,
                                  driverId: advance.driverId,
                                  driverName:
                                      '${driver.firstName} ${driver.lastName}',
                                  date: advance.date,
                                  amount: advance.amount,
                                ),
                              );
                            },
                          );
                        }),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Item de chofer en la lista
class _DriverListItem extends StatelessWidget {
  final DriverData driver;
  final VoidCallback onTap;

  const _DriverListItem({required this.driver, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Mostrar estado como activo por defecto (sin estado en el modelo actual)
    const isActive = true;

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isActive
              ? colors.secondaryContainer
              : colors.surfaceContainerHighest,
          child: Icon(
            Symbols.local_shipping,
            color: isActive
                ? colors.onSecondaryContainer
                : colors.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              isActive ? 'Activo' : 'Inactivo',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${driver.firstName} ${driver.lastName}',
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}

/// Item de adelanto en la lista
class _AdvanceListItem extends StatelessWidget {
  final AdvancePaymentData advance;
  final String driverName;
  final VoidCallback onTap;

  const _AdvanceListItem({
    required this.advance,
    required this.driverName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
      locale: 'es_AR',
    );
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(
              dateFormatter.format(advance.date),
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gap4,
            Text(driverName, style: textTheme.bodyMedium),
            gap4,
            Text(
              currencyFormat.format(advance.amount),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
