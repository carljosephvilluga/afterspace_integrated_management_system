import 'dart:async';

import 'package:aims/widgets/admin_dashboard/calendar_chart.dart';
import 'package:aims/widgets/admin_dashboard/customer_report_bar_chart.dart';
import 'package:aims/widgets/admin_dashboard/sales_report_line_chart.dart';
import 'package:aims/widgets/common/header.dart';
import 'package:aims/widgets/common/sidebar.dart';
import 'package:aims/services/aims_api_client.dart';
import 'package:aims/services/sales_report_pdf_exporter.dart';
import 'package:aims/screens/staff_management/staff_management_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

enum _SalesRange { daily, monthly, weekly, yearly }

class _SalesReportData {
  const _SalesReportData({
    required this.totalSales,
    required this.totalCustomers,
    required this.totalProfit,
    required this.salesChange,
    required this.customerChange,
    required this.profitChange,
    required this.areaSpots,
    required this.lineSpots,
    required this.labels,
    required this.tooltipTitles,
    required this.tooltipValues,
    required this.highlightX,
    required this.maxY,
  });

  final String totalSales;
  final String totalCustomers;
  final String totalProfit;
  final String salesChange;
  final String customerChange;
  final String profitChange;
  final List<FlSpot> areaSpots;
  final List<FlSpot> lineSpots;
  final List<String> labels;
  final List<String> tooltipTitles;
  final List<String> tooltipValues;
  final double highlightX;
  final double maxY;
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const double _desktopFrameWidth = 1560;
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _surfaceBlue = Color(0xFFC6E8EE);
  static const Color _buttonTan = Color(0xFFD7B59E);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6C7B84);

  static const Map<_SalesRange, _SalesReportData> _salesData = {
    _SalesRange.daily: _SalesReportData(
      totalSales: '₱12,480',
      totalCustomers: '46',
      totalProfit: '₱4,910',
      salesChange: '+8%',
      customerChange: '+5%',
      profitChange: '+11%',
      labels: ['6AM', '8AM', '10AM', '12PM', '2PM', '4PM', '6PM'],
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
        '₱1,120',
        '₱1,880',
        '₱2,460',
        '₱2,790',
        '₱2,980',
        '₱2,640',
        '₱3,120',
      ],
      areaSpots: [
        FlSpot(0, 9),
        FlSpot(1, 13),
        FlSpot(2, 18),
        FlSpot(3, 22),
        FlSpot(4, 26),
        FlSpot(5, 24),
        FlSpot(6, 30),
      ],
      lineSpots: [
        FlSpot(0, 8),
        FlSpot(0.5, 10),
        FlSpot(1, 11),
        FlSpot(1.5, 14),
        FlSpot(2, 15),
        FlSpot(2.5, 16),
        FlSpot(3, 18),
        FlSpot(3.5, 17),
        FlSpot(4, 20),
        FlSpot(4.5, 19),
        FlSpot(5, 21),
        FlSpot(5.5, 23),
        FlSpot(6, 22),
      ],
      highlightX: 4,
      maxY: 35,
    ),
    _SalesRange.monthly: _SalesReportData(
      totalSales: '₱2,38,485',
      totalCustomers: '143',
      totalProfit: '₱89,240',
      salesChange: '+14%',
      customerChange: '+36%',
      profitChange: '+22%',
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
        'February 2025',
        'March 2025',
        'April 2025',
        'May 2025',
        'June 2025',
        'July 2025',
        'August 2025',
        'September 2025',
        'October 2025',
        'November 2025',
        'December 2025',
        'January 2026',
      ],
      tooltipValues: [
        '₱24,180',
        '₱28,420',
        '₱27,350',
        '₱38,910',
        '₱45,591',
        '₱43,280',
        '₱41,960',
        '₱48,740',
        '₱46,180',
        '₱58,440',
        '₱55,930',
        '₱63,110',
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
    _SalesRange.weekly: _SalesReportData(
      totalSales: '₱58,920',
      totalCustomers: '87',
      totalProfit: '₱21,770',
      salesChange: '+9%',
      customerChange: '+12%',
      profitChange: '+7%',
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
        '₱5,180',
        '₱6,240',
        '₱5,920',
        '₱7,430',
        '₱9,420',
        '₱10,880',
        '₱8,760',
      ],
      areaSpots: [
        FlSpot(0, 20),
        FlSpot(1, 24),
        FlSpot(2, 22),
        FlSpot(3, 28),
        FlSpot(4, 35),
        FlSpot(5, 39),
        FlSpot(6, 33),
      ],
      lineSpots: [
        FlSpot(0, 17),
        FlSpot(0.5, 16),
        FlSpot(1, 20),
        FlSpot(1.5, 18),
        FlSpot(2, 19),
        FlSpot(2.5, 23),
        FlSpot(3, 21),
        FlSpot(3.5, 25),
        FlSpot(4, 27),
        FlSpot(4.5, 30),
        FlSpot(5, 28),
        FlSpot(5.5, 31),
        FlSpot(6, 26),
      ],
      highlightX: 4,
      maxY: 45,
    ),
    _SalesRange.yearly: _SalesReportData(
      totalSales: '₱1.42M',
      totalCustomers: '1,284',
      totalProfit: '₱534,900',
      salesChange: '+31%',
      customerChange: '+18%',
      profitChange: '+27%',
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
        '₱128,000',
        '₱164,000',
        '₱198,500',
        '₱241,000',
        '₱286,000',
        '₱332,000',
      ],
      areaSpots: [
        FlSpot(0, 28),
        FlSpot(1, 35),
        FlSpot(2, 43),
        FlSpot(3, 51),
        FlSpot(4, 64),
        FlSpot(5, 72),
      ],
      lineSpots: [
        FlSpot(0, 20),
        FlSpot(0.4, 23),
        FlSpot(0.9, 25),
        FlSpot(1.3, 27),
        FlSpot(1.8, 30),
        FlSpot(2.2, 34),
        FlSpot(2.8, 39),
        FlSpot(3.2, 42),
        FlSpot(3.8, 47),
        FlSpot(4.2, 53),
        FlSpot(4.8, 58),
        FlSpot(5, 61),
      ],
      highlightX: 4,
      maxY: 80,
    ),
  };

  bool isSidebarOpen = true;
  String selectedMenu = 'Dashboard';
  _SalesRange _selectedSalesRange = _SalesRange.monthly;
  int _selectedCustomerReportDays = 7;
  bool _isExportingPdf = false;
  late Future<AdminDashboardSummary> _dashboardSummaryFuture;
  late Future<CustomerReportSummary> _customerReportFuture;
  final Map<_SalesRange, Future<SalesReportSeries>> _salesReportFutures = {};
  Timer? _salesRefreshTimer;

  _SalesReportData get _selectedSalesData => _salesData[_selectedSalesRange]!;

  @override
  void initState() {
    super.initState();
    _dashboardSummaryFuture = AimsApiClient.instance
        .fetchAdminDashboardSummary();
    _customerReportFuture = AimsApiClient.instance.fetchCustomerReport(
      days: _selectedCustomerReportDays,
    );
    _refreshSalesReport(_selectedSalesRange);
    _salesRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted || selectedMenu != 'Dashboard') {
        return;
      }
      _refreshSalesReport(_selectedSalesRange, notify: false);
      _refreshCustomerReport(days: _selectedCustomerReportDays, notify: false);
    });
  }

  Future<SalesReportSeries> _primeSalesReport(_SalesRange range) {
    return _salesReportFutures[range] ??
        AimsApiClient.instance.fetchSalesReport(range: _rangeToApi(range));
  }

  void _refreshSalesReport(_SalesRange range, {bool notify = true}) {
    _salesReportFutures[range] = AimsApiClient.instance.fetchSalesReport(
      range: _rangeToApi(range),
    );
    if (notify && mounted) {
      setState(() {});
    }
  }

  void _refreshCustomerReport({required int days, bool notify = true}) {
    final normalizedDays = days.clamp(1, 365).toInt();
    _selectedCustomerReportDays = normalizedDays;
    _customerReportFuture = AimsApiClient.instance.fetchCustomerReport(
      days: normalizedDays,
    );
    if (notify && mounted) {
      setState(() {});
    }
  }

  String _rangeToApi(_SalesRange range) {
    switch (range) {
      case _SalesRange.daily:
        return 'daily';
      case _SalesRange.weekly:
        return 'weekly';
      case _SalesRange.monthly:
        return 'monthly';
      case _SalesRange.yearly:
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
      await SalesReportPdfExporter.exportAllRanges(
        requestedBy: 'Administrator',
      );
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
              role: UserRole.admin,
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
                              : _buildManageStaffContent(),
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
      role: UserRole.admin,
      selectedTitle: selectedMenu,
      onItemSelected: (title) {
        setState(() {
          selectedMenu = title;
        });
      },
    );
  }

  Widget _buildDashboardContent() {
    final salesData = _selectedSalesData;

    return FutureBuilder<AdminDashboardSummary>(
      future: _dashboardSummaryFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data;
        final salesValue = summary != null
            ? AimsApiClient.formatCurrency(summary.totalRevenue)
            : salesData.totalSales;
        final customersValue = summary != null
            ? AimsApiClient.formatCount(summary.userCount)
            : salesData.totalCustomers;
        final thirdTitle = summary != null ? 'ACTIVE SESSIONS' : 'TOTAL PROFIT';
        final thirdValue = summary != null
            ? AimsApiClient.formatCount(summary.activeSessions)
            : salesData.totalProfit;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 980;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    isCompact
                        ? Column(
                            children: [
                              _buildStatCard(
                                title: 'TOTAL SALES',
                                value: salesValue,
                                change: summary != null
                                    ? '+0%'
                                    : salesData.salesChange,
                                changeColor: _getChangeColor(
                                  summary != null
                                      ? '+0%'
                                      : salesData.salesChange,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                title: 'TOTAL CUSTOMERS',
                                value: customersValue,
                                change: summary != null
                                    ? '+0%'
                                    : salesData.customerChange,
                                changeColor: _getChangeColor(
                                  summary != null
                                      ? '+0%'
                                      : salesData.customerChange,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                title: thirdTitle,
                                value: thirdValue,
                                change: summary != null
                                    ? '+0%'
                                    : salesData.profitChange,
                                changeColor: _getChangeColor(
                                  summary != null
                                      ? '+0%'
                                      : salesData.profitChange,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'TOTAL SALES',
                                  value: salesValue,
                                  change: summary != null
                                      ? '+0%'
                                      : salesData.salesChange,
                                  changeColor: _getChangeColor(
                                    summary != null
                                        ? '+0%'
                                        : salesData.salesChange,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'TOTAL CUSTOMERS',
                                  value: customersValue,
                                  change: summary != null
                                      ? '+0%'
                                      : salesData.customerChange,
                                  changeColor: _getChangeColor(
                                    summary != null
                                        ? '+0%'
                                        : salesData.customerChange,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  title: thirdTitle,
                                  value: thirdValue,
                                  change: summary != null
                                      ? '+0%'
                                      : salesData.profitChange,
                                  changeColor: _getChangeColor(
                                    summary != null
                                        ? '+0%'
                                        : salesData.profitChange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 14),
                    isCompact
                        ? Column(
                            children: [
                              SizedBox(
                                height: 320,
                                child: _buildCustomerReportPanel(),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 320,
                                child: _buildCalendarPanel(),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: 348,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _buildCustomerReportPanel(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(flex: 3, child: _buildCalendarPanel()),
                              ],
                            ),
                          ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: isCompact ? 420 : 380,
                      child: _buildSalesReportPanel(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomerReportPanel() {
    final labels = const [
      'Monthly Membership',
      'Walk-in',
      'Monthly Subscription',
      'Loyal Customers',
    ];

    return _buildPanel(
      title: 'Customer Report',
      action: PopupMenuButton<int>(
        initialValue: _selectedCustomerReportDays,
        onSelected: (days) {
          _refreshCustomerReport(days: days);
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 7, child: Text('7 days')),
          PopupMenuItem(value: 30, child: Text('30 days')),
          PopupMenuItem(value: 90, child: Text('90 days')),
        ],
        child: _buildSoftPill(
          '$_selectedCustomerReportDays days',
          icon: Icons.keyboard_arrow_down_rounded,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: FutureBuilder<CustomerReportSummary>(
          future: _customerReportFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: Text(
                  'Loading customer report...',
                  style: TextStyle(color: _textMuted, fontSize: 12),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Unable to load customer report.',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            final report = snapshot.data;
            final values = report?.chartValues ?? const [0.0, 0.0, 0.0, 0.0];
            final maxY = ((report?.maxValue ?? 1) * 1.25).toDouble();
            final counts = report == null
                ? const [0, 0, 0, 0]
                : [
                    report.monthlyMembership,
                    report.walkIn,
                    report.monthlySubscription,
                    report.loyalCustomers,
                  ];

            return Column(
              children: [
                Expanded(
                  child: CustomerReportBarChart(barValues: values, maxY: maxY),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: List.generate(4, (index) {
                    const colors = [
                      Color(0xFF45BFDA),
                      Color(0xFFFAA61A),
                      Color(0xFFFF4545),
                      Color(0xFF94CF1A),
                    ];
                    return _LegendItem(
                      color: colors[index],
                      label: '${labels[index]} (${counts[index]})',
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarPanel() {
    return _buildPanel(
      title: '',
      child: const CalendarChart(allowMeetingScheduling: true),
    );
  }

  Widget _buildSalesReportPanel() {
    final salesData = _selectedSalesData;

    return _buildPanel(
      title: 'Sales Report',
      action: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildRangeButton(_SalesRange.daily, 'Daily'),
          _buildRangeButton(_SalesRange.monthly, 'Monthly'),
          _buildRangeButton(_SalesRange.weekly, 'Weekly'),
          _buildRangeButton(_SalesRange.yearly, 'Yearly'),
          const SizedBox(width: 10),
          InkWell(
            onTap: _isExportingPdf ? null : _handleExportPdf,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _buttonTan,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isExportingPdf
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _textPrimary,
                          ),
                        )
                      : const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 16,
                          color: _textPrimary,
                        ),
                  const SizedBox(width: 6),
                  Text(
                    _isExportingPdf ? 'Exporting...' : 'Export PDF',
                    style: const TextStyle(
                      fontSize: 11,
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
        future: _primeSalesReport(_selectedSalesRange),
        builder: (context, snapshot) {
          final live = snapshot.data;
          final labels = (live?.labels.isNotEmpty ?? false)
              ? live!.labels
              : salesData.labels;
          final areaSpots = (live?.areaValues.isNotEmpty ?? false)
              ? _spotsFromValues(live!.areaValues)
              : salesData.areaSpots;
          final lineSpots = (live?.lineValues.isNotEmpty ?? false)
              ? _spotsFromValues(live!.lineValues)
              : salesData.lineSpots;
          final tooltipTitles = (live?.tooltipTitles.isNotEmpty ?? false)
              ? live!.tooltipTitles
              : salesData.tooltipTitles;
          final tooltipValues = (live?.tooltipValues.isNotEmpty ?? false)
              ? live!.tooltipValues
              : salesData.tooltipValues;
          final highlightX = live?.highlightX ?? salesData.highlightX;
          final maxY = live?.maxY ?? salesData.maxY;

          return Padding(
            padding: const EdgeInsets.only(top: 14),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: SalesReportLineChart(
                key: ValueKey('${_selectedSalesRange}_${snapshot.hasData}'),
                areaSpots: areaSpots,
                lineSpots: lineSpots,
                labels: labels,
                tooltipTitles: tooltipTitles,
                tooltipValues: tooltipValues,
                highlightX: highlightX,
                maxY: maxY,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRangeButton(_SalesRange range, String label) {
    final selected = _selectedSalesRange == range;

    return InkWell(
      onTap: () {
        _refreshSalesReport(range, notify: false);
        setState(() {
          _selectedSalesRange = range;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: _buildToggleButton(label, selected),
    );
  }

  Widget _buildSoftPill(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 2),
            Icon(icon, size: 16, color: _textMuted),
          ],
        ],
      ),
    );
  }

  Widget _buildManageStaffContent() {
    return const StaffManagementScreen(embedded: true);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required Color changeColor,
  }) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: _surfaceBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              color: _textMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: changeColor,
                      ),
                    ),
                    Icon(
                      change.startsWith('-')
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 12,
                      color: changeColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? _buttonTan : _buttonTan.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? _textPrimary : Colors.white.withValues(alpha: 0.75),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPanel({
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: _surfaceBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty || action != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                const Spacer(),
                ?action,
              ],
            ),
          if (title.isNotEmpty || action != null) const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Color _getChangeColor(String change) {
    return change.startsWith('-')
        ? const Color(0xFFEA5B64)
        : const Color(0xFF34B86B);
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: _AdminDashboardScreenState._textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
