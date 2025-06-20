import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String? icon;
  final VoidCallback onPressed;

  CustomButton({
    required this.text,
    required this.onPressed,
    this.icon, // Icon is optional
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff22264B), // Button background color
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        textStyle: TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.white, width: 1), // Border color and width

          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Image.asset(
              icon ?? 'assets/sponsors/dpl2.png',
              height: 15, // Icon height
              width: 15, // Icon width
            ),
            SizedBox(width: 8), // Space between icon and text
          ],
          Text(
            text,
            style: TextStyle(
              color: Colors.white, // Text color
              fontSize: 12, // Text size
              fontWeight: FontWeight.bold, // Text weight
            ),
          ),
        ],
      ),
    );
  }
}
