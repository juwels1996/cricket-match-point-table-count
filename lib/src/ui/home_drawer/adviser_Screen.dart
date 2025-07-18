import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../utils/responsives_classes.dart'; // Assuming this is where your Responsive class is

class AdviserScreen extends StatefulWidget {
  AdviserScreen({Key? key}) : super(key: key);

  @override
  State<AdviserScreen> createState() => _AdviserScreenState();
}

class _AdviserScreenState extends State<AdviserScreen> {
  List advisers = [];

  @override
  void initState() {
    super.initState();
    fetchAdvisers(); // Fetch advisers data when the screen loads
  }

  // Fetch advisers data from the API
  Future<void> fetchAdvisers() async {
    final response =
        await http.get(Uri.parse("https://backend.dplt10.org/api/advisers/"));
    if (response.statusCode == 200) {
      setState(() {
        advisers = jsonDecode(response.body);
      });
    } else {
      throw Exception("Failed to load advisers");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Advisers"),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getColumns(context), // Use responsive column count
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 0.4),
        itemCount: advisers.length,
        itemBuilder: (context, index) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(
                    advisers[index]['image_url']!,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.16,
                    width: MediaQuery.of(context).size.height * 0.2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        advisers[index]['name']!,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        advisers[index]['designation']!,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Function to get the number of columns based on the Responsive class
  int _getColumns(BuildContext context) {
    if (Responsive.isLargeScreen(context)) {
      return 5; // For large screens, 4 columns
    } else if (Responsive.isMediumScreen(context)) {
      return 3; // For medium screens, 3 columns
    } else {
      return 2; // For small screens, 2 columns
    }
  }
}
