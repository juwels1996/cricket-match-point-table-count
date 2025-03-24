import 'package:cricket_scorecard/src/ui/pdf/pdf_list_screen.dart';
import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("News")),
      body: Center(
        child: Column(
          children: [
            Text("News Screen"),
            Text("Coming Soon..."),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PDFListScreen()));
              },
              child: Text("Go forward"),
            ),
          ],
        ),
      ),
    );
  }
}
