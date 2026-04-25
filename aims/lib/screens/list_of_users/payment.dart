import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aims/widgets/common/custom_button.dart';

class PaymentDialog extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onConfirm;

  const PaymentDialog({
    super.key,
    required this.totalAmount,
    required this.onConfirm,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _selectedMethod = 'Cash'; // Default selection
  final TextEditingController _amountController = TextEditingController();
  double _change = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Calculate change dynamically when the user types
  void _calculateChange(String value) {
    final double amountReceived = double.tryParse(value) ?? 0.0;
    setState(() {
      if (amountReceived >= widget.totalAmount) {
        _change = amountReceived - widget.totalAmount;
      } else {
        _change = 0.0; // Don't show negative change
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
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
                      'Payment',
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
                        size: 32,
                        color: Colors.black54,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- PAYMENT METHOD BUTTONS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPaymentMethodBtn(
                    label: 'Cash',
                    iconEmoji: '💵',
                    isSelected: _selectedMethod == 'Cash',
                    onTap: () => setState(() => _selectedMethod = 'Cash'),
                  ),
                  const SizedBox(width: 20),
                  _buildPaymentMethodBtn(
                    label: 'Online Payment',
                    iconEmoji: '📲',
                    isSelected: _selectedMethod == 'Online Payment',
                    onTap: () {
                      setState(() {
                        _selectedMethod = 'Online Payment';
                        _amountController
                            .clear(); // Clear cash when switching to online
                        _change = 0.0;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- AMOUNT & CHANGE SECTION ---
              // Only show the cash calculation if "Cash" is selected
              if (_selectedMethod == 'Cash') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      // Amount Received Row
                      Row(
                        children: [
                          const Text(
                            'Amount Received:   ₱',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              onChanged: _calculateChange,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                border: UnderlineInputBorder(),
                                hintText: '0.00',
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Change Row
                      Row(
                        children: [
                          const Text(
                            'Change:   ',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            '₱${_change.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // --- NEW: ONLINE PAYMENT UI ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 48,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Direct customer to scan the store QR code.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please verify that exactly ₱${widget.totalAmount.toStringAsFixed(2)} was received\nbefore confirming the payment.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // --- CONFIRM BUTTON ---
              CustomButton(
                width: 240,
                height: 48,
                label: 'Confirm Payment',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black,
                onPressed: () async {
                  // Only validate the amount if Cash is selected
                  if (_selectedMethod == 'Cash' &&
                      (double.tryParse(_amountController.text) ?? 0.0) <
                          widget.totalAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Amount received is less than total!'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context); // Close Payment Dialog
                  widget.onConfirm(); // Trigger success logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the gray payment method selection buttons
  Widget _buildPaymentMethodBtn({
    required String label,
    required String iconEmoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 50,
        decoration: BoxDecoration(
          // Make the selected one slightly darker gray so the user knows it's active
          color: isSelected ? const Color(0xFFAFAFAF) : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black54 : Colors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(iconEmoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
