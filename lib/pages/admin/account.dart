import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/widgets/info_card.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/pages/admin/edit_account.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/pages/shared/login_page.dart';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InfoCard.footerButton(
                title: 'Datos de la cuenta',
                items: [
                  InfoItem(label: 'Nombre(s)', value: 'Omar'),
                  InfoItem(label: 'Apellido(s)', value: 'José'),
                  InfoItem(label: 'Email', value: 'omar@gmail.com'),
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
        ),
      ),
    );
  }
}
