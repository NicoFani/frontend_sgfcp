import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/driver/edit_personal_data.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/widgets/info_card.dart';

class PersonalDataPage extends StatelessWidget {
  const PersonalDataPage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/personal_data';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const PersonalDataPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double infoLabelWidth = 125;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos personales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(EditPersonalDataPage.route());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Card: Datos personales ---
              InfoCard(
                title: 'Datos personales',
                items: const [
                  InfoItem(label: 'Nombre(s)', value: 'Juan Antonio'),
                  InfoItem(label: 'Apellido(s)', value: 'Rodriguez'),
                  InfoItem(label: 'CUIL', value: '27-28033514-8'),
                  InfoItem(label: 'CVU', value: '00000031457612579452\n356'),
                  InfoItem(label: 'Número de teléfono', value: '3462 37-8485'),
                ],
                labelColumnWidth: infoLabelWidth,
              ),

              gap4,

              InfoCard.footerButton(
                title: 'Datos de la cuenta',
                items: const [
                  InfoItem(label: 'Email', value: 'juan@gmail.com'),
                  InfoItem(label: 'Contraseña', value: '***********'),
                  InfoItem(label: 'Fecha de alta', value: '23/07/2025'),
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
        ),
      ),
    );
  }
}
