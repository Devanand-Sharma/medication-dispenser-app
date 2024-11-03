import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_view/calendar_view.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final EventController _eventController = EventController();
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final GlobalKey<DayViewState> _dayViewKey = GlobalKey<DayViewState>();

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: _eventController,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer()),
          title: const Text('History'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.calendar_month_rounded),
            ),
          ],
        ),
        body: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              TableCalendar(
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  outsideTextStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  selectedTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary),
                  todayTextStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                weekendDays: const [],
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.week: 'Week',
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _dayViewKey.currentState?.animateToDate(selectedDay);
                  });
                },
                firstDay: DateTime.utc(2012, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: DayView(
                  key: _dayViewKey,
                  controller: _eventController,
                  eventTileBuilder: (date, events, boundry, start, end) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        events.first.title,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  },
                  showVerticalLine: true,
                  showLiveTimeLineInAllDays: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  minDay: DateTime(2020),
                  maxDay: DateTime(2030),
                  initialDay: _selectedDay,
                  heightPerMinute: 1,
                  eventArranger: const SideEventArranger(),
                  dayTitleBuilder: DayHeader.hidden,
                  onEventTap: (events, date) {
                    // Add some action to when we tap on events
                  },
                  onDateLongPress: (date) {
                    // If we want special actions for holding events.
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
