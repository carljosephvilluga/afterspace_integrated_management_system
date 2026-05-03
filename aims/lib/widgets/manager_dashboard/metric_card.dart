import 'package:flutter/material.dart';

class ManagerMetricCard extends StatelessWidget {
  const ManagerMetricCard({
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
              color: mutedColor,
              fontWeight: FontWeight.w700,
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
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: trendColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  change.startsWith('-')
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 12,
                  color: trendColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
