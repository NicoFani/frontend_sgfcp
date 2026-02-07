import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/admin/summaries.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/account.dart';
import 'package:frontend_sgfcp/pages/admin/clients_providers.dart';
import 'package:frontend_sgfcp/pages/admin/trucks.dart';
import 'package:frontend_sgfcp/pages/admin/add_advance_payment.dart';
import 'package:frontend_sgfcp/models/user.dart';
import 'package:frontend_sgfcp/services/user_refresh_notifier.dart';
import 'package:frontend_sgfcp/services/auth_service.dart';

class AdministrationPageAdmin extends StatefulWidget {
  final User user;
  final VoidCallback? onNeedRefresh;

  const AdministrationPageAdmin({
    super.key,
    required this.user,
    this.onNeedRefresh,
  });

  static const String routeName = '/admin/administration';

  static Route route({required User user, VoidCallback? onNeedRefresh}) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          AdministrationPageAdmin(user: user, onNeedRefresh: onNeedRefresh),
    );
  }

  @override
  State<AdministrationPageAdmin> createState() =>
      _AdministrationPageAdminState();
}

class _AdministrationPageAdminState extends State<AdministrationPageAdmin> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    // Listen to global user refresh notifications
    userRefreshNotifier.addListener(_onUserRefresh);
  }

  @override
  void dispose() {
    userRefreshNotifier.removeListener(_onUserRefresh);
    super.dispose();
  }

  Future<void> _onUserRefresh() async {
    // Fetch fresh user data when notified
    final userData = await AuthService.getCurrentUser();
    if (userData['success'] != false && userData['user'] != null) {
      final freshUser = User.fromJson(userData['user'] as Map<String, dynamic>);
      if (mounted) {
        setState(() {
          _currentUser = freshUser;
        });
      }
    }
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

          // Información del usuario
          Column(
            children: [
              Text(_currentUser.fullName, style: textTheme.titleLarge),
              gap4,
              Text(
                _currentUser.email,
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
              Navigator.of(context).push(SummariesPageAdmin.route());
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
              Navigator.of(context).push(TrucksPageAdmin.route());
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
