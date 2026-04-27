import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_text_field.dart'; // reusable text field widget
import 'package:aims/widgets/common/custom_button.dart'; // reusable button widget
import 'package:aims/widgets/utils/validators.dart'; // for input validation

// Stateful widget for the Admin Login screen
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  // Controllers for text fields
  final TextEditingController staffIdController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    staffIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // removes header bar
      body: Container(
        // Background styling
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE4F4F7), // light background color
              Color(0xFF639FAA), // darker accent color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          image: DecorationImage(
            image: AssetImage("assets/images/login_bg.png"),
            fit: BoxFit.contain, // keeps proportions
            alignment: Alignment.center,
            scale: 0.8, // makes image slightly bigger
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // shrink column to fit content
            children: [
              // Title text
              const Text(
                "Staff",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 125), // spacing before the form card
              // Allows the avatar to overlap the form card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // The form card
                  Container(
                    width: 475,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4BBA9), // card background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 60,
                          ), // space for the avatar to overlap
                          // Staff ID field
                          CustomTextField(
                            hint: "Staff ID",
                            controller: staffIdController,
                            validator: Validators.requiredField,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 170),

                          // Sign In button
                          CustomButton(
                            label: "Sign In",
                            height: 80,
                            width: double.infinity,
                            backgroundColor: Colors.grey.shade800,
                            textColor: Colors.white,
                            borderColor: Colors.blue,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Simulate async login
                                await Future.delayed(
                                  const Duration(seconds: 1),
                                );
                                if (!context.mounted) return;
                                Navigator.pushNamed(
                                  context,
                                  '/staff-dashboard',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),

                  // Overlapping avatar icon
                  const Positioned(
                    top: -120, // moves avatar above card
                    left: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 90,
                      child: Icon(Icons.person, size: 120),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
