import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_button.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final Map<String, dynamic> staff;
  final VoidCallback onDelete;

  const ConfirmDeleteDialog({
    super.key,
    required this.staff,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_forever, color: Colors.redAccent, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Center(
              child: Text(
                'Confirm Deletion',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 400, 
        height: 120, 
        child: Center(
          child: Text(
            "Are you sure you want to delete\n${staff['firstName']} ${staff['lastName']} (${staff['id']})?\n\nThis action cannot be undone.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              label: 'Cancel',
              backgroundColor: Colors.grey.shade200,
              textColor: Colors.black87,
              borderColor: Colors.grey.shade400,
              width: 140,
              height: 50,
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 24),
            CustomButton(
              label: 'Delete',
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              borderColor: Colors.redAccent,
              width: 140,
              height: 50,
              onPressed: () async {
                onDelete();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
