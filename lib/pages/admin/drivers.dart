import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/driver_detail.dart';
import 'package:frontend_sgfcp/pages/admin/create_driver.dart';
import 'package:frontend_sgfcp/pages/admin/load_advance.dart';
import 'package:intl/intl.dart';

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
  String _selectedMonth = 'Septiembre, 2025';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Obtener datos reales del backend
    final drivers = [
      _DriverItemData(
        name: 'Carlos Sainz',
        status: _DriverStatusType.onTrip,
      ),
      _DriverItemData(
        name: 'Alexander Albon',
        status: _DriverStatusType.inactive,
      ),
      _DriverItemData(
        name: 'Fernando Alonso',
        status: _DriverStatusType.onTrip,
      ),
    ];

    final advances = [
      _AdvanceData(
        date: '11/09/2025',
        driverName: 'Alexander Albon',
        amount: 120000,
      ),
      _AdvanceData(
        date: '08/09/2025',
        driverName: 'Alexander Albon',
        amount: 80000,
      ),
      _AdvanceData(
        date: '07/09/2025',
        driverName: 'Fernando Alonso',
        amount: 90000,
      ),
      _AdvanceData(
        date: '05/09/2025',
        driverName: 'Carlos Sainz',
        amount: 60000,
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Lista de choferes
              ...drivers.map((driver) => _DriverListItem(driver: driver)),

              gap24,

              // Sección Adelantos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Adelantos',
                    style: textTheme.titleLarge,
                  ),
                ],
              ),

              gap12,

              // Botón Cargar adelanto
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(LoadAdvancePageAdmin.route());
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

              // Selector de mes
              Row(
                children: [
                  Text(
                    _selectedMonth,
                    style: textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      _showMonthPicker(context);
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
                    label: const Text('Elegir mes'),
                  ),
                ],
              ),

              gap16,

              // Lista de adelantos
              ...advances.map((advance) => _AdvanceListItem(advance: advance)),
            ],
          ),
        ),
      ],
    );
  }

  void _showMonthPicker(BuildContext context) {
    // TODO: Implementar selector de mes/año
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar mes'),
          content: const Text('Selector de mes en desarrollo'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

/// Item de chofer en la lista
class _DriverListItem extends StatelessWidget {
  final _DriverItemData driver;

  const _DriverListItem({required this.driver});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: driver.status == _DriverStatusType.onTrip
              ? colors.secondaryContainer
              : colors.surfaceContainerHighest,
          child: Icon(
            Symbols.local_shipping,
            color: driver.status == _DriverStatusType.onTrip
                ? colors.onSecondaryContainer
                : colors.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              driver.status == _DriverStatusType.onTrip ? 'En viaje' : 'Inactivo',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Text(
          driver.name,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colors.onSurfaceVariant,
        ),
        onTap: () {
          Navigator.of(context).push(
            DriverDetailPageAdmin.route(driverName: driver.name),
          );
        },
      ),
    );
  }
}

/// Item de adelanto en la lista
class _AdvanceListItem extends StatelessWidget {
  final _AdvanceData advance;

  const _AdvanceListItem({required this.advance});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(
              advance.date,
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
            Text(
              advance.driverName,
              style: textTheme.bodyMedium,
            ),
            gap4,
            Text(
              currencyFormat.format(advance.amount),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colors.onSurfaceVariant,
        ),
        onTap: () {
          // TODO: Navegar a detalles del adelanto
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ver detalles del adelanto')),
          );
        },
      ),
    );
  }
}

// Modelos de datos
enum _DriverStatusType { onTrip, inactive }

class _DriverItemData {
  final String name;
  final _DriverStatusType status;

  _DriverItemData({
    required this.name,
    required this.status,
  });
}

class _AdvanceData {
  final String date;
  final String driverName;
  final double amount;

  _AdvanceData({
    required this.date,
    required this.driverName,
    required this.amount,
  });
}
