import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/pages/edit_driver_data.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/widgets/info_card.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';

class DriverDataPage extends StatelessWidget {
  final DriverData driver;

  const DriverDataPage({super.key, required this.driver});

  static const String routeName = '/admin/driver-data';

  static Route route({required DriverData driver}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverDataPage(driver: driver),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double infoLabelWidth = 125;
    final bool isAdmin =
        (TokenStorage.user != null && TokenStorage.user!['is_admin'] == true);


    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Datos del chofer' : 'Datos personales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(EditDriverDataPage.route(driverName: '${driver.firstName} ${driver.lastName}'));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Datos personales
          InfoCard(
            title: 'Datos personales',
            items: [
              InfoItem(label: 'Nombre(s)', value: driver.firstName),
              InfoItem(label: 'Apellido(s)', value: driver.lastName),
              InfoItem(label: 'CUIL', value: driver.cuil ?? 'No registrado'),
              InfoItem(label: 'CVU', value: driver.cbu ?? 'No registrado'),
              InfoItem(label: 'Número de teléfono', value: driver.phoneNumber ?? 'No registrado'),
            ],
            labelColumnWidth: infoLabelWidth,
          ),
          
          gap4,

          // Datos de la cuenta
          
          InfoCard.footerButton(
            title: 'Datos de la cuenta',
            items: [
              InfoItem(label: 'Email', value: driver.email ?? 'No registrado'),
              InfoItem(label: 'Contraseña', value: '***********'),
              InfoItem(label: 'Fecha de alta', value: '23/07/2025'), //TODO: Cambiar por fecha real
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
    );
  }
}