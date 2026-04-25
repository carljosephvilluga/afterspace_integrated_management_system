import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_button.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final VoidCallback onGenerateReceipt;

  const PaymentSuccessDialog({super.key, required this.onGenerateReceipt});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- SUCCESS TEXT & ICON ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF00C853,
                      ), // Green background for the check
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // --- GENERATE RECEIPT BUTTON ---
              CustomButton(
                width: 240,
                height: 48,
                label: 'Generate Receipt',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black,
                onPressed: () async {
                  Navigator.pop(context); // Close this dialog
                  onGenerateReceipt(); // Run the placeholder logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
