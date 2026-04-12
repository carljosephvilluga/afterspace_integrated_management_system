//Add User Widget
import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_text_field.dart';
import 'package:aims/widgets/common/custom_button.dart';

//Declares Adduser as a Stateful widget to access interactive elements
class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  String selectedType = "";
  String selectedMembership = "";

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
      selected: isSelected, //Highlights if chosen
      onSelected: (_) => onTap(), //Call the setState wh
      selectedColor: Colors.black, //Active chip
      backgroundColor: const Color(0xFFB9DCE2), //Default chip background
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ), //Text color changes when selected
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //background of page
      body: Center(
        child: Container(
          width: 900, //Form layout
          padding: EdgeInsets.all(35),
          decoration: BoxDecoration(
            color: const Color(0xFFD1EEF2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, //Column adjust to fit content
            children: [
              //Header
              const Text(
                "Add a New User",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text("Fill out the details to add a new user."),
              const SizedBox(height: 40), //Space

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Left Column
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
                              flex: 3,
                              child: CustomTextField(hint: "Last Name"),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 4,
                              child: CustomTextField(hint: "First Name"),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(hint: "M.I"),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Email",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(hint: "user@gmail.com"),
                        const SizedBox(height: 20),

                        const Text(
                          "Phone Number",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(hint: "09xxxxxxxxx"),
                      ],
                    ),
                  ),

                  const SizedBox(width: 60), //Space between the columns
                  //Right Column
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
                              onTap: () =>
                                  setState(() => selectedType = "Professional"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              //Membership
              const SizedBox(height: 40),
              const Text(
                "Membership",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10, //horizontal spacing
                runSpacing: 10, //vertical spacing
                alignment: WrapAlignment.center,
                children: [
                  _selectionChip(
                    "Annual",
                    isSelected: selectedMembership == "Annual",
                    onTap: () => setState(() => selectedMembership = "Annual"),
                  ),
                  _selectionChip(
                    "Loyalty Rewards",
                    isSelected: selectedMembership == "Loyalty Rewards",
                    onTap: () =>
                        setState(() => selectedMembership = "Loyalty Rewards"),
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

              const SizedBox(width: 20),

              //Apply the Custom Button
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
                      //Cancel logic insert lang here
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
                      //Save logic insert lang here
                      await Future.delayed(const Duration(seconds: 2));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("User information saved successfully!"),
                        ),
                      );
                    },
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
