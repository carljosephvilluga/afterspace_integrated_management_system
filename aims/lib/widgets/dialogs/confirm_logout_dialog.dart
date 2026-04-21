import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_button.dart'; // import the reusable button

class ConfirmLogoutDialog extends StatelessWidget {
  const ConfirmLogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),

      content: SizedBox(
        width: 400,
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            const Text.rich(
              TextSpan(
                text: 'Are you sure you want to ',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: 'LOG OUT?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Colors.black, // optional highlight
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                // Cancel button using the reusable button
                CustomButton(
                  label: 'Cancel',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: Colors.black,
                  width: 175,
                  height: 50,
                  onPressed: () async {
                    Navigator.pop(context, false);
                  },
                ),

                // Logout button using the reusable button
                CustomButton(
                  label: 'Log out',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  width: 175,
                  height: 50,
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