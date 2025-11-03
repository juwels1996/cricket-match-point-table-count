import 'dart:convert';
import 'dart:ui';
import 'package:cricket_scorecard/src/core/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/configuration/config.dart';

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _all = [];
  bool isLoading = true;
  String? errorMsg;

  // bg anim
  late final AnimationController _bgCtrl;

  // tabs
  int _tabIndex = 0; // 0 = All, 1 = Upcoming, 2 = Finished

  @override
  void initState() {
    super.initState();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    fetchMatches();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchMatches() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final response =
          await http.get(Uri.parse("${Constants.baseUrl}matches/"));
      print(response.body);
      final raw = response.body;
      if (response.statusCode == 200) {
        if (raw.trim().isEmpty) {
          setState(() {
            _all = [];
            isLoading = false;
          });
          return;
        }
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final list = decoded
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
          // Optional: stable sort by date desc (finished first)
          list.sort((a, b) {
            final da = _parseDateTime(a['date'], a['time']);
            final db = _parseDateTime(b['date'], b['time']);
            return (db ?? DateTime(0)).compareTo(da ?? DateTime(0));
          });
          setState(() {
            _all = list;
            isLoading = false;
          });
        } else {
          setState(() {
            _all = [];
            isLoading = false;
            errorMsg = "Unexpected data received.";
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMsg = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = "Network error. Please try again.";
      });
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final list = _filtered();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _animatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _FrostedAppBar(
                  title: "Matches",
                  onBack: () => Navigator.pop(context),
                ),
                _SegmentedTabs(
                  index: _tabIndex,
                  onChanged: (i) => setState(() => _tabIndex = i),
                  labels: const ["All", "Upcoming", "Finished"],
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: _Brand.accent,
                    onRefresh: fetchMatches,
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 18),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.wifi_off,
                                              color: Colors.white70, size: 36),
                                          const SizedBox(height: 8),
                                          Text(errorMsg!,
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: fetchMatches,
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
                            : (list.isEmpty
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
                                              "There is no match played still now...",
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
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 12, 16, 24),
                                    itemCount: list.length,
                                    itemBuilder: (_, i) => _MatchCard(
                                      data: list[i],
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

  List<Map<String, dynamic>> _filtered() {
    if (_tabIndex == 1) {
      return _all
          .where((m) => (m['status'] ?? 'upcoming') == 'upcoming')
          .toList();
    } else if (_tabIndex == 2) {
      return _all
          .where((m) => (m['status'] ?? 'upcoming') == 'finished')
          .toList();
    }
    return _all;
  }

  // animated bg
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

  // date helpers
  DateTime? _parseDateTime(dynamic date, dynamic time) {
    if (date == null) return null;
    try {
      // Try combined first if backend ever sends "YYYY-MM-DD HH:mm"
      final combined = time != null ? "$date $time" : "$date";
      return DateTime.tryParse(combined) ?? DateTime.tryParse("$date");
    } catch (_) {
      return null;
    }
  }
}

// ============== Match Card (glass) ==============
class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] ?? 'upcoming') as String;
    final team1 = (data['team1_name'] ?? 'Team 1') as String;
    final team2 = (data['team2_name'] ?? 'Team 2') as String;
    final date = (data['date'] ?? 'Date not available').toString();
    final time = (data['time'] ?? '').toString();
    final stadium = (data['stadium'] ?? '—').toString();
    final winner = (data['winner_name'] ?? 'N/A').toString();
    final result = (data['result'] ?? 'No result').toString();

    return GlassSection(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row: status chip + date/time
          Row(
            children: [
              _StatusChip(status: status),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.event, size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.schedule, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(time,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ]
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // matchup row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _TeamBadge(name: team1, alignLeft: true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "vs",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(child: _TeamBadge(name: team2, alignLeft: false)),
            ],
          ),

          const SizedBox(height: 12),
          // stadium
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  stadium,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),

          // result/winner (finished only)
          if (status == 'finished') ...[
            const SizedBox(height: 8),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.emoji_events,
                    size: 16, color: Colors.amberAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Winner: $winner",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Result: $result",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.name, required this.alignLeft});
  final String name;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Text(
          name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = status == 'finished'
        ? Colors.greenAccent
        : (status == 'upcoming' ? _Brand.accent : Colors.orangeAccent);
    final label = status[0].toUpperCase() + status.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ============== Frosted AppBar & Glass helpers ==============

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
      margin: const EdgeInsets.symmetric(vertical: 8),
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

// brand palette
class _Brand {
  static const bgTop = Color(0xFF1B1F3B);
  static const bgBottom = Color(0xFF0F1222);
  static const primary = Color(0xFF635BFF);
  static const accent = Color(0xFF19C3FB);
}

// segmented control pills
class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.index,
    required this.onChanged,
    required this.labels,
  });
  final int index;
  final void Function(int) onChanged;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return GlassSection(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(labels.length, (i) {
          final active = i == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withOpacity(0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withOpacity(active ? 0.50 : 0.22),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
