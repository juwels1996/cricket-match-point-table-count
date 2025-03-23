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
        await http.get(Uri.parse("http://192.168.84.65:8000/api/matches/"));
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
                String matchDate = matches[index]['date'];
                String dateFormatted = _formatDate(matchDate);

                final match = matches[index];
                final team1Name = match['team1_name'] ?? 'Team 1';
                final team2Name = match['team2_name'] ?? 'Team 2';
                final date = match['date'] ?? 'Date not available';
                final status = match['status'] ?? 'upcoming';
                final winnerName = match['winner_name'] ?? 'N/A';
                final result = match['result'] ?? 'No result';

                // Display upcoming matches with schedule
                if (matches[index]['status'] == 'upcoming') {
                  // Upcoming Match: Show schedule only
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        "${matches[index]['team1_name']} vs ${matches[index]['team2_name']}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Date: $dateFormatted"),
                          Text(
                            "Time: ${matches[index]['time']}",
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 12),
                          ), // Use dynamic time if needed
                          Text(
                            "Stadium: ${matches[index]['stadium']}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (matches[index]['status'] == 'finished') {
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        "${matches[index]['team1_name']} vs ${matches[index]['team2_name']}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Winner: ${matches[index]['winner_name']}",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                          Text(
                            "Result: ${matches[index]['result']}",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 12),
                          ), // Displays "Won by X runs" or "Won by X wickets"
                          Text("Date: ${matches[index]['date']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }

                // Return an empty container if status is unknown
                return Container();
              },
            ),
    );
  }

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }
}
