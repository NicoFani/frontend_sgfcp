import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/summary_data.dart';
import 'package:frontend_sgfcp/widgets/summary_data_card.dart';
import 'package:frontend_sgfcp/widgets/summary_item_group_card.dart';
import 'package:frontend_sgfcp/widgets/trips_list_section.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';

class SummaryDetailPage extends StatefulWidget {
  const SummaryDetailPage({super.key});

  static const String routeName = '/admin/summaries';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SummaryDetailPage());
  }

  @override
  State<SummaryDetailPage> createState() => _SummaryDetailPageState();
}

// Row data moved to models/summary_row_data.dart

class _SummaryDetailPageState extends State<SummaryDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          // Primary actions
          SummaryDataCard(
            numberValue: '0001',
            date: DateTime(2026, 1, 31),
            driverValue: 'Albon',
            periodValue: 'Enero 2026',
            status: SummaryStatus.approved,
            leftColumnWidth: 160,
          ),

          gap4,

          SummaryItemGroupCard(
            title: 'Comisión por viajes',
            items: [
              SummaryItemEntry(
                label: 'San Lorenzo → Laboulaye',
                amount: 200000,
                navigable: true,
              ),
              SummaryItemEntry(
                label: 'Venado Tuerto → San Nicolás',
                amount: 200000,
                navigable: true,
              ),
              SummaryItemEntry(
                label: 'Corral de Bustos → Armstrong',
                amount: 400000,
                navigable: true,
              ),
            ],
            onItemTap: (i) {},
          ),

          gap4,

          SummaryItemGroupCard(
            title: 'Gastos',
            items: [
              SummaryItemEntry(label: 'Peaje', amount: 17000),
              SummaryItemEntry(label: 'Reparaciones', amount: 130000),
              SummaryItemEntry(label: 'Multas', amount: -150000),
            ],
          ),

          gap4,

          SummaryItemGroupCard(
            title: 'Adelantos',
            items: [
              SummaryItemEntry(
                label: 'Adelantos de administración',
                amount: -300000,
              ),
              SummaryItemEntry(label: 'Adelantos de clientes', amount: -230000),
            ],
          ),

          gap4,

          SummaryItemGroupCard(
            title: 'Otros conceptos',
            items: [
              SummaryItemEntry(
                label: 'Ajuste Diciembre 2025',
                amount: -30000,
                navigable: true,
              ),
              SummaryItemEntry(
                label: 'Mínimo garantizado',
                amount: 200000,
                navigable: true,
              ),
            ],
            onItemTap: (i) {},
          ),

          gap4,

          SummaryItemGroupCard.total(
            creditBalance: 1300000,
            debitBalance: -500000,
            total: 800000,
          ),

          // Recalculate + Error section
          // TODO: Handle error
          gap8,

          FilledButton.icon(
            onPressed: () {
              // TODO: Trigger recalculation of summary
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Recalcular resumen'),
            style: FilledButton.styleFrom(
              fixedSize: const Size(double.infinity, 48),
            ),
          ),

          gap8,

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error', style: Theme.of(context).textTheme.titleMedium),
                gap8,
                Text(
                  'Resumen no generado porque los siguientes viajes tienen datos faltantes:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          gap12,

          // Sample trips showing missing-data errors (replace with real data)
          TripsListSection(
            trips: [
              TripData(
                id: 1,
                origin: 'San Lorenzo',
                destination: 'Laboulaye',
                startDate: DateTime(2026, 1, 10),
                state: 'missing_data',
                documentType: '',
                documentNumber: '',
                estimatedKms: 0,
                loadWeightOnLoad: 0,
                loadWeightOnUnload: 0,
                calculatedPerKm: false,
                rate: 0,
                fuelOnClient: false,
                fuelLiters: 0,
                loadTypeId: 1,
                driverId: 1,
                driver: DriverData(
                  id: 1,
                  firstName: 'Carlos',
                  lastName: 'Sainz',
                ),
              ),
              TripData(
                id: 2,
                origin: 'Corral de Bustos',
                destination: 'Armstrong',
                startDate: DateTime(2026, 1, 12),
                state: 'missing_data',
                documentType: '',
                documentNumber: '',
                estimatedKms: 0,
                loadWeightOnLoad: 0,
                loadWeightOnUnload: 0,
                calculatedPerKm: false,
                rate: 0,
                fuelOnClient: false,
                fuelLiters: 0,
                loadTypeId: 1,
                driverId: 2,
                driver: DriverData(
                  id: 2,
                  firstName: 'Fernando',
                  lastName: 'Alonso',
                ),
              ),
            ],
            onTripTap: (trip) {
              // TODO: Handle trip tap/navigation
            },
          ),

          // Leave space for the FAB
          const SizedBox(height: 64),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Aprobar resumen'),
              content: const Text(
                'Estás seguro de que querés aprobar este resumen?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    // TODO: Implement approve summary functionality
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Aprobar'),
                ),
              ],
            ),
          );
          if (confirmed ?? false) {
            // TODO: call backend / update state to mark summary as approved
          }
        },
      ),
    );
  }
}
