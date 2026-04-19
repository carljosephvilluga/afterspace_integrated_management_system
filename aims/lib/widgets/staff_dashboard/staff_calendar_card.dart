import 'package:flutter/material.dart';

class StaffCalendarCard extends StatefulWidget {
  const StaffCalendarCard({super.key});

  @override
  State<StaffCalendarCard> createState() => _StaffCalendarCardState();
}

class _StaffCalendarCardState extends State<StaffCalendarCard> {
  final List<String> _months = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  int _month = 9;
  int _year = 2025;
  final Set<int> _selectedDays = {8, 9, 10, 11, 12, 13};

  List<int> get _years => List.generate(11, (index) => 2020 + index);

  void _changeMonth(int delta) {
    setState(() {
      _month += delta;
      if (_month < 1) {
        _month = 12;
        _year -= 1;
      } else if (_month > 12) {
        _month = 1;
        _year += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const weekLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    const visibleDays = [
      1, 2, 3, 4, 5, 6,
      7, 8, 9, 10, 11, 12, 13,
      14, 15, 16, 17, 18, 19, 20,
      21, 22, 23, 24, 25, 26, 27,
      28, 29, 30, 1, 2, 3, 4,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _changeMonth(-1),
                child: const Icon(Icons.chevron_left_rounded, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdownShell(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _month,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(_months[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _month = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdownShell(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _year,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      items: _years
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _year = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _changeMonth(1),
                child: const Icon(Icons.chevron_right_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekLabels
                  .map(
                    (label) => Text(
                      label,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF85939B),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.1,
              ),
              itemCount: visibleDays.length,
              itemBuilder: (context, index) {
                final day = visibleDays[index];
                final isOutside = index >= 31;
                final isSelected = !isOutside && _selectedDays.contains(day);

                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2E343A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white
                          : (isOutside
                              ? const Color(0xFFAAB5BC)
                              : const Color(0xFF3D4850)),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownShell({required Widget child}) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}
