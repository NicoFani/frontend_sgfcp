import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/shared/driver_data.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';

import 'package:frontend_sgfcp/pages/shared/driver_documentation.dart';
import 'package:frontend_sgfcp/pages/shared/vehicle.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/profile';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const ProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gap24,

            // ----- Nombre + email centrados -----
            Center(
              child: Column(
                children: [
                  Text(
                    'Juan',
                    style: textTheme.titleLarge,
                  ),
                  gap4,
                  Text(
                    'juan@gmail.com',
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            gap32,

            // ----- Lista de opciones -----
            _ProfileOptionsList(),
          ],
        ),
      ),
    );
  }
}

/// Lista de opciones del perfil
class _ProfileOptionsList extends StatelessWidget {
  get driver => null;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Symbols.id_card),
            title: Text('Documentación'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              Navigator.of(context).push(DriverDocumentationPage.route(driver: driver));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Divider(height: 1),
          ),
          ListTile(
            leading: Icon(Symbols.local_shipping),
            title: Text('Vehículo'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              Navigator.of(context).push(VehiclePage.route());
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Divider(height: 1),
          ),
          ListTile(
            leading: Icon(Symbols.user_attributes),
            title: Text('Datos personales'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              Navigator.of(context).push(
                DriverDataPage.route(driver: driver)
              );
            },
          ),
        ],
      ),
    );
  }
}