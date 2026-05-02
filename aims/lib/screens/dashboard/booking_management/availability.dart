import 'dart:async';

import 'package:aims/screens/dashboard/booking_management/Booking.dart';
import 'package:aims/screens/dashboard/booking_management/Calendar.dart';
import 'package:aims/screens/dashboard/booking_management/booking_models.dart';
import 'package:aims/screens/dashboard/booking_management/list_of_bookings.dart';
import 'package:aims/services/aims_api_client.dart';
import 'package:aims/widgets/common/header.dart';
import 'package:aims/widgets/common/sidebar.dart';
import 'package:flutter/material.dart';

class StaffBookingManagementScreen extends StatefulWidget {
  const StaffBookingManagementScreen({super.key, this.role = UserRole.staff});

  final UserRole role;

  @override
  State<StaffBookingManagementScreen> createState() =>
      _StaffBookingManagementScreenState();
}

class _StaffBookingManagementScreenState
    extends State<StaffBookingManagementScreen> {
  static const double _desktopFrameWidth = 1560;
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);
  static const Color _cardWhite = Color(0xF7FFFFFF);

  bool isSidebarOpen = true;
  String selectedMenu = 'Calendar';
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  DateTime? _hoveredDay;
  late List<BookingReservation> _reservations;
  bool _isLoadingReservations = false;
  bool _isSubmitting = false;
  Timer? _reservationRefreshTimer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _reservations = const [];
    _loadReservations();
    _reservationRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted || _isSubmitting) {
        return;
      }
      _loadReservations(showLoader: false, showErrorToast: false);
    });
  }

  @override
  void dispose() {
    _reservationRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Header(
              role: widget.role,
              onMenuTap: () {
                setState(() {
                  isSidebarOpen = !isSidebarOpen;
                });
              },
              maxWidth: _desktopFrameWidth,
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _desktopFrameWidth,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isSidebarOpen)
                        Sidebar(
                          role: widget.role,
                          selectedTitle: selectedMenu,
                          onItemSelected: _handleSidebarTap,
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 6),
                              _buildPageHero(),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _buildInfoChip(
                                    label: 'Total Bookings',
                                    value: '${_reservations.length}',
                                  ),
                                  _buildInfoChip(
                                    label: 'Today',
                                    value:
                                        '${reservationsForToday(_reservations).length}',
                                  ),
                                  _buildInfoChip(
                                    label: 'Selected Day',
                                    value:
                                        '${_reservations.where((reservation) => isSameDate(reservation.start, _selectedDay)).length}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              if (_isLoadingReservations)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: LinearProgressIndicator(minHeight: 3),
                                ),
                              Container(
                                decoration: BoxDecoration(
                                  color: _panelBlue,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x12000000),
                                      blurRadius: 16,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(18),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final stacked = constraints.maxWidth < 1100;
                                    final bookingForm = AddReservationCard(
                                      selectedDate: _selectedDay,
                                      reservations: _reservations,
                                      onDateChanged: (day) {
                                        setState(() {
                                          _selectedDay = day;
                                          _focusedDay = DateTime(
                                            day.year,
                                            day.month,
                                            1,
                                          );
                                        });
                                      },
                                      onReservationSaved: _saveReservation,
                                    );
                                    final bookingCalendar = BookingCalendarCard(
                                      focusedDay: _focusedDay,
                                      selectedDay: _selectedDay,
                                      hoveredDay: _hoveredDay,
                                      reservations: _reservations,
                                      onDaySelected: (day) {
                                        setState(() {
                                          _selectedDay = day;
                                          _focusedDay = DateTime(
                                            day.year,
                                            day.month,
                                            1,
                                          );
                                        });
                                      },
                                      onMonthChanged: (month) {
                                        setState(() {
                                          _focusedDay = DateTime(
                                            _focusedDay.year,
                                            month,
                                            1,
                                          );
                                        });
                                      },
                                      onYearChanged: (year) {
                                        setState(() {
                                          _focusedDay = DateTime(
                                            year,
                                            _focusedDay.month,
                                            1,
                                          );
                                        });
                                      },
                                      onPrevMonth: () {
                                        setState(() {
                                          _focusedDay = DateTime(
                                            _focusedDay.year,
                                            _focusedDay.month - 1,
                                            1,
                                          );
                                        });
                                      },
                                      onNextMonth: () {
                                        setState(() {
                                          _focusedDay = DateTime(
                                            _focusedDay.year,
                                            _focusedDay.month + 1,
                                            1,
                                          );
                                        });
                                      },
                                      onDayHovered: (day) {
                                        setState(() {
                                          _hoveredDay = day;
                                        });
                                      },
                                    );
                                    final availabilityPanel =
                                        RealTimeAvailabilityPanel(
                                          selectedDay: _selectedDay,
                                          reservations: _reservations,
                                        );

                                    return stacked
                                        ? Column(
                                            children: [
                                              bookingForm,
                                              const SizedBox(height: 16),
                                              bookingCalendar,
                                              const SizedBox(height: 16),
                                              availabilityPanel,
                                            ],
                                          )
                                        : Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: bookingForm,
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                flex: 4,
                                                child: bookingCalendar,
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                flex: 2,
                                                child: availabilityPanel,
                                              ),
                                            ],
                                          );
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),
                              TodaysBookingsSection(
                                reservations: reservationsForToday(
                                  _reservations,
                                ),
                                onCheckIn: _checkInReservation,
                                onCancel: _cancelReservation,
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
      ),
    );
  }

  Widget _buildPageHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _panelBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: _headerBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendar and Booking Management',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Create reservations, scan availability, and manage today\'s booking activity.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _headerBlue,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSidebarTap(String title) {
    if (title == 'Calendar') {
      setState(() {
        selectedMenu = title;
      });
      return;
    }

    if (title == 'Dashboard') {
      Navigator.pushReplacementNamed(
        context,
        widget.role == UserRole.manager
            ? '/manager-dashboard'
            : '/staff-dashboard',
      );
      return;
    }

    if (title == 'List of Users') {
      Navigator.pushReplacementNamed(
        context,
        widget.role == UserRole.manager ? '/manager-users' : '/staff-users',
      );
      return;
    }

    if (title == 'Pricing and Promo Management') {
      Navigator.pushReplacementNamed(
        context,
        widget.role == UserRole.manager
            ? '/manager-membership'
            : '/membership-loyalty-program',
      );
    }
  }

  void _saveReservation(ReservationDraft draft) {
    _createReservation(draft);
  }

  void _checkInReservation(BookingReservation reservation) {
    _checkInReservationOnServer(reservation);
  }

  void _cancelReservation(BookingReservation reservation) {
    _cancelReservationOnServer(reservation);
  }

  Future<void> _loadReservations({
    bool showLoader = true,
    bool showErrorToast = true,
  }) async {
    if (showLoader && mounted) {
      setState(() {
        _isLoadingReservations = true;
      });
    }

    try {
      final records = await AimsApiClient.instance.fetchBookings(limit: 500);
      final mapped = records.map(_toReservation).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
      if (!mounted) return;
      setState(() {
        _reservations = mapped;
      });
    } on AimsApiException catch (error) {
      if (showErrorToast) {
        _showToast(error.message);
      }
    } catch (_) {
      if (showErrorToast) {
        _showToast('Unable to load reservations right now.');
      }
    } finally {
      if (showLoader && mounted) {
        setState(() {
          _isLoadingReservations = false;
        });
      }
    }
  }

  Future<void> _createReservation(ReservationDraft draft) async {
    if (_isSubmitting) return;

    final startAt = DateTime(
      draft.date.year,
      draft.date.month,
      draft.date.day,
      draft.startHour,
    );
    final endAt = DateTime(
      draft.date.year,
      draft.date.month,
      draft.date.day,
      draft.endHour,
    );
    final spaceType = draft.spaceType == BookingSpaceType.boardRoom
        ? 'Board Room'
        : 'Open Space';

    setState(() {
      _isSubmitting = true;
    });
    try {
      final created = await AimsApiClient.instance.createBooking(
        customerName: draft.customerName.trim(),
        contactDetails: draft.contactDetails.trim(),
        spaceType: spaceType,
        startAt: startAt,
        endAt: endAt,
      );

      final reservation = _toReservation(created);
      if (!mounted) return;
      setState(() {
        _selectedDay = draft.date;
        _focusedDay = DateTime(draft.date.year, draft.date.month, 1);
      });
      await _loadReservations(showLoader: false, showErrorToast: false);
      _showToast(
        '${reservation.customerName} reserved ${reservation.spaceType.label} for ${formatMonthDayYear(draft.date)}.',
      );
    } on AimsApiException catch (error) {
      _showToast(error.message);
    } catch (_) {
      _showToast('Unable to save reservation right now.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _checkInReservationOnServer(
    BookingReservation reservation,
  ) async {
    if (_isSubmitting) return;
    final bookingId = reservation.backendId;
    if (bookingId == null) {
      _showToast('This reservation has no backend ID yet.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    try {
      await AimsApiClient.instance.checkInBooking(bookingId);
      await _loadReservations(showLoader: false, showErrorToast: false);
      _showToast('${reservation.customerName} is now checked in.');
    } on AimsApiException catch (error) {
      _showToast(error.message);
    } catch (_) {
      _showToast('Unable to check in this reservation.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _cancelReservationOnServer(
    BookingReservation reservation,
  ) async {
    if (_isSubmitting) return;
    final bookingId = reservation.backendId;
    if (bookingId == null) {
      _showToast('This reservation has no backend ID yet.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    try {
      await AimsApiClient.instance.cancelBooking(bookingId);
      await _loadReservations(showLoader: false, showErrorToast: false);
      _showToast('${reservation.customerName} reservation has been cancelled.');
    } on AimsApiException catch (error) {
      _showToast(error.message);
    } catch (_) {
      _showToast('Unable to cancel this reservation.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  BookingReservation _toReservation(BookingRecord record) {
    final normalizedSpace = record.spaceType.toLowerCase();
    final normalizedStatus = record.status.toLowerCase();
    return BookingReservation(
      backendId: record.bookingId,
      id: record.bookingCode,
      customerName: record.customerName,
      contactDetails: record.contactDetails.isNotEmpty
          ? record.contactDetails
          : record.email,
      spaceType: normalizedSpace.contains('board')
          ? BookingSpaceType.boardRoom
          : BookingSpaceType.openSpace,
      start: record.startAt,
      end: record.endAt,
      customerType: record.customerType.isEmpty ? 'Guest' : record.customerType,
      status:
          normalizedStatus == 'checkedin' ||
              normalizedStatus == 'checked-in' ||
              normalizedStatus == 'confirmed'
          ? BookingStatus.checkedIn
          : normalizedStatus == 'cancelled' || normalizedStatus == 'canceled'
          ? BookingStatus.cancelled
          : BookingStatus.reserved,
    );
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class RealTimeAvailabilityPanel extends StatefulWidget {
  const RealTimeAvailabilityPanel({
    super.key,
    required this.selectedDay,
    required this.reservations,
  });

  final DateTime selectedDay;
  final List<BookingReservation> reservations;

  @override
  State<RealTimeAvailabilityPanel> createState() =>
      _RealTimeAvailabilityPanelState();
}

class _RealTimeAvailabilityPanelState extends State<RealTimeAvailabilityPanel> {
  bool _boardRoomExpanded = false;
  bool _openSpaceExpanded = false;

  static const Color _panelBlue = Color(0xF7FFFFFF);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _tanSoft = Color(0xFFEBD9CA);
  static const Color _text = Color(0xFF23323A);
  static const Color _muted = Color(0xFF6F7E87);

  @override
  Widget build(BuildContext context) {
    final currentHour = DateTime.now().hour;
    final rangeStart = currentHour.clamp(
      bookingOpeningHour,
      bookingClosingHour - 1,
    );
    final rangeEnd = (currentHour + 1).clamp(
      bookingOpeningHour + 1,
      bookingClosingHour,
    );
    final openSeatsNow = openSeatsLeftForRange(
      widget.reservations,
      widget.selectedDay,
      rangeStart,
      rangeEnd,
    );
    final dayWindows = availabilityWindowsForDay(
      widget.reservations,
      widget.selectedDay,
    );
    final boardRoomTaken = dayWindows
        .where((window) => !window.boardRoomAvailable)
        .toList();
    final openSpaceTaken = dayWindows
        .where((window) => window.openSeatsLeft < openSpaceCapacity)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: _panelBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Real-time Availability',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatMonthDayYear(widget.selectedDay),
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
          const SizedBox(height: 12),
          _availabilityCard(
            icon: BookingSpaceType.boardRoom.icon,
            title: 'Board Room',
            summaryText: _boardRoomSummary(boardRoomTaken),
            expanded: _boardRoomExpanded,
            onTap: () {
              setState(() {
                _boardRoomExpanded = !_boardRoomExpanded;
              });
            },
            detailLines: boardRoomTaken
                .map((window) => formatTimeRange(window.start, window.end))
                .toList(),
            emptyDetailText: 'No booked board room slots yet for this day.',
          ),
          const SizedBox(height: 10),
          _availabilityCard(
            icon: BookingSpaceType.openSpace.icon,
            title: 'Open Space',
            summaryText:
                'Available seats now: ${openSeatsNow < 0 ? 0 : openSeatsNow}',
            expanded: _openSpaceExpanded,
            onTap: () {
              setState(() {
                _openSpaceExpanded = !_openSpaceExpanded;
              });
            },
            detailLines: openSpaceTaken.map((window) {
              final seatsTaken = openSpaceCapacity - window.openSeatsLeft;
              return '${formatTimeRange(window.start, window.end)}  |  $seatsTaken seat${seatsTaken == 1 ? '' : 's'} taken';
            }).toList(),
            emptyDetailText: 'No open space slots are taken yet for this day.',
          ),
        ],
      ),
    );
  }

  String _boardRoomSummary(List<AvailabilityWindow> takenWindows) {
    if (takenWindows.isEmpty) {
      return 'No board room slots taken yet.';
    }

    final preview = takenWindows
        .take(2)
        .map((window) => formatTimeRange(window.start, window.end))
        .join('\n');
    final remaining = takenWindows.length - 2;
    if (remaining > 0) {
      return '$preview\n+$remaining more';
    }
    return preview;
  }

  Widget _availabilityCard({
    required IconData icon,
    required String title,
    required String summaryText,
    required bool expanded,
    required VoidCallback onTap,
    required List<String> detailLines,
    required String emptyDetailText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _tanSoft.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _headerBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: _text,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              summaryText,
              style: const TextStyle(fontSize: 12, height: 1.45, color: _muted),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time taken for this day',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    detailLines.isEmpty
                        ? Text(
                            emptyDetailText,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: _text,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: detailLines
                                .map(
                                  (line) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      line,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: _text,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
