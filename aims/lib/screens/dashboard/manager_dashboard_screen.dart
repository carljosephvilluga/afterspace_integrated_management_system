import 'dart:async';

import 'package:aims/widgets/admin_dashboard/sales_report_line_chart.dart';
import 'package:aims/widgets/common/header.dart';
import 'package:aims/widgets/common/sidebar.dart';
import 'package:aims/services/aims_api_client.dart';
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
    required this.tooltipTitles,
    required this.tooltipValues,
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
  final List<String> tooltipTitles;
  final List<String> tooltipValues;
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
  static const double _desktopFrameWidth = 1560;
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _surfaceBlue = Color(0xFFC7E8EE);
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
      tooltipTitles: [
        '6AM Today',
        '8AM Today',
        '10AM Today',
        '12PM Today',
        '2PM Today',
        '4PM Today',
        '6PM Today',
      ],
      tooltipValues: [
        '\$2,880',
        '\$3,540',
        '\$4,180',
        '\$4,960',
        '\$6,120',
        '\$5,480',
        '\$6,940',
      ],
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
      tooltipTitles: [
        'February 2021',
        'March 2021',
        'April 2021',
        'May 2021',
        'June 2021',
        'July 2021',
        'August 2021',
        'September 2021',
        'October 2021',
        'November 2021',
        'December 2021',
        'January 2022',
      ],
      tooltipValues: [
        '\$24,180',
        '\$28,420',
        '\$27,350',
        '\$38,910',
        '\$45,591',
        '\$43,280',
        '\$41,960',
        '\$48,740',
        '\$46,180',
        '\$58,440',
        '\$55,930',
        '\$63,110',
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
      highlightX: 4,
      maxY: 50,
    ),
    _ManagerRange.weekly: _ManagerReportData(
      revenueToday: '\$84,220',
      customersToday: '512',
      revenueChange: '+11%',
      customersChange: '+8%',
      labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      tooltipTitles: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ],
      tooltipValues: [
        '\$9,420',
        '\$10,860',
        '\$10,120',
        '\$12,310',
        '\$14,320',
        '\$16,440',
        '\$13,780',
      ],
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
      highlightX: 4,
      maxY: 45,
    ),
    _ManagerRange.yearly: _ManagerReportData(
      revenueToday: '\$1.8M',
      customersToday: '8,420',
      revenueChange: '+24%',
      customersChange: '+18%',
      labels: ['2020', '2021', '2022', '2023', '2024', '2025'],
      tooltipTitles: [
        'Year 2020',
        'Year 2021',
        'Year 2022',
        'Year 2023',
        'Year 2024',
        'Year 2025',
      ],
      tooltipValues: [
        '\$186,000',
        '\$214,000',
        '\$241,500',
        '\$268,000',
        '\$286,000',
        '\$332,000',
      ],
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
  late Future<ManagerDashboardSnapshot> _dashboardSnapshotFuture;
  final Map<_ManagerRange, Future<SalesReportSeries>> _salesReportFutures = {};
  Timer? _salesRefreshTimer;

  _ManagerReportData get data => _reportData[selectedRange]!;

  @override
  void initState() {
    super.initState();
    _dashboardSnapshotFuture = AimsApiClient.instance
        .fetchManagerDashboardSnapshot();
    _refreshSalesReport(selectedRange);
    _salesRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted || selectedMenu != 'Dashboard') {
        return;
      }
      _refreshSalesReport(selectedRange, notify: false);
    });
  }

  Future<SalesReportSeries> _primeSalesReport(_ManagerRange range) {
    return _salesReportFutures[range] ??
        AimsApiClient.instance.fetchSalesReport(range: _rangeToApi(range));
  }

  void _refreshSalesReport(_ManagerRange range, {bool notify = true}) {
    _salesReportFutures[range] = AimsApiClient.instance.fetchSalesReport(
      range: _rangeToApi(range),
    );
    if (notify && mounted) {
      setState(() {});
    }
  }

  String _rangeToApi(_ManagerRange range) {
    switch (range) {
      case _ManagerRange.daily:
        return 'daily';
      case _ManagerRange.weekly:
        return 'weekly';
      case _ManagerRange.monthly:
        return 'monthly';
      case _ManagerRange.yearly:
        return 'yearly';
    }
  }

  List<FlSpot> _spotsFromValues(List<double> values) {
    return List<FlSpot>.generate(
      values.length,
      (index) => FlSpot(index.toDouble(), values[index]),
    );
  }

  @override
  void dispose() {
    _salesRefreshTimer?.cancel();
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
              role: UserRole.manager,
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
                      if (isSidebarOpen) _buildSidebar(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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

  Widget _buildSidebar() {
    return Sidebar(
      role: UserRole.manager,
      selectedTitle: selectedMenu,
      onItemSelected: (title) {
        setState(() {
          selectedMenu = title;

          switch (title) {
            case 'Dashboard':
              Navigator.pushReplacementNamed(context, '/manager-dashboard');
              break;
            case 'Calendar':
              Navigator.pushReplacementNamed(context, '/manager-calendar');
              break;
            case 'List of Users':
              Navigator.pushReplacementNamed(context, '/manager-users');
              break;
            case 'Membership and Loyalty Program':
              Navigator.pushReplacementNamed(context, '/manager-membership');
              break;
          }
        });
      },
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
                  SizedBox(height: 340, child: _buildReservationsPanel()),
                  const SizedBox(height: 12),
                  SizedBox(height: 360, child: _buildSalesPanel()),
                  const SizedBox(height: 12),
                  SizedBox(height: 300, child: _buildTransactionsPanel()),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 430,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildMetricRow(),
                        const SizedBox(height: 12),
                        Expanded(child: _buildSalesPanel()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: _buildReservationsPanel()),
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
    return FutureBuilder<ManagerDashboardSnapshot>(
      future: _dashboardSnapshotFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data?.summary;
        final revenueValue = summary != null
            ? AimsApiClient.formatCurrency(summary.revenueToday)
            : data.revenueToday;
        final customersValue = summary != null
            ? AimsApiClient.formatCount(summary.customersToday)
            : data.customersToday;

        return Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'TOTAL REVENUE TODAY',
                value: revenueValue,
                change: summary != null ? '+0%' : data.revenueChange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'TOTAL CUSTOMERS TODAY',
                value: customersValue,
                change: summary != null ? '+0%' : data.customersChange,
              ),
            ),
          ],
        );
      },
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
                Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 14,
                  color: _textPrimary,
                ),
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
      child: FutureBuilder<SalesReportSeries>(
        future: _primeSalesReport(selectedRange),
        builder: (context, snapshot) {
          final live = snapshot.data;
          final labels = (live?.labels.isNotEmpty ?? false)
              ? live!.labels
              : data.labels;
          final areaSpots = (live?.areaValues.isNotEmpty ?? false)
              ? _spotsFromValues(live!.areaValues)
              : data.areaSpots;
          final lineSpots = (live?.lineValues.isNotEmpty ?? false)
              ? _spotsFromValues(live!.lineValues)
              : data.lineSpots;
          final tooltipTitles = (live?.tooltipTitles.isNotEmpty ?? false)
              ? live!.tooltipTitles
              : data.tooltipTitles;
          final tooltipValues = (live?.tooltipValues.isNotEmpty ?? false)
              ? live!.tooltipValues
              : data.tooltipValues;
          final highlightX = live?.highlightX ?? data.highlightX;
          final maxY = live?.maxY ?? data.maxY;

          return SalesReportLineChart(
            key: ValueKey('${selectedRange}_${snapshot.hasData}'),
            areaSpots: areaSpots,
            lineSpots: lineSpots,
            labels: labels,
            tooltipTitles: tooltipTitles,
            tooltipValues: tooltipValues,
            highlightX: highlightX,
            maxY: maxY,
          );
        },
      ),
    );
  }

  Widget _buildReservationsPanel() {
    return FutureBuilder<ManagerDashboardSnapshot>(
      future: _dashboardSnapshotFuture,
      builder: (context, snapshot) {
        final liveReservations = snapshot.data?.pendingReservations
            .map(
              (item) => _Reservation(
                name: item.customerName,
                email: item.email.isNotEmpty ? item.email : item.contactDetails,
                time: _formatTime(item.startAt),
                duration: _formatDuration(item.endAt.difference(item.startAt)),
              ),
            )
            .toList();
        final reservations =
            (liveReservations != null && liveReservations.isNotEmpty)
            ? liveReservations
            : _reservations;

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

  Widget _buildTransactionsPanel() {
    return FutureBuilder<ManagerDashboardSnapshot>(
      future: _dashboardSnapshotFuture,
      builder: (context, snapshot) {
        final liveTransactions = snapshot.data?.latestTransactions
            .map(
              (item) => _Transaction(
                status: _transactionStatusLabel(item.status),
                statusColor: _transactionStatusColor(item.status),
                title: item.customerName,
                subtitle: item.paymentMethod,
                amount: AimsApiClient.formatCurrency(item.finalAmount),
                date: _formatDate(item.createdAt),
                vendor: item.email,
              ),
            )
            .toList();
        final transactions =
            (liveTransactions != null && liveTransactions.isNotEmpty)
            ? liveTransactions
            : _transactions;

        return _buildPanel(
          title: 'Recent Transactions',
          subtitle: 'Live transactions from backend.',
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
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: _textPrimary,
                ),
              ],
            ),
          ),
          child: Column(
            children: transactions
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
                          const SizedBox(width: 8),
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
                              style: const TextStyle(
                                fontSize: 11,
                                color: _textMuted,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.more_horiz_rounded,
                            color: _textMuted,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildRangeButton(_ManagerRange range, String label) {
    final isSelected = selectedRange == range;

    return InkWell(
      onTap: () {
        _refreshSalesReport(range, notify: false);
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

  String _formatDate(DateTime dateTime) {
    const months = [
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
    final month = months[dateTime.month - 1];
    return '$month ${dateTime.day}, ${dateTime.year}';
  }

  String _transactionStatusLabel(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'paid') return 'Completed';
    if (normalized == 'pending') return 'Pending';
    if (normalized == 'failed') return 'Failed';
    return 'Completed';
  }

  Color _transactionStatusColor(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'paid') return const Color(0xFF61D882);
    if (normalized == 'pending') return const Color(0xFFF0C84D);
    if (normalized == 'failed') return const Color(0xFFFF7A7A);
    return const Color(0xFF61D882);
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
