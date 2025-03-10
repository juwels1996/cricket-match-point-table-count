import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List matches = [];

  Future<void> fetchMatches() async {
    final response =
        await http.get(Uri.parse("http://192.168.0.111:8000/api/matches/"));
    if (response.statusCode == 200) {
      setState(() {
        matches = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Matches")),
      body: matches.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                        "${matches[index]['team1_name']} vs ${matches[index]['team2_name']}"),
                    subtitle: Column(
                      children: [
                        Text("Winner Team: ${matches[index]['winner_name']}"),
                        Text("result: ${matches[index]['result']}"),
                        Text("Date: ${matches[index]['date']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
