import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';

class DriverDataPageAdmin extends StatelessWidget {
  final DriverData driver;

  const DriverDataPageAdmin({super.key, required this.driver});

  static const String routeName = '/admin/driver-data';

  static Route route({required DriverData driver}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverDataPageAdmin(driver: driver),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Datos del chofer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Datos personales
          Text('Datos personales', style: textTheme.titleLarge),
          gap8,
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Nombre', value: driver.firstName),
                  gap12,
                  _InfoRow(label: 'Apellido', value: driver.lastName),
                  gap12,
                  _InfoRow(
                    label: 'Teléfono',
                    value: driver.phoneNumber ?? 'No registrado',
                  ),
                  gap12,
                  _InfoRow(
                    label: 'CUIL',
                    value: driver.cuil ?? 'No registrado',
                  ),
                  gap12,
                  _InfoRow(label: 'CVU', value: driver.cbu ?? 'No registrado'),
                ],
              ),
            ),
          ),

          gap24,

          // Datos de la cuenta
          Text('Datos de la cuenta', style: textTheme.titleLarge),
          gap8,
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Email',
                    value: driver.email ?? 'No registrado',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
