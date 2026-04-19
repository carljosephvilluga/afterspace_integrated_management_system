import 'package:flutter/material.dart';

class ActiveCustomersTable extends StatelessWidget {
  const ActiveCustomersTable({
    super.key,
    required this.textColor,
    required this.mutedColor,
  });

  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    const headers = [
      'Customer ID',
      'Type',
      'Customer',
      'Current Duration',
      'Session ID',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: headers
              .map(
                (header) => Expanded(
                  child: Container(
                    height: 16,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8B79F),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      header,
                      style: TextStyle(
                        fontSize: 9,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        _buildSkeletonRow(),
        const SizedBox(height: 10),
        _buildDataRow(),
        const SizedBox(height: 10),
        _buildSkeletonRow(),
      ],
    );
  }

  Widget _buildSkeletonRow() {
    return Container(
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: List.generate(
          5,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB3B3B3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow() {
    return Container(
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          _cell('STU-00123-2026'),
          _cell('Student'),
          _cell('Juan De La Cruz'),
          _cell('1 hr 30 mins'),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _cellText('SES-20260304-001')),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBBBBBB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'View Account Details',
                    style: TextStyle(
                      fontSize: 7,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String value) {
    return Expanded(child: _cellText(value));
  }

  Widget _cellText(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 8,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
