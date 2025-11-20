import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/simple_table_row_data.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class SimpleTable extends StatelessWidget {
  final String? title;                       // Título opcional
  final List<String> headers;                // Encabezados
  final List<SimpleTableRowData> rows;       // Datos
  final bool showStatusColumn;               // Variante

  const SimpleTable({
    super.key,
    this.title,
    required this.headers,
    required this.rows,
    this.showStatusColumn = false,
  });

  /// Variante con columna de estado (Documentación, etc.)
  factory SimpleTable.statusColumn({
    String? title,
    required List<String> headers,
    required List<SimpleTableRowData> rows,
  }) {
    return SimpleTable(
      title: title,
      headers: headers,
      rows: rows,
      showStatusColumn: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 6, left: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: textTheme.titleMedium),
            gap16,
          ],
      
          // ------- Encabezados -------
          Row(
            children: [
              // Columna 1
              Expanded(
                flex: 3,
                child: Text(
                  headers[0],
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              showStatusColumn ? gapW12 : gapW4,
              // Columna 2
              Expanded(
                flex: 2,
                child: Text(
                  headers[1],
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              // Columna de estado (opcional)
              if (showStatusColumn)
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      headers[2],
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              // Columna "Editar" (centered)
              SizedBox(
                width: 56, // ancho reservado para el botón
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Editar',
                    style: textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
      
          gap8,
      
          // ------- Filas -------
          for (int i = 0; i < rows.length; i++) ...[
            _SimpleTableRow(
              data: rows[i],
              showStatus: showStatusColumn,
            ),
            if (i < rows.length - 1) ...[
              const Divider(height: 1),
            ],
          ],
        ],
      ),
    );
  }
}

class _SimpleTableRow extends StatelessWidget {
  final SimpleTableRowData data;
  final bool showStatus;

  const _SimpleTableRow({
    required this.data,
    required this.showStatus,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Columna 1: Tipo / Documento
          Expanded(
            flex: 3,
            child: Text(
              data.col1,
              style: textTheme.bodyMedium,
            ),
          ),

          showStatus ? gapW12 : gapW4,

          // Columna 2: Importe / Vencimiento
          Expanded(
            flex: 2,
            child: Text(
              data.col2,
              style: textTheme.bodyMedium,
            ),
          ),

          // Columna de estado (opcional)
          if (showStatus)
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.center,
                child: data.isValid == null
                    ? const SizedBox.shrink()
                    : Icon(
                        data.isValid! ? Icons.check : Icons.error,
                        size: 18,
                        color: data.isValid! ? colors.primary : colors.error,
                      ),
              ),
            ),

          // Edit column (fixed width to align with header) — center the button
          SizedBox(
            width: 56,
            child: Align(
              alignment: Alignment.center,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                onPressed: data.onEdit,
                child: const Icon(Icons.edit_outlined, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
