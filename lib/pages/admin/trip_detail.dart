import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/widgets/trip_fab_menu.dart';
import 'package:frontend_sgfcp/widgets/simple_card.dart';
import 'package:frontend_sgfcp/pages/admin/finish_trip.dart';
import 'package:frontend_sgfcp/pages/admin/edit_trip.dart';
import 'package:frontend_sgfcp/pages/admin/add_expense.dart';
import 'package:intl/intl.dart';

class TripDetailPageAdmin extends StatelessWidget {
  final bool isFinished;

  const TripDetailPageAdmin({
    super.key,
    this.isFinished = false,
  });

  static const String routeName = '/admin/trip-detail';

  static Route route({bool isFinished = false}) {
    return MaterialPageRoute<void>(
      builder: (_) => TripDetailPageAdmin(isFinished: isFinished),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaje'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con origen-destino
            Container(
              width: double.infinity,
              color: colors.surfaceContainerHighest,
              padding: const EdgeInsets.all(16),
              child: Text(
                'Mattaldi → San Lorenzo',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón Finalizar o Badge (según el estado)
                  if (!isFinished)
                    SimpleCard(
                      title: 'Viaje en curso',
                      icon: Symbols.where_to_vote,
                      label: 'Finalizar',
                      onPressed: () {
                        Navigator.of(context).push(FinishTripPageAdmin.route());
                      },
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Viaje finalizado',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  gap16,

                  // Sección Chofer
                  _SectionHeader(
                    title: 'Chofer',
                    icon: Symbols.person,
                    iconColor: colors.secondaryContainer,
                  ),
                  gap8,
                  _InfoRow(label: 'Nombre', value: 'Carlos Sainz'),

                  gap24,

                  // Sección Fechas
                  _SectionHeader(
                    title: 'Fechas',
                    icon: Symbols.calendar_today,
                  ),
                  gap8,
                  if (!isFinished) ...[
                    _InfoRow(label: 'Inicio', value: '11/09/2025'),
                    _InfoRow(label: 'Fin', value: 'Viaje no finalizado'),
                  ] else
                    _InfoRow(label: 'Fin', value: '11/09/2025'),

                  gap24,

                  // Balance (solo si está finalizado)
                  if (isFinished) ...[
                    _SectionTitle(title: 'Balance'),
                    gap8,
                    _InfoRow(
                      label: 'Comisión total',
                      value: currencyFormat.format(1064000),
                    ),
                    _InfoRow(
                      label: 'Gastos totales',
                      value: currencyFormat.format(61300),
                    ),
                    _InfoRow(
                      label: 'Balance final',
                      value: currencyFormat.format(1002700),
                      valueStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    gap24,
                  ],

                  // Sección Información
                  _SectionTitle(title: 'Información'),
                  gap8,
                  _InfoRow(label: 'Dador de carga', value: 'Monagro SA'),
                  _InfoRow(label: 'Cliente', value: 'Capieletti'),
                  _InfoRow(label: 'Distancia', value: '180 km'),
                  _InfoRow(label: 'Combustible', value: 'Por parte del cliente'),
                  _InfoRow(label: 'Código de transporte', value: '6454987'),

                  gap24,

                  // Sección Documento de Remito
                  _SectionTitle(title: 'Documento de Remito'),
                  gap8,
                  _InfoRow(label: 'Número', value: '465138743164'),

                  gap24,

                  // Sección Carga
                  _SectionTitle(title: 'Carga'),
                  gap8,
                  _InfoRow(label: 'Tipo', value: 'Maíz'),
                  _InfoRow(label: 'Peso', value: '30.000 kg'),
                  if (isFinished)
                    _InfoRow(label: 'Peso luego de descarga', value: '28.000 kg'),

                  gap24,

                  // Sección Tarifa
                  _SectionTitle(title: 'Tarifa'),
                  gap8,
                  _InfoRow(
                    label: 'Tipo',
                    value: isFinished ? 'Por tonelada' : 'Por tonelada',
                  ),
                  _InfoRow(
                    label: 'Tarifa',
                    value: isFinished
                        ? currencyFormat.format(38000)
                        : currencyFormat.format(50000),
                  ),

                  gap24,

                  // Adelanto del cliente
                  _SectionHeader(
                    title: 'Adelanto del cliente',
                    icon: Symbols.payments,
                    iconColor: colors.secondaryContainer,
                  ),
                  gap8,
                  _InfoRow(
                    label: 'Importe',
                    value: currencyFormat.format(isFinished ? 60000 : 60000),
                  ),

                  gap24,

                  // Gastos (solo si está finalizado)
                  if (isFinished) ...[
                    _SectionTitle(title: 'Gastos'),
                    gap8,
                    Card.outlined(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: const Text('Tipo'),
                            trailing: const Text('Importe'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: const Text('Peaje'),
                            trailing: Text(currencyFormat.format(1300)),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: const Text('Combustible'),
                            trailing: Text(currencyFormat.format(60000)),
                          ),
                        ],
                      ),
                    ),
                    gap24,
                  ],

                  // Espacio para el FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: TripFabMenu(
        onAddExpense: () {
          Navigator.of(context).push(AddExpensePageAdmin.route());
        },
        onEditTrip: () {
          Navigator.of(context).push(EditTripPageAdmin.route());
        },
      ),
    );
  }
}

/// Encabezado de sección con ícono
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor ?? colors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor != null
                ? colors.onSecondaryContainer
                : colors.onSurfaceVariant,
          ),
        ),
        gapW12,
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Título de sección simple
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Fila de información
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          gapW16,
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: valueStyle ?? textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
