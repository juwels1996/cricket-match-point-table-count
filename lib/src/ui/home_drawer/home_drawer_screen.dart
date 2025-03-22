import 'package:cricket_scorecard/src/ui/home_drawer/adviser_Screen.dart';
import 'package:flutter/material.dart';

import '../homescreen/componenets/video_list_screen.dart';
import '../matches_screen/matches_screen_page.dart';
import '../over-stat/overall_stats_screen.dart';
import '../point_table/point_table_screen.dart';
import '../team_screen/all_team_player_screen.dart';

class BuildDrawer extends StatelessWidget {
  const BuildDrawer({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue.shade900,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            child: Row(
              children: [
                Image.asset("assets/sponsors/ipl.jpg", height: 40),
                SizedBox(width: 10),
                Text(
                  "INDIAN PREMIER LEAGUE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MatchesScreen()));
              },
              child: Text(
                'Matches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // children: [
            //   ListTile(
            //       title: Text(
            //     'Upcoming Matches',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 14,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   )),
            //   ListTile(
            //       title: Text(
            //     'Completed Matches',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 14,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   )),
            // ],
          ),
          ExpansionTile(
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PointsTableScreen()));
              },
              child: Text(
                'Points Table',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // children: [
            //   ListTile(title: Text('Current Table')),
            //   ListTile(title: Text('Historical Data')),
            // ],
          ),

          ExpansionTile(
            title: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AdviserScreen()));
              },
              child: Text(
                'Governing Counsil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ExpansionTile(
            title: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VideoListScreen()));
              },
              child: Text(
                'Videos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // children: [
            //   ListTile(title: Text('All Videos')),
            //   ListTile(title: Text('Highlights')),
            // ],
          ),
          ExpansionTile(
            title: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TeamsScreen()));
              },
              child: Text(
                'Teams',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // children: [
            //   ListTile(title: Text('Team Details')),
            //   ListTile(title: Text('Team Stats')),
            // ],
          ),
          ExpansionTile(
            title: Text(
              'News',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            // children: [
            //   ListTile(title: Text('Latest News')),
            //   ListTile(title: Text('Archived News')),
            // ],
          ),
          // ExpansionTile(
          //   title: Text(
          //     'Fantasy',
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontSize: 14,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   // children: [
          //   //   ListTile(title: Text('Play Fantasy')),
          //   //   ListTile(title: Text('Fantasy Stats')),
          //   // ],
          // ),
          ExpansionTile(
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OverallStatsScreen()));
              },
              child: Text(
                'Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // children: [
            //   ListTile(title: Text('Player Stats')),
            //   ListTile(title: Text('Team Stats')),
            // ],
          ),
          // ExpansionTile(
          //   title: Text(
          //     'More',
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontSize: 14,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   children: [
          //     ListTile(
          //         title: Text(
          //       'Settings',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 14,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     )),
          //     ListTile(
          //         title: Text(
          //       'Help',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 14,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     )),
          //   ],
          // ),
        ],
      ),
    );
  }
}
