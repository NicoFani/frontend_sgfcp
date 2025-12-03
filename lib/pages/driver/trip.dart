import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/simple_table_row_data.dart';
import 'package:frontend_sgfcp/models/info_item.dart';

import 'package:frontend_sgfcp/pages/driver/edit_expense.dart';
import 'package:frontend_sgfcp/pages/driver/expense.dart';
import 'package:frontend_sgfcp/pages/driver/finish_trip.dart';
import 'package:frontend_sgfcp/pages/driver/edit_trip.dart';
import 'package:frontend_sgfcp/widgets/trip_fab_menu.dart';
import 'package:frontend_sgfcp/widgets/info_card.dart';
import 'package:frontend_sgfcp/widgets/inline_info_card.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
import 'package:frontend_sgfcp/widgets/simple_table.dart';

class TripPage extends StatelessWidget {
  const TripPage({super.key});

  static const String routeName = '/trip';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const TripPage());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Viaje'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mattaldi→San Lorenzo',
                style: textTheme.titleLarge,
              ),
              gap8,
              SimpleCard(
                title: 'Viaje en curso',
                icon: Symbols.where_to_vote,
                label: 'Finalizar',
                onPressed: () { Navigator.of(context).push(FinishTripPage.route()); },
              ),
              const FinishedTripCard(),
              gap4,
              InlineInfoCard(
                title: 'Fechas',
                leftLabel: 'Inicio',
                leftValue: '11/09/2025',
                rightLabel: 'Fin',
                rightValue: 'Viaje no finalizado',
              ),
              gap4,
              InfoCard(
                title: 'Balance',
                items: const [
                  InfoItem(label: 'Comisión total', value: '\$1.064.000'),
                  InfoItem(label: 'Gastos totales', value: '\$329.000'),
                  InfoItem(label: 'Balance final', value: '\$735.000'),
                ],
              ),
              gap4,
              InfoCard(
                title: 'Información',
                items: const [
                  InfoItem(label: 'Dador de carga', value: 'Maniagro SA'),
                  InfoItem(label: 'Cliente', value: 'Capelletti'),
                  InfoItem(label: 'Distancia', value: '180 km'),
                  InfoItem(label: 'Código de transporte', value: '6454987'),
                  InfoItem(label: 'Vale para combustible', value: '329 lts'),
                  InfoItem(label: 'Adelanto del cliente', value: '\$150.000'),
                ],
              ),
              gap4,
              InlineInfoCard(
                title: 'Documento',
                leftLabel: 'Tipo',
                leftValue: 'Remito',
                rightLabel: 'Número',
                rightValue: '465138743164',
              ),
              gap4,
              InfoCard(
                title: 'Carga',
                items: const [
                  InfoItem(label: 'Tipo', value: 'Maíz'),
                  InfoItem(label: 'Peso', value: '30.000 kg'),
                  InfoItem(label: 'Peso luego de descarga', value: 'Viaje no finalizado'),
                ],
              ),
              gap4,
              InlineInfoCard(
                title: 'Tarifa',  
                leftLabel: 'Tipo',
                leftValue: 'Por tonelada',
                rightLabel: 'Tarifa',
                rightValue: '\$50.000/t',
              ),
              gap16,
              SimpleTable(
                title: 'Gastos',
                headers: ['Tipo', 'Importe', 'Editar'],
                rows: [
                  SimpleTableRowData(
                    col1: 'Peaje',
                    col2: '\$1.300',
                    onEdit: () { Navigator.of(context).push(EditExpensePage.route()); },
                  ),
                  SimpleTableRowData(
                    col1: 'Combustible',
                    col2: '\$60.000',
                    onEdit: () { Navigator.of(context).push(EditExpensePage.route()); },
                  ),
                ],
              ),
              const SizedBox(height: 60), // Espacio para el FAB
            ],
          ),
        ),
      ),
      floatingActionButton: TripFabMenu(
        onAddExpense: () {
          Navigator.of(context).push(ExpensePage.route());
        },
        onEditTrip: () {
          Navigator.of(context).push(EditTripPage.route());
        },
      ),
    );
  }
}

class FinishedTripCard extends StatelessWidget {
  const FinishedTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colors.secondaryContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            'Viaje finalizado',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: colors.onSecondaryContainer),
          ),
        ),
      ),
    );
  }
}