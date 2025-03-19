import 'package:cricket_scorecard/src/ui/matches_screen/matches_screen_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../over-stat/overall_stats_screen.dart';
import '../player_screen/player_screen_page.dart';
import '../point_table/point_table_screen.dart';
import '../team_screen/all_team_player_screen.dart';

class HomePage extends StatelessWidget {
  final List<String> sponsorLogos = [
    "assets/sponsors/ipl.jpg",
    "assets/sponsors/tata.jpeg",
    "assets/sponsors/ipl.jpg",
    "assets/sponsors/tata.jpeg",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Dark theme background
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildHeroBanner(),
              _buildQuickLinks(context),
              _buildMagicMomentsSection(),
              _buildSponsorBanner(),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ **Header Section - IPL Logo, Search, Poll, Choice**
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.blue.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset("assets/sponsors/ipl.jpg", height: 40),
          Row(
            children: [
              _iconButton(Icons.bar_chart, "Fan Poll"),
              SizedBox(width: 10),
              _iconButton(Icons.emoji_events, "Viewers Choice"),
              SizedBox(width: 10),
              Icon(Icons.search, color: Colors.white, size: 30),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ **Hero Section with Video/Image**
  Widget _buildHeroBanner() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          "assets/sponsors/hero_banner.png", // Add your image asset
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "2024 Rewind Special: Harshal Patel's All Wickets",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.play_arrow, color: Colors.white),
              label: Text("Play", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ✅ **"What Are You Looking For?" Section**
  Widget _buildQuickLinks(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // White Background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅ **Title Header**
          Text(
            "What Are You Looking For?",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),

          /// ✅ **Grid Layout for Quick Links**
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3.5,
            children: [
              _quickLinkButton("Fixtures & Res..", Icons.calendar_today, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MatchesScreen()));
              }),
              _quickLinkButton("Points Table", Icons.bar_chart, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PointsTableScreen()));
              }),
              _quickLinkButton("Overall Stats", Icons.insights, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OverallStatsScreen()));
              }),
              _quickLinkButton("All Teams", Icons.people_alt, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TeamsScreen()));
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ **Quick Link Button with Hover & Click Effects**
  Widget _quickLinkButton(String title, IconData icon, Function onTap) {
    return MouseRegion(
      onEnter: (event) =>
          HapticFeedback.lightImpact(), // Vibration on hover (if supported)
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.blue.withOpacity(0.3), // Ripple Effect
        highlightColor: Colors.blue.withOpacity(0.1),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200), // Smooth hover effect
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(10),
            color:
                kIsWeb ? Colors.white : Colors.transparent, // Web Hover Effect
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black, size: 12),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ **Magic Moments Section (Carousel of Highlights)**
  Widget _buildMagicMomentsSection() {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ **Header Row with "See More" Button**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Magic Moments",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text("See More"),
                ),
              ],
            ),

            /// ✅ **Horizontal Scrollable List**
            Container(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _highlightCard(
                    "Abhishek Sharma's Most Sixes",
                    "assets/sponsors/magic.png",
                    "01 Jun, 2024",
                    "",
                    "05:14 mins",
                  ),
                  _highlightCard(
                    "Dhoni's Last Match Winning Six",
                    "assets/sponsors/magic.png",
                    "30 May, 2024",
                    "",
                    "04:45 mins",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ **Updated Card Style**
  Widget _highlightCard(String title, String imageUrl, String date,
      String views, String duration) {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅ **Image with Rounded Corners**
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              imageUrl,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ✅ **Title**
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),

                /// ✅ **Date, Views & Duration Row**
                Row(
                  children: [
                    Text(date,
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Spacer(),
                    Icon(Icons.visibility, color: Colors.white54, size: 12),
                    SizedBox(width: 5),
                    Text(views,
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                    SizedBox(width: 5),
                    Text(duration,
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 5),

                /// ✅ **Share Button**
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.share, color: Colors.white54, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **Sponsor Banner**
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
                  child: Image.asset(sponsorLogos[index], height: 40),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🏏 **Helper Widgets**
  Widget _iconButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 25),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  // Widget _quickLinkButton(String title, IconData icon, Function onTap) {
  //   return ElevatedButton(
  //     onPressed: () => onTap(),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.white.withOpacity(0.1),
  //       padding: EdgeInsets.symmetric(vertical: 10),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(icon, color: Colors.white, size: 20),
  //         SizedBox(width: 10),
  //         Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
  //       ],
  //     ),
  //   );
  // }
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
