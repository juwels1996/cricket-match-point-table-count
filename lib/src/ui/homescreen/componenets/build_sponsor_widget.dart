import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/model/sponsor_model.dart';
// make sure the path is correct

class SponsorScreen extends StatefulWidget {
  @override
  _SponsorScreenState createState() => _SponsorScreenState();
}

class _SponsorScreenState extends State<SponsorScreen> {
  List<SponsorModel> sponsors = [];

  @override
  void initState() {
    super.initState();
    fetchSponsors();
  }

  Future<void> fetchSponsors() async {
    // try {
    final response =
        await http.get(Uri.parse("http://192.168.68.103:8000/api/sponsor/"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        sponsors = data.map((item) => SponsorModel.fromJson(item)).toList();
      });
    } else {
      print('Failed to load sponsors: ${response.statusCode}');
    }
    // } catch (e) {
    //   print('Error: $e');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF1E2A48),
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          SizedBox(height: 20),
          sponsors.isEmpty
              ? CircularProgressIndicator()
              : Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 10,
                  children: sponsors.map((sponsor) {
                    return SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              "http://192.168.68.103:8000${sponsor.image}",
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image, color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 5),
                          // Text(
                          //   sponsor.title,
                          //   style: TextStyle(color: Colors.white),
                          // ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
