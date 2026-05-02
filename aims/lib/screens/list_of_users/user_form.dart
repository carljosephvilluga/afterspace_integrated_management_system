import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_text_field.dart';
import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/utils/validators.dart';
import 'package:aims/screens/list_of_users/users_list.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key, required this.userId});

  final String userId;

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _tanSoft = Color(0xFFEBD9CA);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);
  static const Color _cardWhite = Color(0xF7FFFFFF);

  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleInitialNameController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String selectedType = "";
  String selectedMembership = "";

  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleInitialNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Reusable chip widget
  Widget _selectionChip(
    String label, {
    required bool isSelected,
    required Function() onTap,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: _headerBlue,
      backgroundColor: _tanSoft.withValues(alpha: 0.75),
      side: BorderSide(
        color: isSelected ? _headerBlue : Colors.white.withValues(alpha: 0.8),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : _textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            width: 900,
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _panelBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: _headerBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Add a New User",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Fill out the details to add a new user.",
                    style: TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Name",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: CustomTextField(
                                    hint: "Last Name",
                                    validator:
                                        Validators.name, // fixed placement
                                    controller: lastNameController,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 4,
                                  child: CustomTextField(
                                    hint: "First Name",
                                    validator: Validators.name,
                                    controller: firstNameController,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 80,
                                  child: CustomTextField(
                                    hint: "M.I",
                                    validator: Validators.middleInitial,
                                    controller: middleInitialNameController,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            const Text(
                              "Email",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              hint: "user@gmail.com",
                              validator: Validators.emailUserForm,
                              controller: emailController,
                            ),

                            const SizedBox(height: 20),
                            const Text(
                              "Phone Number",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              hint: "09xxxxxxxxx",
                              validator: Validators.phoneNumber,
                              controller: phoneController,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 60),

                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "User ID",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 120,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.userId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    "This is an Auto-generated User ID No.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),
                            const Text(
                              "Type",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _selectionChip(
                                  "Student",
                                  isSelected: selectedType == "Student",
                                  onTap: () =>
                                      setState(() => selectedType = "Student"),
                                ),
                                const SizedBox(width: 20),
                                _selectionChip(
                                  "Professional",
                                  isSelected: selectedType == "Professional",
                                  onTap: () => setState(
                                    () => selectedType = "Professional",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  const Text(
                    "Membership",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _selectionChip(
                        "Annual",
                        isSelected: selectedMembership == "Annual",
                        onTap: () =>
                            setState(() => selectedMembership = "Annual"),
                      ),
                      _selectionChip(
                        "Loyalty Rewards",
                        isSelected: selectedMembership == "Loyalty Rewards",
                        onTap: () => setState(
                          () => selectedMembership = "Loyalty Rewards",
                        ),
                      ),
                      _selectionChip(
                        "Monthly Membership",
                        isSelected: selectedMembership == "Monthly Membership",
                        onTap: () => setState(
                          () => selectedMembership = "Monthly Membership",
                        ),
                      ),
                      _selectionChip(
                        "Open Time",
                        isSelected: selectedMembership == "Open Time",
                        onTap: () =>
                            setState(() => selectedMembership = "Open Time"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        label: "Cancel",
                        backgroundColor: Colors.white,
                        textColor: _textPrimary,
                        borderColor: const Color(0xFFB7C4CB),
                        width: 200,
                        height: 50,
                        onPressed: () async {
                          //Cancel logic insert here
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 20),
                      CustomButton(
                        label: "Save",
                        backgroundColor: _textPrimary,
                        textColor: Colors.white,
                        borderColor: _textPrimary,
                        width: 200,
                        height: 50,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (selectedType.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select a User Type"),
                                ),
                              );
                              return;
                            }
                            if (_formKey.currentState!.validate()) {
                              if (selectedMembership.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please select a Membership Type",
                                    ),
                                  ),
                                );
                                return;
                              }
                              final formData = UserFormData(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                phoneNumber: phoneController.text,
                                userType: selectedType,
                                membershipType: selectedMembership,
                                isActive: true,
                              );
                              Navigator.pop(context, formData);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
