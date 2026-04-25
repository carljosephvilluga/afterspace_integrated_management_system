import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_button.dart';

class CheckOut extends StatelessWidget {
  final String bookingId;
  final String customerName;
  final String spaceUsed;
  final DateTime timeIn;
  final VoidCallback onConfirm;

  const CheckOut({
    super.key,
    required this.bookingId,
    required this.customerName,
    required this.spaceUsed,
    required this.timeIn,
    required this.onConfirm,
  });

  // Helper to format DateTime into "8:00 AM" format
  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  // Helper to calculate and format the duration
  String _calculateDuration(DateTime start, DateTime end) {
    final difference = end.difference(start);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours hrs $minutes mins';
    } else if (hours > 0) {
      return '$hours hrs';
    } else {
      return '$minutes mins';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Capture the exact time the checkout dialog is opened
    final DateTime timeOut = DateTime.now();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center children in Column
            children: [
              // --- TITLE ---
              const Text(
                'Confirm Check-out',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // --- DETAILS SECTION 1 ---
              _buildCenteredDetailRow(Icons.book, 'Booking ID:', bookingId),
              const SizedBox(height: 12),
              _buildCenteredDetailRow(
                Icons.person_outline,
                'Customer:',
                customerName,
              ),
              const SizedBox(height: 12),
              _buildCenteredDetailRow(
                Icons.chair_alt,
                'Space used:',
                spaceUsed,
              ),

              const SizedBox(height: 24),

              // --- DETAILS SECTION 2 (TIME) ---
              _buildCenteredDetailRow(
                Icons.access_time,
                'Time in:',
                _formatTime(timeIn),
              ),
              const SizedBox(height: 12),
              _buildCenteredDetailRow(
                Icons.access_time,
                'Time out:',
                _formatTime(timeOut),
              ),
              const SizedBox(height: 12),
              _buildCenteredDetailRow(
                Icons.hourglass_bottom,
                'Duration:',
                _calculateDuration(timeIn, timeOut),
              ),

              const SizedBox(height: 24),

              // --- TOTAL SECTION (Now Centered) ---
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'TOTAL: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '₱235.00', // Hardcoded placeholder
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- CHECKOUT BUTTON ---
              CustomButton(
                width: 240,
                height: 48,
                label: 'Check-out',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black,
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog
                  onConfirm();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build centered rows using RichText
  Widget _buildCenteredDetailRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 14),
        Flexible(
          // Wrap RichText to allow for long customer names
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
