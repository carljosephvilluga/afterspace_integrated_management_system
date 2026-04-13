import 'package:flutter/material.dart';
import 'package:aims/widgets/utils/validators.dart';

//Reusable text field
class CustomTextField extends StatelessWidget {
  final String hint; //Placeholder
  final double? width; //Optional width for layout flexibility
  final bool isPassword; //if true, hide it
  final TextEditingController? controller; //Read/Write Text
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hint,
    this.width,
    this.isPassword = false, //default: not hidden
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          //Error styling
          errorStyle: const TextStyle(fontSize: 11, height: 0.8),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.red, width: 0.5),
          ),
        ),
      ),
    );
  }
}
