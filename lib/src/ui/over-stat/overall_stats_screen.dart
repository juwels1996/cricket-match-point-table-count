import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OverallStatsScreen extends StatefulWidget {
  @override
  _OverallStatsScreenState createState() => _OverallStatsScreenState();
}

class _OverallStatsScreenState extends State<OverallStatsScreen> {
  List players = [];
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

  Future<void> fetchOverallStats() async {
    final response = await http
        .get(Uri.parse("https://backend.dplt10.org/api/overall_stats/"));

    if (response.statusCode == 200) {
      setState(() {
        players = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOverallStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Overall Player Stats")),
        body: players.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: DataTable(
                      columnSpacing: 12,
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.black87),
                      dataRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.white),
                      columns: [
                        // Column 1: Position
                        DataColumn(
                            label: Text("POS",
                                style: TextStyle(color: Colors.white))),
                        // Column 2: PLAYER (Make it wider)
                        DataColumn(
                          label: Text("PLAYER",
                              style: TextStyle(color: Colors.white)),
                          numeric: false, // Ensures it's treated as non-numeric
                        ),
                        DataColumn(
                            label: Text("RUNS",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("MAT",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("INNS",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("NO",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("HS",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("AVG",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("BF",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("SR",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("100",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("50",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("4S",
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text("6S",
                                style: TextStyle(color: Colors.white))),
                      ],
                      rows: players.asMap().entries.map((entry) {
                        int index = entry.key + 1; // Position number
                        var player = entry.value;

                        String shortTeamName =
                            teamNameMapping[player["team_name"]] ??
                                player["team_name"];
                        return DataRow(
                          cells: [
                            DataCell(Text(
                              index.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )), // Position
                            // PLAYER: Increase width and make it flexible
                            DataCell(
                              Container(
                                width:
                                    245, // Make the width of the PLAYER column wider
                                child: Row(
                                  children: [
                                    Image.network(player["image_url"] ?? "",
                                        width: 40, height: 60), // Player Image
                                    SizedBox(width: 2),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player["name"],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          width:
                                              200, // Adjust width for team name
                                          child: Text(
                                            shortTeamName,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            DataCell(Text(player["runs"].toString())),
                            DataCell(Text(player["matches"].toString())),
                            DataCell(Text(player["innings"].toString())),
                            DataCell(Text(player["not_outs"].toString())),
                            DataCell(Text(player["highest_score"])),
                            DataCell(Text(player["average"].toString())),
                            DataCell(Text(player["balls_faced"].toString())),
                            DataCell(Text(player["strike_rate"].toString())),
                            DataCell(Text(player["hundreds"].toString())),
                            DataCell(Text(player["fifties"].toString())),
                            DataCell(Text(player["fours"].toString())),
                            DataCell(Text(player["sixes"].toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ));
  }
}
