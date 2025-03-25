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
          _buildSponsorRow([
            "assets/sponsors/1.png",
            "assets/sponsors/2.png",
            "assets/sponsors/3.png",
          ]),
          SizedBox(height: 20),

          // Associate Partners Section
          _buildSectionTitle("Associate Partners"),
          _buildSponsorRow([
            "assets/sponsors/ipl.jpg",
            "assets/sponsors/tata.jpeg",
            "assets/sponsors/ipl.jpg",
          ]),
          SizedBox(height: 20),

          // Official Partners Section
          _buildSectionTitle(
              "Official Umpire Partner & Official Strategic Timeout Partner"),
          _buildSponsorRow([
            "assets/sponsors/ipl.jpg",
            "assets/sponsors/tata.jpeg",
            "assets/sponsors/ipl.jpg",
          ]),
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
  Widget _buildSponsorRow(List<String> images) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: images.map((image) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Image.asset(image,
                height: 60, width: 60), // Image size adjusted
          ),
        );
      }).toList(),
    );
  }
}
