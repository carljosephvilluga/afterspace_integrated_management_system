import 'package:flutter/material.dart';

//Reusable Button
class CustomButton extends StatefulWidget {
  final String label; //Label text  of the button
  final Future<void> Function()?
  onPressed; //Aync function triggered when pressed
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double? width; //Optional
  final double? height; //Optional

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.borderColor = Colors.black,
    this.width, //Flexible
    this.height, //Flexible
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isLoading = false; //Tracks if the button is busy

  //Handles the button press
  Future<void> _handlePress() async {
    if (widget.onPressed == null) return; //Do nothing

    setState(() => _isLoading = true); //Show spinner

    await widget.onPressed!(); //Run the async task

    if (mounted) {
      setState(
        () => _isLoading = false,
      ); //Hide the spinner if widget still exist
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.textColor,
          side: BorderSide(color: widget.borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _isLoading ? null : _handlePress, //Disable if loading
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.textColor,
                ),
              )
            : Text(widget.label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
