import 'dart:convert';
import 'package:cricket_scorecard/src/ui/team_screen/team_details_screen/team_details_Screen.dart';
import 'package:cricket_scorecard/src/utils/responsives_classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        title: Text("TEAMSrtfbyveht9uo8gyiit",
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
                  crossAxisCount: Responsive.isSmallScreen(context)
                      ? 2
                      : Responsive.isMediumScreen(context)
                          ? 3
                          : 4,
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
      "Northan Falcons": Color(0xFFFFCC00), // Yellow
      "Kabir Chairman Warriors": Color(0xFF045093), // Blue
      "Ripon Cricket Stars": Color(0xFFDA1818), // Red
      "The Kingdon Of South": Color(0xFF17443D), // Dark Blue
      "Dr. Ali Legal Lions": Color(0xFF3F2051), // Purple
      // Pink
      "Doctor's Super Kings": Color(0xFFFF822A), // Orange
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
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: BoxDecoration(
                color: teamColors[team['name']] ??
                    Colors.grey, // ✅ Manual color assignment
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(25)),
              ),
              child: Center(
                child: Image.network(
                  team['logo'],
                  height: 80.h,
                  fit: BoxFit.cover,
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
