import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_input_field.dart';
import 'package:flutter/material.dart';

class AddMembershipDialogResult {
  const AddMembershipDialogResult({
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

class AddMembershipDialog extends StatefulWidget {
  const AddMembershipDialog({super.key});

  @override
  State<AddMembershipDialog> createState() => _AddMembershipDialogState();
}

class _AddMembershipDialogState extends State<AddMembershipDialog> {
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationValueController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();

  final List<String> _durationUnits = const [
    'Month(s)',
    'Day(s)',
    'Week(s)',
    'Year(s)',
  ];

  String _selectedDurationUnit = 'Month(s)';

  @override
  void dispose() {
    _nameController.dispose();
    _durationValueController.dispose();
    _priceController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
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
              final stacked = constraints.maxWidth < 560;

              return Column(
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
                          'Create a new membership plan with pricing and benefits.',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (stacked)
                          Column(
                            children: [
                              _buildTopFields(stacked: true),
                              const SizedBox(height: 14),
                              _buildBottomFields(stacked: true),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildTopFields(stacked: false),
                              const SizedBox(height: 14),
                              _buildBottomFields(stacked: false),
                            ],
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
                        label: 'Add Membership Type',
                        backgroundColor: _textPrimary,
                        textColor: Colors.white,
                        borderColor: _textPrimary,
                        width: 200,
                        height: 42,
                        onPressed: () async {
                          final type = _nameController.text.trim();
                          final durationValue = _durationValueController.text
                              .trim();
                          final price = _priceController.text.trim();
                          final benefits = _benefitsController.text.trim();

                          if (type.isEmpty ||
                              durationValue.isEmpty ||
                              price.isEmpty ||
                              benefits.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please complete membership name, duration, price, and benefits.',
                                ),
                              ),
                            );
                            return;
                          }

                          final parsedDuration = int.tryParse(durationValue);
                          if (parsedDuration == null || parsedDuration <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Duration must be a positive number.',
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(
                            context,
                            AddMembershipDialogResult(
                              type: type,
                              duration:
                                  '$parsedDuration $_selectedDurationUnit',
                              price: price,
                              benefits: benefits,
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
            Icons.add_card_rounded,
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
                'Add Membership Type',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Set a plan name, duration, price, and benefits.',
                style: TextStyle(fontSize: 13, color: _textMuted),
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

  Widget _buildTopFields({required bool stacked}) {
    if (stacked) {
      return Column(
        children: [
          MembershipProgramInputField(
            label: 'Membership Name',
            controller: _nameController,
            hintText: 'Enter membership name',
          ),
          const SizedBox(height: 14),
          MembershipProgramInputField(
            label: 'Price',
            controller: _priceController,
            hintText: 'P 0.00',
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: MembershipProgramInputField(
            label: 'Membership Name',
            controller: _nameController,
            hintText: 'Enter membership name',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: MembershipProgramInputField(
            label: 'Price',
            controller: _priceController,
            hintText: 'P 0.00',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomFields({required bool stacked}) {
    final durationField = _buildDurationField();
    final benefitsField = MembershipProgramInputField(
      label: 'Benefits',
      controller: _benefitsController,
      hintText: 'Describe the membership benefits',
      maxLines: 2,
    );

    if (stacked) {
      return Column(
        children: [durationField, const SizedBox(height: 14), benefitsField],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: durationField),
        const SizedBox(width: 14),
        Expanded(flex: 2, child: benefitsField),
      ],
    );
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _textMuted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3EBEF)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: TextField(
                  controller: _durationValueController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDurationUnit,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(14),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                    items: _durationUnits
                        .map(
                          (unit) => DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedDurationUnit = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
