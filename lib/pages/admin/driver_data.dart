import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/edit_driver_data.dart';

class DriverDataPageAdmin extends StatelessWidget {
  final String driverName;

  const DriverDataPageAdmin({
    super.key,
    required this.driverName,
  });

  static const String routeName = '/admin/driver-data';

  static Route route({required String driverName}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverDataPageAdmin(driverName: driverName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Obtener datos reales del backend
    final personalData = {
      'Nombre(s)': 'Juan Antonio',
      'Apellido(s)': 'Rodriguez',
      'CUIL': '27-28033514-8',
      'CVU': '0000031547612579452356',
      'Número de teléfono': '3462 37-8485',
    };

    final accountData = {
      'Email': 'juan@gmail.com',
      'Contraseña': '••••••••••',
      'Fecha de alta': '23/07/2025',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del chofer'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.edit),
            onPressed: () {
              Navigator.of(context).push(
                EditDriverDataPageAdmin.route(driverName: driverName),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Datos personales
          Text(
            'Datos personales',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          gap8,

          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...personalData.entries.map((entry) {
                    final isLast = entry.key == personalData.keys.last;
                    return Column(
                      children: [
                        _DataRow(
                          label: entry.key,
                          value: entry.value,
                        ),
                        if (!isLast) gap12,
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          gap24,

          // Datos de la cuenta
          Text(
            'Datos de la cuenta',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          gap8,

          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...accountData.entries.map((entry) {
                    return Column(
                      children: [
                        _DataRow(
                          label: entry.key,
                          value: entry.value,
                        ),
                        gap12,
                      ],
                    );
                  }),
                  // Botón reestablecer contraseña
                  FilledButton.icon(
                    onPressed: () {
                      _showResetPasswordDialog(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Symbols.lock_reset, size: 18),
                    label: const Text('Reestablecer contraseña'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reestablecer contraseña'),
          content: const Text(
            '¿Estás seguro de que quieres reestablecer la contraseña de este chofer? Se enviará un correo con las instrucciones.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Correo de restablecimiento enviado'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}

/// Fila de datos (label y valor)
class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        gap4,
        Text(
          value,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
