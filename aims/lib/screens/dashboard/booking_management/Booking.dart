import 'package:aims/screens/dashboard/booking_management/booking_models.dart';
import 'package:flutter/material.dart';

class AddReservationCard extends StatefulWidget {
  const AddReservationCard({
    super.key,
    required this.selectedDate,
    required this.reservations,
    required this.onDateChanged,
    required this.onReservationSaved,
  });

  final DateTime selectedDate;
  final List<BookingReservation> reservations;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<ReservationDraft> onReservationSaved;

  @override
  State<AddReservationCard> createState() => _AddReservationCardState();
}

class _AddReservationCardState extends State<AddReservationCard> {
  late int _month;
  late int _day;
  late int _year;
  int _fromHour = bookingOpeningHour;
  int _toHour = bookingOpeningHour + 1;
  BookingSpaceType _spaceType = BookingSpaceType.boardRoom;
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _tanSoft = Color(0xFFEBD9CA);
  static const Color _text = Color(0xFF23323A);
  static const Color _muted = Color(0xFF6F7E87);
  static const Color _danger = Color(0xFFC95656);

  @override
  void initState() {
    super.initState();
    _syncDate(widget.selectedDate);
  }

  @override
  void didUpdateWidget(covariant AddReservationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDate(oldWidget.selectedDate, widget.selectedDate)) {
      _syncDate(widget.selectedDate);
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _syncDate(DateTime date) {
    _month = date.month;
    _day = date.day;
    _year = date.year;
  }

  DateTime get _draftDate => DateTime(_year, _month, _day);

  ReservationDraft get _draft => ReservationDraft(
    date: _draftDate,
    startHour: _fromHour,
    endHour: _toHour,
    spaceType: _spaceType,
    customerName: _customerController.text,
    contactDetails: _contactController.text,
  );

  String? get _errorText =>
      availabilityErrorForDraft(widget.reservations, _draft);

  List<int> get _daysInMonth {
    final lastDay = DateTime(_year, _month + 1, 0).day;
    return List<int>.generate(lastDay, (index) => index + 1);
  }

  void _notifyDateChange() {
    final nextDate = DateTime(_year, _month, _day);
    widget.onDateChanged(nextDate);
  }

  @override
  Widget build(BuildContext context) {
    final errorText = _errorText;
    final canSubmit = errorText == null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _headerBlue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Add Reservation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Calendar date: ${formatMonthDayYear(widget.selectedDate)}',
              style: const TextStyle(fontSize: 12, color: _muted),
            ),
            const SizedBox(height: 12),
            const Text(
              'Date',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _dropdownShell(
                    value: _month,
                    items: List.generate(
                      bookingMonthLabels.length,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(bookingMonthLabels[index]),
                      ),
                    ),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _month = value;
                        if (!_daysInMonth.contains(_day)) {
                          _day = _daysInMonth.last;
                        }
                      });
                      _notifyDateChange();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _dropdownShell(
                    value: _day,
                    items: _daysInMonth
                        .map(
                          (day) => DropdownMenuItem<int>(
                            value: day,
                            child: Text('$day'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _day = value);
                      _notifyDateChange();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _dropdownShell(
                    value: _year,
                    items: bookingYears().map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text('$year'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _year = value;
                        if (!_daysInMonth.contains(_day)) {
                          _day = _daysInMonth.last;
                        }
                      });
                      _notifyDateChange();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Time',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _timeDropdown(
                    label: 'From',
                    value: _fromHour,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _fromHour = value;
                        if (_toHour <= _fromHour) {
                          _toHour = _fromHour + 1;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _timeDropdown(
                    label: 'To',
                    value: _toHour,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _toHour = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Space Type',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 6),
            _dropdownShell(
              value: _spaceType,
              items: BookingSpaceType.values.map((type) {
                return DropdownMenuItem<BookingSpaceType>(
                  value: type,
                  child: Text(type.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _spaceType = value);
              },
            ),
            const SizedBox(height: 14),
            const Text(
              'Customer Name',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 6),
            _textField(
              controller: _customerController,
              hintText: 'Enter full name',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            const Text(
              'Contact Details',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 6),
            _textField(
              controller: _contactController,
              hintText: 'Phone or email',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorText == null
                    ? _tanSoft.withValues(alpha: 0.58)
                    : const Color(0xFFFFE6E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorText == null
                      ? Colors.white.withValues(alpha: 0.75)
                      : _danger.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                errorText ??
                    '${_spaceType.label} is available for ${formatHour(_fromHour)} to ${formatHour(_toHour)}.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: errorText == null ? _muted : _danger,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubmit
                    ? () {
                        widget.onReservationSaved(_draft);
                        _customerController.clear();
                        _contactController.clear();
                        setState(() {});
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tanSoft,
                  foregroundColor: _text,
                  disabledBackgroundColor: const Color(0xFFE2D7CA),
                  elevation: 0,
                  side: const BorderSide(color: Color(0x2A23323A)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Add Reservation',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownShell<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _timeDropdown({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    final values = label == 'From'
        ? bookingTimeOptions()
              .where((hour) => hour < bookingClosingHour)
              .toList()
        : bookingTimeOptions()
              .where((hour) => hour > bookingOpeningHour)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _muted,
          ),
        ),
        const SizedBox(height: 4),
        _dropdownShell(
          value: value,
          items: values
              .map(
                (hour) => DropdownMenuItem<int>(
                  value: hour,
                  child: Text(formatHour(hour)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.76),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _headerBlue),
        ),
      ),
    );
  }
}
