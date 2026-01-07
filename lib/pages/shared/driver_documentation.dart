import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/simple_table_row_data.dart';
import 'package:frontend_sgfcp/pages/shared/documentation_update.dart';
import 'package:frontend_sgfcp/widgets/simple_table.dart';
// import 'package:material_symbols_icons/symbols.dart';
// import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:intl/intl.dart';

class DriverDocumentationPage extends StatelessWidget {
  final DriverData driver;

  const DriverDocumentationPage({super.key, required this.driver});

  static const String routeName = '/admin/driver-documentation';

  static Route route({required DriverData driver}) {
    return MaterialPageRoute<void>(
      builder: (_) => DriverDocumentationPage(driver: driver),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final colors = Theme.of(context).colorScheme;
    // final textTheme = Theme.of(context).textTheme;
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Documentación')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          SimpleTable.statusColumn(
            headers: ['Documentación', 'Vencimiento', 'Vigente', 'Editar'],
            rows: [
              SimpleTableRowData(
                col1: 'Licencia de conducir',
                col2: driver.driverLicenseDueDate != null
                    ? dateFormatter.format(driver.driverLicenseDueDate!)
                    : 'Sin fecha',
                dateToValidate: driver.driverLicenseDueDate,
                onEdit: () { Navigator.of(context).push(DocumentationUpdatePage.route()); },
              ),
              SimpleTableRowData(
                col1: 'Examen médico',
                col2: driver.medicalExamDueDate != null
                    ? dateFormatter.format(driver.medicalExamDueDate!)
                    : 'Sin fecha',
                dateToValidate: driver.medicalExamDueDate,
                onEdit: () { Navigator.of(context).push(DocumentationUpdatePage.route()); },
              ),
            ],
          ),

          // // Licencia de conducir
          // _DocumentCard(
          //   title: 'Licencia de conducir',
          //   dueDate: driver.driverLicenseDueDate,
          //   dateFormatter: dateFormatter,
          //   colors: colors,
          //   textTheme: textTheme,
          // ),

          // gap16,

          // // Examen médico
          // _DocumentCard(
          //   title: 'Examen médico',
          //   dueDate: driver.medicalExamDueDate,
          //   dateFormatter: dateFormatter,
          //   colors: colors,
          //   textTheme: textTheme,
          // ),
        ],
      ),
    );
  }
}

// class _DocumentCard extends StatelessWidget {
//   final String title;
//   final DateTime? dueDate;
//   final DateFormat dateFormatter;
//   final ColorScheme colors;
//   final TextTheme textTheme;

//   const _DocumentCard({
//     required this.title,
//     required this.dueDate,
//     required this.dateFormatter,
//     required this.colors,
//     required this.textTheme,
//   });

//   bool _isValid() {
//     if (dueDate == null) return false;
//     return dueDate!.isAfter(DateTime.now());
//   }

//   String _getStatus() {
//     if (dueDate == null) return 'Sin fecha';
//     if (_isValid()) {
//       return 'Vigente';
//     } else {
//       return 'Vencido';
//     }
//   }

//   Color _getStatusColor() {
//     if (dueDate == null) return colors.onSurfaceVariant;
//     if (_isValid()) {
//       return Colors.green;
//     } else {
//       return Colors.red;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card.outlined(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor().withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     _getStatus(),
//                     style: textTheme.bodySmall?.copyWith(
//                       color: _getStatusColor(),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             gap12,
//             if (dueDate != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Vencimiento',
//                         style: textTheme.bodyMedium?.copyWith(
//                           color: colors.onSurfaceVariant,
//                         ),
//                       ),
//                       Text(
//                         dateFormatter.format(dueDate!),
//                         style: textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               )
//             else
//               Text(
//                 'Sin fecha de vencimiento registrada',
//                 style: textTheme.bodyMedium?.copyWith(
//                   color: colors.onSurfaceVariant,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
