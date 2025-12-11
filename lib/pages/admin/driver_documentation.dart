import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/update_document.dart';

class DriverDocumentationPageAdmin extends StatelessWidget {
  final String driverName;

  const DriverDocumentationPageAdmin({
    super.key,
    required this.driverName,
  });

  static const String routeName = '/admin/driver-documentation';

  static Route route({required String driverName}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverDocumentationPageAdmin(driverName: driverName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Obtener datos reales del backend
    final documents = [
      _DocumentData(
        name: 'Licencia de conducir',
        expirationDate: DateTime(2025, 3, 20),
      ),
      _DocumentData(
        name: 'Examen psicofísico',
        expirationDate: DateTime(2025, 4, 20),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentación'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Encabezados de columnas
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Documentación',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Vencimiento',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  gapW16,
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Vigente',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  gapW16,
                  SizedBox(
                    width: 50,
                    child: Text(
                      'Editar',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de documentos
            ...documents.map((doc) => _DocumentListItem(
              document: doc,
              onTap: () {
                Navigator.of(context).push(
                  UpdateDocumentPageAdmin.route(
                    documentName: doc.name,
                    currentDate: doc.expirationDate,
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _DocumentListItem extends StatelessWidget {
  final _DocumentData document;
  final VoidCallback onTap;

  const _DocumentListItem({
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final daysUntilExpiration = document.expirationDate.difference(now).inDays;

    // Determinar icono de estado
    IconData statusIcon;
    Color statusColor;

    if (daysUntilExpiration < 0) {
      // Vencido
      statusIcon = Symbols.error;
      statusColor = colors.error;
    } else {
      // Al día
      statusIcon = Symbols.check_circle;
      statusColor = Colors.green;
    }

    final formattedDate = DateFormat('dd/MM/yyyy').format(document.expirationDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Nombre del documento (columna Documentación)
          Expanded(
            flex: 2,
            child: Text(
              document.name,
              style: textTheme.bodyLarge,
            ),
          ),

          // Fecha (columna Vencimiento)
          Expanded(
            child: Text(
              formattedDate,
              style: textTheme.bodyLarge,
            ),
          ),

          gapW16,

          // Icono de estado (columna Vigente)
          SizedBox(
            width: 60,
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
              fill: 1,
            ),
          ),

          gapW16,

          // Botón de editar (columna Editar)
          SizedBox(
            width: 50,
            child: Material(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Symbols.edit,
                    color: colors.onSecondaryContainer,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentData {
  final String name;
  final DateTime expirationDate;

  _DocumentData({
    required this.name,
    required this.expirationDate,
  });
}
