import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_input_field.dart';
import 'package:flutter/material.dart';

class HourlyPricingDialogResult {
  const HourlyPricingDialogResult({
    required this.boardRoomHourlyRate,
    required this.ordinarySpaceHourlyRate,
  });

  final double boardRoomHourlyRate;
  final double ordinarySpaceHourlyRate;
}

class EditHourlyPricingDialog extends StatefulWidget {
  const EditHourlyPricingDialog({
    super.key,
    required this.initialBoardRoomRate,
    required this.initialOrdinarySpaceRate,
  });

  final double initialBoardRoomRate;
  final double initialOrdinarySpaceRate;

  @override
  State<EditHourlyPricingDialog> createState() => _EditHourlyPricingDialogState();
}

class _EditHourlyPricingDialogState extends State<EditHourlyPricingDialog> {
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);

  late final TextEditingController _boardRoomController;
  late final TextEditingController _ordinarySpaceController;

  @override
  void initState() {
    super.initState();
    _boardRoomController = TextEditingController(
      text: widget.initialBoardRoomRate.toStringAsFixed(2),
    );
    _ordinarySpaceController = TextEditingController(
      text: widget.initialOrdinarySpaceRate.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _boardRoomController.dispose();
    _ordinarySpaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.85)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 28,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _panelBlue.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Only managers can update the hourly charges used during checkout.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 520) {
                          return Column(
                            children: [
                              MembershipProgramInputField(
                                label: 'Board Room Hourly Charge',
                                controller: _boardRoomController,
                                hintText: '0.00',
                              ),
                              const SizedBox(height: 14),
                              MembershipProgramInputField(
                                label: 'Ordinary Space Hourly Charge',
                                controller: _ordinarySpaceController,
                                hintText: '0.00',
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MembershipProgramInputField(
                                label: 'Board Room Hourly Charge',
                                controller: _boardRoomController,
                                hintText: '0.00',
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: MembershipProgramInputField(
                                label: 'Ordinary Space Hourly Charge',
                                controller: _ordinarySpaceController,
                                hintText: '0.00',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  CustomButton(
                    label: 'Cancel',
                    backgroundColor: Colors.white,
                    textColor: _textPrimary,
                    borderColor: const Color(0xFFB7C4CB),
                    width: 172,
                    height: 42,
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                  CustomButton(
                    label: 'Save Hourly Rates',
                    backgroundColor: _textPrimary,
                    textColor: Colors.white,
                    borderColor: _textPrimary,
                    width: 190,
                    height: 42,
                    onPressed: () async {
                      final boardRoomRate =
                          double.tryParse(_boardRoomController.text.trim());
                      final ordinarySpaceRate =
                          double.tryParse(_ordinarySpaceController.text.trim());

                      if (boardRoomRate == null ||
                          ordinarySpaceRate == null ||
                          boardRoomRate <= 0 ||
                          ordinarySpaceRate <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Enter valid hourly charges for both space types.',
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(
                        context,
                        HourlyPricingDialogResult(
                          boardRoomHourlyRate: boardRoomRate,
                          ordinarySpaceHourlyRate: ordinarySpaceRate,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _panelBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.payments_outlined,
            color: _headerBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Hourly Charges',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Set the manager-approved rates for boardrooms and ordinary spaces.',
                style: TextStyle(
                  fontSize: 13,
                  color: _textMuted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF5F8F9),
            foregroundColor: _textPrimary,
          ),
          icon: const Icon(Icons.close_rounded, size: 24),
        ),
      ],
    );
  }
}
