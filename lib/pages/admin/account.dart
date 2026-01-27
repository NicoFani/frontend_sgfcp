import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/widgets/info_card.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/pages/admin/edit_account.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/pages/shared/login_page.dart';
import 'package:frontend_sgfcp/services/auth_service.dart';
import 'package:frontend_sgfcp/models/user.dart';
import 'package:frontend_sgfcp/services/user_refresh_notifier.dart';

class AccountPageAdmin extends StatefulWidget {
  const AccountPageAdmin({super.key});

  static const String routeName = '/admin/account';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const AccountPageAdmin());
  }

  @override
  State<AccountPageAdmin> createState() => _AccountPageAdminState();
}

class _AccountPageAdminState extends State<AccountPageAdmin> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
  }

  Future<User> _fetchUser() async {
    final userData = await AuthService.getCurrentUser();
    if (userData['success'] != false && userData['user'] != null) {
      return User.fromJson(userData['user'] as Map<String, dynamic>);
    }
    throw Exception('No se pudo obtener los datos del usuario');
  }

  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reestablecer contraseña'),
        content: const Text(
          'Se enviará un correo para reestablecer la contraseña',
        ),
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
    const double infoLabelWidth = 125;

    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cuenta'),
            actions: [
                if (snapshot.hasData)
                  IconButton(
                    icon: const Icon(Symbols.edit),
                    onPressed: () async {
                      final user = snapshot.data!;
                      final result = await Navigator.of(context)
                          .push(EditAccountPageAdmin.route(user: user));
                      if (result == true) {
                        setState(() {
                          _userFuture = _fetchUser();
                        });
                        // Notify all listeners that user data has been refreshed
                        triggerUserRefresh();
                      }
                    },
                  ),
            ],
          ),
          body: SafeArea(
            child: _buildBody(snapshot, infoLabelWidth),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<User> snapshot,
    double infoLabelWidth,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${snapshot.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userFuture = _fetchUser();
                });
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (!snapshot.hasData) {
      return const Center(child: Text('No se encontraron datos'));
    }

    final user = snapshot.data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InfoCard.footerButton(
            title: 'Datos de la cuenta',
            items: [
              InfoItem(label: 'Nombre(s)', value: user.firstName),
              InfoItem(label: 'Apellido(s)', value: user.lastName),
              InfoItem(label: 'Email', value: user.email),
              InfoItem(label: 'Contraseña', value: '***********'),
            ],
            buttonIcon: Symbols.lock_reset,
            buttonLabel: 'Reestablecer contraseña',
            onPressed: () {
              _showResetPasswordDialog(context);
            },
            labelColumnWidth: infoLabelWidth,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                TokenStorage.clear();
                Navigator.of(
                  context,
                ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
              },
              icon: const Icon(Symbols.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
