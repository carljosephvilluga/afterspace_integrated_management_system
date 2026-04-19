import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarChart extends StatefulWidget {
  const CalendarChart({
    super.key,
    this.allowMeetingScheduling = false,
  });

  final bool allowMeetingScheduling;

  @override
  State<CalendarChart> createState() => _CalendarChartState();
}

class _CalendarChartState extends State<CalendarChart> {
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF7D8B93);
  static const Color _textOutside = Color(0xFFB2BEC6);
  static const Color _meetingAccent = Color(0xFF80AEC1);

  DateTime _focusedDay = DateTime(2025, 9, 1);
  DateTime? _selectedMeetingDay = DateTime(2025, 9, 9);
  final Map<DateTime, List<_MeetingSchedule>> _meetingSchedules = {
    DateTime(2025, 9, 9): [
      _MeetingSchedule(title: 'Operations Sync', time: '9:00 AM'),
    ],
  };

  final List<String> _months = const [
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

  List<int> get _years => List.generate(11, (index) => 2020 + index);

  DateTime _normalizeDay(DateTime day) => DateTime(day.year, day.month, day.day);

  List<_MeetingSchedule> get _selectedDayMeetings {
    if (_selectedMeetingDay == null) {
      return const [];
    }

    return _meetingSchedules[_normalizeDay(_selectedMeetingDay!)] ?? const [];
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  bool _isSame(DateTime? a, DateTime b) {
    if (a == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _openMeetingDialog(DateTime selectedDay) async {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    String? errorText;

    final newMeeting = await showDialog<_MeetingSchedule>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Schedule meeting for ${selectedDay.month}/${selectedDay.day}/${selectedDay.year}',
              ),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_meetingSchedules[_normalizeDay(selectedDay)] case final meetings?)
                      ...[
                        const Text(
                          'Existing schedules',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...meetings.map(
                          (meeting) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '${meeting.time} - ${meeting.title}',
                              style: const TextStyle(
                                color: _textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Meeting title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        hintText: 'e.g. 2:00 PM',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorText!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final time = timeController.text.trim();

                    if (title.isEmpty || time.isEmpty) {
                      setDialogState(() {
                        errorText = 'Add both a meeting title and time.';
                      });
                      return;
                    }

                    Navigator.of(context).pop(
                      _MeetingSchedule(title: title, time: time),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    timeController.dispose();

    if (newMeeting == null) {
      return;
    }

    final normalizedDay = _normalizeDay(selectedDay);
    setState(() {
      final meetings = List<_MeetingSchedule>.from(
        _meetingSchedules[normalizedDay] ?? const [],
      )..add(newMeeting);
      _meetingSchedules[normalizedDay] = meetings;
      _selectedMeetingDay = normalizedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Row(
              children: [
                _buildArrowButton(Icons.chevron_left_rounded, _previousMonth),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdownShell(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _focusedDay.month,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 12,
                        ),
                        items: List.generate(
                          12,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(_months[index]),
                          ),
                        ),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _focusedDay = DateTime(_focusedDay.year, value, 1);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdownShell(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _focusedDay.year,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 12,
                        ),
                        items: _years
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _focusedDay = DateTime(value, _focusedDay.month, 1);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildArrowButton(Icons.chevron_right_rounded, _nextMonth),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => _isSame(_selectedMeetingDay, day),
                headerVisible: false,
                availableGestures: AvailableGestures.none,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                sixWeekMonthsEnforced: false,
                rowHeight: 27,
                daysOfWeekHeight: 22,
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedMeetingDay = selectedDay;
                  });

                  if (widget.allowMeetingScheduling) {
                    _openMeetingDialog(selectedDay);
                  }
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final meetingCount =
                        _meetingSchedules[_normalizeDay(day)]?.length ?? 0;

                    if (meetingCount == 0) {
                      return const SizedBox.shrink();
                    }

                    return Positioned(
                      bottom: 2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: _meetingAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                  dowBuilder: (context, day) {
                    const names = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
                    return Center(
                      child: Text(
                        names[day.weekday % 7],
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    if (_isSame(_selectedMeetingDay, day)) {
                      return _selectedDay(day.day.toString());
                    }

                    return _plainDay(
                      label: day.day.toString(),
                      isOutside: day.month != _focusedDay.month,
                    );
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return _plainDay(
                      label: day.day.toString(),
                      isOutside: true,
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    if (_isSame(_selectedMeetingDay, day)) {
                      return _selectedDay(day.day.toString());
                    }

                    return _plainDay(
                      label: day.day.toString(),
                      isOutside: day.month != _focusedDay.month,
                    );
                  },
                ),
                calendarStyle: const CalendarStyle(
                  isTodayHighlighted: false,
                  outsideDaysVisible: true,
                  cellMargin: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                  weekendTextStyle: TextStyle(
                    color: _textPrimary,
                    fontSize: 12,
                  ),
                  defaultTextStyle: TextStyle(
                    color: _textPrimary,
                    fontSize: 12,
                  ),
                  outsideTextStyle: TextStyle(
                    color: _textOutside,
                    fontSize: 12,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          if (widget.allowMeetingScheduling)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMeetingDay == null
                            ? 'Meeting Schedule'
                            : 'Meeting Schedule ${_selectedMeetingDay!.month}/${_selectedMeetingDay!.day}/${_selectedMeetingDay!.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (_selectedDayMeetings.isEmpty)
                        const Text(
                          'Click a date to add a meeting.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _textMuted,
                          ),
                        )
                      else
                        ..._selectedDayMeetings.map(
                          (meeting) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${meeting.time} - ${meeting.title}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _textPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownShell({required Widget child}) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6E0E4)),
      ),
      child: child,
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(icon, color: _textPrimary, size: 18),
      ),
    );
  }

  Widget _plainDay({
    required String label,
    required bool isOutside,
  }) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          color: isOutside ? _textOutside : _textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _selectedDay(String label) {
    return Center(
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF2E343A),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MeetingSchedule {
  const _MeetingSchedule({
    required this.title,
    required this.time,
  });

  final String title;
  final String time;
}
