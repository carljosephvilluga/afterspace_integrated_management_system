import 'package:aims/services/aims_api_client.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarChart extends StatefulWidget {
  const CalendarChart({super.key, this.allowMeetingScheduling = false});

  final bool allowMeetingScheduling;

  @override
  State<CalendarChart> createState() => _CalendarChartState();
}

class _CalendarChartState extends State<CalendarChart> {
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF7D8B93);
  static const Color _textOutside = Color(0xFFB2BEC6);
  static const Color _meetingAccent = Color(0xFF80AEC1);

  late DateTime _focusedDay;
  DateTime? _selectedMeetingDay;
  bool _isLoadingSchedules = false;
  bool _isSubmittingSchedule = false;
  String? _schedulesError;
  List<MeetingScheduleRecord> _schedules = const [];

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

  List<int> get _years => List.generate(21, (index) => 2020 + index);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, 1);
    _selectedMeetingDay = DateTime(now.year, now.month, now.day);
    _loadSchedulesForFocusedMonth();
  }

  DateTime _normalizeDay(DateTime day) =>
      DateTime(day.year, day.month, day.day);

  Map<DateTime, List<MeetingScheduleRecord>> get _meetingSchedulesByDay {
    final grouped = <DateTime, List<MeetingScheduleRecord>>{};
    for (final schedule in _schedules) {
      final day = _normalizeDay(schedule.startAt);
      grouped.putIfAbsent(day, () => <MeetingScheduleRecord>[]).add(schedule);
    }
    for (final schedules in grouped.values) {
      schedules.sort((a, b) => a.startAt.compareTo(b.startAt));
    }
    return grouped;
  }

  List<MeetingScheduleRecord> get _selectedDayMeetings {
    final selected = _selectedMeetingDay;
    if (selected == null) {
      return const [];
    }
    return _meetingSchedulesByDay[_normalizeDay(selected)] ?? const [];
  }

  void _setFocusedMonth(DateTime nextFocus) {
    setState(() {
      _focusedDay = DateTime(nextFocus.year, nextFocus.month, 1);
    });
    _loadSchedulesForFocusedMonth();
  }

  void _previousMonth() {
    _setFocusedMonth(DateTime(_focusedDay.year, _focusedDay.month - 1, 1));
  }

  void _nextMonth() {
    _setFocusedMonth(DateTime(_focusedDay.year, _focusedDay.month + 1, 1));
  }

  bool _isSame(DateTime? a, DateTime b) {
    if (a == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _loadSchedulesForFocusedMonth() async {
    final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    setState(() {
      _isLoadingSchedules = true;
      _schedulesError = null;
    });

    try {
      final schedules = await AimsApiClient.instance.fetchMeetingSchedules(
        from: start,
        to: end,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _schedules = schedules;
        _isLoadingSchedules = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingSchedules = false;
        _schedulesError = error.toString();
      });
    }
  }

  Future<_ScheduleFormData?> _openScheduleDialog({
    required DateTime day,
    MeetingScheduleRecord? existing,
  }) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final notesController = TextEditingController(text: existing?.notes ?? '');
    var startTime = TimeOfDay.fromDateTime(
      existing?.startAt ?? DateTime(day.year, day.month, day.day, 9),
    );
    var endTime = TimeOfDay.fromDateTime(
      existing?.endAt ?? DateTime(day.year, day.month, day.day, 10),
    );
    String? errorText;

    final result = await showDialog<_ScheduleFormData>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickTime({required bool isStart}) async {
              final chosen = await showTimePicker(
                context: context,
                initialTime: isStart ? startTime : endTime,
              );
              if (chosen == null) {
                return;
              }
              setDialogState(() {
                if (isStart) {
                  startTime = chosen;
                } else {
                  endTime = chosen;
                }
              });
            }

            return AlertDialog(
              title: Text(
                existing == null
                    ? 'Add schedule ${day.month}/${day.day}/${day.year}'
                    : 'Edit schedule ${day.month}/${day.day}/${day.year}',
              ),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Meeting title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => pickTime(isStart: true),
                            child: Text('Start ${_formatTimeOfDay(startTime)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => pickTime(isStart: false),
                            child: Text('End ${_formatTimeOfDay(endTime)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
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
                    final notes = notesController.text.trim();
                    if (title.isEmpty) {
                      setDialogState(() {
                        errorText = 'Add a meeting title.';
                      });
                      return;
                    }

                    final startAt = DateTime(
                      day.year,
                      day.month,
                      day.day,
                      startTime.hour,
                      startTime.minute,
                    );
                    final endAt = DateTime(
                      day.year,
                      day.month,
                      day.day,
                      endTime.hour,
                      endTime.minute,
                    );

                    if (!endAt.isAfter(startAt)) {
                      setDialogState(() {
                        errorText = 'End time must be later than start time.';
                      });
                      return;
                    }

                    Navigator.of(context).pop(
                      _ScheduleFormData(
                        title: title,
                        notes: notes,
                        startAt: startAt,
                        endAt: endAt,
                      ),
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
    notesController.dispose();
    return result;
  }

  Future<void> _handleAddSchedule() async {
    final selectedDay = _selectedMeetingDay;
    if (selectedDay == null || _isSubmittingSchedule) {
      return;
    }

    final formData = await _openScheduleDialog(day: selectedDay);
    if (formData == null) {
      return;
    }

    setState(() {
      _isSubmittingSchedule = true;
    });
    try {
      await AimsApiClient.instance.createMeetingSchedule(
        title: formData.title,
        startAt: formData.startAt,
        endAt: formData.endAt,
        notes: formData.notes,
      );
      await _loadSchedulesForFocusedMonth();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Schedule added.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add schedule: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingSchedule = false;
        });
      }
    }
  }

  Future<void> _handleEditSchedule(MeetingScheduleRecord schedule) async {
    if (_isSubmittingSchedule) {
      return;
    }

    final formData = await _openScheduleDialog(
      day: _normalizeDay(schedule.startAt),
      existing: schedule,
    );
    if (formData == null) {
      return;
    }

    setState(() {
      _isSubmittingSchedule = true;
    });
    try {
      await AimsApiClient.instance.updateMeetingSchedule(
        scheduleId: schedule.scheduleId,
        title: formData.title,
        startAt: formData.startAt,
        endAt: formData.endAt,
        notes: formData.notes,
      );
      await _loadSchedulesForFocusedMonth();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Schedule updated.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update schedule: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingSchedule = false;
        });
      }
    }
  }

  Future<void> _handleDeleteSchedule(MeetingScheduleRecord schedule) async {
    if (_isSubmittingSchedule) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete schedule'),
          content: Text(
            'Delete "${schedule.title}" at ${_formatTime(schedule.startAt)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isSubmittingSchedule = true;
    });
    try {
      await AimsApiClient.instance.deleteMeetingSchedule(schedule.scheduleId);
      await _loadSchedulesForFocusedMonth();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Schedule deleted.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete schedule: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingSchedule = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
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
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                        ),
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
                          _setFocusedMonth(
                            DateTime(_focusedDay.year, value, 1),
                          );
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
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                        ),
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
                          _setFocusedMonth(
                            DateTime(value, _focusedDay.month, 1),
                          );
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
                selectedDayPredicate: (day) =>
                    _isSame(_selectedMeetingDay, day),
                headerVisible: false,
                availableGestures: AvailableGestures.none,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                sixWeekMonthsEnforced: false,
                rowHeight: 27,
                daysOfWeekHeight: 22,
                onPageChanged: (focusedDay) {
                  _setFocusedMonth(focusedDay);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedMeetingDay = selectedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final meetingCount =
                        _meetingSchedulesByDay[_normalizeDay(day)]?.length ?? 0;

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedMeetingDay == null
                                  ? 'Meeting Schedule'
                                  : 'Meeting Schedule ${_selectedMeetingDay!.month}/${_selectedMeetingDay!.day}/${_selectedMeetingDay!.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Add schedule',
                            onPressed: _isSubmittingSchedule
                                ? null
                                : _handleAddSchedule,
                            icon: _isSubmittingSchedule
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add_rounded, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (_isLoadingSchedules)
                        const Text(
                          'Loading schedules...',
                          style: TextStyle(fontSize: 12, color: _textMuted),
                        )
                      else if (_schedulesError != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Unable to load schedules.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadSchedulesForFocusedMonth,
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      else if (_selectedDayMeetings.isEmpty)
                        const Text(
                          'No schedule for this date yet.',
                          style: TextStyle(fontSize: 12, color: _textMuted),
                        )
                      else
                        ..._selectedDayMeetings.map(
                          (meeting) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_formatTime(meeting.startAt)} - ${meeting.title}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      if (meeting.notes.trim().isNotEmpty)
                                        Text(
                                          meeting.notes,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: _textMuted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: _isSubmittingSchedule
                                      ? null
                                      : () => _handleEditSchedule(meeting),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  onPressed: _isSubmittingSchedule
                                      ? null
                                      : () => _handleDeleteSchedule(meeting),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                  ),
                                ),
                              ],
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

  Widget _plainDay({required String label, required bool isOutside}) {
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String _formatTimeOfDay(TimeOfDay value) {
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }
}

class _ScheduleFormData {
  const _ScheduleFormData({
    required this.title,
    required this.notes,
    required this.startAt,
    required this.endAt,
  });

  final String title;
  final String notes;
  final DateTime startAt;
  final DateTime endAt;
}
