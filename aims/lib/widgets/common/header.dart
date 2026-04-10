import 'package:flutter/material.dart';

enum UserRole { admin, manager, staff } //User roles

class Header extends StatelessWidget {
  final UserRole role; //User role
  final VoidCallback onMenuTap; //Function when menu tapped

  const Header({super.key, required this.role, required this.onMenuTap});

  //Convert enum role to text(that will display)
  String getRoleText() {
    switch (role) {
      case UserRole.admin:
        return "Admin";
      case UserRole.manager:
        return "Manager";
      case UserRole.staff:
        return "Staff";
    }
  }

  @override
  Widget build(BuildContext context) {
    //Container
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ), //Space inside
      color: const Color(0xFF76ACBD),

      //Row
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, //Spread the children in the row
        children: [
          //Left: Menu icon and Logout
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white), //Menu Icon
                onPressed: onMenuTap, //Run it when tapped
              ),
              const SizedBox(width: 7),
              const Icon(Icons.logout, color: Colors.white), //Logout Icon
              const SizedBox(width: 10),
              const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ), //Logout Text
            ],
          ),

          //Center
          const Text(
            "afterspace",
            style: TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),

          Row(
            children: [
              Text(
                getRoleText(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ), //User Role
              const SizedBox(width: 15),
              const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
