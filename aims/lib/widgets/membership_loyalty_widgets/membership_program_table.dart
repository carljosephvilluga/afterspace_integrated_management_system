import 'package:flutter/material.dart';

class MembershipProgramTable extends StatelessWidget {
  const MembershipProgramTable({
    super.key,
    required this.headers,
    required this.rows,
    required this.flexes,
    required this.headerColor,
    required this.primaryTextColor,
    required this.actionTextColor,
    this.actionColumnIndex,
    this.actionBuilder,
  });

  final List<String> headers;
  final List<List<String>> rows;
  final List<int> flexes;
  final Color headerColor;
  final Color primaryTextColor;
  final Color actionTextColor;
  final int? actionColumnIndex;
  final Widget Function(int rowIndex)? actionBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: headerColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: List.generate(headers.length, (index) {
              return Expanded(
                flex: flexes[index],
                child: Text(
                  headers[index],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ),
        ),
        ...rows.asMap().entries.map((entry) => _buildRow(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildRow(int rowIndex, List<String> values) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: rowIndex.isEven
            ? Colors.white.withOpacity(0.30)
            : Colors.white.withOpacity(0.16),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(values.length, (index) {
          final isActionColumn = actionColumnIndex == index;

          return Expanded(
            flex: flexes[index],
            child: isActionColumn && actionBuilder != null
                ? actionBuilder!(rowIndex)
                : Text(
                    values[index],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActionColumn
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isActionColumn
                          ? actionTextColor
                          : primaryTextColor,
                      height: 1.25,
                    ),
                  ),
          );
        }),
      ),
    );
  }
}
