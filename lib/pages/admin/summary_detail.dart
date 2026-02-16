import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/summary_data.dart';
import 'package:frontend_sgfcp/models/payroll_summary_data.dart';
import 'package:frontend_sgfcp/pages/shared/trip.dart';
import 'package:frontend_sgfcp/services/payroll_summary_service.dart';
import 'package:frontend_sgfcp/widgets/summary_data_card.dart';
import 'package:frontend_sgfcp/widgets/summary_item_group_card.dart';
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
  List<PayrollDetailData> _details = const [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _wasApproved = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final summaryWithDetails =
          await PayrollSummaryService.getSummaryWithDetailsById(
            summaryId: widget.summaryId,
          );

      if (mounted) {
        setState(() {
          _summary = summaryWithDetails.summary;
          _details = summaryWithDetails.details;
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
    final tripCommissionDetails = _details
        .where(
          (detail) =>
              detail.detailType == 'trip_commission' && detail.tripId != null,
        )
        .toList();
    final adminAdvances = _details
        .where((detail) => detail.detailType == 'advance')
        .fold<double>(0, (sum, detail) => sum + detail.amount);
    final clientAdvances = _details
        .where((detail) => detail.detailType == 'client_advance')
        .fold<double>(0, (sum, detail) => sum + detail.amount);

    final fallbackAdminAdvances =
        adminAdvances == 0 &&
            clientAdvances == 0 &&
            summary.advancesDeducted > 0
        ? summary.advancesDeducted
        : adminAdvances;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop && _wasApproved) {
          // Notificar que el resumen fue aprobado
          // Esto se hace automáticamente porque el callback ya recibió el resultado
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resumen'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(_wasApproved);
            },
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'excel',
                  child: Text('Descargar Excel'),
                ),
                const PopupMenuItem(value: 'pdf', child: Text('Descargar PDF')),
              ],
              onSelected: (value) => _handleExport(value),
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
              periodValue: _formatPeriod(
                summary.periodYear,
                summary.periodMonth,
              ),
              status: _getStatusFromString(summary.status),
              leftColumnWidth: 160,
            ),

            gap4,

            // Comisión por viajes
            if (tripCommissionDetails.isNotEmpty)
              SummaryItemGroupCard(
                title: 'Comisión por viajes',
                items: tripCommissionDetails
                    .map(
                      (detail) => SummaryItemEntry(
                        label: _getTripLabel(detail.description),
                        amount: detail.amount,
                        navigable: true,
                      ),
                    )
                    .toList(),
                onItemTap: (index) {
                  final detail = tripCommissionDetails[index];
                  final tripId = detail.tripId;
                  if (tripId == null) return;

                  Navigator.of(context).push(TripPage.route(tripId: tripId));
                },
              )
            else
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
                SummaryItemEntry(
                  label: 'Gastos a reintegrar',
                  amount: summary.expensesToReimburse,
                ),
                SummaryItemEntry(
                  label: 'Gastos a descontar',
                  amount: -summary.expensesToDeduct,
                ),
              ],
            ),

            gap4,

            // Adelantos
            SummaryItemGroupCard(
              title: 'Adelantos',
              items: [
                SummaryItemEntry(
                  label: 'Adelantos de administración',
                  amount: -fallbackAdminAdvances,
                ),
                SummaryItemEntry(
                  label: 'Adelantos de clientes',
                  amount: -clientAdvances,
                ),
              ],
            ),
            gap4,

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
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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

            // Botón recalcular (solo si no está aprobado)
            if (summary.status != 'approved')
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
        floatingActionButton:
            summary.status != 'approved' && summary.status != 'draft'
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
                    try {
                      // Aprobar el resumen
                      await PayrollSummaryService.approveSummary(
                        summaryId: widget.summaryId,
                      );

                      if (!mounted) return;

                      // Marcar que se aprobó
                      _wasApproved = true;

                      // Mostrar mensaje de éxito
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Resumen aprobado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Recargar el resumen para actualizar la vista
                      await _loadSummary();
                    } catch (e) {
                      if (!mounted) return;

                      // Mostrar error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al aprobar resumen: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              )
            : null,
      ),
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

  String _getTripLabel(String description) {
    final separatorIndex = description.indexOf(' - ');
    if (separatorIndex >= 0 && separatorIndex + 3 < description.length) {
      return description.substring(separatorIndex + 3).trim();
    }
    return description;
  }

  Future<void> _recalculateSummary() async {
    try {
      // Mostrar diálogo de carga
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Recalculando resumen...'),
            ],
          ),
        ),
      );

      // Recalcular el resumen
      final recalculatedSummary =
          await PayrollSummaryService.recalculateSummary(
            summaryId: widget.summaryId,
          );

      if (!context.mounted) return;

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      // Actualizar el estado con el resumen recalculado
      setState(() {
        _summary = recalculatedSummary;
      });

      // Recargar para actualizar también los detalles del resumen
      await _loadSummary();

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resumen recalculado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // Cerrar diálogo de carga si aún está abierto
      Navigator.of(context).pop();

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleExport(String format) async {
    final formatName = format == 'excel' ? 'Excel' : 'PDF';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exportar a $formatName'),
        content: Text('¿Deseas exportar este resumen a $formatName?'),
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
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportando a $formatName...'),
            duration: const Duration(seconds: 2),
          ),
        );

        // Exportar
        await PayrollSummaryService.exportSummary(
          summaryId: widget.summaryId,
          format: format,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resumen exportado a $formatName exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
