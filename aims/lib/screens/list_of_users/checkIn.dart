import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_button.dart';

class CheckInData {
  final String spaceUsed;
  final DateTime timeIn;

  CheckInData({required this.spaceUsed, required this.timeIn});
}

class CheckIn extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String userType;
  final String membershipType;
  final DateTime timeIn; // 1. Added timeIn back!
  final VoidCallback onConfirm;
  final VoidCallback? onEditUser;

  const CheckIn({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.membershipType,
    required this.timeIn, // 2. Added to constructor
    required this.onConfirm,
    this.onEditUser,
  });

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  String _selectedSpace = 'Ordinary Space';

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.month}/${dt.day}/${dt.year} $hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER & CLOSE BUTTON ---
              Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Confirm Check-in',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 28,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- ROW 1: USER ID & NAME ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildReadonlyField(
                      title: 'User ID',
                      value: widget.userId,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildReadonlyField(
                      title: 'Name',
                      subtitle: 'Last Name',
                      value: widget.lastName,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: _buildReadonlyField(
                      subtitle: 'First Name',
                      value: widget.firstName,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildReadonlyField(
                      subtitle: 'M.I',
                      value: widget.firstName.isNotEmpty
                          ? '${widget.firstName[0]}.'
                          : '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- ROW 2: EMAIL & PHONE ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildReadonlyField(
                      title: 'Email',
                      value: widget.email,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: _buildReadonlyField(
                      title: 'Phone Number',
                      value: widget.phoneNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- ROW 3: TYPE, MEMBERSHIP, LAST VISIT ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildReadonlyField(
                      title: 'Type',
                      value: widget.userType,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildReadonlyField(
                      title: 'Membership',
                      value: widget.membershipType,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildReadonlyField(
                      title: 'Last Visit',
                      value: 'Mar. 1, 2026',
                      trailingWidget: Container(
                        height: 32,
                        margin: const EdgeInsets.only(left: 8),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            side: const BorderSide(color: Colors.black87),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('View'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- ROW 4: TIME IN & Space SELECTION ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // TIME IN
                  Expanded(
                    flex: 1,
                    child: _buildReadonlyField(
                      title: 'Time In',
                      value: _formatTime(widget.timeIn),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Space DROPDOWN
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Facility',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 32, // Matched height with read-only boxes
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDE3E6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSpace,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Ordinary Space',
                                  child: Text('Ordinary Space'),
                                ),
                                DropdownMenuItem(
                                  value: 'Board Room',
                                  child: Text('Board Room'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedSpace = value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- ACTION BUTTONS ---
              CustomButton(
                width: 200,
                height: 40,
                label: 'Edit User Info',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                borderColor: Colors.black,
                onPressed: () async {
                  if (widget.onEditUser != null) {
                    Navigator.pop(context);
                    widget.onEditUser!();
                  }
                },
              ),

              const SizedBox(height: 12),

              CustomButton(
                width: 240,
                height: 48,
                label: 'Confirm Check-in',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black,
                onPressed: () async {
                  Navigator.pop(
                    context,
                    CheckInData(
                      spaceUsed: _selectedSpace,
                      timeIn: widget.timeIn,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget
  Widget _buildReadonlyField({
    String? title,
    String? subtitle,
    required String value,
    Widget? trailingWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ] else if (subtitle == null) ...[
          const SizedBox(height: 18),
        ],

        if (subtitle != null) ...[
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ] else if (title != null) ...[
          const SizedBox(height: 4),
        ],

        Row(
          children: [
            Expanded(
              child: Container(
                height: 32,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE3E6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ],
    );
  }
}
