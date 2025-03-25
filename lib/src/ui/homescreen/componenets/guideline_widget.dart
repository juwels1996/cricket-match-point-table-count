import 'package:flutter/material.dart';

import '../../news/news_screen.dart';

class GuidelineWidget extends StatelessWidget {
  const GuidelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Guidelines",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
                "Dpl Code of conduct for Match officials",
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
                "Governing Council",
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
