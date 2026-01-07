import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/account.dart';
import 'package:frontend_sgfcp/pages/admin/clients_providers.dart';
import 'package:frontend_sgfcp/pages/admin/vehicles.dart';
import 'package:frontend_sgfcp/pages/admin/add_advance_payment.dart';

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
          gap24,

          // Información del usuario (Omar)
          Column(
            children: [
              Text('Omar', style: textTheme.titleLarge),
              gap4,
              Text(
                'omar@gmail.com',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          gap32,

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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Divider(height: 1),
          ),

          _MenuItem(
            icon: Symbols.insert_chart,
            label: 'Estadísticas',
            onTap: () {
              // TODO: Navegar a Estadísticas
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estadísticas - En desarrollo')),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Divider(height: 1),
          ),

          _MenuItem(
            icon: Symbols.local_shipping,
            label: 'Vehículos',
            onTap: () {
              Navigator.of(context).push(VehiclesPageAdmin.route());
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Divider(height: 1),
          ),

          _MenuItem(
            icon: Symbols.group,
            label: 'Clientes y Dadores',
            onTap: () {
              Navigator.of(context).push(ClientsProvidersPageAdmin.route());
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Divider(height: 1),
          ),

          _MenuItem(
            icon: Symbols.mintmark,
            label: 'Cargar Adelanto',
            onTap: () {
              Navigator.of(context).push(AddAdvancePaymentPage.route());
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Divider(height: 1),
          ),

          _MenuItem(
            icon: Symbols.user_attributes,
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
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Icon(Icons.arrow_right),
      onTap: onTap,
    );
  }
}
