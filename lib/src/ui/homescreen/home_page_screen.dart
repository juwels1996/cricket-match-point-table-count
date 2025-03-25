import 'package:cricket_scorecard/src/ui/matches_screen/matches_screen_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../home_drawer/home_drawer_screen.dart';
import '../over-stat/overall_stats_screen.dart';
import '../point_table/point_table_screen.dart';
import '../team_screen/all_team_player_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/highlight_card.dart';
import 'componenets/video_list_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List videos = [];
  late YoutubePlayerController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // fetchVideos(); // Fetch the YouTube videos when the page loads
  }

  // Fetch YouTube video data from the backend
  Future<void> fetchVideos() async {
    final response = await http
        .get(Uri.parse("http://64.227.150.216:8454/api/youtube_videos/"));
    if (response.statusCode == 200) {
      setState(() {
        videos = jsonDecode(response.body);
        print("video list check $videos");
      });
      // Initialize the YouTube player with the first video
      if (videos.isNotEmpty) {
        _initializePlayer(videos[0]['video_link']);
      }
    }
  }

  // Initialize the YouTube Player with the first video URL
  void _initializePlayer(String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: BuildDrawer(context: context),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: fetchVideos, // Trigger API call when pulled down
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildHeroBanner(), // Keep the Hero Banner as is// Use carousel for video thumbnails
                _buildQuickLinks(context),
                _buildMagicMomentsSection(),
                _buildSponsorBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Widget _buildMagicMomentsSection() {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoListScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text("View All"),
                ),
              ],
            ),
            Container(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _initializePlayer(videos[index]['video_link']),
                    child: HighlightCard(
                      title: videos[index]['title'],
                      imageUrl: videos[index]['thumbnail_url'],
                      date: videos[index]['created_at'],
                      views: videos[index]['video_link'],
                      duration: "05:14 mins",
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header Section - IPL Logo, Search, Poll, Choice
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      color: Colors.blue.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _openDrawer,
            icon: Icon(Icons.menu),
            color: Colors.white,
          ),
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

  // Hero Section with Video Player
  Widget _buildHeroBanner() {
    String youtubeUrl = videos.isNotEmpty
        ? videos[0]['video_link']
        : ""; // Grab the first video URL

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          "assets/sponsors/hero_banner.png", // Your image asset
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // YouTube Player to play the selected video
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.amber,
            ),
            SizedBox(height: 10),
            // Carousel Slider for Video Thumbnails
            // CarouselSlider(
            //   items: videos.map((video) {
            //     return GestureDetector(
            //       onTap: () {
            //         _initializePlayer(
            //             video['video_link']); // Play the selected video
            //         setState(() {});
            //       },
            //       child: Column(
            //         children: [
            //           Image.network(video['thumbnail_url'],
            //               width: 250, height: 115, fit: BoxFit.cover),
            //           SizedBox(height: 10),
            //           Text(
            //             video['title'],
            //             style: TextStyle(
            //                 color: Colors.white, fontWeight: FontWeight.bold),
            //             textAlign: TextAlign.center,
            //           ),
            //         ],
            //       ),
            //     );
            //   }).toList(),
            //   options: CarouselOptions(
            //     height: 180,
            //     autoPlay: true,
            //     enlargeCenterPage: true,
            //     viewportFraction: 0.8,
            //     aspectRatio: 2.0,
            //     initialPage: 0,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  // YouTube Video Carousel
  Widget _buildYouTubeVideoCarousel() {
    return CarouselSlider(
      items: videos.map((video) {
        return GestureDetector(
          onTap: () {
            _initializePlayer(video['video_link']); // Play selected video
            setState(() {});
          },
          child: Column(
            children: [
              Image.network(video['thumbnail_url'],
                  width: 300, height: 150, fit: BoxFit.cover),
              SizedBox(height: 10),
              Text(
                video['title'],
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
        aspectRatio: 2.0,
        initialPage: 0,
      ),
    );
  }

  // YouTube Video Carousel
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PointsTableScreen()));
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
          color: kIsWeb ? Colors.white : Colors.transparent, // Web Hover Effect
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

/// ✅ **Sponsor Banner**
Widget _buildSponsorBanner() {
  final List<String> sponsorLogos = [
    "assets/sponsors/ipl.jpg",
    "assets/sponsors/tata.jpeg",
    "assets/sponsors/ipl.jpg",
    "assets/sponsors/tata.jpeg",
  ];
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

/// Custom button widget for navigation
