import 'package:cricket_scorecard/src/ui/homescreen/componenets/video_list_screen.dart';
import 'package:cricket_scorecard/src/ui/matches_screen/matches_screen_page.dart';
import 'package:cricket_scorecard/src/ui/news/news_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/responsives_classes.dart';
import '../gallery_screen/gallery_screen.dart';
import '../home_drawer/home_drawer_screen.dart';
import '../over-stat/overall_stats_screen.dart';
import '../point_table/point_table_screen.dart';
import '../team_screen/all_team_player_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/highlight_card.dart';
import 'componenets/build_sponsor_widget.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List videos = [];
  late final player = Player();
  late final controller = VideoController(player);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVideos();
    MediaKit.ensureInitialized();
  }

  // Fetch YouTube video data from the backend
  Future<void> fetchVideos() async {
    final response = await http
        .get(Uri.parse("https://backend.dplt10.org/api/youtube_videos/"));
    if (response.statusCode == 200) {
      setState(() {
        videos = jsonDecode(response.body);
      });
      // Initialize the YouTube player with the first video
      if (videos.isNotEmpty) {
        _initializePlayer(videos[0]['video_link']);
      }
    } else {}
    setState(() {
      isLoading = false;
    });
  }

  void _initializePlayer(String videoUrl) async {
    await player.open(Media(videoUrl), play: false); // Don't auto play
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: BuildDrawer(context: context),
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      _buildHeroBanner(),
                      _buildQuickLinks(context),
                      _buildMagicMomentsSection(),
                      // EventRegistrationCards(),

                      Text(
                        "Official Broadcaster, Title Sponsor & Partner",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                          height: 400,
                          width: double.infinity,
                          color: Color(0xFF1E2A48),
                          child: Column(
                            children: [
                              SponsorScreen(),
                              Text(
                                "Contact With Us",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              Text(
                                "Phone: 01812-557248",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                "Email: dplcrickett10@gmail.com",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: 'FB Page: DPL - Deedar Premier League',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final Uri url = Uri.parse(
                                          'https://www.facebook.com/profile.php?id=61566986897071');
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url,
                                            mode:
                                                LaunchMode.externalApplication);
                                      }
                                    },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    "assets/sponsors/la.png",
                                    height: 70,
                                  ),
                                  Image.asset(
                                    "assets/sponsors/la.png",
                                    height: 70,
                                  )
                                ],
                              )
                            ],
                          )),

                      // Container(
                      //   color: Color(0xff213894),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Image.asset(
                      //         'assets/sponsors/la.png',
                      //         fit: BoxFit.cover,
                      //         height: 80,
                      //         width: 100,
                      //       ),
                      //       Image.asset(
                      //         'assets/sponsors/la.png',
                      //         fit: BoxFit.cover,
                      //         height: 80,
                      //         width: 100,
                      //       ),
                      //     ],
                      //   ),
                      // )
                      // TeamListScreen(),
                      // AboutUsInformation(),
                      // GuidelineWidget(),
                      // ContactUsWidget(),
                      // Center(
                      //   child: Text(
                      //     "App Version: 1.6.0",
                      //     style: TextStyle(
                      //       color: Colors.purple,
                      //       fontFamily: 'Roboto',
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      // Center(
                      //   child: Text(
                      //     "Developed and maintained by Juwel Sheikh❤️",
                      //     style: TextStyle(
                      //       color: Colors.black54,
                      //       fontFamily: 'Roboto',
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                    ]),
                  ),
                ],
              ),
      ),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Widget _buildMagicMomentsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Magic Moments",
              style: TextStyle(
                color: Colors.indigo.shade900,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return HighlightCard(
                  title: videos[index]['title'],
                  imageUrl: videos[index]['thumbnail_url'],
                  date: videos[index]['created_at'],
                  duration: "05:14 mins",
                  views: videos[index]['video_link'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Header Section - IPL Logo, Search, Poll, Choice
  Widget _buildHeader() {
    final isMobile = Responsive.isSmallScreen(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade900,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                IconButton(
                  onPressed: _openDrawer,
                  icon: Icon(Icons.menu, color: Colors.white),
                ),
                SizedBox(width: 12),
                Image.asset(
                  "assets/sponsors/dpl2.png",
                  height: 40,
                ),
                SizedBox(width: 8),
                Text(
                  "Deedar Premier League",
                  style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.white),
                ),
                Spacer(),
                if (!isMobile)
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MatchesScreen()));
                          },
                          child: _navItem("Matches")),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PointsTableScreen()));
                        },
                        child: _navItem("Point Table"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoListScreen()));
                        },
                        child: _navItem("Videos"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeamsScreen()));
                        },
                        child: _navItem("Teams"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MatchGalleryScreen()));
                        },
                        child: _navItem("Gallery"),
                      ),
                    ],
                  ),
              ],
            ),

            // Show menu below for mobile
            if (isMobile)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MatchesScreen()));
                        },
                        child: _navItem("Matches")),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PointsTableScreen()));
                      },
                      child: _navItem("Point Table"),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MatchGalleryScreen()));
                        },
                        child: _navItem("Gallery")),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoListScreen()));
                        },
                        child: _navItem("Videos")),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _navItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Hero Section with Video Player
  Widget _buildHeroBanner() {
    return Stack(
      children: [
        Image.asset(
          "assets/sponsors/background_cover.png",
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.6,
          fit: BoxFit.fill,
        ),
        Positioned(
          left: 16,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Learnings, ambitions and\nconquering dreams with\nDPL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "17 July, 2025 | 01.05min",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: Responsive.isSmallScreen(context)
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width,
                height: Responsive.isSmallScreen(context)
                    ? MediaQuery.of(context).size.width * 9.0 / 16.0
                    : MediaQuery.of(context).size.width * 9.0 / 26.0,
                child: GestureDetector(
                  onTap: () {
                    if (controller.player.state.playing) {
                      controller.player.pause();
                    } else {
                      controller.player.play();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Video(controller: controller),

                      // ✅ Use StreamBuilder to show/hide play icon
                      StreamBuilder<bool>(
                        stream: controller.player.stream.playing,
                        initialData: controller.player.state.playing,
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data ?? false;
                          if (!isPlaying) {
                            return Icon(
                              Icons.play_circle_fill,
                              color: Colors.white.withOpacity(0.7),
                              size: 64,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildHeroBanner() {
  //   String youtubeUrl = videos.isNotEmpty
  //       ? videos[0]['video_link']
  //       : ""; // Grab the first video URL
  //
  //   return Stack(
  //     alignment: Alignment.center,
  //     children: [
  //       Image.asset(
  //         "assets/sponsors/background_cover.png",
  //         width: double.infinity,
  //         height: MediaQuery.of(context).size.height * 0.6,
  //         fit: BoxFit.fill,
  //       ),
  //       Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           SizedBox(
  //             width: Responsive.isSmallScreen(context)
  //                 ? MediaQuery.of(context).size.width
  //                 : MediaQuery.of(context).size.width,
  //             height: Responsive.isSmallScreen(context)
  //                 ? MediaQuery.of(context).size.width * 9.0 / 16.0
  //                 : MediaQuery.of(context).size.width * 9.0 / 26.0,
  //             // Use [Video] widget to display video output.
  //             child: Video(controller: controller),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

// YouTube Video Carousel
  // Widget _buildYouTubeVideoCarousel() {
  //   return CarouselSlider(
  //     items: videos.map((video) {
  //       return GestureDetector(
  //         onTap: () {
  //           _initializePlayer(video['video_link']); // Play selected video
  //           setState(() {});
  //         },
  //         child: Column(
  //           children: [
  //             Image.network(video['thumbnail_url'],
  //                 width: 300, height: 150, fit: BoxFit.cover),
  //             SizedBox(height: 10),
  //             Text(
  //               video['title'],
  //               style:
  //                   TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //       );
  //     }).toList(),
  //     options: CarouselOptions(
  //       height: 180,
  //       autoPlay: true,
  //       enlargeCenterPage: true,
  //       viewportFraction: 0.8,
  //       aspectRatio: 2.0,
  //       initialPage: 0,
  //     ),
  //   );
  // }

// YouTube Video Carousel
}

/// ✅ **"What Are You Looking For?" Section**
Widget _buildQuickLinks(BuildContext context) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What are you Looking For?",
          style: TextStyle(
            color: Colors.indigo.shade900,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: Responsive.isLargeScreen(context) ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3,
          children: [
            _quickLinkButton("Fixtures", Icons.calendar_today, () {
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
Widget _quickLinkButton(String title, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.deepOrange),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
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
