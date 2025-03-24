import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PointsTableScreen extends StatefulWidget {
  @override
  _PointsTableScreenState createState() => _PointsTableScreenState();
}

class _PointsTableScreenState extends State<PointsTableScreen> {
  List teams = [];

  Future<void> fetchPointsTable() async {
    final response = await http
        .get(Uri.parse("http://64.227.150.216:8454/api/points_table/"));
    if (response.statusCode == 200) {
      setState(() {
        teams = jsonDecode(response.body);
      });
    }
  }

  Map<String, String> teamNameMapping = {
    'Chennai Super Kings': 'CSK',
    'Mumbai Indians': 'MI',
    'Royal Challengers Bengaluru': 'RCB',
    'Delhi Capitals': 'DC',
    'Kolkata Knight Riders': 'KKR',
    'Rajasthan Royals': 'RR',
    'Sunrisers Hyderabad': 'SRH',
    'Punjab Kings': 'PBKS',
  };

  @override
  void initState() {
    super.initState();
    fetchPointsTable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Points Table",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          )),
      body: teams.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                String teamName = teams[index]['name'] ?? 'No team name';
                // Replace full team name with the custom name from the map
                String customTeamName = teamNameMapping[teamName] ??
                    teamName; // Use the original name if no mapping exists

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column header row
                    if (index == 0)
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Team',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                          Expanded(
                              child: Text(
                            'Played',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                          Expanded(
                              child: Text(
                            'Wins',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                          Expanded(
                              child: Text(
                            'Losses',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                          Expanded(
                              child: Text(
                            'Ties',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                          Expanded(
                              child: Text(
                            'NRR',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                          Expanded(
                              child: Text(
                            'Points',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                        ],
                      ),
                    // Row for each team data
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, top: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              customTeamName,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child:
                                Text(teams[index]['matches_played'].toString()),
                          ),
                          Expanded(
                            child: Text(teams[index]['wins'].toString()),
                          ),
                          Expanded(
                            child: Text(teams[index]['losses'].toString()),
                          ),
                          Expanded(
                            child: Text(teams[index]['ties'].toString()),
                          ),
                          Expanded(
                            child: Text(teams[index]['net_run_rate']
                                .toStringAsFixed(2)),
                          ),
                          Expanded(
                            child: Text(teams[index]['points'].toString()),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
