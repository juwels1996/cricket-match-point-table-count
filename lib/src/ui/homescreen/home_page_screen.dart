import 'package:cricket_scorecard/src/ui/homescreen/componenets/about_us_widget.dart';
import 'package:cricket_scorecard/src/ui/homescreen/componenets/contact_us_widget.dart';
import 'package:cricket_scorecard/src/ui/homescreen/componenets/guideline_widget.dart';
import 'package:cricket_scorecard/src/ui/matches_screen/matches_screen_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../utils/responsives_classes.dart';
import '../home_drawer/home_drawer_screen.dart';
import '../over-stat/overall_stats_screen.dart';
import '../point_table/point_table_screen.dart';
import '../team_screen/all_team_player_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/button/hoverbutton.dart';
import '../widgets/highlight_card.dart';
import 'componenets/build_sponsor_widget.dart';
import 'componenets/team_list_widget.dart';
import 'componenets/video_list_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List videos = [];
  late YoutubePlayerController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVideos(); // Fetch the YouTube videos when the page loads
  }

  // Fetch YouTube video data from the backend
  Future<void> fetchVideos() async {
    final response = await http
        .get(Uri.parse("https://backend.dplt10.org/api/youtube_videos/"));
    if (response.statusCode == 200) {
      setState(() {
        videos = jsonDecode(response.body);
        print("video list check $videos");
      });
      // Initialize the YouTube player with the first video
      if (videos.isNotEmpty) {
        _initializePlayer(videos[0]['video_link']);
      }
    } else {
      print("video list check $videos");
    }
    setState(() {
      isLoading = false;
    });
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
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildHeroBanner(),
                      // Keep the Hero Banner as is// Use carousel for video thumbnails
                      _buildQuickLinks(context),
                      _buildMagicMomentsSection(),
                      SponsorScreen(),
                      TeamListScreen(),
                      AboutUsInformation(),
                      GuidelineWidget(),
                      ContactUsWidget(),

                      // _buildSponsorBanner(),
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
          // Row(
          //   children: [
          //     _iconButton(Icons.bar_chart, "Fan Poll"),
          //     SizedBox(width: 10),
          //     _iconButton(Icons.emoji_events, "Viewers Choice"),
          //     SizedBox(width: 10),
          //     Icon(Icons.search, color: Colors.white, size: 30),
          //   ],
          // ),
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
          width: MediaQuery.of(context).size.width * 0.5,
          "assets/sponsors/hero_banner.png", // Your image asset
          height: 160,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // YouTube Player to play the selected video
            YoutubePlayer(
              aspectRatio: 16 / 6,
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.amber,
            ),
            SizedBox(height: 10),
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
          crossAxisCount: Responsive.isLargeScreen(context)
              ? 4
              : 2, // Adjust column count based on screen size
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio:
              Responsive.isLargeScreen(context) ? 3.5 : 4, // Adjust item size
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
  return HoverButton(
    title: title,
    icon: icon,
    onTap: onTap,
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
