import 'package:flutter/material.dart';
import 'package:aims/widgets/utils/validators.dart';

//Reusable text field
class CustomTextField extends StatefulWidget {
  final String hint; //Placeholder
  final double? width; //Optional width for layout flexibility
  final bool isPassword; //if true, hide it
  final TextEditingController? controller; //Read/Write Text
  final String? Function(String?)? validator;
  final TextAlign textAlign; // Control Alignment
  final bool showToggle; // Show eye icon for password
  final Color fillColor; // background color override
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hint,
    this.width,
    this.isPassword = false, //default: not hidden
    this.controller,
    this.validator,
    this.textAlign = TextAlign.start, // default left align
    this.showToggle = false,          // default: no eye icon
    this.fillColor = Colors.white,    // default background
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscure,
        validator: widget.validator,
        textAlign: widget.textAlign,
        style: const TextStyle(fontSize: 18),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.fillColor,
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          //Error styling
          errorStyle: const TextStyle(fontSize: 11, height: 0.8),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 0.5),
          ),

          // Password visibility toggle only if requested
          suffixIcon: widget.isPassword && widget.showToggle
              ? IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
        ),
      ),
    );
  }
}
