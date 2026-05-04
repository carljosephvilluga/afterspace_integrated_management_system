import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesReportLineChart extends StatefulWidget {
  const SalesReportLineChart({
    super.key,
    required this.areaSpots,
    required this.lineSpots,
    required this.labels,
    required this.tooltipTitles,
    required this.tooltipValues,
    required this.highlightX,
    required this.maxY,
  });

  final List<FlSpot> areaSpots;
  final List<FlSpot> lineSpots;
  final List<String> labels;
  final List<String> tooltipTitles;
  final List<String> tooltipValues;
  final double highlightX;
  final double maxY;

  @override
  State<SalesReportLineChart> createState() => _SalesReportLineChartState();
}

class _SalesReportLineChartState extends State<SalesReportLineChart> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _clampIndex(widget.highlightX.round());
  }

  @override
  void didUpdateWidget(covariant SalesReportLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.labels != widget.labels ||
        oldWidget.highlightX != widget.highlightX) {
      _selectedIndex = _clampIndex(widget.highlightX.round());
    }
  }

  int _clampIndex(int index) {
    if (widget.labels.isEmpty) {
      return 0;
    }

    return index.clamp(0, widget.labels.length - 1);
  }

  FlSpot get _selectedAreaSpot {
    for (final spot in widget.areaSpots) {
      if (spot.x.round() == _selectedIndex) {
        return spot;
      }
    }

    return FlSpot(_selectedIndex.toDouble(), 0);
  }

  String get _tooltipTitle {
    if (_selectedIndex < widget.tooltipTitles.length) {
      return widget.tooltipTitles[_selectedIndex];
    }

    if (_selectedIndex < widget.labels.length) {
      return widget.labels[_selectedIndex];
    }

    return '';
  }

  String get _tooltipValue {
    if (_selectedIndex < widget.tooltipValues.length) {
      return _withPesoSymbol(widget.tooltipValues[_selectedIndex]);
    }

    return '₱${_selectedAreaSpot.y.toStringAsFixed(1)}';
  }

  String _withPesoSymbol(String value) {
    return value.replaceAll(r'$', '₱');
  }

  void _updateSelectedIndex(double dx, double width) {
    if (widget.labels.length <= 1 || width <= 0) {
      return;
    }

    final progress = (dx / width).clamp(0.0, 1.0);
    final rawIndex = (progress * (widget.labels.length - 1)).round();
    final nextIndex = _clampIndex(rawIndex);

    if (nextIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = nextIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const tooltipWidth = 92.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;
        final selectedProgress = widget.labels.length <= 1
            ? 0.0
            : _selectedIndex / (widget.labels.length - 1);
        final pointLeft = selectedProgress * chartWidth;
        final tooltipLeft = (pointLeft - (tooltipWidth / 2)).clamp(
          0.0,
          chartWidth - tooltipWidth,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            _updateSelectedIndex(details.localPosition.dx, chartWidth);
          },
          onHorizontalDragStart: (details) {
            _updateSelectedIndex(details.localPosition.dx, chartWidth);
          },
          onHorizontalDragUpdate: (details) {
            _updateSelectedIndex(details.localPosition.dx, chartWidth);
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 34),
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (widget.labels.length - 1).toDouble(),
                    minY: 0,
                    maxY: widget.maxY,
                    clipData: const FlClipData.all(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: widget.maxY / 5,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Color(0x66FFFFFF),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 || index >= widget.labels.length) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                widget.labels[index],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6C7B84),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: const LineTouchData(enabled: false),
                    extraLinesData: ExtraLinesData(
                      verticalLines: [
                        VerticalLine(
                          x: _selectedAreaSpot.x,
                          color: const Color(0x99FFFFFF),
                          strokeWidth: 1,
                        ),
                      ],
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: widget.areaSpots,
                        isCurved: true,
                        barWidth: 2,
                        color: const Color(0xFF876C58),
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) =>
                              spot.x.round() == _selectedIndex,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: const Color(0xFF6F64FF),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFFD8B79F),
                        ),
                      ),
                      LineChartBarData(
                        spots: widget.lineSpots,
                        isCurved: true,
                        barWidth: 2,
                        color: const Color(0xFF232323),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 120),
                ),
              ),
              Positioned(
                left: tooltipLeft,
                top: 0,
                child: Column(
                  children: [
                    Container(
                      width: tooltipWidth,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8B79F),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _tooltipTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF5D4B40),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tooltipValue,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2A221D),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomPaint(
                      size: const Size(10, 10),
                      painter: _TooltipPointerPainter(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TooltipPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD8B79F);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
