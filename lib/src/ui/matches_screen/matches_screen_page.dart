import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List matches = [];

  // Fetch matches data from the backend
  Future<void> fetchMatches() async {
    final response =
        await http.get(Uri.parse("http://192.168.0.66:8000/api/matches/"));
    if (response.statusCode == 200) {
      print("Matches response--------: ${response.body}");
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
        appBar: AppBar(centerTitle: true, title: Text("Matches")),
        body: matches.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  final team1Name = match['team1_name'] ??
                      'Team 1'; // Now using team1_name from the response
                  final team2Name = match['team2_name'] ??
                      'Team 2'; // Now using team2_name from the response

                  final date = match['date'] ?? 'Date not available';
                  final status = match['status'] ?? 'upcoming';
                  final winnerName = match['winner_name'] ?? 'N/A';
                  final result = match['result'] ?? 'No result';

                  if (status == 'upcoming') {
                    // Handle upcoming match display
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(
                          "$team1Name vs $team2Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Date: $date"),
                            Text(
                              "Time: ${match['time']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 12),
                            ),
                            Text(
                              "Stadium: ${match['stadium']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (status == 'finished') {
                    // Handle finished match display
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(
                          "$team1Name vs $team2Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Winner: $winnerName",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                            Text(
                              "Result: $result",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12),
                            ),
                            Text("Date: $date",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }

                  return Container(); // Return empty container if the status is unknown
                },
              ));
  }

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }
}
