import 'package:aims/screens/dashboard/booking_management/booking_models.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingCalendarCard extends StatelessWidget {
  const BookingCalendarCard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.hoveredDay,
    required this.reservations,
    required this.onDaySelected,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDayHovered,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final DateTime? hoveredDay;
  final List<BookingReservation> reservations;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime?> onDayHovered;

  static const Color _panel = Colors.white;
  static const Color _text = Color(0xFF22313A);
  static const Color _muted = Color(0xFF71808A);
  static const Color _accent = Color(0xFFC49672);
  static const Color _accentSoft = Color(0xFFF1E4D8);
  static const Color _danger = Color(0xFFC95656);

  List<BookingReservation> _bookingsFor(DateTime day) {
    return reservationsForDay(reservations, day);
  }

  @override
  Widget build(BuildContext context) {
    final hoveredBookings =
        hoveredDay == null ? const <BookingReservation>[] : _bookingsFor(hoveredDay!);
    final selectedWindows = availabilityWindowsForDay(reservations, selectedDay);

    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _arrowButton(Icons.chevron_left_rounded, onPrevMonth),
              const SizedBox(width: 8),
              Expanded(
                child: _selectorShell(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: focusedDay.month,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      items: List.generate(
                        bookingMonthLabels.length,
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(bookingMonthLabels[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          onMonthChanged(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _selectorShell(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: focusedDay.year,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      items: bookingYears().map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onYearChanged(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _arrowButton(Icons.chevron_right_rounded, onNextMonth),
            ],
          ),
          const SizedBox(height: 12),
          TableCalendar<BookingReservation>(
            firstDay: DateTime(2025, 1, 1),
            lastDay: DateTime(2035, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDate(day, selectedDay),
            headerVisible: false,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            eventLoader: _bookingsFor,
            availableGestures: AvailableGestures.horizontalSwipe,
            onPageChanged: (_) {},
            onDaySelected: (selected, focused) {
              onDaySelected(selected);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _dayCell(day);
              },
              todayBuilder: (context, day, focusedDay) {
                return _dayCell(day, isToday: true);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _dayCell(day, isSelected: true);
              },
              outsideBuilder: (context, day, focusedDay) {
                return _dayCell(day, isOutside: true);
              },
              markerBuilder: (context, day, events) {
                if (events.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  bottom: 6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: true,
              cellMargin: EdgeInsets.all(4),
              defaultDecoration: BoxDecoration(shape: BoxShape.circle),
              todayDecoration: BoxDecoration(shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(shape: BoxShape.circle),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Availability for ${formatMonthDayYear(selectedDay)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedWindows.take(8).map((window) {
              final isBlocked =
                  !window.boardRoomAvailable && window.openSeatsLeft <= 0;
              return Container(
                width: 148,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: isBlocked ? const Color(0xFFF8E1E1) : _accentSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isBlocked ? _danger.withOpacity(0.3) : _accent.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      window.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      window.boardRoomAvailable
                          ? 'Board Room open'
                          : 'Board Room reserved',
                      style: TextStyle(
                        fontSize: 11,
                        color: window.boardRoomAvailable ? const Color(0xFF2E8B57) : _danger,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Open Space: ${window.openSeatsLeft} seats left',
                      style: TextStyle(
                        fontSize: 11,
                        color: window.openSeatsLeft > 0 ? _muted : _danger,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F1EB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: hoveredBookings.isEmpty
                ? const Text(
                    'Hover over a date with bookings to preview reservations.',
                    style: TextStyle(fontSize: 12, color: _muted),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reservations on ${formatMonthDayYear(hoveredDay!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...hoveredBookings.take(3).map(
                        (booking) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${formatTimeRange(booking.start, booking.end)} • ${booking.customerName} • ${booking.spaceType.label}',
                            style: const TextStyle(fontSize: 11, color: _muted),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _selectorShell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _text),
      ),
    );
  }

  Widget _dayCell(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
    bool isOutside = false,
  }) {
    final events = _bookingsFor(day);
    final boardRoomBusy = !boardRoomAvailableForRange(
      reservations,
      day,
      bookingOpeningHour,
      bookingClosingHour,
    );
    final bookedOutOpenSpace = openSeatsLeftForRange(
          reservations,
          day,
          bookingOpeningHour,
          bookingClosingHour,
        ) <=
        0;
    final fullyBooked = boardRoomBusy && bookedOutOpenSpace;

    final bgColor = isSelected
        ? _accent
        : isToday
            ? _accentSoft
            : fullyBooked
                ? const Color(0xFFF9E0E0)
                : Colors.transparent;
    final textColor = isOutside
        ? const Color(0xFFC4CBD0)
        : isSelected
            ? Colors.white
            : fullyBooked
                ? _danger
                : _text;

    return MouseRegion(
      onEnter: (_) => onDayHovered(day),
      onExit: (_) => onDayHovered(null),
      child: Tooltip(
        message: buildReservationTooltip(events),
        waitDuration: const Duration(milliseconds: 150),
        child: InkWell(
          onTap: () => onDaySelected(day),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _accent
                    : isToday
                        ? _accent.withOpacity(0.35)
                        : Colors.transparent,
              ),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
