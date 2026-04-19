import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomerReportBarChart extends StatelessWidget {
  const CustomerReportBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    const barValues = [10.0, 13.2, 11.2, 7.0];
    const barColors = [
      Color(0xFF45BFDA),
      Color(0xFFFAA61A),
      Color(0xFFFF4545),
      Color(0xFF94CF1A),
    ];

    return BarChart(
      BarChartData(
        maxY: 15,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Color(0x66FFFFFF),
              strokeWidth: 1,
            );
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
              y: 4.5,
              color: Colors.white.withOpacity(0.4),
              strokeWidth: 1,
              dashArray: [3, 5],
            ),
          ],
        ),
        barGroups: List.generate(
          barValues.length,
          (index) => BarChartGroupData(
            x: index,
            barsSpace: 10,
            barRods: [
              BarChartRodData(
                toY: barValues[index],
                width: 24,
                borderRadius: BorderRadius.circular(7),
                color: barColors[index],
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 15,
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
