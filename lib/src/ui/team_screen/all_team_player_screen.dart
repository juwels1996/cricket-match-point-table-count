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
        await http.get(Uri.parse("http://192.168.0.107:8000/api/teams/"));
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
        leading: Icon(
          Icons.arrow_back,
          color: Colors.white,
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
    Color _parseColor(String colorString) {
      try {
        if (colorString.startsWith("#")) {
          return Color(
              int.parse(colorString.replaceFirst("#", "#0000FF"), radix: 16));
        }
      } catch (e) {
        print("Error parsing color: $e");
      }
      return Colors.grey; // Default fallback color if error occurs
    }

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
        // Card background
        child: Column(
          children: [
            // 🔹 Top half with curved banner and team logo
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.yellow,

// Team color
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Center(
                child: Image.network(
                  team['logo'],
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 🔹 Bottom Half with Team Name
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(15)),
                ),
                child: Center(
                  child: Text(
                    team['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
