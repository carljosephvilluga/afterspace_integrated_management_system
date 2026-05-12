// Purpose: Collects details for creating a new promotion.
import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/common/top_notification.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_input_field.dart';
import 'package:flutter/material.dart';

class PromoDialogResult {
  const PromoDialogResult({
    required this.name,
    required this.type,
    required this.discount,
    required this.start,
    required this.expiry,
    required this.benefits,
  });

  final String name;
  final String type;
  final String discount;
  final String start;
  final String expiry;
  final String benefits;
}

class CreatePromoDialog extends StatefulWidget {
  const CreatePromoDialog({super.key});

  @override
  State<CreatePromoDialog> createState() => _CreatePromoDialogState();
}

class _CreatePromoDialogState extends State<CreatePromoDialog> {
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);

  final TextEditingController _promoNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();

  DateTimeRange? _selectedRange;

  @override
  void dispose() {
    _promoNameController.dispose();
    _priceController.dispose();
    _typeController.dispose();
    _durationController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 28,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 560;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogHeader(),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _panelBlue.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Set up a new promo offer for members and students.',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (stacked)
                          Column(
                            children: [
                              _buildTopFields(stacked: true),
                              const SizedBox(height: 14),
                              _buildBottomFields(stacked: true),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildTopFields(stacked: false),
                              const SizedBox(height: 14),
                              _buildBottomFields(stacked: false),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      CustomButton(
                        label: 'Cancel',
                        backgroundColor: Colors.white,
                        textColor: _textPrimary,
                        borderColor: const Color(0xFFB7C4CB),
                        width: 172,
                        height: 42,
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                      CustomButton(
                        label: 'Add Promotion Type',
                        backgroundColor: _textPrimary,
                        textColor: Colors.white,
                        borderColor: _textPrimary,
                        width: 190,
                        height: 42,
                        onPressed: () async {
                          final name = _promoNameController.text.trim();
                          final type = _typeController.text.trim();
                          final discount = _priceController.text.trim();
                          final start = _selectedRange == null
                              ? ''
                              : _formatDate(_selectedRange!.start);
                          final expiry = _selectedRange == null
                              ? _durationController.text.trim()
                              : _formatDate(_selectedRange!.end);
                          if (name.isEmpty ||
                              type.isEmpty ||
                              discount.isEmpty ||
                              expiry.isEmpty) {
                            showTopNotification(
                              context,
                              message:
                                  'Please complete promo name, type, discount, and expiry.',
                              isError: true,
                            );
                            return;
                          }

                          final parsedDiscount = _parsePercent(discount);
                          if (parsedDiscount == null ||
                              parsedDiscount <= 0 ||
                              parsedDiscount > 100) {
                            showTopNotification(
                              context,
                              message:
                                  'Discount must be greater than 0% and no more than 100%.',
                              isError: true,
                            );
                            return;
                          }

                          Navigator.pop(
                            context,
                            PromoDialogResult(
                              name: name,
                              type: type,
                              discount: _formatPercent(parsedDiscount),
                              start: start,
                              expiry: expiry,
                              benefits: _benefitsController.text.trim(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _panelBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.local_offer_outlined,
            color: _headerBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Promo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Add a promo name, schedule, and benefit details.',
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF5F8F9),
            foregroundColor: _textPrimary,
          ),
          icon: const Icon(Icons.close_rounded, size: 24),
        ),
      ],
    );
  }

  Widget _buildTopFields({required bool stacked}) {
    if (stacked) {
      return Column(
        children: [
          MembershipProgramInputField(
            label: 'Promo Name',
            controller: _promoNameController,
            hintText: 'Enter promo name',
          ),
          const SizedBox(height: 14),
          MembershipProgramInputField(
            label: 'Discount (%)',
            controller: _priceController,
            hintText: '0',
          ),
          const SizedBox(height: 14),
          MembershipProgramInputField(
            label: 'Promo Type',
            controller: _typeController,
            hintText: 'Enter promo type',
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: MembershipProgramInputField(
            label: 'Promo Name',
            controller: _promoNameController,
            hintText: 'Enter promo name',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: MembershipProgramInputField(
            label: 'Discount (%)',
            controller: _priceController,
            hintText: '0',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: MembershipProgramInputField(
            label: 'Promo Type',
            controller: _typeController,
            hintText: 'Enter promo type',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomFields({required bool stacked}) {
    final durationField = MembershipProgramInputField(
      label: 'Duration',
      controller: _durationController,
      readOnly: true,
      onTap: _pickDateRange,
      suffixIcon: IconButton(
        onPressed: _pickDateRange,
        icon: const Icon(
          Icons.calendar_today_outlined,
          size: 20,
          color: _textPrimary,
        ),
      ),
    );

    final benefitsField = MembershipProgramInputField(
      label: 'Benefits',
      controller: _benefitsController,
      hintText: 'Describe the promo benefit',
      maxLines: 2,
    );

    if (stacked) {
      return Column(
        children: [durationField, const SizedBox(height: 14), benefitsField],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: durationField),
        const SizedBox(width: 14),
        Expanded(flex: 2, child: benefitsField),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final pickedRange = await showDialog<DateTimeRange>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (_) => _PromoDateRangeDialog(
        initialRange: _selectedRange,
        firstDate: DateTime(2024),
        lastDate: DateTime(2035),
      ),
    );

    if (pickedRange == null) {
      return;
    }

    setState(() {
      _selectedRange = pickedRange;
      _durationController.text =
          '${_formatDate(pickedRange.start)} - ${_formatDate(pickedRange.end)}';
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatPercent(double value) {
    return value % 1 == 0
        ? '${value.round()}%'
        : '${value.toStringAsFixed(2)}%';
  }

  double? _parsePercent(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
  }
}

class _PromoDateRangeDialog extends StatefulWidget {
  const _PromoDateRangeDialog({
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTimeRange? initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_PromoDateRangeDialog> createState() => _PromoDateRangeDialogState();
}

class _PromoDateRangeDialogState extends State<_PromoDateRangeDialog> {
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);

  late DateTime _focusedMonth;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialRange?.start;
    _endDate = widget.initialRange?.end;
    final focus = _startDate ?? DateTime.now();
    _focusedMonth = DateTime(focus.year, focus.month);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildSelectedRangeLabel(),
              const SizedBox(height: 16),
              _buildMonthHeader(),
              const SizedBox(height: 12),
              _buildWeekdayHeader(),
              const SizedBox(height: 6),
              _buildCalendarGrid(),
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _panelBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calendar_today_outlined,
            color: _headerBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promo Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Select a start and end date.',
                style: TextStyle(fontSize: 12, color: _textMuted),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: _textPrimary),
        ),
      ],
    );
  }

  Widget _buildSelectedRangeLabel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _panelBlue.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _headerBlue.withValues(alpha: 0.28)),
      ),
      child: Text(
        _rangeLabel,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      children: [
        _buildMonthButton(
          icon: Icons.chevron_left_rounded,
          enabled: _canGoToPreviousMonth,
          onTap: () {
            setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month - 1,
              );
            });
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
          ),
        ),
        _buildMonthButton(
          icon: Icons.chevron_right_rounded,
          enabled: _canGoToNextMonth,
          onTap: () {
            setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildMonthButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(
          icon,
          color: enabled ? _textPrimary : _textMuted.withValues(alpha: 0.35),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const labels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final cells = _calendarCells();

    return Column(
      children: [
        for (var row = 0; row < cells.length / 7; row++)
          Row(
            children: [
              for (var column = 0; column < 7; column++)
                Expanded(child: _buildDayCell(cells[(row * 7) + column])),
            ],
          ),
      ],
    );
  }

  Widget _buildDayCell(DateTime? day) {
    if (day == null) {
      return const SizedBox(height: 38);
    }

    final disabled = _isOutsideAllowedRange(day);
    final selectedStart = _isSameDate(day, _startDate);
    final selectedEnd = _isSameDate(day, _endDate);
    final selected = selectedStart || selectedEnd;
    final inRange = _isInsideSelectedRange(day);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        onTap: disabled ? null : () => _selectDay(day),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? _headerBlue
                : inRange
                ? _headerBlue.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: selectedStart && !selectedEnd
                ? Border.all(color: _textPrimary.withValues(alpha: 0.16))
                : null,
          ),
          child: Text(
            day.day.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: disabled
                  ? _textMuted.withValues(alpha: 0.35)
                  : selected
                  ? Colors.white
                  : _textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _startDate == null || _endDate == null
              ? null
              : () {
                  Navigator.pop(
                    context,
                    DateTimeRange(start: _startDate!, end: _endDate!),
                  );
                },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _selectDay(DateTime day) {
    setState(() {
      if (_startDate == null || _endDate != null) {
        _startDate = day;
        _endDate = null;
        return;
      }

      if (day.isBefore(_startDate!)) {
        _startDate = day;
        _endDate = null;
        return;
      }

      _endDate = day;
    });
  }

  List<DateTime?> _calendarCells() {
    final firstMonthDay = DateTime(_focusedMonth.year, _focusedMonth.month);
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final leadingBlankDays = firstMonthDay.weekday % 7;
    final totalCells = ((leadingBlankDays + daysInMonth) / 7).ceil() * 7;

    return List<DateTime?>.generate(totalCells, (index) {
      final dayNumber = index - leadingBlankDays + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) {
        return null;
      }

      return DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
    });
  }

  bool _isInsideSelectedRange(DateTime day) {
    final start = _startDate;
    final end = _endDate;
    if (start == null || end == null) {
      return false;
    }

    return day.isAfter(start) && day.isBefore(end);
  }

  bool _isOutsideAllowedRange(DateTime day) {
    final first = _dateOnly(widget.firstDate);
    final last = _dateOnly(widget.lastDate);
    return day.isBefore(first) || day.isAfter(last);
  }

  bool _isSameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get _canGoToPreviousMonth {
    final current = DateTime(_focusedMonth.year, _focusedMonth.month);
    final first = DateTime(widget.firstDate.year, widget.firstDate.month);
    return current.isAfter(first);
  }

  bool get _canGoToNextMonth {
    final current = DateTime(_focusedMonth.year, _focusedMonth.month);
    final last = DateTime(widget.lastDate.year, widget.lastDate.month);
    return current.isBefore(last);
  }

  String get _rangeLabel {
    final start = _startDate;
    final end = _endDate;
    if (start == null) {
      return 'Select start date';
    }
    if (end == null) {
      return '${_shortDate(start)} - Select end date';
    }
    return '${_shortDate(start)} - ${_shortDate(end)}';
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _shortDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[(month - 1).clamp(0, 11)];
  }
}
