import 'package:flutter/material.dart';

class ManagerDashboardPanel extends StatelessWidget {
  const ManagerDashboardPanel({
    super.key,
    required this.title,
    required this.child,
    required this.surfaceColor,
    required this.textColor,
    this.action,
    this.subtitle,
  });

  final String title;
  final Widget child;
  final Widget? action;
  final String? subtitle;
  final Color surfaceColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty || action != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  const Spacer(),
                if (action != null) ...[const SizedBox(width: 12), action!],
              ],
            ),
            const SizedBox(height: 16),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}
