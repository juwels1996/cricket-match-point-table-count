import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../team_screen/team_details_screen/team_details_Screen.dart';

class TeamListScreen extends StatefulWidget {
  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  List teams = [];

  Future<void> fetchTeams() async {
    final response =
        await http.get(Uri.parse("https://backend.dplt10.org/api/teams/"));
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        teams = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 50,
          color: Colors.black,
          child: Center(
            child: Text(
              "Teams",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
          ),
          height: 220,
          child: ListView.builder(
            itemCount: teams.length,
            shrinkWrap: false,
            controller: false
                ? ScrollController()
                : ScrollController(keepScrollOffset: false),
            itemBuilder: (context, index) {
              return Card(
                  color: Colors.black,
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to TeamDetailScreen when a team name is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamDetailScreen(
                                teamId: teams[index]['id'],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            teams[index]['name'],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ));
            },
          ),
        ),
      ],
    );
  }
}
