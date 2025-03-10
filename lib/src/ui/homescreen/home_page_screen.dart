import 'package:flutter/material.dart';
import '../player_screen/player_screen_page.dart';
import '../point_table/point_table_screen.dart';
import '../team_screen/all_team_player_screen.dart';
import 'package:cricket_scorecard/src/ui/matches_screen/matches_screen_page.dart';

class HomePage extends StatelessWidget {
  final List<String> sponsorLogos = [
    "assets/sponsors/ipl.jpg",
    "assets/sponsors/tata.jpeg",
    "assets/sponsors/ipl.jpg",
    "assets/sponsors/tata.jpeg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          title: Text('Cricket Draft Home')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomeButton(title: "Teams", route: TeamsScreen()),
                  HomeButton(title: "Players", route: PlayersScreen()),
                  HomeButton(title: "Matches", route: MatchesScreen()),
                  HomeButton(title: "Points Table", route: PointsTableScreen()),
                ],
              ),
            ),
          ),
          _buildSponsorBanner(),
        ],
      ),
    );
  }

  /// Sponsor banner with logos
  Widget _buildSponsorBanner() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.blueGrey.shade900,
      child: Column(
        children: [
          Text(
            "Official Sponsors",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sponsorLogos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Image.asset(
                    sponsorLogos[index],
                    height: 40,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom button widget for navigation
class HomeButton extends StatelessWidget {
  final String title;
  final Widget route;

  HomeButton({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => route));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          shadowColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          textStyle: TextStyle(fontSize: 18),
        ),
        child: Text(title),
      ),
    );
  }
}
