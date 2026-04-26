import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_input_field.dart';
import 'package:flutter/material.dart';

class PromoDialogResult {
  const PromoDialogResult({
    required this.name,
    required this.type,
    required this.discount,
    required this.expiry,
  });

  final String name;
  final String type;
  final String discount;
  final String expiry;
}

class CreatePromoDialog extends StatefulWidget {
  const CreatePromoDialog({super.key});

  @override
  State<CreatePromoDialog> createState() => _CreatePromoDialogState();
}

class _CreatePromoDialogState extends State<CreatePromoDialog> {
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);

  final TextEditingController _promoNameController = TextEditingController(
    text: 'Exam Season Promo',
  );
  final TextEditingController _priceController = TextEditingController(
    text: 'P 100.00',
  );
  final TextEditingController _typeController = TextEditingController(
    text: 'Student Discount',
  );
  final TextEditingController _durationController = TextEditingController(
    text: 'March 02, 2026- March 13, 2026',
  );
  final TextEditingController _benefitsController = TextEditingController(
    text: 'Avail for 4 hours and Get 1 hour free(for students only)',
  );

  DateTimeRange? _selectedRange = DateTimeRange(
    start: DateTime(2026, 3, 2),
    end: DateTime(2026, 3, 13),
  );

  @override
  void dispose() {
    _promoNameController.dispose();
    _priceController.dispose();
    _typeController.dispose();
    _durationController.dispose();
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
                          'Set up a new promo offer for members and students.',
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
                        label: 'Add Promotion Type',
                        backgroundColor: _textPrimary,
                        textColor: Colors.white,
                        borderColor: _textPrimary,
                        width: 190,
                        height: 42,
                        onPressed: () async {
                          Navigator.pop(
                            context,
                            PromoDialogResult(
                              name: _promoNameController.text.trim(),
                              type: _typeController.text.trim(),
                              discount: _priceController.text.trim(),
                              expiry: _selectedRange == null
                                  ? _durationController.text.trim()
                                  : _formatDate(_selectedRange!.end),
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
            Icons.local_offer_outlined,
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
                'Create Promo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Add a promo name, schedule, and benefit details.',
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

  Widget _buildTopFields({required bool stacked}) {
    if (stacked) {
      return Column(
        children: [
          MembershipProgramInputField(
            label: 'Promo Name',
            controller: _promoNameController,
            hintText: 'Enter promo name',
          ),
          const SizedBox(height: 14),
          MembershipProgramInputField(
            label: 'Price',
            controller: _priceController,
            hintText: 'P 0.00',
          ),
          const SizedBox(height: 14),
          MembershipProgramInputField(
            label: 'Promo Type',
            controller: _typeController,
            hintText: 'Student Discount',
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
            label: 'Promo Name',
            controller: _promoNameController,
            hintText: 'Enter promo name',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: MembershipProgramInputField(
            label: 'Price',
            controller: _priceController,
            hintText: 'P 0.00',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: MembershipProgramInputField(
            label: 'Promo Type',
            controller: _typeController,
            hintText: 'Student Discount',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomFields({required bool stacked}) {
    final durationField = MembershipProgramInputField(
      label: 'Duration',
      controller: _durationController,
      readOnly: true,
      onTap: _pickDateRange,
      suffixIcon: IconButton(
        onPressed: _pickDateRange,
        icon: const Icon(
          Icons.calendar_today_outlined,
          size: 20,
          color: _textPrimary,
        ),
      ),
    );

    final benefitsField = MembershipProgramInputField(
      label: 'Benefits',
      controller: _benefitsController,
      hintText: 'Describe the promo benefit',
      maxLines: 2,
    );

    if (stacked) {
      return Column(
        children: [
          durationField,
          const SizedBox(height: 14),
          benefitsField,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: durationField),
        const SizedBox(width: 14),
        Expanded(flex: 2, child: benefitsField),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialDateRange: _selectedRange,
    );

    if (pickedRange == null) {
      return;
    }

    setState(() {
      _selectedRange = pickedRange;
      _durationController.text =
          '${_formatDate(pickedRange.start)}- ${_formatDate(pickedRange.end)}';
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    return '$month $day, ${date.year}';
  }
}
