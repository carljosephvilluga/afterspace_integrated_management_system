import 'package:flutter/material.dart';

enum BookingSpaceType { boardRoom, openSpace }

enum BookingStatus { reserved, checkedIn, cancelled }

class BookingReservation {
  const BookingReservation({
    this.backendId,
    required this.id,
    required this.customerName,
    required this.contactDetails,
    required this.spaceType,
    required this.start,
    required this.end,
    required this.customerType,
    required this.status,
  });

  final int? backendId;
  final String id;
  final String customerName;
  final String contactDetails;
  final BookingSpaceType spaceType;
  final DateTime start;
  final DateTime end;
  final String customerType;
  final BookingStatus status;

  BookingReservation copyWith({
    int? backendId,
    String? id,
    String? customerName,
    String? contactDetails,
    BookingSpaceType? spaceType,
    DateTime? start,
    DateTime? end,
    String? customerType,
    BookingStatus? status,
  }) {
    return BookingReservation(
      backendId: backendId ?? this.backendId,
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      contactDetails: contactDetails ?? this.contactDetails,
      spaceType: spaceType ?? this.spaceType,
      start: start ?? this.start,
      end: end ?? this.end,
      customerType: customerType ?? this.customerType,
      status: status ?? this.status,
    );
  }
}

class AvailabilityWindow {
  const AvailabilityWindow({
    required this.label,
    required this.start,
    required this.end,
    required this.boardRoomAvailable,
    required this.openSeatsLeft,
  });

  final String label;
  final DateTime start;
  final DateTime end;
  final bool boardRoomAvailable;
  final int openSeatsLeft;
}

class ReservationDraft {
  const ReservationDraft({
    required this.date,
    required this.startHour,
    required this.endHour,
    required this.spaceType,
    required this.customerName,
    required this.contactDetails,
  });

  final DateTime date;
  final int startHour;
  final int endHour;
  final BookingSpaceType spaceType;
  final String customerName;
  final String contactDetails;
}

extension BookingSpaceTypeX on BookingSpaceType {
  String get label {
    switch (this) {
      case BookingSpaceType.boardRoom:
        return 'Board Room';
      case BookingSpaceType.openSpace:
        return 'Open Space';
    }
  }

  int get capacity {
    switch (this) {
      case BookingSpaceType.boardRoom:
        return 1;
      case BookingSpaceType.openSpace:
        return 12;
    }
  }

  IconData get icon {
    switch (this) {
      case BookingSpaceType.boardRoom:
        return Icons.meeting_room_outlined;
      case BookingSpaceType.openSpace:
        return Icons.weekend_outlined;
    }
  }
}

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.reserved:
        return 'Reserved';
      case BookingStatus.checkedIn:
        return 'Checked-in';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.reserved:
        return const Color(0xFFC49672);
      case BookingStatus.checkedIn:
        return const Color(0xFF2E8B57);
      case BookingStatus.cancelled:
        return const Color(0xFFC95656);
    }
  }
}

const List<String> bookingMonthLabels = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const int bookingOpeningHour = 8;
const int bookingClosingHour = 23;
const int openSpaceCapacity = 12;

DateTime normalizeDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatMonthDayYear(DateTime value) {
  return '${bookingMonthLabels[value.month - 1]} ${value.day}, ${value.year}';
}

String formatTimeRange(DateTime start, DateTime end) {
  return '${formatHour(start.hour)} - ${formatHour(end.hour)}';
}

String formatHour(int hour) {
  final suffix = hour >= 12 ? 'PM' : 'AM';
  final normalized = hour % 12 == 0 ? 12 : hour % 12;
  return '$normalized:00 $suffix';
}

String buildReservationTooltip(List<BookingReservation> reservations) {
  if (reservations.isEmpty) {
    return 'No reservations';
  }

  return reservations
      .map(
        (reservation) =>
            '${formatTimeRange(reservation.start, reservation.end)}  ${reservation.customerName}  ${reservation.spaceType.label}',
      )
      .join('\n');
}

List<int> bookingYears({int startYear = 2025, int span = 8}) {
  return List<int>.generate(span, (index) => startYear + index);
}

List<int> bookingTimeOptions() {
  return List<int>.generate(
    bookingClosingHour - bookingOpeningHour + 1,
    (index) => bookingOpeningHour + index,
  );
}

List<BookingReservation> sampleReservations() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final selectedDay = DateTime(now.year, now.month, 9);

  return [
    BookingReservation(
      id: 'BK-${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}-001',
      customerName: 'Juan Dela Cruz',
      contactDetails: '09171234567',
      spaceType: BookingSpaceType.openSpace,
      start: DateTime(today.year, today.month, today.day, 8),
      end: DateTime(today.year, today.month, today.day, 11),
      customerType: 'Student',
      status: BookingStatus.reserved,
    ),
    BookingReservation(
      id: 'BK-${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}-002',
      customerName: 'Mika Santos',
      contactDetails: 'mika.santos@example.com',
      spaceType: BookingSpaceType.boardRoom,
      start: DateTime(today.year, today.month, today.day, 10),
      end: DateTime(today.year, today.month, today.day, 12),
      customerType: 'Professional',
      status: BookingStatus.checkedIn,
    ),
    BookingReservation(
      id: 'BK-${selectedDay.year}${selectedDay.month.toString().padLeft(2, '0')}${selectedDay.day.toString().padLeft(2, '0')}-003',
      customerName: 'Andrea Lim',
      contactDetails: 'andrea.lim@example.com',
      spaceType: BookingSpaceType.boardRoom,
      start: DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 13),
      end: DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 15),
      customerType: 'Student',
      status: BookingStatus.reserved,
    ),
    BookingReservation(
      id: 'BK-${selectedDay.year}${selectedDay.month.toString().padLeft(2, '0')}${selectedDay.day.toString().padLeft(2, '0')}-004',
      customerName: 'Paolo Reyes',
      contactDetails: '09987654321',
      spaceType: BookingSpaceType.openSpace,
      start: DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 9),
      end: DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 12),
      customerType: 'Professional',
      status: BookingStatus.reserved,
    ),
    BookingReservation(
      id: 'BK-${tomorrow.year}${tomorrow.month.toString().padLeft(2, '0')}${tomorrow.day.toString().padLeft(2, '0')}-005',
      customerName: 'Jenny Wilson',
      contactDetails: 'j.wilson@example.com',
      spaceType: BookingSpaceType.openSpace,
      start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14),
      end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 17),
      customerType: 'Guest',
      status: BookingStatus.reserved,
    ),
  ];
}

bool reservationsOverlap(
  DateTime startA,
  DateTime endA,
  DateTime startB,
  DateTime endB,
) {
  return startA.isBefore(endB) && endA.isAfter(startB);
}

List<BookingReservation> reservationsForDay(
  List<BookingReservation> reservations,
  DateTime day,
) {
  return reservations
      .where(
        (reservation) =>
            reservation.status != BookingStatus.cancelled &&
            isSameDate(reservation.start, day),
      )
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
}

List<BookingReservation> reservationsForToday(
  List<BookingReservation> reservations,
) {
  return reservationsForDay(reservations, DateTime.now());
}

List<BookingReservation> reservationsForSpace(
  List<BookingReservation> reservations,
  DateTime day,
  BookingSpaceType spaceType,
) {
  return reservationsForDay(
    reservations,
    day,
  ).where((reservation) => reservation.spaceType == spaceType).toList();
}

int openSeatsLeftForRange(
  List<BookingReservation> reservations,
  DateTime day,
  int startHour,
  int endHour,
) {
  final rangeStart = DateTime(day.year, day.month, day.day, startHour);
  final rangeEnd = DateTime(day.year, day.month, day.day, endHour);
  final overlaps =
      reservationsForSpace(reservations, day, BookingSpaceType.openSpace).where(
        (reservation) => reservationsOverlap(
          reservation.start,
          reservation.end,
          rangeStart,
          rangeEnd,
        ),
      );

  final usedSeats = overlaps.length;
  return openSpaceCapacity - usedSeats;
}

bool boardRoomAvailableForRange(
  List<BookingReservation> reservations,
  DateTime day,
  int startHour,
  int endHour,
) {
  final rangeStart = DateTime(day.year, day.month, day.day, startHour);
  final rangeEnd = DateTime(day.year, day.month, day.day, endHour);
  return reservationsForSpace(
    reservations,
    day,
    BookingSpaceType.boardRoom,
  ).every(
    (reservation) => !reservationsOverlap(
      reservation.start,
      reservation.end,
      rangeStart,
      rangeEnd,
    ),
  );
}

String? availabilityErrorForDraft(
  List<BookingReservation> reservations,
  ReservationDraft draft,
) {
  if (draft.customerName.trim().isEmpty ||
      draft.contactDetails.trim().isEmpty) {
    return 'Enter the customer name and contact details.';
  }

  if (draft.endHour <= draft.startHour) {
    return 'The end time must be later than the start time.';
  }

  if (draft.startHour < bookingOpeningHour ||
      draft.endHour > bookingClosingHour) {
    return 'Bookings must stay within operating hours.';
  }

  switch (draft.spaceType) {
    case BookingSpaceType.boardRoom:
      if (!boardRoomAvailableForRange(
        reservations,
        draft.date,
        draft.startHour,
        draft.endHour,
      )) {
        return 'Board Room is already reserved for that time.';
      }
      break;
    case BookingSpaceType.openSpace:
      if (openSeatsLeftForRange(
            reservations,
            draft.date,
            draft.startHour,
            draft.endHour,
          ) <=
          0) {
        return 'Open Space has no available seats for that time.';
      }
      break;
  }

  return null;
}

List<AvailabilityWindow> availabilityWindowsForDay(
  List<BookingReservation> reservations,
  DateTime day,
) {
  return List<AvailabilityWindow>.generate(
    bookingClosingHour - bookingOpeningHour,
    (index) {
      final startHour = bookingOpeningHour + index;
      final endHour = startHour + 1;
      return AvailabilityWindow(
        label: '${formatHour(startHour)} - ${formatHour(endHour)}',
        start: DateTime(day.year, day.month, day.day, startHour),
        end: DateTime(day.year, day.month, day.day, endHour),
        boardRoomAvailable: boardRoomAvailableForRange(
          reservations,
          day,
          startHour,
          endHour,
        ),
        openSeatsLeft: openSeatsLeftForRange(
          reservations,
          day,
          startHour,
          endHour,
        ),
      );
    },
  );
}

String nextBoardRoomAvailability(
  List<BookingReservation> reservations,
  DateTime day,
) {
  final windows = availabilityWindowsForDay(
    reservations,
    day,
  ).where((window) => window.boardRoomAvailable).take(3).toList();

  if (windows.isEmpty) {
    return 'Fully reserved today';
  }

  return windows.map((window) => window.label).join('\n');
}

String nextOpenSpaceAvailability(
  List<BookingReservation> reservations,
  DateTime day,
) {
  final windows = availabilityWindowsForDay(
    reservations,
    day,
  ).where((window) => window.openSeatsLeft > 0).take(3).toList();

  if (windows.isEmpty) {
    return 'No seats available today';
  }

  return windows
      .map((window) => '${window.label}  •  ${window.openSeatsLeft} seats left')
      .join('\n');
}
