import 'package:aims/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';

class DeleteMembershipDialog extends StatelessWidget {
  const DeleteMembershipDialog({
    super.key,
    required this.membershipType,
  });

  final String membershipType;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 430,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFFDEAEA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFC95656),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Membership',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF23323A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Are you sure you want to delete "$membershipType"? This action will remove it from the membership list.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF6F7E87),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                CustomButton(
                  label: 'Cancel',
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF23323A),
                  borderColor: const Color(0xFFB7C4CB),
                  width: 160,
                  height: 42,
                  onPressed: () async {
                    Navigator.pop(context, false);
                  },
                ),
                CustomButton(
                  label: 'Delete',
                  backgroundColor: const Color(0xFFC95656),
                  textColor: Colors.white,
                  borderColor: const Color(0xFFC95656),
                  width: 160,
                  height: 42,
                  onPressed: () async {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
