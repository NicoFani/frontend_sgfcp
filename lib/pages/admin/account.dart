import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/edit_account.dart';

class AccountPageAdmin extends StatelessWidget {
  const AccountPageAdmin({super.key});

  static const String routeName = '/admin/account';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const AccountPageAdmin());
  }

  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reestablecer contraseña'),
        content: const Text('Se enviará un correo para reestablecer la contraseña'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Correo enviado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Obtener datos reales del backend
    final accountData = {
      'Nombre(s)': 'Omar',
      'Apellido(s)': 'José',
      'Email': 'omar@gmail.com',
      'Contraseña': '**********',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.edit),
            onPressed: () {
              Navigator.of(context).push(EditAccountPageAdmin.route());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Datos de la cuenta
              Text(
                'Datos de la cuenta',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              gap16,

              // Card con datos y líneas divisoras
              Card.outlined(
                child: Column(
                  children: accountData.entries.map((entry) {
                    final isLast = entry.key == accountData.keys.last;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _DataRow(label: entry.key, value: entry.value),
                        ),
                        if (!isLast) Divider(height: 1, color: colors.outlineVariant),
                      ],
                    );
                  }).toList(),
                ),
              ),

              gap24,

              // Botón Reestablecer contraseña
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => _showResetPasswordDialog(context),
                icon: const Icon(Symbols.lock_reset),
                label: const Text('Reestablecer contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyLarge,
        ),
        Text(
          value,
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}
