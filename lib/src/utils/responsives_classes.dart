import 'package:flutter/material.dart';

class Responsive {
  // Define your breakpoint for large screens (e.g., 800 pixels)
  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800;
  static bool isMediumScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 800;
  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  // Returns carousel height based on screen size
  static double carouselHeight(BuildContext context) =>
      isLargeScreen(context) ? 450 : 250;

  // Returns carousel aspect ratio based on screen size
  static double carouselAspectRatio(BuildContext context) =>
      isLargeScreen(context) ? 16 / 9 : 4 / 3;

// Add more responsive logic or breakpoints as needed.
}
