import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_text_field.dart';
import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/utils/validators.dart';
import 'package:aims/screens/list_of_users/users_list.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
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
      selectedColor: Colors.black,
      backgroundColor: const Color(0xFFB9DCE2),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            width: 900,
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: const Color(0xFFD1EEF2),
              borderRadius: BorderRadius.circular(9),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  const Text(
                    "Add a New User",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text("Fill out the details to add a new user."),
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
                                  width: 80, //fixed width for MI
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
                                SizedBox(
                                  width: 80,
                                  child: CustomTextField(hint: ""),
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
                        textColor: Colors.black,
                        borderColor: Colors.black,
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
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        borderColor: Colors.black,
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
