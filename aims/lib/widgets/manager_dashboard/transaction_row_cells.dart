import 'package:flutter/material.dart';

class TransactionStatusCell extends StatelessWidget {
  const TransactionStatusCell({
    super.key,
    required this.status,
    required this.statusColor,
  });

  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TransactionTitleCell extends StatelessWidget {
  const TransactionTitleCell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.mutedColor,
  });

  final String title;
  final String subtitle;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(subtitle, style: TextStyle(fontSize: 10, color: mutedColor)),
      ],
    );
  }
}

class TransactionAmountCell extends StatelessWidget {
  const TransactionAmountCell({
    super.key,
    required this.amount,
    required this.date,
    required this.textColor,
    required this.mutedColor,
  });

  final String amount;
  final String date;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          amount,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(date, style: TextStyle(fontSize: 10, color: mutedColor)),
      ],
    );
  }
}
