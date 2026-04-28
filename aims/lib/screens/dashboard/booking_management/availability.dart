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
  static const Color _surfaceBlue = Color(0xFFCDECF3);

  bool isSidebarOpen = true;
  String selectedMenu = 'Calendar';
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  DateTime? _hoveredDay;
  late List<BookingReservation> _reservations;
  bool _isLoadingReservations = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _reservations = const [];
    _loadReservations();
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
                              const Text(
                                'Calendar and Booking Management',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (_isLoadingReservations)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: LinearProgressIndicator(minHeight: 3),
                                ),
                              Container(
                                decoration: BoxDecoration(
                                  color: _surfaceBlue,
                                  borderRadius: BorderRadius.circular(24),
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

  Future<void> _loadReservations() async {
    setState(() {
      _isLoadingReservations = true;
    });

    try {
      final records = await AimsApiClient.instance.fetchBookings(limit: 500);
      final mapped = records.map(_toReservation).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
      if (!mounted) return;
      setState(() {
        _reservations = mapped;
      });
    } on AimsApiException catch (error) {
      _showToast(error.message);
    } catch (_) {
      _showToast('Unable to load reservations right now.');
    } finally {
      if (mounted) {
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
        _reservations = [..._reservations, reservation]
          ..sort((a, b) => a.start.compareTo(b.start));
        _selectedDay = draft.date;
        _focusedDay = DateTime(draft.date.year, draft.date.month, 1);
      });
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
      if (!mounted) return;
      setState(() {
        _reservations = _reservations.map((item) {
          if (item.backendId != reservation.backendId) {
            return item;
          }
          return item.copyWith(status: BookingStatus.checkedIn);
        }).toList();
      });
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
      if (!mounted) return;
      setState(() {
        _reservations = _reservations.map((item) {
          if (item.backendId != reservation.backendId) {
            return item;
          }
          return item.copyWith(status: BookingStatus.cancelled);
        }).toList();
      });
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

class RealTimeAvailabilityPanel extends StatelessWidget {
  const RealTimeAvailabilityPanel({
    super.key,
    required this.selectedDay,
    required this.reservations,
  });

  final DateTime selectedDay;
  final List<BookingReservation> reservations;

  static const Color _panelBlue = Color(0xFFCFEFF5);
  static const Color _cardTan = Color(0xFFD8C0AC);
  static const Color _text = Color(0xFF22313A);

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
      reservations,
      selectedDay,
      rangeStart,
      rangeEnd,
    );

    return Container(
      decoration: BoxDecoration(
        color: _panelBlue,
        borderRadius: BorderRadius.circular(22),
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
            formatMonthDayYear(selectedDay),
            style: const TextStyle(fontSize: 12, color: Color(0xFF71808A)),
          ),
          const SizedBox(height: 12),
          _availabilityCard(
            icon: BookingSpaceType.boardRoom.icon,
            title: 'Board Room',
            availabilityText: nextBoardRoomAvailability(
              reservations,
              selectedDay,
            ),
          ),
          const SizedBox(height: 10),
          _availabilityCard(
            icon: BookingSpaceType.openSpace.icon,
            title: 'Open Space',
            availabilityText:
                'Available seats now: ${openSeatsNow < 0 ? 0 : openSeatsNow}\n${nextOpenSpaceAvailability(reservations, selectedDay)}',
          ),
        ],
      ),
    );
  }

  Widget _availabilityCard({
    required IconData icon,
    required String title,
    required String availabilityText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardTan,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _text, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            availabilityText,
            style: const TextStyle(fontSize: 12, height: 1.45, color: _text),
          ),
        ],
      ),
    );
  }
}
