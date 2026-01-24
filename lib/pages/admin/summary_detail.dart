import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/summary_data.dart';
import 'package:frontend_sgfcp/models/payroll_summary_data.dart';
import 'package:frontend_sgfcp/services/payroll_summary_service.dart';
import 'package:frontend_sgfcp/widgets/summary_data_card.dart';
import 'package:frontend_sgfcp/widgets/summary_item_group_card.dart';
import 'package:frontend_sgfcp/widgets/trips_list_section.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:intl/intl.dart';

class SummaryDetailPage extends StatefulWidget {
  final int summaryId;

  const SummaryDetailPage({super.key, required this.summaryId});

  static const String routeName = '/admin/summaries';

  static Route route({required int summaryId}) {
    return MaterialPageRoute<void>(
      builder: (_) => SummaryDetailPage(summaryId: summaryId),
    );
  }

  @override
  State<SummaryDetailPage> createState() => _SummaryDetailPageState();
}

// Row data moved to models/summary_row_data.dart

class _SummaryDetailPageState extends State<SummaryDetailPage> {
  PayrollSummaryData? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await PayrollSummaryService.getSummaryById(
        summaryId: widget.summaryId,
      );

      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar resumen: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resumen')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resumen')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              gap16,
              Text(_errorMessage!, textAlign: TextAlign.center),
              gap16,
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = _summary!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'pdf', child: Text('Descargar PDF')),
              const PopupMenuItem(
                value: 'excel',
                child: Text('Descargar Excel'),
              ),
            ],
            onSelected: (value) {
              if (value == 'pdf') {
                // TODO: Implementar descarga de PDF
              } else if (value == 'excel') {
                // TODO: Implementar descarga de Excel
              }
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Datos del resumen
          SummaryDataCard(
            numberValue: summary.id.toString().padLeft(4, '0'),
            date: summary.createdAt ?? DateTime.now(),
            driverValue: summary.driverName ?? 'N/A',
            periodValue: _formatPeriod(summary.periodYear, summary.periodMonth),
            status: _getStatusFromString(summary.status),
            leftColumnWidth: 160,
          ),

          gap4,

          // Comisión por viajes
          SummaryItemGroupCard(
            title: 'Comisión por viajes',
            items: [
              SummaryItemEntry(
                label: 'Total comisiones',
                amount: summary.commissionFromTrips,
              ),
            ],
          ),

          gap4,

          // Gastos
          SummaryItemGroupCard(
            title: 'Gastos',
            items: [
              if (summary.expensesToReimburse > 0)
                SummaryItemEntry(
                  label: 'Gastos a reintegrar',
                  amount: summary.expensesToReimburse,
                ),
              if (summary.expensesToDeduct > 0)
                SummaryItemEntry(
                  label: 'Gastos a descontar',
                  amount: -summary.expensesToDeduct,
                ),
            ],
          ),

          gap4,

          // Adelantos
          if (summary.advancesDeducted > 0) ...[
            SummaryItemGroupCard(
              title: 'Adelantos',
              items: [
                SummaryItemEntry(
                  label: 'Adelantos descontados',
                  amount: -summary.advancesDeducted,
                ),
              ],
            ),
            gap4,
          ],

          // Otros conceptos
          SummaryItemGroupCard(
            title: 'Otros conceptos',
            items: [
              if (summary.guaranteedMinimumApplied > 0)
                SummaryItemEntry(
                  label: 'Mínimo garantizado aplicado',
                  amount: summary.guaranteedMinimumApplied,
                ),
              if (summary.otherItemsTotal != 0)
                SummaryItemEntry(
                  label: 'Otros ajustes',
                  amount: summary.otherItemsTotal,
                ),
            ],
          ),

          gap4,

          // Totales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: Theme.of(context).textTheme.titleMedium),
                  gap16,
                  _buildTotalRow(
                    'Saldo a favor',
                    summary.totalAmount > 0 ? summary.totalAmount : 0,
                  ),
                  gap8,
                  _buildTotalRow(
                    'Saldo en contra',
                    summary.totalAmount < 0 ? summary.totalAmount : 0,
                  ),
                  const Divider(height: 24),
                  _buildTotalRow('Total', summary.totalAmount, isBold: true),
                ],
              ),
            ),
          ),

          gap16,

          // Mensaje de error si existe
          if (summary.errorMessage != null) ...[
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        gap8,
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.red.shade700),
                        ),
                      ],
                    ),
                    gap8,
                    Text(
                      summary.errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
            ),
            gap16,
          ],

          // Botón recalcular
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: _recalculateSummary,
            icon: const Icon(Icons.refresh),
            label: const Text('Recalcular resumen'),
          ),
        ],
      ),
      floatingActionButton: summary.status != 'approved'
          ? FloatingActionButton(
              child: const Icon(Icons.check),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Aprobar resumen'),
                    content: const Text(
                      '¿Estás seguro de que querés aprobar este resumen?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Aprobar'),
                      ),
                    ],
                  ),
                );
                if (confirmed ?? false) {
                  // TODO: Implementar aprobación del resumen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidad en desarrollo'),
                    ),
                  );
                }
              },
            )
          : null,
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    final textStyle = isBold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: textStyle?.copyWith(color: amount < 0 ? Colors.red : null),
        ),
      ],
    );
  }

  SummaryStatus _getStatusFromString(String status) {
    switch (status) {
      case 'approved':
        return SummaryStatus.approved;
      case 'pending_approval':
        return SummaryStatus.pendingApproval;
      case 'draft':
        return SummaryStatus.draft;
      case 'error':
        return SummaryStatus.calculationError;
      case 'calculation_pending':
        return SummaryStatus.calculationPending;
      default:
        return SummaryStatus.draft;
    }
  }

  String _formatPeriod(int? year, int? month) {
    if (year == null || month == null) return 'N/A';

    final date = DateTime(year, month);
    final formatted = DateFormat.yMMMM('es').format(date);
    // Capitalizar primera letra
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  Future<void> _recalculateSummary() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad en desarrollo')),
    );
  }
}
