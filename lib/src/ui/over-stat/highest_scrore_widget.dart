import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cricket_scorecard/src/ui/over-stat/overall_stats_screen.dart';

class HighestScroreWidget extends StatefulWidget {
  const HighestScroreWidget({super.key, this.title = 'Highest Score'});
  final String title;

  @override
  State<HighestScroreWidget> createState() => _HighestScroreWidgetState();
}

class _HighestScroreWidgetState extends State<HighestScroreWidget> {
  late PageController _pc;
  double _vf = 0.78;

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _leaders = [];

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: _vf);
    _fetch();
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _ensureVF(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    // let side players peek on large screens
    final newVf = w >= 1200 ? 0.32 : (w >= 900 ? 0.42 : 0.78);
    if ((newVf - _vf).abs() > 0.001) {
      final page = _pc.hasClients ? (_pc.page?.round() ?? 0) : 0;
      _pc.dispose();
      _vf = newVf;
      _pc = PageController(viewportFraction: _vf, initialPage: page);
      // no setState needed; next build uses updated controller
    }
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final r = await http
          .get(Uri.parse('https://backend.dplt10.org/api/overall_stats/'));
      if (r.statusCode == 200) {
        final raw = jsonDecode(r.body);
        if (raw is List) {
          final list = raw
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();

          // sort by Highest Score (HS). handles "141*", "89" etc.
          int hsVal(Map<String, dynamic> p) {
            final s = (p['runs'] ?? '').toString();
            final n = int.tryParse(RegExp(r'\d+').stringMatch(s) ?? '');
            return n ?? 0;
          }

          list.sort((a, b) => hsVal(b).compareTo(hsVal(a)));
          if (!mounted) return;
          setState(() {
            _leaders = list.take(7).toList(); // keep a few to swipe
            _loading = false;
          });
        } else {
          setState(() {
            _loading = false;
            _error = 'Unexpected response.';
          });
        }
      } else {
        setState(() {
          _loading = false;
          _error = 'Server error ${r.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Network error. Please try again.';
      });
    }
  }

  void _openLeaderboard() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => OverallStatsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    _ensureVF(context);
    final h = MediaQuery.of(context).size.height;
    final height = h.clamp(360.0, 520.0).toDouble();

    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, 1),
          colors: [Color(0xFF0E1630), Color(0xFF0B1024)],
        ),
      ),
      child: Stack(
        children: [
          // Title + See more
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Row(
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900)),
                const Spacer(),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.5)),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder()),
                  onPressed: _openLeaderboard,
                  child: const Text('See More'),
                ),
              ],
            ),
          ),

          // Content
          Positioned.fill(
            top: 64,
            child: _loading
                ? const _TopPerfSkeleton()
                : (_error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.redAccent),
                            const SizedBox(height: 8),
                            Text(_error!,
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            TextButton(
                                onPressed: _fetch, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : PageView.builder(
                        controller: _pc,
                        itemCount: _leaders.length,
                        itemBuilder: (ctx, i) {
                          return _PerformerSlide(
                            rank: i + 1,
                            data: _leaders[i],
                            onTap: _openLeaderboard,
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}

class _PerformerSlide extends StatelessWidget {
  const _PerformerSlide({
    required this.rank,
    required this.data,
    required this.onTap,
  });

  final int rank;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  int _hsVal(String s) {
    final n = int.tryParse(RegExp(r'\d+').stringMatch(s) ?? '');
    return n ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? '').toString();
    final img = (data['image_url'] ?? '').toString();
    final team = (data['team_name'] ?? '').toString();
    final matches = (data['matches'] ?? 0).toString();
    final hs = (data['runs'] ?? '0').toString();
    final highestScroe = (data['highest_score'] ?? '0').toString();
    final avg = (data['average'] ?? 0).toString();
    final fours = (data['fours'] ?? 0).toString();
    final sixes = (data['sixes'] ?? 0).toString();
    final fifties = (data['fifties'] ?? 0).toString();
    final hundreds = (data['hundreds'] ?? 0).toString();

    final hsNum = _hsVal(hs);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Side “ghosts” (subtle)
            Positioned(
              left: 0,
              child: _GhostPlayer(url: img),
            ),
            Positioned(
              right: 0,
              child: _GhostPlayer(url: img),
            ),

            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge "Highest score"
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: const Text('Highest Runs',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),

                // Rank + Name
                Text('#$rank $name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                    )),
                const SizedBox(height: 6),

                // HS big
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$highestScroe',
                        style: const TextStyle(
                          color: Color(0xFFE85A32),
                          fontWeight: FontWeight.w900,
                          fontSize: 44,
                        ),
                      ),
                      // const TextSpan(
                      //   text: '  HR',
                      //   style: TextStyle(color: Colors.white70, fontSize: 16),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Player image (center)
                SizedBox(
                  height: 160,
                  child: img.isNotEmpty
                      ? Image.network(img, fit: BoxFit.contain)
                      : const Icon(Icons.person,
                          size: 120, color: Colors.white30),
                ),
                const SizedBox(height: 8),

                // Glass stats row
                _Glass(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _StatItem(title: 'M', valueKey: 'matches'),
                        _StatItem(title: 'HS', valueKey: 'runs'),
                        _StatItem(title: 'Avg', valueKey: 'average'),
                        _StatPair(
                            title: '4/6\'s', keyA: 'fours', keyB: 'sixes'),
                        _StatPair(
                            title: '50/100\'s',
                            keyA: 'fifties',
                            keyB: 'hundreds'),
                      ],
                    ),
                  ),
                  data: data,
                ),
                const SizedBox(height: 16),

                // CTA
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE85A32),
                      shape: const StadiumBorder(),
                      shadows: [
                        BoxShadow(
                          color: const Color(0xFFE85A32).withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Text('Full Leaderboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostPlayer extends StatelessWidget {
  const _GhostPlayer({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.25,
      child: SizedBox(
        height: 120,
        width: 90,
        child: url.isNotEmpty
            ? Image.network(url, fit: BoxFit.contain)
            : const SizedBox.shrink(),
      ),
    );
  }
}

// ---- tiny stat widgets bound to map keys ----

class _StatItem extends StatelessWidget {
  const _StatItem({required this.title, required this.valueKey});
  final String title;
  final String valueKey;

  @override
  Widget build(BuildContext context) {
    return _Bound.builder((m) {
      final v = (m[valueKey] ?? '').toString();
      return _stat(title, v);
    });
  }

  Widget _stat(String t, String v) => Column(
        children: [
          Text(v,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(t, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );
}

class _StatPair extends StatelessWidget {
  const _StatPair(
      {required this.title, required this.keyA, required this.keyB});
  final String title;
  final String keyA;
  final String keyB;

  @override
  Widget build(BuildContext context) {
    return _Bound.builder((m) {
      final a = (m[keyA] ?? '0').toString();
      final b = (m[keyB] ?? '0').toString();
      return Column(
        children: [
          Text('$a/$b',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );
    });
  }
}

// binds child to the current slide's data via InheritedWidget-like pattern
class _Bound extends InheritedWidget {
  final Map<String, dynamic> data;
  const _Bound._(this.data, {required super.child});

  static Map<String, dynamic> of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<_Bound>();
    return w?.data ?? {};
  }

  @override
  bool updateShouldNotify(covariant _Bound oldWidget) => oldWidget.data != data;

  // convenience builder
  static Widget builder(Widget Function(Map<String, dynamic>) b) {
    return _BoundConsumer(builder: b);
  }
}

class _BoundConsumer extends StatelessWidget {
  const _BoundConsumer({required this.builder});
  final Widget Function(Map<String, dynamic>) builder;

  @override
  Widget build(BuildContext context) => builder(_Bound.of(context));
}

// glass container that supplies data map to descendants
class _Glass extends StatelessWidget {
  const _Glass({required this.child, required this.data});
  final Widget child;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return _Bound._(
      data,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              border: Border.all(color: Colors.white.withOpacity(0.20)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// skeleton while loading
class _TopPerfSkeleton extends StatelessWidget {
  const _TopPerfSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _skeletonBox(width: 280, height: 280),
    );
  }

  Widget _skeletonBox({required double width, required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          height: height,
          color: Colors.white.withOpacity(0.06),
        ),
      ),
    );
  }
}
