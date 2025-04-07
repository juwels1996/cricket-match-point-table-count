import 'package:cricket_scorecard/src/utils/responsives_classes.dart';
import 'package:flutter/material.dart';

class HoverButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  HoverButton({required this.title, required this.icon, required this.onTap});

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  Color _buttonColor = Colors.white; // Initial color
  Color _iconTextColor = Colors.black; // Initial text and icon color

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _buttonColor = Color(0xFFF26B38); // Change to orange when hovered
          _iconTextColor = Colors.white; // Change icon and text color to white
        });
      },
      onExit: (_) {
        setState(() {
          _buttonColor = Colors.white; // Revert to original color
          _iconTextColor = Colors.black; // Revert icon and text color to black
        });
      },
      child: InkWell(
        onTap: () => widget.onTap(),
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.blue.withOpacity(0.3),
        highlightColor: Colors.blue.withOpacity(0.1),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(10),
            color: _buttonColor, // Set dynamic color
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  color: _iconTextColor, // Set dynamic color for the icon
                  size: Responsive.isSmallScreen(context) ? 14 : 20),
              // SizedBox(height: 8),
              Text(
                widget.title,
                style: TextStyle(
                  color: _iconTextColor, // Set dynamic color for the text
                  fontSize: Responsive.isSmallScreen(context) ? 10 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
