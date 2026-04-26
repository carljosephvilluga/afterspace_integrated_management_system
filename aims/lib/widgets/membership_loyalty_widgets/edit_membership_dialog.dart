import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_input_field.dart';
import 'package:flutter/material.dart';

class MembershipDialogResult {
  const MembershipDialogResult({
    required this.type,
    required this.duration,
    required this.price,
    required this.benefits,
  });

  final String type;
  final String duration;
  final String price;
  final String benefits;
}

class EditMembershipDialog extends StatefulWidget {
  const EditMembershipDialog({
    super.key,
    required this.initialType,
    required this.initialDuration,
    required this.initialPrice,
    required this.initialBenefits,
  });

  final String initialType;
  final String initialDuration;
  final String initialPrice;
  final String initialBenefits;

  @override
  State<EditMembershipDialog> createState() => _EditMembershipDialogState();
}

class _EditMembershipDialogState extends State<EditMembershipDialog> {
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);

  late final TextEditingController _typeController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;
  late final TextEditingController _benefitsController;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.initialType);
    _durationController = TextEditingController(text: widget.initialDuration);
    _priceController = TextEditingController(text: widget.initialPrice);
    _benefitsController = TextEditingController(text: widget.initialBenefits);
  }

  @override
  void dispose() {
    _typeController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _benefitsController.dispose();
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 540;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _panelBlue.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        if (stacked) ...[
                          MembershipProgramInputField(
                            label: 'Membership Type',
                            controller: _typeController,
                            hintText: 'Monthly Membership',
                          ),
                          const SizedBox(height: 14),
                          MembershipProgramInputField(
                            label: 'Duration',
                            controller: _durationController,
                            hintText: '30 days',
                          ),
                          const SizedBox(height: 14),
                          MembershipProgramInputField(
                            label: 'Price',
                            controller: _priceController,
                            hintText: 'PHP 0.00',
                          ),
                          const SizedBox(height: 14),
                          MembershipProgramInputField(
                            label: 'Benefits',
                            controller: _benefitsController,
                            hintText: 'Membership benefits',
                            maxLines: 2,
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: MembershipProgramInputField(
                                  label: 'Membership Type',
                                  controller: _typeController,
                                  hintText: 'Monthly Membership',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: MembershipProgramInputField(
                                  label: 'Duration',
                                  controller: _durationController,
                                  hintText: '30 days',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: MembershipProgramInputField(
                                  label: 'Price',
                                  controller: _priceController,
                                  hintText: 'PHP 0.00',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: MembershipProgramInputField(
                                  label: 'Benefits',
                                  controller: _benefitsController,
                                  hintText: 'Membership benefits',
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                        width: 160,
                        height: 42,
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                      CustomButton(
                        label: 'Save Changes',
                        backgroundColor: _textPrimary,
                        textColor: Colors.white,
                        borderColor: _textPrimary,
                        width: 170,
                        height: 42,
                        onPressed: () async {
                          Navigator.pop(
                            context,
                            MembershipDialogResult(
                              type: _typeController.text.trim(),
                              duration: _durationController.text.trim(),
                              price: _priceController.text.trim(),
                              benefits: _benefitsController.text.trim(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            Icons.edit_note_rounded,
            color: _headerBlue,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Membership',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Update the membership details and save your changes.',
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
