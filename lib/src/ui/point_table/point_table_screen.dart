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
        .get(Uri.parse("http://192.168.0.106:8000/api/points_table/"));
    if (response.statusCode == 200) {
      print("Points table response--------: ${response.body}");
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
          : SingleChildScrollView(
              child: Card(
                color: Colors.grey[200],
                elevation: 5,
                margin: EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // Column header row
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
                            'P',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                          Expanded(
                              child: Text(
                            'W',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                          Expanded(
                              child: Text(
                            'L',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                          Expanded(
                              child: Text(
                            'T',
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
                            'P',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                        ],
                      ),
                      // List of Teams
                      Container(
                        height: getCardHeight(), // Dynamic height for the card
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: teams.length,
                          itemBuilder: (context, index) {
                            String teamName =
                                teams[index]['name'] ?? 'No team name';
                            String customTeamName =
                                teamNameMapping[teamName] ?? teamName;

                            return Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        NetworkImage(teams[index]['logo']),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      customTeamName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                        teams[index]['matches_played']
                                            .toString(),
                                        textAlign: TextAlign.center),
                                  ),
                                  Expanded(
                                    child: Text(teams[index]['wins'].toString(),
                                        textAlign: TextAlign.center),
                                  ),
                                  Expanded(
                                    child: Text(
                                        teams[index]['losses'].toString(),
                                        textAlign: TextAlign.center),
                                  ),
                                  Expanded(
                                    child: Text(teams[index]['ties'].toString(),
                                        textAlign: TextAlign.center),
                                  ),
                                  Expanded(
                                    child: Text(
                                      (teams[index]['net_run_rate'] ?? 0)
                                          .toString(), // Ensure it's converted to String
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                        teams[index]['points'].toString(),
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Function to dynamically calculate the height of the card based on the number of teams
  double getCardHeight() {
    // 50 is the space for the header and 10 for padding
    int itemCount = teams.length;
    double calculatedHeight = itemCount * 50.0 + 60.0;

    // Setting a max height for card
    double maxHeight = 900.0;
    return calculatedHeight < maxHeight ? calculatedHeight : maxHeight;
  }
}
