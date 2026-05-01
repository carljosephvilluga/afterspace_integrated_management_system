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
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // center the row content
        children: [
          const Icon(Icons.delete_forever, color: Colors.redAccent, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Confirm Deletion',
              textAlign: TextAlign.center, // center the text itself
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Text(
          "Are you sure you want to delete "
          "${staff['firstName']} ${staff['lastName']} (${staff['id']})?\n\n"
          "This action cannot be undone.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              label: 'Cancel',
              backgroundColor: Colors.grey.shade200,
              textColor: Colors.black87,
              borderColor: Colors.grey.shade400,
              width: 120,
              height: 44,
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 20),
            CustomButton(
              label: 'Delete',
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              borderColor: Colors.redAccent,
              width: 120,
              height: 44,
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
