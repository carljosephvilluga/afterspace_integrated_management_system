import 'package:aims/widgets/admin_dashboard/calendar_chart.dart';
import 'package:aims/widgets/staff_dashboard/active_customers_table.dart';
import 'package:aims/widgets/staff_dashboard/dashboard_panel.dart';
import 'package:aims/widgets/staff_dashboard/metric_card.dart';
import 'package:aims/widgets/staff_dashboard/reservation_list_item.dart';
import 'package:flutter/material.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
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

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _surfaceBlue = Color(0xFFC7E8EE);
  static const Color _sidebarBlue = Color(0xFF9AA9BD);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF7D8A93);

  static final List<_Reservation> _reservations = [
    _Reservation(
      name: 'Jenny Wilson',
      email: 'j.wilson@example.com',
      time: '12:30pm',
      duration: '2 hours',
    ),
    _Reservation(
      name: 'Devon Lane',
      email: 'd.roberts@example.com',
      time: '1:00pm',
      duration: '3 hours',
    ),
    _Reservation(
      name: 'Jane Cooper',
      email: 'jgraham@example.com',
      time: '3:00pm',
      duration: '4 hours',
    ),
    _Reservation(
      name: 'Dianne Russell',
      email: 'curtis.d@example.com',
      time: '4:00pm',
      duration: '1 hour',
    ),
  ];

  bool isSidebarOpen = true;
  String selectedMenu = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isSidebarOpen) _buildSidebar(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _headerBlue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                isSidebarOpen = !isSidebarOpen;
              });
            },
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            'afterspace',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const Spacer(),
          const Text(
            'Staff',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.95),
            child: const Icon(Icons.badge_outlined, size: 20, color: _headerBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 146,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(
        color: _sidebarBlue,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          _buildSidebarItem(Icons.home_outlined, 'Dashboard'),
          _buildSidebarItem(Icons.calendar_today_outlined, 'Calendar'),
          _buildSidebarItem(Icons.list_alt_outlined, 'List of Users'),
          _buildSidebarItem(Icons.inventory_2_outlined, 'Inventory'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title) {
    final isSelected = selectedMenu == title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedMenu = title;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? _textPrimary : Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                icon,
                size: 18,
                color: isSelected ? _textPrimary : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
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
                  Expanded(
                    flex: 4,
                    child: _buildReservationsPanel(),
                  ),
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
    return Row(
      children: const [
        Expanded(
          child: StaffMetricCard(
            title: 'TOTAL SALES',
            value: '\$2,38,485',
            change: '+14%',
            surfaceColor: _surfaceBlue,
            textColor: _textPrimary,
            mutedColor: _textMuted,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StaffMetricCard(
            title: 'ACTIVE CUSTOMERS',
            value: '143',
            change: '+36%',
            surfaceColor: _surfaceBlue,
            textColor: _textPrimary,
            mutedColor: _textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarPanel() {
    return _buildPanel(
      title: '',
      child: const CalendarChart(),
    );
  }

  Widget _buildReservationsPanel() {
    return _buildPanel(
      title: 'Pending Reservations',
      subtitle: 'Lorem ipsum dolor sit ametis.',
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reservations.length,
              separatorBuilder: (context, index) => const Divider(
                height: 18,
                thickness: 1,
                color: Color(0x1A6C7B84),
              ),
              itemBuilder: (context, index) {
                final item = _reservations[index];
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
              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: _textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCustomersPanel() {
    return _buildPanel(
      title: 'Active Customers',
      child: ActiveCustomersTable(
        textColor: _textPrimary,
        mutedColor: _textMuted,
      ),
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
