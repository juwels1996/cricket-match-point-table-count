import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List matches = [];
  bool isLoading = true; // ✅ Add this line

  Future<void> fetchMatches() async {
    try {
      final response =
          await http.get(Uri.parse("https://backend.dplt10.org/api/matches/"));
      print("Response body: '${response.body}'");

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          setState(() {
            matches = [];
            isLoading = false;
          });
          return;
        }

        final decoded = jsonDecode(response.body);

        // If decoded is not a list, safely handle it
        if (decoded is List) {
          setState(() {
            matches = decoded;
            isLoading = false;
          });
        } else {
          setState(() {
            matches = [];
            isLoading = false;
          });
          print("Expected a list, got: $decoded");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Exception while fetching matches: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Matches")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : matches.isEmpty
              ? Center(
                  child: Text(
                    "There is no match played still now...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final team1Name = match['team1_name'] ?? 'Team 1';
                    final team2Name = match['team2_name'] ?? 'Team 2';
                    final date = match['date'] ?? 'Date not available';
                    final status = match['status'] ?? 'upcoming';
                    final winnerName = match['winner_name'] ?? 'N/A';
                    final result = match['result'] ?? 'No result';

                    if (status == 'upcoming') {
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            "$team1Name vs $team2Name",
                            textAlign: TextAlign.center,
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
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            "$team1Name vs $team2Name",
                            textAlign: TextAlign.center,
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
                              Text(
                                "Date: $date",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Container(); // Unknown status
                  },
                ),
    );
  }
}
