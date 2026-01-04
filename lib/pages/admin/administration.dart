import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/account.dart';
import 'package:frontend_sgfcp/pages/admin/clients_providers.dart';
import 'package:frontend_sgfcp/pages/admin/vehicles.dart';
import 'package:frontend_sgfcp/pages/admin/load_advance.dart';

class AdministrationPageAdmin extends StatelessWidget {
  const AdministrationPageAdmin({super.key});

  static const String routeName = '/admin/administration';

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const AdministrationPageAdmin(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información del usuario (Omar)
          Column(
            children: [
              Text(
                'Omar',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              gap4,
              Text(
                'omar@gmail.com',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          gap24,

          // Opciones del menú con divisores
          _MenuItem(
            icon: Symbols.description,
            label: 'Resúmenes',
            onTap: () {
              // TODO: Navegar a Resúmenes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resúmenes - En desarrollo')),
              );
            },
          ),

          Divider(height: 1, color: colors.outlineVariant),

          _MenuItem(
            icon: Symbols.bar_chart,
            label: 'Estadísticas',
            onTap: () {
              // TODO: Navegar a Estadísticas
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estadísticas - En desarrollo')),
              );
            },
          ),

          Divider(height: 1, color: colors.outlineVariant),

          _MenuItem(
            icon: Symbols.local_shipping,
            label: 'Vehículos',
            onTap: () {
              Navigator.of(context).push(VehiclesPageAdmin.route());
            },
          ),

          Divider(height: 1, color: colors.outlineVariant),

          _MenuItem(
            icon: Symbols.groups,
            label: 'Clientes y Dadores',
            onTap: () {
              Navigator.of(context).push(ClientsProvidersPageAdmin.route());
            },
          ),

          Divider(height: 1, color: colors.outlineVariant),

          _MenuItem(
            icon: Symbols.attach_money,
            label: 'Cargar Adelanto',
            onTap: () {
              Navigator.of(context).push(LoadAdvancePageAdmin.route());
            },
          ),

          Divider(height: 1, color: colors.outlineVariant),

          _MenuItem(
            icon: Symbols.calculate,
            label: 'Cuenta',
            onTap: () {
              Navigator.of(context).push(AccountPageAdmin.route());
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      leading: Icon(icon, color: colors.onSurface, size: 24),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
