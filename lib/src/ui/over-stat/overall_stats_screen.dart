import 'dart:convert';
import 'dart:ui';
import 'package:cricket_scorecard/src/core/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OverallStatsScreen extends StatefulWidget {
  @override
  _OverallStatsScreenState createState() => _OverallStatsScreenState();
}

class _OverallStatsScreenState extends State<OverallStatsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> players = [];
  bool isLoading = true;
  String? errorMsg;

  // ui state
  String search = '';
  int sortKey = 0; // 0=Runs,1=Avg,2=SR,3=100s,4=50s
  bool sortAsc = false; // default desc for runs

  // bg anim
  late final AnimationController _bgCtrl;

  Map<String, String> teamNameMapping = {
    'Chennai Super Kings': 'CSK',
    'Mumbai Indians': 'MI',
    'Royal Challengers Bengaluru': 'RCB',
    'Delhi Capitals': 'DC',
    'Kolkata Knight Riders': 'KKR',
    'Rajasthan Royals': 'RR',
    'Sunrisers Hyderabad': 'SRH',
    'Punjab Kings': 'PBKS',
  };

  @override
  void initState() {
    super.initState();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    fetchOverallStats();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchOverallStats() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final response =
          await http.get(Uri.parse("${Constants.baseUrl}overall_stats/"));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = (body as List)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
        if (!mounted) return;
        setState(() {
          players = data;
          isLoading = false;
        });
        _applySort(sortKey, sortAsc);
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMsg = "Failed to load (${response.statusCode}).";
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
      players.sort((a, b) {
        final av = _sortValue(a, key);
        final bv = _sortValue(b, key);
        return asc ? av.compareTo(bv) : bv.compareTo(av);
      });
    });
  }

  num _sortValue(Map<String, dynamic> p, int key) {
    num val(String k) {
      final v = p[k];
      if (v is num) return v;
      if (v is String) return num.tryParse(v) ?? 0;
      return 0;
    }

    switch (key) {
      case 1:
        return val('average'); // AVG
      case 2:
        return val('strike_rate'); // SR
      case 3:
        return val('hundreds'); // 100s
      case 4:
        return val('fifties'); // 50s
      case 0:
      default:
        return val('runs'); // Runs
    }
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> list) {
    if (search.trim().isEmpty) return list;
    final q = search.toLowerCase();
    return list.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final team = (p['team_name'] ?? '').toString().toLowerCase();
      return name.contains(q) || team.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final filtered = _filtered(players);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _animatedBackground(),
          Column(
            children: [
              _FrostedAppBar(
                title: "Overall Player Stats",
                onBack: () => Navigator.maybePop(context),
              ),

              // Search + Sort controls
              GlassSection(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  children: [
                    // Search
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
                                hintText: "Search player or team...",
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.55)),
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
                        // Asc/Desc toggle
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

                    // Sort chips
                    _SortChips(
                      current: sortKey,
                      onChanged: (i) =>
                          _applySort(i, i == sortKey ? !sortAsc : false),
                      labels: const ["Runs", "Avg", "SR", "100s", "50s"],
                      activeAsc: sortAsc,
                      activeIndex: sortKey,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: RefreshIndicator(
                  color: _Brand.accent,
                  onRefresh: fetchOverallStats,
                  child: isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 80),
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                        )
                      : (errorMsg != null
                          ? ListView(
                              // physics: const AlwaysScrollableScrollPhysics(),
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
                                          onPressed: fetchOverallStats,
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
                              ],
                            )
                          : (filtered.isEmpty
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
                                            "No players found.",
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
                              : (isWide
                                  ? _buildWideTable(
                                      filtered) // ✅ fixed: dual-axis scroll
                                  : _buildCompactCards(filtered)))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Wide mode: horizontal + vertical scroll (fixed) ----------
  Widget _buildWideTable(List<Map<String, dynamic>> list) {
    return Scrollbar(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // ✅ vertical scroll
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1100),
          child: GlassSection(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                  ),
                  child: Row(
                    children: const [
                      _HdrCell("POS", flex: 1),
                      _HdrCell("PLAYER", flex: 4),
                      _HdrCell("RUNS"),
                      _HdrCell("MAT"),
                      _HdrCell("INNS"),
                      _HdrCell("NO"),
                      _HdrCell("HS"),
                      _HdrCell("AVG"),
                      _HdrCell("BF"),
                      _HdrCell("SR"),
                      _HdrCell("100"),
                      _HdrCell("50"),
                      _HdrCell("4S"),
                      _HdrCell("6S"),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white24, height: 1),

                // Rows
                ...List.generate(list.length, (i) {
                  final p = list[i];
                  final pos = i + 1;
                  final name = (p["name"] ?? '').toString();
                  final image = (p["image_url"] ?? '').toString();
                  final teamFull = (p["team_name"] ?? '').toString();
                  final teamShort = teamNameMapping[teamFull] ?? teamFull;

                  String s(String k) => (p[k] ?? '').toString();
                  String nf(String k, {int frac = 2}) {
                    final v = p[k];
                    if (v is num) return v.toStringAsFixed(frac);
                    return (num.tryParse('$v') ?? 0).toStringAsFixed(frac);
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 6),
                        child: Row(
                          children: [
                            _CellText('$pos', flex: 1),
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: image.isNotEmpty
                                        ? NetworkImage(image)
                                        : null,
                                    backgroundColor: Colors.white10,
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 240,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          teamShort,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _CellText(s('runs')),
                            _CellText(s('matches')),
                            _CellText(s('innings')),
                            _CellText(s('not_outs')),
                            _CellText(s('highest_score')),
                            _CellText(nf('average')),
                            _CellText(s('balls_faced')),
                            _CellText(nf('strike_rate')),
                            _CellText(s('hundreds')),
                            _CellText(s('fifties')),
                            _CellText(s('fours')),
                            _CellText(s('sixes')),
                          ],
                        ),
                      ),
                      Divider(color: Colors.white.withOpacity(0.08), height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Compact mode: player stat cards ----------
  Widget _buildCompactCards(List<Map<String, dynamic>> list) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final p = list[i];
        final pos = i + 1;
        final name = (p["name"] ?? '').toString();
        final image = (p["image_url"] ?? '').toString();
        final teamFull = (p["team_name"] ?? '').toString();
        final teamShort = teamNameMapping[teamFull] ?? teamFull;

        String s(String k) => (p[k] ?? '0').toString();
        double d(String k) {
          final v = p[k];
          if (v is num) return v.toDouble();
          return (double.tryParse('$v') ?? 0);
        }

        return GlassSection(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header row
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        image.isNotEmpty ? NetworkImage(image) : null,
                    backgroundColor: Colors.white10,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$pos. $name",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        Text(teamShort,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  _Pill("Runs ${s('runs')}"),
                ],
              ),
              const SizedBox(height: 10),

              // pills
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Pill("Mat ${s('matches')}"),
                  _Pill("Inn ${s('innings')}"),
                  _Pill("NO ${s('not_outs')}"),
                  _Pill("HS ${s('highest_score')}"),
                  _Pill("Avg ${d('average').toStringAsFixed(2)}"),
                  _Pill("BF ${s('balls_faced')}"),
                  _Pill("SR ${d('strike_rate').toStringAsFixed(2)}"),
                  _Pill("100 ${s('hundreds')}"),
                  _Pill("50 ${s('fifties')}"),
                  _Pill("4s ${s('fours')}"),
                  _Pill("6s ${s('sixes')}"),
                ],
              ),
              const SizedBox(height: 10),

              // SR bar
              Row(
                children: [
                  const Text("Strike Rate",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (d('strike_rate') / 200)
                              .clamp(0, 1), // 0..200 scale
                          backgroundColor: Colors.white12,
                          color: _Brand.accent,
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- Background ----------
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

// ======= UI helpers =======

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

class _HdrCell extends StatelessWidget {
  const _HdrCell(this.label, {this.flex = 1});
  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  const _CellText(this.text, {this.flex = 1});
  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _SortChips extends StatelessWidget {
  const _SortChips({
    required this.current,
    required this.onChanged,
    required this.labels,
    required this.activeIndex,
    required this.activeAsc,
  });

  final int current;
  final void Function(int) onChanged;
  final List<String> labels;
  final int activeIndex;
  final bool activeAsc;

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

// brand palette
class _Brand {
  static const bgTop = Color(0xFF1B1F3B);
  static const bgBottom = Color(0xFF0F1222);
  static const primary = Color(0xFF635BFF);
  static const accent = Color(0xFF19C3FB);
}
