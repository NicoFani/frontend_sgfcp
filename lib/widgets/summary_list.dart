import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/summary_data.dart';
import 'package:frontend_sgfcp/models/summary_row_data.dart';
import 'package:frontend_sgfcp/pages/admin/summary_detail.dart';
import 'package:frontend_sgfcp/services/payroll_summary_service.dart';

class SummaryList extends StatelessWidget {
  final List<SummaryRowData> rows;
  final VoidCallback? onSummaryChanged;

  const SummaryList({super.key, required this.rows, this.onSummaryChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final double sizedBoxWidth = 48;
    final double actionsWidth = 80; // Ancho para columna de acciones

    final headerStyle = textTheme.labelLarge?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Column(
      children: [
        // Header aligned with list rows
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: SizedBox(width: sizedBoxWidth, child: const Text('id')),
          title: Row(
            children: const [
              Expanded(child: Text('Chofer')),
              Expanded(child: Text('Periodo')),
              Expanded(child: Text('Fecha')),
              SizedBox(width: 80, child: Center(child: Text('Acciones'))),
            ],
          ),
          trailing: SizedBox(
            width: sizedBoxWidth,
            child: Center(child: Text('Estado')),
          ),
          // Apply header style to all texts
          titleTextStyle: headerStyle,
          leadingAndTrailingTextStyle: headerStyle,
        ),
        const Divider(height: 1),
        // Rows with dividers between items only
        ...List.generate(rows.length, (index) {
          final row = rows[index];
          final isLast = index == rows.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: SizedBox(
                  width: sizedBoxWidth,
                  child: Text(row.id, style: textTheme.bodySmall),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(row.driver, style: textTheme.bodyMedium),
                    ),
                    Expanded(
                      child: Text(row.period, style: textTheme.bodyMedium),
                    ),
                    Expanded(
                      child: Text(
                        _formatDate(row.date),
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(
                      width: actionsWidth,
                      child: _buildActionButtons(context, row),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: sizedBoxWidth,
                  child: Icon(row.status.icon, color: row.status.color(colors)),
                ),
                onTap: () async {
                  final result = await Navigator.of(
                    context,
                  ).push(SummaryDetailPage.route(summaryId: row.summaryId));
                  // result será true si se aprobó el resumen
                  if (result == true && onSummaryChanged != null) {
                    onSummaryChanged!();
                  }
                },
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, SummaryRowData row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón Excel - disponible para todos los estados
        IconButton(
          icon: const Icon(Icons.file_download, size: 20),
          color: Colors.green.shade700,
          tooltip: 'Exportar a Excel',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _confirmExport(context, row, 'excel'),
        ),
        const SizedBox(width: 8),
        // Botón PDF - solo para aprobados
        if (row.status == SummaryStatus.approved)
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, size: 20),
            color: Colors.red.shade700,
            tooltip: 'Exportar a PDF',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _confirmExport(context, row, 'pdf'),
          ),
      ],
    );
  }

  Future<void> _confirmExport(
    BuildContext context,
    SummaryRowData row,
    String format,
  ) async {
    final formatName = format == 'excel' ? 'Excel' : 'PDF';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exportar a $formatName'),
        content: Text(
          '¿Deseas exportar el resumen de ${row.driver} (${row.period}) a $formatName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exportar'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        // Mostrar indicador de carga
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportando a $formatName...'),
            duration: const Duration(seconds: 2),
          ),
        );

        // Exportar
        await PayrollSummaryService.exportSummary(
          summaryId: row.summaryId,
          format: format,
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resumen exportado a $formatName exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }
}
