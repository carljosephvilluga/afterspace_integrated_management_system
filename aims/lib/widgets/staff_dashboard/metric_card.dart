import 'package:flutter/material.dart';

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
    final trendColor = change.startsWith('-')
        ? const Color(0xFFEA5B64)
        : const Color(0xFF34B86B);

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 8,
              color: mutedColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    change,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: trendColor,
                    ),
                  ),
                  Icon(
                    change.startsWith('-')
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 12,
                    color: trendColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
