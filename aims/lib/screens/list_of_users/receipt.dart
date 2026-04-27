import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_button.dart';

class ReceiptDialog extends StatelessWidget {
  final String bookingId;
  final String customerName;
  final String spaceUsed;
  final double totalAmount;

  const ReceiptDialog({
    super.key,
    required this.bookingId,
    required this.customerName,
    required this.spaceUsed,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    // Current date and time formatting
    final now = DateTime.now();
    final dateFormatted =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final suffix = now.hour >= 12 ? 'PM' : 'AM';
    final timeFormatted = '$hour:$minute $suffix';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Icon & Title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F1F4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 42,
                  color: Color(0xFF76ACBD),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AfterSpace Study Hub',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF22313A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Receipt',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF71808A),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              _buildDashedLine(),
              const SizedBox(height: 20),

              // Receipt Details
              _buildDetailRow('Date', dateFormatted),
              _buildDetailRow('Time', timeFormatted),
              _buildDetailRow('Booking ID', bookingId),
              _buildDetailRow('Customer', customerName),
              _buildDetailRow('Space', spaceUsed),

              const SizedBox(height: 20),
              _buildDashedLine(),
              const SizedBox(height: 20),

              // Total Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF22313A),
                    ),
                  ),
                  Text(
                    '₱${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E8B57),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Close Receipt',
                  height: 52,
                  backgroundColor: const Color(0xFF76ACBD),
                  textColor: Colors.white,
                  borderColor: const Color(0xFF76ACBD),
                  onPressed: () async {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF71808A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF22313A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1.5,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFD8E4E8)),
              ),
            );
          }),
        );
      },
    );
  }
}
