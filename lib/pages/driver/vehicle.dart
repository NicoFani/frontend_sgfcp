import 'package:flutter/material.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/info_item.dart';
import 'package:frontend_sgfcp/models/simple_table_row_data.dart';

import 'package:frontend_sgfcp/pages/driver/documentation_update.dart';
import 'package:frontend_sgfcp/widgets/info_card.dart';
import 'package:frontend_sgfcp/widgets/simple_table.dart';

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


    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículo'),
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

              gap16,

              SimpleTable.statusColumn(
                title: 'Documentación del vehículo',
                headers: ['Documentación', 'Vencimiento', 'Vigente', 'Editar'],
                rows: [
                  SimpleTableRowData(
                    col1: 'VTV',
                    col2: '20/09/2025',
                    isValid: false,
                    onEdit: () { Navigator.of(context).push(DocumentationUpdatePage.route()); },
                  ),
                  SimpleTableRowData(
                    col1: 'Service',
                    col2: '15/11/2026',
                    isValid: true,
                    onEdit: () { Navigator.of(context).push(DocumentationUpdatePage.route()); },
                  ),
                  SimpleTableRowData(
                    col1: 'Patente',
                    col2: '23/07/2026',
                    isValid: true,
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
