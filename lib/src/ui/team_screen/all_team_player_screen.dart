import 'dart:convert';
import 'package:cricket_scorecard/src/ui/team_screen/team_details_screen/team_details_Screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeamsScreen extends StatefulWidget {
  @override
  _TeamsScreenState createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  List teams = [];

  Future<void> fetchTeams() async {
    final response =
        await http.get(Uri.parse("https://backend.dplt10.org/api/teams/"));
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
      backgroundColor: Colors.black12, // Background similar to IPL theme
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("TEAMS",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: teams.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1, // Square shape
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
    final Map<String, Color> teamColors = {
      "Chennai Super Kings": Color(0xFFFFCC00), // Yellow
      "Mumbai Indians": Color(0xFF045093), // Blue
      "Royal Challengers Bengaluru": Color(0xFFDA1818), // Red
      "Delhi Capitals": Color(0xFF17449B), // Dark Blue
      "Kolkata Knight Riders": Color(0xFF3F2051), // Purple
      "Rajasthan Royals": Color(0xFFEA1A85), // Pink
      "Sunrisers Hyderabad": Color(0xFFFF822A), // Orange
      "Punjab Kings": Color(0xFFDA1818), // Red
      "Gujarat Titans": Color(0xFF19326A), // Navy Blue
      "Lucknow Super Giants": Color(0xFF004C99), // Royal Blue
    };

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        color: Colors.black, // Background color
        child: Column(
          children: [
            // 🔹 Top curved banner for team logo
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: teamColors[team['name']] ??
                    Colors.grey, // ✅ Manual color assignment
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(25)),
              ),
              child: Center(
                child: Image.network(
                  team['logo'],
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 🔹 Bottom Team Name
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                ),
                child: Center(
                  child: Text(
                    team['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
