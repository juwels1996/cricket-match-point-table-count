import 'dart:convert';
import 'dart:ui'; // 👈 for BackdropFilter blur
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cricket_scorecard/src/ui/homescreen/componenets/video_list_screen.dart';
import 'package:cricket_scorecard/src/ui/matches_screen/matches_screen_page.dart';
import 'package:cricket_scorecard/src/ui/news/news_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/responsives_classes.dart';
import '../event/event_screen.dart';
import '../gallery_screen/gallery_screen.dart';
import '../home_drawer/home_drawer_screen.dart';
import '../over-stat/highest_scrore_widget.dart';
import '../over-stat/overall_stats_screen.dart';
import '../over-stat/top_performer_preview.dart';
import '../point_table/point_table_preview.dart';
import '../point_table/point_table_screen.dart';
import '../team_screen/all_team_player_screen.dart';
import '../widgets/highlight_card.dart';
import 'componenets/build_sponsor_widget.dart';

// ====== Brand palette (tweak freely) ======
class _Brand {
  static const bgTop = Color(0xFF1B1F3B);
  static const bgBottom = Color(0xFF0F1222);
  static const primary = Color(0xFF635BFF);
  static const accent = Color(0xFF19C3FB);
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List videos = [];
  late final player = Player();
  late final controller = VideoController(player);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> imagesList = [
    'assets/sponsors/dpl2.png',
    'assets/sponsors/dpl2.png',
    'assets/sponsors/dpl2.png',
  ];

  bool isLoading = true;

  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    fetchVideos();
    MediaKit.ensureInitialized();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    player.dispose();
    super.dispose();
  }

  // Fetch YouTube video data from the backend
  Future<void> fetchVideos() async {
    final response = await http
        .get(Uri.parse("https://backend.dplt10.org/api/youtube_videos/"));
    if (response.statusCode == 200) {
      setState(() {
        videos = jsonDecode(response.body);
      });
      if (videos.isNotEmpty) {
        _initializePlayer(videos[0]['video_link']);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void _initializePlayer(String videoUrl) async {
    await player.open(Media(videoUrl), play: false); // Don't auto play
  }

  // ====== Animated gradient + blobs background ======
  Widget _animatedBackground() {
    return AnimatedBuilder(
      animation: _bgCtrl,
      builder: (_, __) {
        final t = _bgCtrl.value;
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1, -1),
                  end: Alignment(1, 1),
                  colors: [_Brand.bgTop, _Brand.bgBottom],
                ),
              ),
            ),
            Positioned(
              left: -140 + 40 * t,
              top: -120 + 30 * (1 - t),
              child: _blob(280, _Brand.primary.withOpacity(0.28)),
            ),
            Positioned(
              right: -110 + 30 * (1 - t),
              bottom: -140 + 40 * t,
              child: _blob(340, _Brand.accent.withOpacity(0.24)),
            ),
          ],
        );
      },
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(blurRadius: 64, spreadRadius: 12, color: color)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = EdgeInsets.symmetric(horizontal: width >= 1100 ? 28 : 16);
    final double carouselHeight =
        width >= 1100 ? 220 : (width >= 800 ? 200 : 160);

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: BuildDrawer(context: context),
        backgroundColor: Colors.black, // covered by gradient
        body: Stack(
          children: [
            _animatedBackground(),
            if (isLoading)
              const Center(
                  child: CircularProgressIndicator(color: Colors.white))
            else
              CustomScrollView(
                slivers: [
                  // ====== Frosted SliverAppBar ======
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: true,
                    leading: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: _openDrawer,
                    ),
                    title: const Text(
                      "Deedar Premier League",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    flexibleSpace: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(color: Colors.black.withOpacity(0.12)),
                      ),
                    ),
                  ),

                  // ====== Main Content (glass cards) ======
                  SliverPadding(
                    padding: padding.copyWith(top: 16, bottom: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Header
                        GlassSection(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: _buildHeader(),
                        ),
                        const SizedBox(height: 18),

                        // Hero banner
                        GlassSection(
                          padding: EdgeInsets.zero,
                          child: _buildHeroBanner(),
                        ),
                        const SizedBox(height: 18),

                        // Quick links
                        GlassSection(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionTitle("What are you Looking For?"),
                              // use your existing quick links inside
                              _buildQuickLinks(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Magic Moments
                        GlassSection(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionTitle("Magic Moments"),
                              _buildMagicMomentsSection(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        PointsTablePreview(),
                        const SizedBox(height: 18),
                        TopPerformerBanner(),
                        const SizedBox(height: 18),
                        HighestScroreWidget(),

                        // Event Going On + Carousel
                        GlassSection(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionTitle("Event Going on"),
                              const Divider(
                                  color: Colors.white24, thickness: 0.6),
                              const SizedBox(height: 8),
                              // Keep your CarouselSlider but with tighter wrapper
                              // CarouselSlider(
                              //   options: CarouselOptions(
                              //     animateToClosest: true,
                              //     autoPlayCurve: Curves.easeOutCirc,
                              //     height: carouselHeight,
                              //     autoPlay: true,
                              //     autoPlayAnimationDuration:
                              //         const Duration(milliseconds: 800),
                              //     autoPlayInterval: const Duration(seconds: 3),
                              //     enlargeCenterPage: true,
                              //     viewportFraction: 0.45,
                              //   ),
                              //   items: imagesList.map((item) {
                              //     return Builder(
                              //       builder: (BuildContext context) {
                              //         return ClipRRect(
                              //           borderRadius: BorderRadius.circular(14),
                              //           child: Stack(
                              //             fit: StackFit.expand,
                              //             children: [EventSection()],
                              //           ),
                              //         );
                              //       },
                              //     );
                              //   }).toList(),
                              // ),
                            ],
                          ),
                        ),
                        EventSection(),
                        const SizedBox(height: 18),

                        // Sponsors + Contact footer
                        GlassSection(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Official Broadcaster, Title Sponsor & Partner",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SponsorScreen(),
                              const SizedBox(height: 8),
                              const Text(
                                "Contact With Us",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Phone: 01812-557248",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white70),
                              ),
                              const Text(
                                "Email: dplcrickett10@gmail.com",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              const _FbLink(
                                label: "FB Page: DPL - Deedar Premier League",
                                url:
                                    'https://www.facebook.com/profile.php?id=61566986897071',
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(builder: (context, c) {
                                final logoSize =
                                    c.maxWidth >= 600 ? 84.0 : 64.0;
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset("assets/sponsors/la.png",
                                        height: logoSize),
                                    Image.asset("assets/sponsors/la.png",
                                        height: logoSize),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  // ====== Sections (your original content kept) ======

  Widget _buildMagicMomentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: SizedBox(
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
    );
  }

  // Header Section - logo + nav
  Widget _buildHeader() {
    final isMobile = Responsive.isSmallScreen(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.indigo.shade900],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              IconButton(
                onPressed: _openDrawer,
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Image.asset("assets/sponsors/dpl2.png", height: 40),
              const SizedBox(width: 8),
              const Text(
                "Deedar Premier League",
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (!isMobile)
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MatchesScreen()),
                          );
                        },
                        child: _navItem("Matches")),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PointsTableScreen()),
                        );
                      },
                      child: _navItem("Point Table"),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoListScreen()),
                        );
                      },
                      child: _navItem("Videos"),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TeamsScreen()),
                        );
                      },
                      child: _navItem("Teams"),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MatchGalleryScreen()),
                        );
                      },
                      child: _navItem("Gallery"),
                    ),
                  ],
                ),
            ],
          ),
          // Mobile nav below
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
                              builder: (context) => MatchesScreen()),
                        );
                      },
                      child: _navItem("Matches")),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PointsTableScreen()),
                      );
                    },
                    child: _navItem("Point Table"),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MatchGalleryScreen()),
                        );
                      },
                      child: _navItem("Gallery")),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoListScreen()),
                        );
                      },
                      child: _navItem("Videos")),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _navItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Hero Section with Video Player (kept, just overlay sits inside GlassSection now)
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
              const Text(
                "Learnings, ambitions and\nconquering dreams with\nDPL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "17 July, 2025 | 01.05min",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width,
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
                      // show play icon when paused
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
}

// ====== Quick links (your existing widget kept) ======
Widget _buildQuickLinks(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title provided by SectionTitle wrapper above
        const SizedBox(height: 4),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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

/// Quick Link Button
Widget _quickLinkButton(String title, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _Brand.accent),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

// ====== helpers: glass and titles ======
class GlassSection extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;
  final double radius;
  const GlassSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry margin;
  const SectionTitle(this.title,
      {super.key, this.margin = const EdgeInsets.only(bottom: 8)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _FbLink extends StatelessWidget {
  const _FbLink({required this.label, required this.url});
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.lightBlueAccent,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
      ),
    );
  }
}
