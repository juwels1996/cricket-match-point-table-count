import 'package:cricket_scorecard/src/utils/responsives_classes.dart';
import 'package:flutter/material.dart';

class SponsorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF1E2A48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          // Title Sponsors Section
          _buildSectionTitle("Official Broadcaster, Title Sponsor &  Partner"),
          _buildSponsorRow(context, [
            "assets/sponsors/sponsor_1.jpg",
            "assets/sponsors/sponsor_2.png",
            "assets/sponsors/sponsor_3.jpg",
          ]),
          SizedBox(height: 20),

          // Associate Partners Section
          _buildSectionTitle("Associate Partners"),
          _buildSponsorRow(context, [
            "assets/sponsors/sponsor_1.jpg",
            "assets/sponsors/sponsor_2.png",
            "assets/sponsors/sponsor_3.jpg",
          ]),
          SizedBox(height: 20),

          // Official Partners Section
          // _buildSectionTitle(
          //     "Official Umpire Partner & Official Strategic Timeout Partner"),
          // _buildSponsorRow([
          //   "assets/sponsors/ipl.jpg",
          //   "assets/sponsors/tata.jpeg",
          //   "assets/sponsors/ipl.jpg",
          // ]
          // ),
        ],
      ),
    );
  }

  // Function to create the title for each section
  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // Function to build the row of sponsors
  Widget _buildSponsorRow(BuildContext context, List<String> images) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: images.map((image) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Image.asset(
              image,
              height: Responsive.isSmallScreen(context) ? 70 : 120,
              width: Responsive.isSmallScreen(context)
                  ? 70
                  : 120, // Image size adjusted
            ),
          ),
        );
      }).toList(),
    );
  }
}
