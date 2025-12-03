import 'package:flutter/material.dart';

import 'package:frontend_sgfcp/models/simple_table_row_data.dart';

import 'package:frontend_sgfcp/pages/driver/documentation_update.dart';
import 'package:frontend_sgfcp/widgets/simple_table.dart';

class DocumentationListPage extends StatelessWidget {
  const DocumentationListPage({super.key});

  static const String routeName = '/documentation_list';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const DocumentationListPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documentación'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [          
              SimpleTable.statusColumn(
                headers: ['Documentación', 'Vencimiento', 'Vigente', 'Editar'],
                rows: [
                  SimpleTableRowData(
                    col1: 'Licencia de conducir',
                    col2: '20/09/2025',
                    isValid: false,
                    onEdit: () { Navigator.of(context).push(DocumentationUpdatePage.route()); },
                  ),
                  SimpleTableRowData(
                    col1: 'Examen médico',
                    col2: '15/11/2026',
                    isValid: true,
                    onEdit: () { Navigator.of(context).push(DocumentationUpdatePage.route()); },
                  ),
                ],
              ),
              const SizedBox(height: 60), // Espacio para el FAB
            ],
          ),
        ),
      ),
    );
  }
}