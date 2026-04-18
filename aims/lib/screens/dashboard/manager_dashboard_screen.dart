import 'package:aims/widgets/admin_dashboard/sales_report_line_chart.dart';
import 'package:aims/widgets/manager_dashboard/dashboard_panel.dart';
import 'package:aims/widgets/manager_dashboard/metric_card.dart';
import 'package:aims/widgets/manager_dashboard/reservation_list_item.dart';
import 'package:aims/widgets/manager_dashboard/transaction_row_cells.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

enum _ManagerRange { daily, monthly, weekly, yearly }

class _ManagerReportData {
  const _ManagerReportData({
    required this.revenueToday,
    required this.customersToday,
    required this.revenueChange,
    required this.customersChange,
    required this.areaSpots,
    required this.lineSpots,
    required this.labels,
    required this.tooltipTitle,
    required this.tooltipValue,
    required this.highlightX,
    required this.maxY,
  });

  final String revenueToday;
  final String customersToday;
  final String revenueChange;
  final String customersChange;
  final List<FlSpot> areaSpots;
  final List<FlSpot> lineSpots;
  final List<String> labels;
  final String tooltipTitle;
  final String tooltipValue;
  final double highlightX;
  final double maxY;
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

class _Transaction {
  const _Transaction({
    required this.status,
    required this.statusColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.vendor,
  });

  final String status;
  final Color statusColor;
  final String title;
  final String subtitle;
  final String amount;
  final String date;
  final String vendor;
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _surfaceBlue = Color(0xFFC7E8EE);
  static const Color _sidebarBlue = Color(0xFF9AA9BD);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _buttonTan = Color(0xFFD6B39A);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF7D8A93);

  static final Map<_ManagerRange, _ManagerReportData> _reportData = {
    _ManagerRange.daily: _ManagerReportData(
      revenueToday: '\$18,420',
      customersToday: '86',
      revenueChange: '+9%',
      customersChange: '+4%',
      labels: ['6a', '8a', '10a', '12p', '2p', '4p', '6p'],
      areaSpots: [
        FlSpot(0, 10),
        FlSpot(1, 14),
        FlSpot(2, 16),
        FlSpot(3, 19),
        FlSpot(4, 25),
        FlSpot(5, 22),
        FlSpot(6, 28),
      ],
      lineSpots: [
        FlSpot(0, 8),
        FlSpot(0.5, 9),
        FlSpot(1, 11),
        FlSpot(1.5, 10),
        FlSpot(2, 13),
        FlSpot(2.5, 12),
        FlSpot(3, 14),
        FlSpot(3.5, 15),
        FlSpot(4, 17),
        FlSpot(4.5, 16),
        FlSpot(5, 18),
        FlSpot(5.5, 19),
        FlSpot(6, 18),
      ],
      tooltipTitle: '2PM Today',
      tooltipValue: '\$6,120',
      highlightX: 4,
      maxY: 32,
    ),
    _ManagerRange.monthly: _ManagerReportData(
      revenueToday: '\$2,38,485',
      customersToday: '143',
      revenueChange: '+14%',
      customersChange: '+36%',
      labels: [
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
        'Jan',
      ],
      areaSpots: [
        FlSpot(0, 14),
        FlSpot(1, 17),
        FlSpot(2, 16),
        FlSpot(3, 24),
        FlSpot(4, 29),
        FlSpot(5, 27),
        FlSpot(6, 26),
        FlSpot(7, 31),
        FlSpot(8, 29),
        FlSpot(9, 38),
        FlSpot(10, 36),
        FlSpot(11, 42),
      ],
      lineSpots: [
        FlSpot(0, 12),
        FlSpot(0.4, 11),
        FlSpot(0.9, 15),
        FlSpot(1.4, 13),
        FlSpot(2.1, 11),
        FlSpot(2.8, 16),
        FlSpot(3.4, 15),
        FlSpot(4, 14),
        FlSpot(4.6, 19),
        FlSpot(5.2, 17),
        FlSpot(5.8, 18),
        FlSpot(6.4, 16),
        FlSpot(7, 17),
        FlSpot(7.6, 14),
        FlSpot(8.2, 13),
        FlSpot(8.9, 16),
        FlSpot(9.4, 15),
        FlSpot(10, 21),
        FlSpot(10.4, 18),
        FlSpot(10.9, 19),
        FlSpot(11, 18),
      ],
      tooltipTitle: 'June 2021',
      tooltipValue: '\$45,591',
      highlightX: 4,
      maxY: 50,
    ),
    _ManagerRange.weekly: _ManagerReportData(
      revenueToday: '\$84,220',
      customersToday: '512',
      revenueChange: '+11%',
      customersChange: '+8%',
      labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      areaSpots: [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 23),
        FlSpot(3, 28),
        FlSpot(4, 33),
        FlSpot(5, 39),
        FlSpot(6, 35),
      ],
      lineSpots: [
        FlSpot(0, 14),
        FlSpot(0.5, 16),
        FlSpot(1, 18),
        FlSpot(1.5, 17),
        FlSpot(2, 19),
        FlSpot(2.5, 20),
        FlSpot(3, 21),
        FlSpot(3.5, 22),
        FlSpot(4, 24),
        FlSpot(4.5, 26),
        FlSpot(5, 29),
        FlSpot(5.5, 28),
        FlSpot(6, 25),
      ],
      tooltipTitle: 'Friday',
      tooltipValue: '\$14,320',
      highlightX: 4,
      maxY: 45,
    ),
    _ManagerRange.yearly: _ManagerReportData(
      revenueToday: '\$1.8M',
      customersToday: '8,420',
      revenueChange: '+24%',
      customersChange: '+18%',
      labels: ['2020', '2021', '2022', '2023', '2024', '2025'],
      areaSpots: [
        FlSpot(0, 24),
        FlSpot(1, 31),
        FlSpot(2, 40),
        FlSpot(3, 49),
        FlSpot(4, 60),
        FlSpot(5, 73),
      ],
      lineSpots: [
        FlSpot(0, 18),
        FlSpot(0.4, 21),
        FlSpot(1, 24),
        FlSpot(1.5, 28),
        FlSpot(2, 31),
        FlSpot(2.5, 36),
        FlSpot(3, 39),
        FlSpot(3.5, 45),
        FlSpot(4, 48),
        FlSpot(4.5, 54),
        FlSpot(5, 59),
      ],
      tooltipTitle: 'Year 2024',
      tooltipValue: '\$286,000',
      highlightX: 4,
      maxY: 80,
    ),
  };

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

  static final List<_Transaction> _transactions = [
    _Transaction(
      status: 'Completed',
      statusColor: Color(0xFF61D882),
      title: 'Visa card  **** 4831',
      subtitle: 'Card payment',
      amount: '\$182.94',
      date: 'Jan 17, 2022',
      vendor: 'Amazon',
    ),
    _Transaction(
      status: 'Completed',
      statusColor: Color(0xFF61D882),
      title: 'Mastercard  **** 6442',
      subtitle: 'Card payment',
      amount: '\$99.00',
      date: 'Jan 17, 2022',
      vendor: 'Facebook',
    ),
    _Transaction(
      status: 'Pending',
      statusColor: Color(0xFFF0C84D),
      title: 'Account  **** 882',
      subtitle: 'Bank payment',
      amount: '\$249.94',
      date: 'Jan 17, 2022',
      vendor: 'Netflix',
    ),
    _Transaction(
      status: 'Canceled',
      statusColor: Color(0xFFFF7A7A),
      title: 'Amex card  **** 5666',
      subtitle: 'Card payment',
      amount: '\$199.24',
      date: 'Jan 17, 2022',
      vendor: 'Amazon Prime',
    ),
  ];

  bool isSidebarOpen = true;
  String selectedMenu = 'Dashboard';
  _ManagerRange selectedRange = _ManagerRange.monthly;

  _ManagerReportData get data => _reportData[selectedRange]!;

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
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
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
            'Manager',
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
      width: 150,
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
          _buildSidebarItem(Icons.person_outline, 'Manage Staff'),
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
        final isCompact = constraints.maxWidth < 1100;

        if (isCompact) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMetricRow(),
                  const SizedBox(height: 12),
                  SizedBox(height: 320, child: _buildReservationsPanel()),
                  const SizedBox(height: 12),
                  SizedBox(height: 300, child: _buildSalesPanel()),
                  const SizedBox(height: 12),
                  SizedBox(height: 236, child: _buildTransactionsPanel()),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 380,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        _buildMetricRow(),
                        const SizedBox(height: 12),
                        Expanded(child: _buildSalesPanel()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildReservationsPanel(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildTransactionsPanel()),
          ],
        );
      },
    );
  }

  Widget _buildMetricRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'TOTAL REVENUE TODAY',
            value: data.revenueToday,
            change: data.revenueChange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'TOTAL CUSTOMERS TODAY',
            value: data.customersToday,
            change: data.customersChange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
  }) {
    return ManagerMetricCard(
      title: title,
      value: value,
      change: change,
      surfaceColor: _surfaceBlue,
      textColor: _textPrimary,
      mutedColor: _textMuted,
    );
  }

  Widget _buildSalesPanel() {
    return _buildPanel(
      title: 'Sales\nReport',
      action: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _buildRangeButton(_ManagerRange.daily, 'Daily'),
          _buildRangeButton(_ManagerRange.monthly, 'Monthly'),
          _buildRangeButton(_ManagerRange.weekly, 'Weekly'),
          _buildRangeButton(_ManagerRange.yearly, 'Yearly'),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _buttonTan,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.picture_as_pdf_outlined, size: 14, color: _textPrimary),
                SizedBox(width: 4),
                Text(
                  'Export PDF',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: SalesReportLineChart(
        key: ValueKey(selectedRange),
        areaSpots: data.areaSpots,
        lineSpots: data.lineSpots,
        labels: data.labels,
        tooltipTitle: data.tooltipTitle,
        tooltipValue: data.tooltipValue,
        highlightX: data.highlightX,
        maxY: data.maxY,
      ),
    );
  }

  Widget _buildReservationsPanel() {
    return _buildPanel(
      title: 'Pending Reservations',
      subtitle: 'Lorem ipsum dolor sit amet.',
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
                return ReservationListItem(
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

  Widget _buildTransactionsPanel() {
    return _buildPanel(
      title: 'Recent Transactions',
      subtitle: 'Lorem ipsum dolor sit amet, consectetur adipis.',
      action: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _buttonTan,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'See All Transactions',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: _textPrimary),
          ],
        ),
      ),
      child: Column(
        children: _transactions
            .map(
              (tx) => Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0x166C7B84)),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TransactionStatusCell(
                          status: tx.status,
                          statusColor: tx.statusColor,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TransactionTitleCell(
                          title: tx.title,
                          subtitle: tx.subtitle,
                          textColor: _textPrimary,
                          mutedColor: _textMuted,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TransactionAmountCell(
                          amount: tx.amount,
                          date: tx.date,
                          textColor: _textPrimary,
                          mutedColor: _textMuted,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tx.vendor,
                          style: const TextStyle(fontSize: 11, color: _textMuted),
                        ),
                      ),
                      const Icon(Icons.more_horiz_rounded, color: _textMuted),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRangeButton(_ManagerRange range, String label) {
    final isSelected = selectedRange == range;

    return InkWell(
      onTap: () {
        setState(() {
          selectedRange = range;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _buttonTan : _buttonTan.withOpacity(0.72),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isSelected ? _textPrimary : Colors.white.withOpacity(0.78),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel({
    required String title,
    required Widget child,
    Widget? action,
    String? subtitle,
  }) {
    return ManagerDashboardPanel(
      title: title,
      subtitle: subtitle,
      action: action,
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
