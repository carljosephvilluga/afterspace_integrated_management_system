import 'package:flutter/material.dart';

class ReservationListItem extends StatelessWidget {
  const ReservationListItem({
    super.key,
    required this.name,
    required this.email,
    required this.time,
    required this.duration,
    required this.textColor,
    required this.mutedColor,
  });

  final String name;
  final String email;
  final String time;
  final String duration;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withValues(alpha: 0.75),
          child: Text(
            name.substring(0, 1),
            style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(email, style: TextStyle(fontSize: 12, color: mutedColor)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(duration, style: TextStyle(fontSize: 12, color: mutedColor)),
          ],
        ),
      ],
    );
  }
}
