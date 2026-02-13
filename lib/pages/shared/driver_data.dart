import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/pages/shared/edit_driver_data.dart';
import 'package:frontend_sgfcp/pages/admin/payroll_data.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/widgets/info_card.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/services/driver_commission_service.dart';
import 'package:frontend_sgfcp/services/driver_guaranteed_minimum_service.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

class DriverDataPage extends StatefulWidget {
  final DriverData initialDriver;

  const DriverDataPage({super.key, required this.initialDriver});

  static const String routeName = '/admin/driver-data';

  static Route route({required DriverData driver}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverDataPage(initialDriver: driver),
    );
  }

  @override
  State<DriverDataPage> createState() => _DriverDataPageState();
}

class _DriverDataPageState extends State<DriverDataPage> {
  late DriverData driver;
  bool _isLoading = false;
  bool _isLoadingPayroll = true;
  double? _currentCommission;
  double? _currentMinimumGuaranteed;

  @override
  void initState() {
    super.initState();
    driver = widget.initialDriver;
    _loadDriverData();
    _loadPayrollData();
  }

  Future<void> _loadDriverData() async {
    setState(() => _isLoading = true);
    try {
      final updatedDriver = await DriverService.getDriverById(
        driverId: driver.id,
      );
      setState(() {
        driver = updatedDriver;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadPayrollData() async {
    setState(() => _isLoadingPayroll = true);
    try {
      final commission = await DriverCommissionService.getDriverCommissionById(
        driverId: driver.id,
      );
      final minimum =
          await DriverGuaranteedMinimumService.getCurrentMinimumGuaranteed(
            driverId: driver.id,
          );

      if (mounted) {
        setState(() {
          _currentCommission = commission['commission_percentage'] is String
              ? double.parse(commission['commission_percentage'])
              : commission['commission_percentage'] as double?;
          _currentMinimumGuaranteed = minimum['minimum_guaranteed'] is String
              ? double.parse(minimum['minimum_guaranteed'])
              : minimum['minimum_guaranteed'] as double?;
          _isLoadingPayroll = false;
        });
      }
    } catch (e) {
      // Silently handle error - payroll data is optional
      if (mounted) {
        setState(() => _isLoadingPayroll = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double infoLabelWidth = 125;
    final bool isAdmin =
        (TokenStorage.user != null && TokenStorage.user!['is_admin'] == true);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Datos del chofer' : 'Datos personales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.of(
                context,
              ).push(EditDriverDataPage.route(driverId: driver.id));
              if (result == true) {
                _loadDriverData();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Datos personales
                InfoCard(
                  title: 'Datos personales',
                  items: [
                    InfoItem(label: 'Nombre(s)', value: driver.firstName),
                    InfoItem(label: 'Apellido(s)', value: driver.lastName),
                    InfoItem(
                      label: 'CUIL',
                      value: driver.cuil ?? 'No registrado', // TODO: Decorator para mostrar CUIL con formato (XX-XXXXXXXX-X)
                    ),
                    InfoItem(
                      label: 'CVU',
                      value: driver.cbu ?? 'No registrado',
                    ),
                    InfoItem(
                      label: 'Número de teléfono',
                      value: driver.phoneNumber ?? 'No registrado', // TODO: Decorator para mostrar número de teléfono con formato (XXXX XX-XXXXX)
                    ),
                  ],
                  labelColumnWidth: infoLabelWidth,
                ),

                gap4,

                // Datos de la nómina
                if (isAdmin)...[
                  InfoCard.footerButton(
                    title: 'Datos de la nómina',
                    items: [
                      InfoItem(
                        label: 'Comisión',
                        value: _isLoadingPayroll
                            ? 'Cargando...'
                            : _currentCommission != null
                            ? '${(_currentCommission! * 100).toStringAsFixed(2)}%'
                            : 'No registrado',
                      ),
                      InfoItem(
                        label: 'Mínimo garantizado',
                        value: _isLoadingPayroll
                            ? 'Cargando...'
                            : _currentMinimumGuaranteed != null
                            ? formatCurrency(_currentMinimumGuaranteed!)
                            : 'No registrado',
                      ),
                    ],
                    buttonIcon: Symbols.edit,
                    buttonLabel: 'Editar datos de nómina',
                    onPressed: () async {
                      await Navigator.of(
                        context,
                      ).push(PayrollDataPage.route(driver: driver));
                      _loadPayrollData();
                    },
                    labelColumnWidth: infoLabelWidth,
                  )
                ] else ...[
                  InfoCard(
                    title: 'Datos de la nómina',
                    items: [
                      InfoItem(
                        label: 'Comisión',
                        value: _isLoadingPayroll
                            ? 'Cargando...'
                            : _currentCommission != null
                            ? '${(_currentCommission! * 100).toStringAsFixed(2)}%'
                            : 'No registrado',
                      ),
                      InfoItem(
                        label: 'Mínimo garantizado',
                        value: _isLoadingPayroll
                            ? 'Cargando...'
                            : _currentMinimumGuaranteed != null
                            ? formatCurrency(_currentMinimumGuaranteed!)
                            : 'No registrado',
                      ),
                    ],
                  ),
                ],


                gap4,

                // Datos de la cuenta
                InfoCard.footerButton(
                  title: 'Datos de la cuenta',
                  items: [
                    InfoItem(
                      label: 'Email',
                      value: driver.email ?? 'No registrado',
                    ),
                    InfoItem(label: 'Contraseña', value: '***********'),
                    InfoItem(
                      label: 'Fecha de alta',
                      value: '23/07/2025',
                    ), //TODO: Cambiar por fecha real
                  ],
                  buttonIcon: Symbols.lock_reset,
                  buttonLabel: 'Reestablecer contraseña',
                  onPressed: () {
                    // TODO: Implementar funcionalidad de reestablecer contraseña y diseñar la UI correspondiente.
                  },
                  labelColumnWidth: infoLabelWidth,
                ),
              ],
            ),
    );
  }
}
