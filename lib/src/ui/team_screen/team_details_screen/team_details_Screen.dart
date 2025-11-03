import 'dart:convert';
import 'dart:ui';
import 'package:cricket_scorecard/src/core/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../utils/responsives_classes.dart';
import '../owner_details_Screen.dart';

class TeamDetailScreen extends StatefulWidget {
  final int teamId;
  const TeamDetailScreen({required this.teamId, super.key});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? teamData;
  bool isLoading = true;
  String? errorMsg;

  // bg anim
  late final AnimationController _bgCtrl;

  // simple accent by team name (fallback if not found)
  static const Map<String, Color> _teamColors = {
    "Northan Falcons": Color(0xFFFFCC00),
    "Kabir Chairman Warriors": Color(0xFF045093),
    "Ripon Cricket Stars": Color(0xFFDA1818),
    "The Kingdon Of South": Color(0xFF17443D),
    "Dr. Ali Legal Lions": Color(0xFF3F2051),
    "Doctor's Super Kings": Color(0xFFFF822A),
  };

  @override
  void initState() {
    super.initState();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    _fetchTeamDetails();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchTeamDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final res = await http.get(
        Uri.parse("${Constants.baseUrl}teams/${widget.teamId}/"),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          teamData = data;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMsg = "Server error: ${res.statusCode}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMsg = "Network error. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (teamData?['name'] ?? 'Team').toString();
    final logo = (teamData?['logo'] ?? '').toString();
    final accent = _teamColors[name] ?? _Brand.accent;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _animatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _FrostedAppBar(
                  title: name,
                  onBack: () => Navigator.maybePop(context),
                ),

                // Team header (logo + name)
                GlassSection(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              accent.withOpacity(0.9),
                              accent.withOpacity(0.5)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: ClipOval(
                          child: logo.isNotEmpty
                              ? Image.network(logo, fit: BoxFit.cover)
                              : const Icon(Icons.shield,
                                  color: Colors.white, size: 36),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // content
                Expanded(
                  child: RefreshIndicator(
                    color: _Brand.accent,
                    onRefresh: _fetchTeamDetails,
                    child: isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          )
                        : (errorMsg != null
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 120),
                                  Center(
                                    child: GlassSection(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 16),
                                        child: Text(
                                          errorMsg!,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : _buildBody(context, accent)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, Color accent) {
    final players =
        (teamData?['players'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final local =
        players.where((p) => (p['category'] ?? '') == 'Local').toList();
    final semiLocal =
        players.where((p) => (p['category'] ?? '') == 'Semi-Local').toList();
    final overseas =
        players.where((p) => (p['category'] ?? '') == 'Overseas').toList();

    final coaches =
        (teamData?['coaches'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final owners =
        (teamData?['owners'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _CategorySection(
            title: "Local Players",
            accent: accent,
            child: _grid(local, accent)),
        _CategorySection(
            title: "Semi-Local Players",
            accent: accent,
            child: _grid(semiLocal, accent)),
        _CategorySection(
            title: "Overseas Players",
            accent: accent,
            child: _grid(overseas, accent)),
        _CategorySection(
            title: "Coaches", accent: accent, child: _grid(coaches, accent)),
        _CategorySection(
            title: "Owners",
            accent: accent,
            child: _grid(owners, accent, slideIn: true)),
      ],
    );
  }

  Widget _grid(List<Map<String, dynamic>> list, Color accent,
      {bool slideIn = false}) {
    if (list.isEmpty) {
      return const GlassSection(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text("No data available",
                style: TextStyle(color: Colors.white70)),
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount =
        Responsive.isLargeScreen(context) ? 5 : (width >= 800 ? 3 : 2);

    final grid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72, // taller IPL style
      ),
      itemBuilder: (_, i) => _IplCard(
        item: list[i],
        accent: accent,
        animMs: 380 + (i % 8) * 30,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OwnerDetailsScreen(owner: list[i]),
            ),
          );
        },
      ),
    );

    if (!slideIn) return grid;

    // subtle slide-in for owners like your original
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0, 0.06), end: Offset.zero),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (_, offset, child) => Transform.translate(
        offset: offset * 40.0,
        child: child,
      ),
      child: grid,
    );
  }

  // ===== background =====
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
}

// ================= IPL-style Card =================

class _IplCard extends StatelessWidget {
  const _IplCard({
    required this.item,
    required this.accent,
    required this.animMs,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final Color accent;
  final int animMs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final img = (item['image_url'] ?? '').toString();
    final name = (item['name'] ?? 'No Name').toString();
    final role = (item['role'] ?? '').toString();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1.0),
      duration: Duration(milliseconds: animMs),
      curve: Curves.easeOutCubic,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: GestureDetector(
        onTap: onTap,
        child: GlassSection(
          padding: EdgeInsets.zero,
          radius: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gradient header bar + badge chip (IPL vibe)
              Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              // Image pane with glossy overlay & corner ribbon
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: img.isNotEmpty
                          ? Image.network(
                              img,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/default_avatar.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset('assets/images/default_avatar.png',
                              fit: BoxFit.cover),
                    ),
                    // subtle gloss
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.08),
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // top-left ribbon for role
                    if (role.isNotEmpty)
                      Positioned(
                        top: 3,
                        left: -6,
                        child: _Ribbon(
                            text: role.toUpperCase(), accent: Colors.orange),
                      ),
                  ],
                ),
              ),

              // Name / role
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (role.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.text, required this.accent});
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.95),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 8,
          ),
        ),
      ),
    );
  }
}

// ================= Category Section =================

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.accent,
    required this.child,
  });

  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassSection(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 18,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 12),
      ],
    );
  }
}

// ================= Glass, AppBar, Brand =================

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
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
      ),
    );
  }
}

class _FrostedAppBar extends StatelessWidget {
  const _FrostedAppBar({required this.title, this.onBack});
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.12)),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand {
  static const bgTop = Color(0xFF1B1F3B);
  static const bgBottom = Color(0xFF0F1222);
  static const primary = Color(0xFF635BFF);
  static const accent = Color(0xFF19C3FB);
}
