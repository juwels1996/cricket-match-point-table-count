import 'package:cricket_scorecard/src/ui/news/news_screen.dart';
import 'package:flutter/material.dart';

class AboutUsInformation extends StatelessWidget {
  const AboutUsInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About Us",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            GestureDetector(
              onTap: () {
                // Navigate to TeamDetailScreen when a team name is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFListScreen(),
                  ),
                );
              },
              child: Text(
                "Anti Corruption Code",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to TeamDetailScreen when a team name is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFListScreen(),
                  ),
                );
              },
              child: Text(
                "Code of conduct for player and teams officials",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
