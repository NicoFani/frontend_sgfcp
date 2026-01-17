import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/services/advance_payment_service.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/widgets/month_selector_header.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/driver_detail.dart';
import 'package:frontend_sgfcp/pages/admin/add_advance_payment.dart';
import 'package:frontend_sgfcp/pages/admin/edit_advance_payment.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/advance_payment_data.dart';
import 'package:frontend_sgfcp/widgets/drivers_list.dart' as dl;

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
  DateTime _selectedMonth = DateTime.now();
  late Future<List<DriverData>> _driversFuture;
  late Future<List<AdvancePaymentData>> _advancesFuture;

  @override
  void initState() {
    super.initState();
    _driversFuture = DriverService.getDrivers();
    _advancesFuture = AdvancePaymentService.getAdvancePayments();
  }

  List<AdvancePaymentData> _filterAdvancesByDateRange(
    List<AdvancePaymentData> advances,
  ) {
    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );

    return advances.where((advance) {
      return !advance.date.isBefore(startOfMonth) &&
          !advance.date.isAfter(endOfMonth);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                          _driversFuture = DriverService.getDrivers();
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
                          _advancesFuture =
                              AdvancePaymentService.getAdvancePayments();
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

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      dl.DriversList(
                        drivers: drivers,
                        onDriverTap: (driverId) {
                          final driver = drivers.firstWhere(
                            (d) => d.id == driverId,
                          );
                          Navigator.of(context).push(
                            DriverDetailPageAdmin.route(
                              driverId: driver.id,
                              driverName: driver.fullName,
                            ),
                          );
                        },
                      ),

                    gap24,

                    // Sección Adelantos
                    Text('Adelantos', style: textTheme.titleLarge),

                    gap12,

                    // Botón Cargar adelanto
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).push(AddAdvancePaymentPage.route());
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: const Icon(Symbols.mintmark),
                      label: const Text('Cargar adelanto'),
                    ),

                    gap16,

                    // Selector de mes
                    MonthSelectorHeader(
                      initialMonth: _selectedMonth,
                      onMonthChanged: (newMonth) {
                        setState(() {
                          _selectedMonth = newMonth;
                          //TODO: filtrar adelantos por mes seleccionado
                        });
                      },
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
                      _AdvancePaymentsList(
                        advancePayments: filteredAdvances,
                        drivers: drivers,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AdvancePaymentsList extends StatelessWidget {
  final List<AdvancePaymentData> advancePayments;
  final List<DriverData> drivers;

  const _AdvancePaymentsList({
    required this.advancePayments,
    required this.drivers,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          for (int i = 0; i < advancePayments.length; i++) ...[
            Builder(
              builder: (context) {
                final advance = advancePayments[i];
                final driver = drivers.firstWhere(
                  (d) => d.id == advance.driverId,
                  orElse: () => DriverData(
                    id: -1,
                    firstName: 'Chofer',
                    lastName: 'desconocido',
                  ),
                );

                final driverName = '${driver.firstName} ${driver.lastName}';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormatter.format(advance.date),
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(driverName, style: textTheme.bodyMedium),
                    ],
                  ),
                  subtitle: Text(
                    currencyFormat.format(advance.amount),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    if (driver.id != -1) {
                      Navigator.of(context).push(
                        EditAdvancePaymentPage.route(
                          advancePaymentId: advance.id,
                          driverId: advance.driverId,
                          driverName: driverName,
                          date: advance.date,
                          amount: advance.amount,
                        ),
                      );
                    }
                  },
                );
              },
            ),
            if (i < advancePayments.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
