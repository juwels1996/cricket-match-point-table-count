import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// keep your player screen
import 'package:cricket_scorecard/src/ui/homescreen/componenets/video_player_screen.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({Key? key}) : super(key: key);

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _videos = [];
  bool isLoading = true;
  String? errorMsg;

  // ui state
  String search = '';
  int sortKey = 0; // 0=Newest, 1=Oldest, 2=Title
  bool sortAsc = false;

  // animated bg
  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    _fetchVideos();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchVideos() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final res = await http
          .get(Uri.parse("https://backend.dplt10.org/api/youtube_videos/"));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          final list = decoded
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
          if (!mounted) return;
          setState(() {
            _videos = list;
            isLoading = false;
          });
          _applySort(sortKey, sortAsc);
        } else {
          if (!mounted) return;
          setState(() {
            _videos = [];
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

  void _applySort(int key, bool asc) {
    setState(() {
      sortKey = key;
      sortAsc = asc;
      int cmp(Map<String, dynamic> a, Map<String, dynamic> b) {
        int compareDate(String ka, String kb) {
          DateTime pa =
              DateTime.tryParse(a[ka]?.toString() ?? '') ?? DateTime(0);
          DateTime pb =
              DateTime.tryParse(b[kb]?.toString() ?? '') ?? DateTime(0);
          return pa.compareTo(pb);
        }

        switch (key) {
          case 1: // Oldest
            return compareDate('created_at', 'created_at');
          case 2: // Title
            final ta = (a['title'] ?? '').toString().toLowerCase();
            final tb = (b['title'] ?? '').toString().toLowerCase();
            return ta.compareTo(tb);
          case 0: // Newest
          default:
            // invert for newest by default
            return -compareDate('created_at', 'created_at');
        }
      }

      _videos.sort((a, b) => asc ? cmp(a, b) : cmp(a, b));
    });
  }

  List<Map<String, dynamic>> _filtered() {
    if (search.trim().isEmpty) return _videos;
    final q = search.toLowerCase();
    return _videos.where((v) {
      final t = (v['title'] ?? '').toString().toLowerCase();
      final d = (v['description'] ?? '').toString().toLowerCase();
      return t.contains(q) || d.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1100
        ? 4
        : width >= 800
            ? 3
            : 1;
    final vids = _filtered();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _animatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _FrostedAppBar(
                  title: "Magic Moments",
                  onBack: () => Navigator.maybePop(context),
                ),

                // Search + Sort
                GlassSection(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                    children: [
                      Row(
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
                                  hintText: "Search videos...",
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
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => _applySort(sortKey, !sortAsc),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.16)),
                              ),
                              child: Icon(
                                sortAsc
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _SortChips(
                        labels: const ["Newest", "Oldest", "Title"],
                        activeIndex: sortKey,
                        activeAsc: sortAsc,
                        onChanged: (i) =>
                            _applySort(i, i == sortKey ? !sortAsc : false),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: RefreshIndicator(
                    color: _Brand.accent,
                    onRefresh: _fetchVideos,
                    child: isLoading
                        ? _GridSkeleton(cols: crossAxisCount)
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
                                        child: Text(errorMsg!,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : (vids.isEmpty
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
                                              "No videos found.",
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
                                        16, 12, 16, 24),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.82,
                                    ),
                                    itemCount: vids.length,
                                    itemBuilder: (_, i) {
                                      final v = vids[i];
                                      final title =
                                          (v['title'] ?? '').toString();
                                      final thumb =
                                          (v['thumbnail_url'] ?? '').toString();
                                      final date =
                                          (v['created_at'] ?? '').toString();
                                      final duration = (v['duration'] ?? '')
                                          .toString(); // if backend has it
                                      final views = (v['views'] ?? '')
                                          .toString(); // optional

                                      final heroTag =
                                          "vid:${v['id'] ?? v['video_link'] ?? i}";
                                      return _VideoCard(
                                        title: title,
                                        imageUrl: thumb,
                                        dateStr: date,
                                        duration: duration,
                                        viewsStr: views,
                                        heroTag: heroTag,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => VideoPlayerScreen(
                                                videoLink: v['video_link'],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
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

  // animated background
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

// ================== Video Card (IPL-styled highlight card) ==================

class _VideoCard extends StatefulWidget {
  const _VideoCard({
    required this.title,
    required this.imageUrl,
    required this.dateStr,
    required this.onTap,
    required this.heroTag,
    this.duration,
    this.viewsStr,
  });

  final String title;
  final String imageUrl;
  final String dateStr;
  final String heroTag;
  final VoidCallback onTap;
  final String? duration;
  final String? viewsStr;

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _down = false;

  String _friendlyDate(String s) {
    final dt = DateTime.tryParse(s);
    if (dt == null) return s;
    // dd MMM yyyy
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}";
  }

  String? _durationOrNull(String? d) {
    if (d == null || d.trim().isEmpty) return null;
    return d;
  }

  String? _viewsPretty(String? v) {
    if (v == null || v.isEmpty) return null;
    final n = int.tryParse(v.replaceAll(RegExp(r'\D'), ''));
    if (n == null) return v;
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return "$n";
  }

  @override
  Widget build(BuildContext context) {
    final duration = _durationOrNull(widget.duration);
    final views = _viewsPretty(widget.viewsStr);

    return AnimatedScale(
      scale: _down ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: GlassSection(
          padding: EdgeInsets.zero,
          radius: 18,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // thumbnail (hero)
                Positioned.fill(
                  child: Hero(
                    tag: widget.heroTag,
                    child: widget.imageUrl.isNotEmpty
                        ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                        : Container(color: Colors.white10),
                  ),
                ),

                // glossy gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.35),
                          Colors.black.withOpacity(0.60),
                        ],
                      ),
                    ),
                  ),
                ),

                // big play button
                const Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Icon(Icons.play_circle_fill,
                          color: Colors.white70, size: 64),
                    ),
                  ),
                ),

                // duration pill (bottom right)
                if (duration != null)
                  Positioned(
                    right: 10,
                    bottom: 48,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.18)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timelapse,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(duration,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ),

                // title + meta
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.event,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _friendlyDate(widget.dateStr),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          if (views != null) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.visibility,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 6),
                            Text(views,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // thin top accent bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_Brand.accent, _Brand.primary],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================== UI helpers ==================

class _SortChips extends StatelessWidget {
  const _SortChips({
    required this.labels,
    required this.activeIndex,
    required this.activeAsc,
    required this.onChanged,
  });

  final List<String> labels;
  final int activeIndex;
  final bool activeAsc;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: List.generate(labels.length, (i) {
        final active = i == activeIndex;
        return InkWell(
          onTap: () => onChanged(i),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  active ? Colors.white.withOpacity(0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(active ? 0.5 : 0.22),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  labels[i],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (active) ...[
                  const SizedBox(width: 4),
                  Icon(
                    activeAsc ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: Colors.white,
                  ),
                ]
              ],
            ),
          ),
        );
      }),
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

class _Brand {
  static const bgTop = Color(0xFF1B1F3B);
  static const bgBottom = Color(0xFF0F1222);
  static const primary = Color(0xFF635BFF);
  static const accent = Color(0xFF19C3FB);
}

// ====== skeletons ======

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton({this.cols = 2});
  final int cols;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: cols * 4,
      itemBuilder: (_, __) => const _ShimmerBox(),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _a;
  @override
  void initState() {
    super.initState();
    _a = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) {
        return GlassSection(
          padding: EdgeInsets.zero,
          radius: 18,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + 2 * _a.value, -1),
                end: Alignment(1 + 2 * _a.value, 1),
                colors: [
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.06),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
