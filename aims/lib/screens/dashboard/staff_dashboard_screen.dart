import 'dart:async';

import 'package:aims/widgets/common/header.dart';
import 'package:aims/widgets/common/sidebar.dart';
import 'package:aims/services/aims_api_client.dart';
import 'package:flutter/material.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class StaffDashboardPanel extends StatelessWidget {
  const StaffDashboardPanel({
    super.key,
    required this.title,
    required this.child,
    required this.surfaceColor,
    required this.textColor,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Color surfaceColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}

class StaffMetricCard extends StatelessWidget {
  const StaffMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
  });

  final String title;
  final String value;
  final String change;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: mutedColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              change,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StaffReservationListItem extends StatelessWidget {
  const StaffReservationListItem({
    super.key,
    required this.name,
    required this.email,
    required this.time,
    required this.duration,
    required this.textColor,
    required this.mutedColor,
  });

  final String name;
  final String email;
  final String time;
  final String duration;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withOpacity(0.75),
          child: Text(
            name.substring(0, 1),
            style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(email, style: TextStyle(fontSize: 12, color: mutedColor)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(duration, style: TextStyle(fontSize: 12, color: mutedColor)),
          ],
        ),
      ],
    );
  }
}

class _ActiveCustomersTable extends StatelessWidget {
  const _ActiveCustomersTable({
    required this.rows,
    required this.textColor,
    required this.mutedColor,
  });

  final List<_ActiveCustomerRow> rows;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(child: _TableHeader('Customer', mutedColor)),
              Expanded(child: _TableHeader('Membership', mutedColor)),
              Expanded(child: _TableHeader('Time In', mutedColor)),
              Expanded(child: _TableHeader('Status', mutedColor)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final row = rows[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.membership,
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.timeIn,
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D8C63).withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          row.status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF2D8C63),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
    );
  }
}

class _CalendarChart extends StatelessWidget {
  const _CalendarChart({required this.bars});

  final List<_WeeklyActivityBar> bars;

  @override
  Widget build(BuildContext context) {
    final maxCount = bars.isEmpty
        ? 1
        : bars
              .map((bar) => bar.count)
              .reduce((left, right) => left > right ? left : right);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weekly Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              _buildRangeLabel(),
              style: const TextStyle(fontSize: 12, color: Color(0xFF7D8A93)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(bars.length, (index) {
              final item = bars[index];
              final heightFactor = item.count <= 0
                  ? 0.08
                  : (item.count / maxCount).clamp(0.08, 1.0);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: heightFactor,
                            child: Container(
                              decoration: BoxDecoration(
                                color: index == bars.length - 1
                                    ? const Color(0xFF80AEC1)
                                    : Colors.white.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7D8A93),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  String _buildRangeLabel() {
    if (bars.isEmpty) {
      return 'Last 7 days';
    }

    final start = bars.first.date;
    final end = bars.last.date;
    return '${_monthShort(start.month)} ${start.day} - ${_monthShort(end.month)} ${end.day}';
  }

  String _monthShort(int month) {
    const months = <String>[
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
    return months[(month - 1).clamp(0, 11)];
  }
}

class _Reservation {
  const _Reservation({
    required this.name,
    required this.email,
    required this.time,
    required this.duration,
  });

  final String name;
  final String email;
  final String time;
  final String duration;
}

class _ActiveCustomerRow {
  const _ActiveCustomerRow({
    required this.name,
    required this.membership,
    required this.timeIn,
    required this.status,
  });

  final String name;
  final String membership;
  final String timeIn;
  final String status;
}

class _WeeklyActivityBar {
  const _WeeklyActivityBar({
    required this.label,
    required this.date,
    required this.count,
  });

  final String label;
  final DateTime date;
  final int count;
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  static const double _desktopFrameWidth = 1560;
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _surfaceBlue = Color(0xFFC7E8EE);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF7D8A93);

  bool isSidebarOpen = true;
  String selectedMenu = 'Dashboard';
  late Future<StaffDashboardSnapshot> _dashboardSnapshotFuture;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _reloadDashboard(notify: false);
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted || selectedMenu != 'Dashboard') {
        return;
      }
      _reloadDashboard();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _reloadDashboard({bool notify = true}) {
    final nextFuture = AimsApiClient.instance.fetchStaffDashboardSnapshot();
    if (!notify || !mounted) {
      _dashboardSnapshotFuture = nextFuture;
      return;
    }

    setState(() {
      _dashboardSnapshotFuture = nextFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Header(
              role: UserRole.staff,
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
                          role: UserRole.staff,
                          selectedTitle: selectedMenu,
                          onItemSelected: _handleSidebarTap,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: selectedMenu == 'Dashboard'
                              ? _buildDashboardContent()
                              : _buildPlaceholder(selectedMenu),
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
      Navigator.pushNamed(context, '/calendar');
      return;
    }

    if (title == 'List of Users') {
      Navigator.pushNamed(context, '/staff-users');
      return;
    }

    if (title == 'Pricing and Promo Management') {
      Navigator.pushNamed(context, '/membership-loyalty-program');
      return;
    }

    setState(() {
      selectedMenu = title;
    });
  }

  Widget _buildDashboardContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1060;

        if (isCompact) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMetricRow(),
                const SizedBox(height: 12),
                SizedBox(height: 320, child: _buildCalendarPanel()),
                const SizedBox(height: 12),
                SizedBox(height: 320, child: _buildReservationsPanel()),
                const SizedBox(height: 12),
                SizedBox(height: 280, child: _buildActiveCustomersPanel()),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 360,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        _buildMetricRow(),
                        const SizedBox(height: 12),
                        Expanded(child: _buildCalendarPanel()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: _buildReservationsPanel()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildActiveCustomersPanel()),
          ],
        );
      },
    );
  }

  Widget _buildMetricRow() {
    return FutureBuilder<StaffDashboardSnapshot>(
      future: _dashboardSnapshotFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data?.summary;
        final leftValue = summary != null
            ? AimsApiClient.formatCount(summary.activeCustomers)
            : '--';
        final rightValue = summary != null
            ? AimsApiClient.formatCount(summary.reservedBookings)
            : '--';
        final status = snapshot.hasError
            ? 'OFFLINE'
            : summary != null
            ? 'LIVE'
            : 'SYNCING';

        return Row(
          children: [
            Expanded(
              child: StaffMetricCard(
                title: 'ACTIVE CUSTOMERS',
                value: leftValue,
                change: status,
                surfaceColor: _surfaceBlue,
                textColor: _textPrimary,
                mutedColor: _textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StaffMetricCard(
                title: 'RESERVED BOOKINGS',
                value: rightValue,
                change: status,
                surfaceColor: _surfaceBlue,
                textColor: _textPrimary,
                mutedColor: _textMuted,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarPanel() {
    return FutureBuilder<StaffDashboardSnapshot>(
      future: _dashboardSnapshotFuture,
      builder: (context, snapshot) {
        final bars =
            (snapshot.data?.weeklyActivity ??
                    const <DashboardWeeklyActivityItem>[])
                .map(
                  (item) => _WeeklyActivityBar(
                    label: item.label,
                    date: item.date,
                    count: item.count,
                  ),
                )
                .toList();

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildPanel(
            title: '',
            child: _buildCenteredPanelMessage('Loading weekly activity...'),
          );
        }

        if (snapshot.hasError) {
          return _buildPanel(
            title: '',
            child: _buildCenteredPanelMessage(
              'Unable to load weekly activity from backend.',
            ),
          );
        }

        if (bars.isEmpty) {
          return _buildPanel(
            title: '',
            child: _buildCenteredPanelMessage('No weekly activity yet.'),
          );
        }

        return _buildPanel(
          title: '',
          child: _CalendarChart(bars: bars),
        );
      },
    );
  }

  Widget _buildReservationsPanel() {
    return FutureBuilder<StaffDashboardSnapshot>(
      future: _dashboardSnapshotFuture,
      builder: (context, snapshot) {
        final reservations =
            (snapshot.data?.pendingReservations ??
                    const <DashboardReservationItem>[])
                .map(
                  (item) => _Reservation(
                    name: item.customerName,
                    email: item.email.isNotEmpty
                        ? item.email
                        : item.contactDetails,
                    time: _formatTime(item.startAt),
                    duration: _formatDuration(
                      item.endAt.difference(item.startAt),
                    ),
                  ),
                )
                .toList();

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildPanel(
            title: 'Pending Reservations',
            subtitle: 'Live reservations from backend.',
            child: _buildCenteredPanelMessage('Loading reservations...'),
          );
        }

        if (snapshot.hasError) {
          return _buildPanel(
            title: 'Pending Reservations',
            subtitle: 'Live reservations from backend.',
            child: _buildCenteredPanelMessage(
              'Unable to load reservations from backend.',
            ),
          );
        }

        if (reservations.isEmpty) {
          return _buildPanel(
            title: 'Pending Reservations',
            subtitle: 'Live reservations from backend.',
            child: _buildCenteredPanelMessage('No pending reservations yet.'),
          );
        }

        return _buildPanel(
          title: 'Pending Reservations',
          subtitle: 'Live reservations from backend.',
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reservations.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 18,
                    thickness: 1,
                    color: Color(0x1A6C7B84),
                  ),
                  itemBuilder: (context, index) {
                    final item = reservations[index];
                    return StaffReservationListItem(
                      name: item.name,
                      email: item.email,
                      time: item.time,
                      duration: item.duration,
                      textColor: _textPrimary,
                      mutedColor: _textMuted,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Text(
                    'SEE ALL CUSTOMERS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _textMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: _textMuted,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveCustomersPanel() {
    return FutureBuilder<StaffDashboardSnapshot>(
      future: _dashboardSnapshotFuture,
      builder: (context, snapshot) {
        final rows =
            (snapshot.data?.activeCustomers ??
                    const <DashboardActiveCustomerItem>[])
                .map(
                  (item) => _ActiveCustomerRow(
                    name: item.name,
                    membership: item.membershipType,
                    timeIn: _formatTime(item.timeIn),
                    status: item.status,
                  ),
                )
                .toList();

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildPanel(
            title: 'Active Customers',
            child: _buildCenteredPanelMessage('Loading active customers...'),
          );
        }

        if (snapshot.hasError) {
          return _buildPanel(
            title: 'Active Customers',
            child: _buildCenteredPanelMessage(
              'Unable to load active customers from backend.',
            ),
          );
        }

        if (rows.isEmpty) {
          return _buildPanel(
            title: 'Active Customers',
            child: _buildCenteredPanelMessage('No active customers right now.'),
          );
        }

        return _buildPanel(
          title: 'Active Customers',
          child: _ActiveCustomersTable(
            rows: rows,
            textColor: _textPrimary,
            mutedColor: _textMuted,
          ),
        );
      },
    );
  }

  Widget _buildPanel({
    required String title,
    required Widget child,
    String? subtitle,
  }) {
    return StaffDashboardPanel(
      title: title,
      subtitle: subtitle,
      surfaceColor: _surfaceBlue,
      textColor: _textPrimary,
      child: child,
    );
  }

  Widget _buildCenteredPanelMessage(String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _textMuted,
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

  String _formatDuration(Duration value) {
    final totalMinutes = value.inMinutes;
    if (totalMinutes <= 0) {
      return '0 min';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours h $minutes min';
    }
    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    }
    return '$minutes min';
  }

  Widget _buildPlaceholder(String title) {
    return _buildPanel(
      title: title,
      child: Center(
        child: Text(
          '$title section coming next',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ),
    );
  }
}
