import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomerReportBarChart extends StatelessWidget {
  const CustomerReportBarChart({
    super.key,
    required this.barValues,
    required this.maxY,
  });

  final List<double> barValues;
  final double maxY;

  @override
  Widget build(BuildContext context) {
    const barColors = [
      Color(0xFF45BFDA),
      Color(0xFFFAA61A),
      Color(0xFFFF4545),
      Color(0xFF94CF1A),
    ];
    final effectiveValues = List<double>.generate(
      barColors.length,
      (index) => index < barValues.length ? barValues[index] : 0,
    );
    final normalizedMaxY = maxY <= 0 ? 10.0 : maxY;
    final guideLineY = normalizedMaxY * 0.35;
    final horizontalInterval = normalizedMaxY / 3;

    return BarChart(
      BarChartData(
        maxY: normalizedMaxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: horizontalInterval <= 0 ? 1 : horizontalInterval,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Color(0x66FFFFFF), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(enabled: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: guideLineY,
              color: Colors.white.withValues(alpha: 0.4),
              strokeWidth: 1,
              dashArray: [3, 5],
            ),
          ],
        ),
        barGroups: List.generate(
          effectiveValues.length,
          (index) => BarChartGroupData(
            x: index,
            barsSpace: 10,
            barRods: [
              BarChartRodData(
                toY: effectiveValues[index],
                width: 24,
                borderRadius: BorderRadius.circular(7),
                color: barColors[index],
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: normalizedMaxY,
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
      swapAnimationDuration: const Duration(milliseconds: 300),
    );
  }
}
