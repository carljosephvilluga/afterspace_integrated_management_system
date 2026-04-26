import 'package:aims/screens/dashboard/booking_management/booking_models.dart';
import 'package:flutter/material.dart';

class TodaysBookingsSection extends StatefulWidget {
  const TodaysBookingsSection({
    super.key,
    required this.reservations,
    required this.onCheckIn,
    required this.onCancel,
  });

  final List<BookingReservation> reservations;
  final ValueChanged<BookingReservation> onCheckIn;
  final ValueChanged<BookingReservation> onCancel;

  @override
  State<TodaysBookingsSection> createState() => _TodaysBookingsSectionState();
}

class _TodaysBookingsSectionState extends State<TodaysBookingsSection> {
  DateTime? _selectedDate;
  String _spaceFilter = 'All';
  String _statusFilter = 'All';
  final TextEditingController _customerController = TextEditingController();

  static const Color _panelBlue = Color(0xFFCFEFF5);
  static const Color _cardTan = Color(0xFFD8C0AC);
  static const Color _text = Color(0xFF22313A);
  static const Color _muted = Color(0xFF71808A);
  static const Color _danger = Color(0xFFC95656);

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  List<BookingReservation> get _filteredReservations {
    final query = _customerController.text.trim().toLowerCase();
    return widget.reservations.where((reservation) {
      final matchesDate =
          _selectedDate == null || isSameDate(reservation.start, _selectedDate!);
      final matchesSpace = _spaceFilter == 'All' || reservation.spaceType.label == _spaceFilter;
      final matchesStatus = _statusFilter == 'All' || reservation.status.label == _statusFilter;
      final matchesCustomer =
          query.isEmpty || reservation.customerName.toLowerCase().contains(query);
      return matchesDate && matchesSpace && matchesStatus && matchesCustomer;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filteredReservations;

    return Container(
      decoration: BoxDecoration(
        color: _panelBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackVertically = constraints.maxWidth < 860;
          return stackVertically
              ? Column(
                  children: [
                    _buildTable(rows),
                    const SizedBox(height: 14),
                    _buildFilters(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildTable(rows)),
                    const SizedBox(width: 14),
                    SizedBox(width: 230, child: _buildFilters()),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildTable(List<BookingReservation> rows) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Booking",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
          const SizedBox(height: 10),
          _headerRow(),
          const SizedBox(height: 6),
          Expanded(
            child: rows.isEmpty
                ? const Center(
                    child: Text(
                      'No bookings found for the selected filters.',
                      style: TextStyle(color: _muted),
                    ),
                  )
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final reservation = rows[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: index.isEven ? const Color(0xFFF4E8DB) : const Color(0xFFF9F5F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _cell(flex: 2, reservation.id),
                            _cell(flex: 1, formatHour(reservation.start.hour)),
                            _cell(flex: 1, reservation.spaceType.label),
                            _cell(flex: 1, reservation.customerType),
                            _cell(flex: 2, reservation.customerName),
                            _cell(flex: 1, formatHour(reservation.end.hour)),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  _statusChip(reservation.status),
                                  const SizedBox(width: 8),
                                  _smallAction(
                                    label: 'Check-in',
                                    onTap: reservation.status == BookingStatus.reserved
                                        ? () => widget.onCheckIn(reservation)
                                        : null,
                                  ),
                                  const SizedBox(width: 6),
                                  _smallAction(
                                    label: 'Cancel',
                                    foreground: _danger,
                                    onTap: reservation.status != BookingStatus.cancelled
                                        ? () => widget.onCancel(reservation)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      decoration: BoxDecoration(
        color: _cardTan,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _text),
          ),
          const SizedBox(height: 8),
          const Text('Date', style: TextStyle(fontSize: 11, color: _text)),
          const SizedBox(height: 4),
          _datePickerButton(),
          const SizedBox(height: 10),
          const Text('Space Type', style: TextStyle(fontSize: 11, color: _text)),
          const SizedBox(height: 4),
          _dropdown(
            value: _spaceFilter,
            items: const ['All', 'Board Room', 'Open Space'],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _spaceFilter = value);
            },
          ),
          const SizedBox(height: 10),
          const Text('Reservation Status', style: TextStyle(fontSize: 11, color: _text)),
          const SizedBox(height: 4),
          _dropdown(
            value: _statusFilter,
            items: const ['All', 'Reserved', 'Checked-in', 'Cancelled'],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _statusFilter = value);
            },
          ),
          const SizedBox(height: 10),
          const Text('Customer', style: TextStyle(fontSize: 11, color: _text)),
          const SizedBox(height: 4),
          TextField(
            controller: _customerController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white.withOpacity(0.95),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                  _spaceFilter = 'All';
                  _statusFilter = 'All';
                  _customerController.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _text,
                side: const BorderSide(color: Colors.white70),
              ),
              child: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    const headers = [
      ('Booking ID', 2),
      ('Time In', 1),
      ('Space', 1),
      ('Type', 1),
      ('Customer', 2),
      ('Time Out', 1),
      ('Status', 2),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1ED),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: headers
            .map(
              (header) => Expanded(
                flex: header.$2,
                child: Text(
                  header.$1,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _cell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: _text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusChip(BookingStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: status.color,
        ),
      ),
    );
  }

  Widget _smallAction({
    required String label,
    required VoidCallback? onTap,
    Color foreground = _text,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFE2E2E2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: onTap == null ? _muted : foreground,
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _datePickerButton() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2025, 1, 1),
          lastDate: DateTime(2035, 12, 31),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _selectedDate == null ? 'Any date' : formatMonthDayYear(_selectedDate!),
          style: const TextStyle(fontSize: 13, color: _text),
        ),
      ),
    );
  }
}
