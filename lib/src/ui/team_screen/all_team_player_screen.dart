import 'dart:convert';
import 'package:cricket_scorecard/src/ui/team_screen/team_details_screen/team_details_Screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/responsives_classes.dart';

class TeamsScreen extends StatefulWidget {
  @override
  _TeamsScreenState createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  List teams = [];

  Future<void> fetchTeams() async {
    final response =
        await http.get(Uri.parse("http://192.168.0.105:8000/api/teams/"));
    if (response.statusCode == 200) {
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
    return Scaffold(
      appBar: AppBar(title: Text("Teams")),
      body: teams.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.isLargeScreen(context) ? 4 : 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  return TeamCard(team: teams[index]);
                },
              ),
            ),
    );
  }
}

class TeamCard extends StatelessWidget {
  final Map<String, dynamic> team;

  TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamDetailScreen(teamId: team['id']),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_cricket,
                size: 40, color: Colors.blue), // Placeholder for team logo
            SizedBox(height: 10),
            Text(
              textAlign: TextAlign.center,
              team['name'],
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
