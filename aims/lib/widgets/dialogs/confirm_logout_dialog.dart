import 'package:flutter/material.dart';

class ConfirmLogoutDialog extends StatelessWidget {
  const ConfirmLogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Logout'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // cancel
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true), // confirm
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}