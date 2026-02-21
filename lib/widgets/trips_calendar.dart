import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/pages/shared/trip.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';


class TripsCalendar extends StatefulWidget {
  final List<TripData> trips;
  final ValueChanged<DateTime>? onDaySelected;

  const TripsCalendar({
    super.key,
    required this.trips,
    this.onDaySelected,
  });

  @override
  State<TripsCalendar> createState() => _TripsCalendarState();
}

class _TripsCalendarState extends State<TripsCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Map<DateTime, List<TripData>> _eventsMap;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _buildEventsMap();
  }

  @override
  void didUpdateWidget(TripsCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trips != widget.trips) {
      _buildEventsMap();
    }
  }

  void _buildEventsMap() {
    _eventsMap = {};
    for (final trip in widget.trips) {
      final startDate = trip.startDate;

      final normalizedStart = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      _eventsMap.putIfAbsent(normalizedStart, () => []).add(trip);
    }
  }

  List<TripData> _getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _eventsMap[normalized] ?? [];
  }

  // Trip state color helpers
  Color _finishedTripColor(ColorScheme colors) => colors.primary;
  Color _ongoingTripColor(ColorScheme colors) => colors.secondary;
  Color _scheduledTripColor(ColorScheme colors) => colors.onSecondaryFixedVariant;
  Color _moreThanOneTrip(ColorScheme colors) => colors.tertiary;

  Color _getDayColor(
    ColorScheme colors,
    List<TripData> trips,
    String type,
  ) {
    final states = trips.map((t) => t.state).toSet();

    if (type == 'label') {
      if (states.length != 1) {
        return colors.onPrimary;
      }

      switch (states.first) {
        case 'Finalizado':
          return colors.onPrimary;
        case 'Pendiente':
          return colors.onTertiary;
        default:
          return colors.onSecondaryContainer;
      }
    }

    if (states.length != 1) {
      return _moreThanOneTrip(colors).withValues(alpha: 0.7);
    }

    switch (states.first) {
      case 'Finalizado':
        return _finishedTripColor(colors).withValues(alpha: 0.7);
      case 'En curso':
        return _ongoingTripColor(colors).withValues(alpha: 0.7);
      case 'Pendiente':
        return _scheduledTripColor(colors).withValues(alpha: 0.7);
      default:
        return colors.onPrimaryContainer.withValues(alpha: 0.7);
    }
  }

  Color _getTripStateColor(ColorScheme colors, TripData trip) {
    switch (trip.state) {
      case 'Finalizado':
        return _finishedTripColor(colors);
      case 'En curso':
        return _ongoingTripColor(colors);
      case 'Pendiente':
        return _scheduledTripColor(colors);
      default:
        return _moreThanOneTrip(colors);
    }
  }

  Future<void> _showTripsForDay(DateTime day) async {
    final events = _getEventsForDay(day);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final title = DateFormat.yMMMMEEEEd(locale).format(day);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return TripsDayDialog(
          title: title,
          trips: events,
          stateColorBuilder: _getTripStateColor,
          onTripTap: (trip) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              TripPage.route(tripId: trip.id, trip: trip),
            );
          },
        );
      },
    );
  }

  void _showColorGuideDialog(BuildContext context, ColorScheme colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guia de colores'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Pendiente'),
              leading: Icon(Icons.circle, size: 12, color: _scheduledTripColor(colors).withValues(alpha: 0.7),),
              visualDensity: VisualDensity.compact,
            ),
            ListTile(
              title: Text('En curso'),
              leading: Icon(Icons.circle, size: 12, color: _ongoingTripColor(colors).withValues(alpha: 0.7),),
              visualDensity: VisualDensity.compact,
            ),
            ListTile(
              title: Text('Finalizado'),
              leading: Icon(Icons.circle, size: 12, color: _finishedTripColor(colors).withValues(alpha: 0.7),),
              visualDensity: VisualDensity.compact,
            ),
            ListTile(
              title: Text('Más de un viaje'),
              leading: Icon(Icons.circle, size: 12, color: _moreThanOneTrip(colors).withValues(alpha: 0.7),),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Viajes', style: textTheme.titleLarge),
            IconButton(
              onPressed: () => _showColorGuideDialog(context, colors),
              icon: Icon(Icons.info_outline, color: colors.onSurfaceVariant),
            )
          ],
        ),
        gap8,
        Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TableCalendar(
                locale: Localizations.localeOf(context).toString(),
                firstDay: DateTime(DateTime.now().year - 2),
                lastDay: DateTime(DateTime.now().year + 2),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  if (_getEventsForDay(selectedDay).isNotEmpty) {
                    _showTripsForDay(selectedDay);
                  }
                  widget.onDaySelected?.call(selectedDay);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final events = _getEventsForDay(day);
                    if (events.isNotEmpty) {
                      return Container(
                        decoration: BoxDecoration(
                          color: _getDayColor(colors, events, 'decoration'),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: _getDayColor(colors, events, 'label'),
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.primary,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: textTheme.titleLarge ?? const TextStyle(),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: colors.onSurface,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: colors.onSurface,
                  ),
                ),
            )
                  ),
        ),
      ],
    ); 
  }
}

class TripsDayDialog extends StatelessWidget {
  final String title;
  final List<TripData> trips;
  final Color Function(ColorScheme, TripData) stateColorBuilder;
  final ValueChanged<TripData> onTripTap;

  const TripsDayDialog({
    super.key,
    required this.title,
    required this.trips,
    required this.stateColorBuilder,
    required this.onTripTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bool isAdmin =
      (TokenStorage.user != null && TokenStorage.user!['is_admin'] == true);

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 360,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: trips.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final trip = trips[index];
            final driverName = trip.driver?.fullName ?? 'Sin chofer';
            return ListTile(
              title: Text(trip.route),
              subtitle: isAdmin ? Text(driverName) : null,
              leading: Icon(
                Icons.circle,
                size: 12,
                color: stateColorBuilder(colors, trip),
              ),
              onTap: () => onTripTap(trip),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
