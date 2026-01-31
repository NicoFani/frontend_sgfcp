import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend_sgfcp/models/trip_data.dart';

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
      final endDate = trip.endDate;

      final normalizedStart = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      _eventsMap.putIfAbsent(normalizedStart, () => []).add(trip);

      if (endDate != null && endDate != startDate) {
        final normalizedEnd = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
        );
        _eventsMap.putIfAbsent(normalizedEnd, () => []).add(trip);
      }
    }
  }

  List<TripData> _getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _eventsMap[normalized] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
            onDaySelected: (selectedDay, focusedDay) { //TODO: Dialog con detalles de viajes del día
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
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
                      color: colors.secondary.withValues(alpha: 0.7), // TODO: Color condicional según estado del viaje
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
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
    ); 
  }
}
