import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/shared/driver_data.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';

import 'package:frontend_sgfcp/pages/shared/driver_documentation.dart';
import 'package:frontend_sgfcp/pages/shared/truck.dart';
import 'package:frontend_sgfcp/services/driver_truck_service.dart';
import 'package:frontend_sgfcp/models/truck_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/driver_service.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/profile';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const ProfilePage());
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<DriverData> _driverFuture;
  late Future<TruckData?> _currentTruckFuture;

  @override
  void initState() {
    super.initState();
    _loadDriver();
  }

  void _loadDriver() {
    final user = TokenStorage.user;
    if (user != null && user['id'] != null) {
      _driverFuture = DriverService.getDriverById(driverId: user['id'] as int);
      _currentTruckFuture = DriverTruckService.getCurrentTruckByDriver(
        user['id'] as int,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final user = TokenStorage.user;

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
                    '${user?['name'] ?? ''} ${user?['surname'] ?? ''}',
                    style: textTheme.titleLarge,
                  ),
                  gap4,
                  Text(
                    user?['email'] ?? '',
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            gap32,

            // ----- Lista de opciones -----
            FutureBuilder<DriverData>(
              future: _driverFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar información del chofer'),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: Text('No se encontró información del chofer'),
                  );
                }

                return _ProfileOptionsList(
                  driver: snapshot.data!,
                  currentTruckFuture: _currentTruckFuture,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista de opciones del perfil
class _ProfileOptionsList extends StatelessWidget {
  final DriverData driver;
  final Future<TruckData?> currentTruckFuture;

  const _ProfileOptionsList({
    required this.driver,
    required this.currentTruckFuture,
  });

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
              Navigator.of(
                context,
              ).push(DriverDocumentationPage.route(driver: driver));
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
            onTap: () async {
              final truck = await currentTruckFuture;
              if (truck == null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No hay vehículo asignado'),
                  ),
                );
                return;
              }
              if (!context.mounted) return;
              Navigator.of(context).push(
                TruckPage.route(truckId: truck.id),
              );
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
              Navigator.of(context).push(DriverDataPage.route(driver: driver));
            },
          ),
        ],
      ),
    );
  }
}
