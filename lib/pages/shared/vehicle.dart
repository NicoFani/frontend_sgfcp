import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/admin/driver_detail.dart';
import 'package:frontend_sgfcp/pages/admin/edit_vehicle.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/models/simple_table_row_data.dart';

import 'package:frontend_sgfcp/pages/shared/documentation_update.dart';
import 'package:frontend_sgfcp/widgets/info_card.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
import 'package:frontend_sgfcp/widgets/simple_table.dart';
import 'package:material_symbols_icons/symbols.dart';

class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/vehicle';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const VehiclePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double infoLabelWidth = 125;
    final bool isAdmin =
      (TokenStorage.user != null && TokenStorage.user!['is_admin'] == true);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(EditVehiclePage.route(
                  brand: 'Scania',
                  model: 'R500',
                  plate: 'AE698LE',
                ),);
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
                title: 'Datos del vehículo',
                items: const [
                  InfoItem(label: 'Marca', value: 'Scania'),
                  InfoItem(label: 'Modelo', value: 'R500'),
                  InfoItem(label: 'Año', value: '2018'),
                  InfoItem(label: 'Patente', value: 'ABC123'),
                ],
                labelColumnWidth: infoLabelWidth,
              ),

              gap12,

              // --- Card: Chofer asignado (solo admin) ---
              if (isAdmin) ...[
                SimpleCard.iconOnly(
                  title: 'Chofer',
                  subtitle: 'Carlos Sainz',
                  icon: Symbols.arrow_right,
                  onPressed: () {
                    Navigator.of(context).push(
                      DriverDetailPageAdmin.route(
                        driverId: 1,
                        driverName: 'Juan Pérez', // Aquí debería ir el nombre real del chofer
                      ),
                    );
                  },
                ),

                gap12,
              ],

              // --- Table: Documentación del vehículo ---
              SimpleTable.statusColumn(
                title: 'Documentación del vehículo',
                headers: ['Documentación', 'Vencimiento', 'Vigente', 'Editar'],
                rows: [
                  SimpleTableRowData(
                    col1: 'VTV',
                    col2: '20/09/2025',
                    dateToValidate: DateTime(2025, 9, 20),
                    onEdit: () { Navigator.of(context).push(DocumentationUpdatePage.route()); },
                  ),
                  SimpleTableRowData(
                    col1: 'Service',
                    col2: '15/11/2026',
                    dateToValidate: DateTime(2026, 11, 15),
                    onEdit: () { Navigator.of(context).push(DocumentationUpdatePage.route()); },
                  ),
                  SimpleTableRowData(
                    col1: 'Patente',
                    col2: '23/07/2026',
                    dateToValidate: DateTime(2026, 07, 23),
                    onEdit: () { Navigator.of(context).push(DocumentationUpdatePage.route()); },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
