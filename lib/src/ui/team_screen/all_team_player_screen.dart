import 'dart:convert';
import 'package:cricket_scorecard/src/core/const.dart';
import 'package:cricket_scorecard/src/ui/team_screen/team_details_screen/team_details_Screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';

class TeamsScreen extends StatefulWidget {
  @override
  _TeamsScreenState createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _teams = [];
  bool isLoading = true;
  String? errorMsg;
  String search = '';

  // animated bg
  late final AnimationController _bgCtrl;

  // team color accents (fallbacks used if name not matched)
  static const Map<String, Color> _teamColors = {
    "Northan Falcons": Color(0xFFFFCC00), // Yellow
    "Kabir Chairman Warriors": Color(0xFF045093), // Blue
    "Ripon Cricket Stars": Color(0xFFDA1818), // Red
    "The Kingdon Of South": Color(0xFF17443D), // Teal-ish
    "Dr. Ali Legal Lions": Color(0xFF3F2051), // Purple
    "Doctor's Super Kings": Color(0xFFFF822A), // Orange
  };

  @override
  void initState() {
    super.initState();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    _fetchTeams();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchTeams() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final res = await http.get(Uri.parse("${Constants.baseUrl}teams/"));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          final list = decoded
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
          if (!mounted) return;
          setState(() {
            _teams = list;
            isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _teams = [];
            isLoading = false;
            errorMsg = "Unexpected response format.";
          });
        }
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

  List<Map<String, dynamic>> _filtered() {
    if (search.trim().isEmpty) return _teams;
    final q = search.toLowerCase();
    return _teams.where((t) {
      final n = (t['name'] ?? '').toString().toLowerCase();
      return n.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1100
        ? 4
        : width >= 800
            ? 3
            : 2;
    final teams = _filtered();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _animatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _FrostedAppBar(
                  title: "Teams",
                  onBack: () => Navigator.maybePop(context),
                ),

                // search
                GlassSection(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.16)),
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => search = v),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Search team...",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                              ),
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.white70),
                              suffixIcon: search.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white70),
                                      onPressed: () =>
                                          setState(() => search = ''),
                                    )
                                  : null,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // grid content
                Expanded(
                  child: RefreshIndicator(
                    color: _Brand.accent,
                    onRefresh: _fetchTeams,
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
                                  // const SizedBox(height: 120),
                                  Center(
                                    child: GlassSection(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 18),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.wifi_off,
                                              color: Colors.white70, size: 36),
                                          const SizedBox(height: 8),
                                          Text(
                                            errorMsg!,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: _fetchTeams,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _Brand.accent,
                                              foregroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text("Retry"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : (teams.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: const [
                                      SizedBox(height: 120),
                                      Center(
                                        child: GlassSection(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18, vertical: 16),
                                            child: Text(
                                              "No teams found.",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : GridView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 12, 16, 0),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: teams.length,
                                    itemBuilder: (_, i) => _TeamCard(
                                      team: teams[i],
                                      color: _teamColors[teams[i]['name']] ??
                                          Colors.blueGrey.shade700,
                                      // staggered entrance via anim duration
                                      animMs: 420 + (i % 8) * 30,
                                    ),
                                  ))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

// ================= Team Card =================

class _TeamCard extends StatefulWidget {
  const _TeamCard({
    required this.team,
    required this.color,
    required this.animMs,
  });

  final Map<String, dynamic> team;
  final Color color;
  final int animMs;

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final logo = (team['logo'] ?? '').toString();
    final name = (team['name'] ?? '').toString();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: Duration(milliseconds: widget.animMs),
      curve: Curves.easeOutCubic,
      builder: (_, scale, child) {
        return AnimatedScale(
          scale: _pressed ? scale * 0.98 : scale,
          duration: const Duration(milliseconds: 120),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          // Navigate to your team detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeamDetailScreen(teamId: team['id']),
            ),
          );
        },
        child: GlassSection(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // top banner with logo
              Container(
                height: 120, // nice fixed height for grid
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withOpacity(0.95),
                      widget.color.withOpacity(0.70),
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: logo.isNotEmpty
                        ? Image.network(
                            logo,
                            // height: 80,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.shield,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),

              // name area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Center(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
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

// ================= Helpers (glass, appbar, brand) =================

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
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
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
