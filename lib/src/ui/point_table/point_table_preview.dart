// lib/src/ui/home/widgets/points_table_preview.dart
import 'dart:convert';
import 'dart:ui';
import 'package:cricket_scorecard/src/core/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// adjust this import path if needed
import 'package:cricket_scorecard/src/ui/point_table/point_table_screen.dart';

class PointsTablePreview extends StatefulWidget {
  const PointsTablePreview({
    super.key,
    this.maxTeams = 5,
    this.title = 'Points Table',
  });

  final int maxTeams;
  final String title;

  @override
  State<PointsTablePreview> createState() => _PointsTablePreviewState();
}

class _PointsTablePreviewState extends State<PointsTablePreview> {
  // smaller fraction so cards don't look full-width
  // final PageController _pageCtrl = PageController(viewportFraction: 0.68);
  // int _page = 0;
  late PageController _pageCtrl;
  double _vf = 0.68;

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _teams = [];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: _vf);
    _fetch();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await http.get(Uri.parse('${Constants.baseUrl}points_table/'));
      if (r.statusCode == 200) {
        final raw = jsonDecode(r.body);
        if (raw is List) {
          final list = raw
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
          list.sort((a, b) {
            final pa = (a['points'] ?? 0) as num;
            final pb = (b['points'] ?? 0) as num;
            if (pb.compareTo(pa) != 0) return pb.compareTo(pa);
            final nrra = (a['net_run_rate'] ?? 0) as num;
            final nrrb = (b['net_run_rate'] ?? 0) as num;
            return nrrb.compareTo(nrra);
          });
          if (!mounted) return;
          setState(() {
            _teams = list.take(widget.maxTeams).toList();
            _loading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _error = 'Unexpected data format.';
          });
        }
      } else {
        if (!mounted) return;
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

  void _ensurePageControllerForWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // show ~3–4 cards on very wide, ~3 on desktop, ~1.4 on mobile
    final newVf = w >= 1200 ? 0.28 : (w >= 900 ? 0.34 : 0.68);

    if ((newVf - _vf).abs() > 0.001) {
      final currentPage =
          _pageCtrl.hasClients ? (_pageCtrl.page?.round() ?? 0) : 0;
      _pageCtrl.dispose();
      _vf = newVf;
      _pageCtrl = PageController(
        viewportFraction: _vf,
        initialPage: currentPage,
      );
      // no setState; next build uses new controller
    }
  }

  void _openFullTable() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => PointsTableScreen()));
  }

  @override
  Widget build(BuildContext context) {
    _ensurePageControllerForWidth(context);
    final isWide = MediaQuery.of(context).size.width >= 900;
    final cardHeight = isWide ? 300.0 : 260.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),

        // Content
        SizedBox(
          height: cardHeight,
          child: _loading
              ? const _PointsSkeleton()
              : (_error != null
                  ? _ErrorBox(message: _error!, onRetry: _fetch)
                  : Stack(
                      children: [
                        PageView.builder(
                          controller: _pageCtrl,
                          // onPageChanged: (i) => setState(() =>   = i),
                          itemCount: _teams.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _TeamPointsCard(
                              rank: i + 1,
                              team: _teams[i],
                              onTap: _openFullTable,
                            ),
                          ),
                        ),
                        if (_teams.length > 1 && isWide) ...[
                          _Arrow(
                            left: true,
                            onTap: () => _pageCtrl.previousPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOut,
                            ),
                          ),
                          _Arrow(
                            left: false,
                            onTap: () => _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOut,
                            ),
                          ),
                        ],
                      ],
                    )),
        ),

        const SizedBox(height: 8),

        // CTA
        Center(
          child: GestureDetector(
            onTap: _openFullTable,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: ShapeDecoration(
                color: const Color(0xFF1B49E3),
                shape: const _SlantedCapsule(),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Text(
                'Full Points Table',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- Card ----------------

class _TeamPointsCard extends StatelessWidget {
  const _TeamPointsCard({
    required this.rank,
    required this.team,
    required this.onTap,
  });

  final int rank;
  final Map<String, dynamic> team;
  final VoidCallback onTap;

  List<String> _recentForm(dynamic f) {
    if (f == null) return [];
    if (f is List) return f.map((e) => e.toString()).toList();
    if (f is String) {
      if (f.contains(',')) return f.split(',').map((e) => e.trim()).toList();
      return f.trim().isEmpty ? [] : [f.trim()];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final name = (team['name'] ?? '').toString().toUpperCase();
    final logo = (team['logo'] ?? '').toString();
    final points = (team['points'] ?? 0).toString();
    final played = (team['matches_played'] ?? 0).toString();
    final won = (team['wins'] ?? 0).toString();
    final nrr = ((team['net_run_rate'] ?? 0) as num).toStringAsFixed(3);
    final recent = _recentForm(team['recent_form']);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: _GlassCard(
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank + mini badge
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const SizedBox(width: 2),
                      Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                      Positioned(
                        left: -8,
                        top: -6,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFFAF1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF6EDC8F)),
                          ),
                          child: const Icon(Icons.check,
                              size: 12, color: Color(0xFF3DBE66)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Logo
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: logo.isNotEmpty
                      ? Image.network(logo, fit: BoxFit.cover)
                      : const Icon(Icons.sports_cricket,
                          size: 36, color: Colors.white),
                ),
              ),

              const SizedBox(height: 12),

              const Divider(height: 1, color: Colors.white24),
              const SizedBox(height: 12),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatCol(label: 'Points', value: points),
                  _StatCol(label: 'Played', value: played, dim: true),
                  _StatCol(label: 'Won', value: won, dim: true),
                  _StatCol(
                      label: 'NRR',
                      value: nrr,
                      valueColor: const Color(0xFF1FDE6A)),
                ],
              ),

              const SizedBox(height: 12),

              // Recent form
              if (recent.isNotEmpty) ...[
                const Text(
                  'Recent form',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children:
                      recent.take(6).map((r) => _FormChip(result: r)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({
    required this.label,
    required this.value,
    this.valueColor,
    this.dim = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: valueColor ?? Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: dim ? Colors.white60 : Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _FormChip extends StatelessWidget {
  const _FormChip({required this.result});
  final String result;

  @override
  Widget build(BuildContext context) {
    final r = result.toUpperCase();
    Color border;
    Color fill;
    Color text;

    if (r == 'W') {
      border = const Color(0xFF58C372);
      fill = const Color(0xFFEFFAF1);
      text = const Color(0xFF2A9A50);
    } else if (r == 'L') {
      border = const Color(0xFFE16A6A);
      fill = const Color(0xFFFDEEEE);
      text = const Color(0xFFB94E4E);
    } else {
      border = const Color(0xFF8AA0FF);
      fill = const Color(0xFFEEF1FF);
      text = const Color(0xFF5D70E0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        r,
        style: TextStyle(color: text, fontWeight: FontWeight.w800),
      ),
    );
  }
}

// ---------------- Arrows & helpers ----------------

class _Arrow extends StatelessWidget {
  const _Arrow({required this.left, required this.onTap});
  final bool left;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: left ? null : 6,
      left: left ? 6 : null,
      top: 0,
      bottom: 0,
      child: Center(
        child: Material(
          color: Colors.white.withOpacity(0.12),
          elevation: 0,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Icons.chevron_right, size: 22, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// error box in dark/glass
class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// frosted/glass card wrapper
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.radius = 20});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// CTA shape
class _SlantedCapsule extends ShapeBorder {
  const _SlantedCapsule();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(16),
      bottomLeft: const Radius.circular(16),
      topRight: const Radius.circular(22),
      bottomRight: const Radius.circular(22),
    );
    final path = Path()..addRRect(r);
    final notch = Path()
      ..moveTo(rect.right - 8, rect.top)
      ..lineTo(rect.right, rect.top + 8)
      ..lineTo(rect.right, rect.bottom - 8)
      ..lineTo(rect.right - 8, rect.bottom)
      ..close();
    path.addPath(notch, Offset.zero);
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final deflated = rect.deflate(1.0);
    return getOuterPath(deflated, textDirection: textDirection);
  }

  @override
  ShapeBorder scale(double t) => this;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}

// lightweight loading skeleton (dark/glass friendly)
class _PointsSkeleton extends StatelessWidget {
  const _PointsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width * 0.68).clamp(240.0, 340.0);

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: cardWidth),
          child: _GlassCard(
            radius: 20,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _shade(width: 36, height: 28, radius: 6),
                    const SizedBox(width: 8),
                    Expanded(child: _shade(height: 14, radius: 6)),
                  ]),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Colors.white24),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (_) => Column(
                        children: [
                          _shade(width: 36, height: 12, radius: 4),
                          const SizedBox(height: 6),
                          _shade(
                              width: 32, height: 10, radius: 4, opacity: 0.25),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _shade(width: 90, height: 12, radius: 4),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                        5, (_) => _shade(width: 28, height: 28, radius: 999)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _shade({
    double? width,
    required double height,
    double radius = 8,
    double opacity = 0.18,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
