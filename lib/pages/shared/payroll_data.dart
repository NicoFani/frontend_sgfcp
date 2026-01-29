import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/driver_commission_history.dart';
import 'package:frontend_sgfcp/models/minimum_guaranteed_history.dart';
import 'package:frontend_sgfcp/services/driver_commission_service.dart';
import 'package:frontend_sgfcp/services/driver_guaranteed_minimum_service.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/widgets/driver_payroll_data_card.dart';
import 'package:material_symbols_icons/symbols.dart';

class PayrollDataPage extends StatefulWidget {
  final DriverData driver;

  const PayrollDataPage({super.key, required this.driver});

  static const String routeName = '/admin/payroll-data';

  static Route route({required DriverData driver}) {
    return MaterialPageRoute<void>(
      builder: (_) => PayrollDataPage(driver: driver),
    );
  }

  @override
  State<PayrollDataPage> createState() => _PayrollDataPageState();
}

class _PayrollDataPageState extends State<PayrollDataPage> {
  late DriverData driver;
  bool _isLoading = false;
  List<DriverCommissionHistory> commissionHistory = [];
  List<MinimumGuaranteedHistory> minimumGuaranteedHistory = [];
  int _commissionIndex = 0;
  int _minimumIndex = 0;

  @override
  void initState() {
    super.initState();
    driver = widget.driver;
    _loadPayrollData();
  }

  Future<void> _loadPayrollData() async {
    setState(() => _isLoading = true);
    try {
      final commissionsData =
          await DriverCommissionService.getDriverCommissions(
        driverId: driver.id,
      );
      final minimumsData =
          await DriverGuaranteedMinimumService.getDriverGuaranteedMinimums(
        driverId: driver.id,
      );

      setState(() {
        commissionHistory = commissionsData
            .map((json) => DriverCommissionHistory.fromJson(json))
            .toList();
        minimumGuaranteedHistory = minimumsData
            .map((json) => MinimumGuaranteedHistory.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos de nómina: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos de nómina'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : commissionHistory.isEmpty && minimumGuaranteedHistory.isEmpty
              ? const Center(
                  child: Text('No hay datos de nómina disponibles'),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Commission History Card
                    if (commissionHistory.isNotEmpty)
                      DriverPayrollDataCard(
                        title: 'Comisión por viajes',
                        valueLabel: 'Comisión',
                        valueText:
                            '${commissionHistory[_commissionIndex].commissionPercentage}',
                        startDateLabel: 'Fecha de inicio',
                        startDate:
                            commissionHistory[_commissionIndex].effectiveFrom,
                        endDateLabel: 'Fecha de fin',
                        endDate: commissionHistory[_commissionIndex]
                            .effectiveUntil,
                        canNavigatePrevious: _commissionIndex > 0,
                        canNavigateNext:
                            _commissionIndex < commissionHistory.length - 1,
                        onPreviousPressed: () {
                          setState(() => _commissionIndex--);
                        },
                        onNextPressed: () {
                          setState(() => _commissionIndex++);
                        },
                        driverId: driver.id,
                        payrollType: PayrollType.commission,
                        onDataSaved: _loadPayrollData,
                      ),

                    gap4,

                    // Minimum Guaranteed History Card
                    if (minimumGuaranteedHistory.isNotEmpty)
                      DriverPayrollDataCard(
                        title: 'Salario mínimo garantizado',
                        valueLabel: 'Importe',
                        valueText:
                            '\$ ${minimumGuaranteedHistory[_minimumIndex].minimumGuaranteed.toStringAsFixed(2).replaceAll('.', ',')}',
                        startDateLabel: 'Fecha de inicio',
                        startDate: minimumGuaranteedHistory[_minimumIndex]
                            .effectiveFrom,
                        endDateLabel: 'Fecha de fin',
                        endDate:
                            minimumGuaranteedHistory[_minimumIndex]
                                .effectiveUntil,
                        canNavigatePrevious: _minimumIndex > 0,
                        canNavigateNext:
                            _minimumIndex < minimumGuaranteedHistory.length - 1,
                        onPreviousPressed: () {
                          setState(() => _minimumIndex--);
                        },
                        onNextPressed: () {
                          setState(() => _minimumIndex++);
                        },
                        driverId: driver.id,
                        payrollType: PayrollType.minimumGuaranteed,
                        onDataSaved: _loadPayrollData,
                      ),
                  ],
                ),
    );
  }
}
