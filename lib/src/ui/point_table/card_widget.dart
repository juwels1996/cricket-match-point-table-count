import 'package:flutter/material.dart';

class TeamTableView extends StatelessWidget {
  final List<Map<String, dynamic>> teams;
  final Map<String, String> teamNameMapping;

  TeamTableView({required this.teams, required this.teamNameMapping});

  @override
  Widget build(BuildContext context) {
    double getCardHeight() {
      // 50 is the space for the header and 10 for padding
      int itemCount = teams.length;
      double calculatedHeight = itemCount * 50.0 + 60.0;

      // Setting a max height for card
      double maxHeight = 900.0;
      return calculatedHeight < maxHeight ? calculatedHeight : maxHeight;
    }

    return Container(
      height: getCardHeight(), // Dynamic height for the card
      child: ListView(
        shrinkWrap: true,
        children: [
          Table(
            border: TableBorder.all(
                color: Colors.grey, width: 1), // Add border for the table
            columnWidths: {
              0: FixedColumnWidth(60), // Column for logos
              1: FixedColumnWidth(120), // Column for team names
              2: FixedColumnWidth(60), // Other columns with equal width
              3: FixedColumnWidth(60),
              4: FixedColumnWidth(60),
              5: FixedColumnWidth(60),
              6: FixedColumnWidth(60),
              7: FixedColumnWidth(60),
            },
            children: [
              // Table Header
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                ),
                children: [
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Logo",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Team Name",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Matches Played",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Wins",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Losses",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Ties",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("NRR",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Points",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                ],
              ),
              // Table Rows for each team
              for (int index = 0; index < teams.length; index++) ...[
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(teams[index]['logo']),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          teamNameMapping[teams[index]['name']] ??
                              teams[index]['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(teams[index]['matches_played'].toString(),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(teams[index]['wins'].toString(),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(teams[index]['losses'].toString(),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(teams[index]['ties'].toString(),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          (teams[index]['net_run_rate'] ?? 0).toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(teams[index]['points'].toString(),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
