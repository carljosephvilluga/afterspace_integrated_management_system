//Reusable text field widget
import 'package:flutter/material.dart';

//Reusable text field widget
class CustomTextField extends StatelessWidget {
  final String hint; //Placeholder
  final double? width; //Optional width for layout flexibility
  final bool isPassword; //if true, hide it
  final TextEditingController? controller; //Read/Write Text

  const CustomTextField({
    super.key,
    required this.hint,
    this.width,
    this.isPassword = false, //default: not hidden
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
