import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/advance_payment_data.dart';
import 'package:frontend_sgfcp/services/advance_payment_service.dart';
import 'package:frontend_sgfcp/widgets/month_selector_header.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:intl/intl.dart';

class DriverAdvancePaymentsPage extends StatefulWidget {
  final DriverData driver;

  const DriverAdvancePaymentsPage({super.key, required this.driver});

  static const String routeName = '/driver/advance-payments';

  static Route route({required DriverData driver}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverAdvancePaymentsPage(driver: driver),
    );
  }

  @override
  State<DriverAdvancePaymentsPage> createState() =>
      _DriverAdvancePaymentsPageState();
}

class _DriverAdvancePaymentsPageState extends State<DriverAdvancePaymentsPage> {
  late Future<List<AdvancePaymentData>> _advancePaymentsFuture;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAdvancePayments();
  }

  void _loadAdvancePayments() {
    _advancePaymentsFuture =
        AdvancePaymentService.getAdvancePaymentsByDriver(
          driverId: widget.driver.id,
        );
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

    final filtered = advances.where((advance) {
      return !advance.date.isBefore(startOfMonth) &&
          !advance.date.isAfter(endOfMonth);
    }).toList();

    // Mostrar más recientes primero
    filtered.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return b.id.compareTo(a.id);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Adelantos')),
      body: FutureBuilder<List<AdvancePaymentData>>(
        future: _advancePaymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  gap8,
                  Text('Error al cargar adelantos'),
                  gap8,
                  Text(snapshot.error.toString()),
                  gap16,
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadAdvancePayments();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final allAdvances = snapshot.data ?? [];
          final filteredAdvances = _filterAdvancesByDateRange(allAdvances);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de mes
                  MonthSelectorHeader(
                    initialMonth: _selectedMonth,
                    onMonthChanged: (newMonth) {
                      setState(() {
                        _selectedMonth = newMonth;
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
                          'No hay adelantos este mes',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    _AdvancePaymentsList(
                      advancePayments: filteredAdvances,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdvancePaymentsList extends StatelessWidget {
  final List<AdvancePaymentData> advancePayments;

  const _AdvancePaymentsList({
    required this.advancePayments,
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                currencyFormat.format(advancePayments[i].amount),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                dateFormatter.format(advancePayments[i].date),
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            if (i < advancePayments.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
