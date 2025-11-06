import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cricket_scorecard/src/utils/responsives_classes.dart';
import '../../core/api-service/api_services.dart';
import '../../core/model/photo_gallery.dart';
import '../widgets/fullphotoview.dart';

class MatchGalleryScreen extends StatefulWidget {
  @override
  State<MatchGalleryScreen> createState() => _MatchGalleryScreenState();
}

class _MatchGalleryScreenState extends State<MatchGalleryScreen>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  late Future<List<MatchGallery>> _future;
  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _future = apiService.fetchMatchGallery();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = apiService.fetchMatchGallery();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = Responsive.isLargeScreen(context)
        ? 6
        : width >= 800
            ? 4
            : 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _animatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _FrostedAppBar(
                  title: "Match Photo Gallery",
                  onBack: () => Navigator.maybePop(context),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: _Brand.accent,
                    onRefresh: _refresh,
                    child: FutureBuilder<List<MatchGallery>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _GridSkeleton();
                        }
                        if (snapshot.hasError) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 120),
                              Center(
                                child: GlassSection(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Colors.white70,
                                            size: 36),
                                        const SizedBox(height: 8),
                                        Text("Error: ${snapshot.error}",
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: _refresh,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _Brand.accent,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                          child: const Text("Retry"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        final data = snapshot.data ?? [];
                        if (data.isEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: GlassSection(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 16),
                                    child: Text(
                                      "No data found.",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        // Group by date
                        final Map<String, List<MatchGallery>> grouped = {};
                        for (final g in data) {
                          grouped.putIfAbsent(g.date, () => []).add(g);
                        }
                        // Sort dates (desc)
                        final dates = grouped.keys.toList()
                          ..sort((a, b) {
                            final da = DateTime.tryParse(a) ?? DateTime(0);
                            final db = DateTime.tryParse(b) ?? DateTime(0);
                            return db.compareTo(da);
                          });

                        return GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: dates.length,
                          itemBuilder: (_, i) {
                            final date = dates[i];
                            final album = grouped[date]!;
                            final cover = album.first;
                            return _AlbumCard(
                              date: date,
                              count: album.length,
                              description: cover.description,
                              imageUrl: cover.photo,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MatchPhotoDetailScreen(
                                      galleryList: album,
                                      heroTag: "album:$date",
                                    ),
                                  ),
                                );
                              },
                              heroTag: "album:$date",
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // bg
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

// ====== Album Card (IPL style) ======
class _AlbumCard extends StatefulWidget {
  const _AlbumCard({
    required this.date,
    required this.count,
    required this.description,
    required this.imageUrl,
    required this.onTap,
    required this.heroTag,
  });

  final String date;
  final int count;
  final String description;
  final String imageUrl;
  final VoidCallback onTap;
  final String heroTag;

  @override
  State<_AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<_AlbumCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
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
                // cover image
                // Positioned.fill(
                //   child: Hero(
                //     tag: widget.heroTag,
                //     child: widget.imageUrl.isNotEmpty
                //         ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                //         : Container(color: Colors.white10),
                //   ),
                // ),
                // glossy gradient overlay bottom
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.35),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                // camera count pill
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.photo_camera_outlined,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text("${widget.count}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                // title + date
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            widget.date,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // thin top gradient bar (IPL accent)
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

// ====== Detail Screen ======
class MatchPhotoDetailScreen extends StatelessWidget {
  final List<MatchGallery> galleryList;
  final String? heroTag;
  const MatchPhotoDetailScreen(
      {required this.galleryList, this.heroTag, super.key});

  @override
  Widget build(BuildContext context) {
    final cover = galleryList.first;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // bg gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1, -1),
                end: Alignment(1, 1),
                colors: [_Brand.bgTop, _Brand.bgBottom],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _FrostedAppBar(
                  title: "Photos • ${cover.date}",
                  onBack: () => Navigator.maybePop(context),
                ),
                // hero banner
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                //   child: GlassSection(
                //     padding: EdgeInsets.zero,
                //     radius: 18,
                //     child: AspectRatio(
                //       aspectRatio: 16 / 9,
                //       child: Stack(
                //         fit: StackFit.expand,
                //         children: [
                //           if (heroTag != null)
                //             Hero(
                //               tag: heroTag!,
                //               child:
                //                   Image.network(cover.photo, fit: BoxFit.cover),
                //             )
                //           else
                //             Image.network(cover.photo, fit: BoxFit.cover),
                //           Positioned.fill(
                //             child: DecoratedBox(
                //               decoration: BoxDecoration(
                //                 gradient: LinearGradient(
                //                   begin: Alignment.topCenter,
                //                   end: Alignment.bottomCenter,
                //                   colors: [
                //                     Colors.transparent,
                //                     Colors.black.withOpacity(0.45)
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           ),
                //           Positioned(
                //             left: 12,
                //             right: 12,
                //             bottom: 12,
                //             child: Text(
                //               cover.description,
                //               maxLines: 2,
                //               overflow: TextOverflow.ellipsis,
                //               style: const TextStyle(
                //                 color: Colors.white,
                //                 fontWeight: FontWeight.w800,
                //                 fontSize: 16,
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // grid of photos
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.isLargeScreen(context) ? 5 : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: galleryList.length,
                    itemBuilder: (_, i) {
                      final g = galleryList[i];
                      return GlassSection(
                        padding: EdgeInsets.zero,
                        radius: 14,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullPhotoView(
                                        imageUrl: g.photo,
                                        heroTag: 'photo_${g.id}', // unique tag
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: 'photo_${g.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      g.photo,
                                      fit: BoxFit.cover,
                                      height: 150,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              ),

                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black26
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Text(
                              //   cover.description,
                              // )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====== Skeleton while loading ======
class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = Responsive.isLargeScreen(context)
        ? 6
        : width >= 800
            ? 4
            : 2;
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: cols * 3,
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

// ====== Frosted AppBar, Glass, Brand ======
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
