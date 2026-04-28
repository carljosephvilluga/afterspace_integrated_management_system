import 'dart:async';

import 'package:aims/widgets/admin_dashboard/sales_report_line_chart.dart';
import 'package:aims/widgets/common/header.dart';
import 'package:aims/widgets/common/sidebar.dart';
import 'package:aims/services/aims_api_client.dart';
import 'package:aims/services/sales_report_pdf_exporter.dart';
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

  bool isSidebarOpen = true;
  String selectedMenu = 'Dashboard';
  _ManagerRange selectedRange = _ManagerRange.monthly;
  bool _isExportingPdf = false;
  late Future<ManagerDashboardSnapshot> _dashboardSnapshotFuture;
  final Map<_ManagerRange, Future<SalesReportSeries>> _salesReportFutures = {};
  Timer? _salesRefreshTimer;

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

  Future<void> _handleExportPdf() async {
    if (_isExportingPdf) {
      return;
    }

    setState(() {
      _isExportingPdf = true;
    });

    try {
      await SalesReportPdfExporter.exportAllRanges(requestedBy: 'Manager');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sales report PDF generated (daily, weekly, monthly, yearly).',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export PDF: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
        });
      }
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
            : '--';
        final customersValue = summary != null
            ? AimsApiClient.formatCount(summary.customersToday)
            : '--';
        final status = snapshot.hasError
            ? 'OFFLINE'
            : summary != null
            ? 'LIVE'
            : 'SYNCING';

        return Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'TOTAL REVENUE TODAY',
                value: revenueValue,
                change: status,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'TOTAL CUSTOMERS TODAY',
                value: customersValue,
                change: status,
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
          InkWell(
            onTap: _isExportingPdf ? null : _handleExportPdf,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _buttonTan,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isExportingPdf
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _textPrimary,
                          ),
                        )
                      : const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 14,
                          color: _textPrimary,
                        ),
                  const SizedBox(width: 4),
                  Text(
                    _isExportingPdf ? 'Exporting...' : 'Export PDF',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: FutureBuilder<SalesReportSeries>(
        future: _primeSalesReport(selectedRange),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return _buildCenteredPanelMessage('Loading sales report...');
          }

          if (snapshot.hasError) {
            return _buildCenteredPanelMessage(
              'Unable to load sales report from backend.',
            );
          }

          final live = snapshot.data;
          if (live == null ||
              live.labels.isEmpty ||
              live.areaValues.isEmpty ||
              live.lineValues.isEmpty) {
            return _buildCenteredPanelMessage('No sales data available yet.');
          }

          return SalesReportLineChart(
            key: ValueKey('${selectedRange}_${snapshot.hasData}'),
            areaSpots: _spotsFromValues(live.areaValues),
            lineSpots: _spotsFromValues(live.lineValues),
            labels: live.labels,
            tooltipTitles: live.tooltipTitles,
            tooltipValues: live.tooltipValues,
            highlightX: live.highlightX,
            maxY: live.maxY,
          );
        },
      ),
    );
  }

  Widget _buildReservationsPanel() {
    return FutureBuilder<ManagerDashboardSnapshot>(
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
        final transactions =
            (snapshot.data?.latestTransactions ??
                    const <DashboardTransactionItem>[])
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

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildPanel(
            title: 'Recent Transactions',
            subtitle: 'Live transactions from backend.',
            action: _buildTransactionsAction(),
            child: _buildCenteredPanelMessage('Loading transactions...'),
          );
        }

        if (snapshot.hasError) {
          return _buildPanel(
            title: 'Recent Transactions',
            subtitle: 'Live transactions from backend.',
            action: _buildTransactionsAction(),
            child: _buildCenteredPanelMessage(
              'Unable to load transactions from backend.',
            ),
          );
        }

        if (transactions.isEmpty) {
          return _buildPanel(
            title: 'Recent Transactions',
            subtitle: 'Live transactions from backend.',
            action: _buildTransactionsAction(),
            child: _buildCenteredPanelMessage('No transactions found yet.'),
          );
        }

        return _buildPanel(
          title: 'Recent Transactions',
          subtitle: 'Live transactions from backend.',
          action: _buildTransactionsAction(),
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

  Widget _buildTransactionsAction() {
    return Container(
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
