import 'dart:convert';
import 'dart:ui';
import 'package:cricket_scorecard/src/core/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PointsTableScreen extends StatefulWidget {
  @override
  _PointsTableScreenState createState() => _PointsTableScreenState();
}

class _PointsTableScreenState extends State<PointsTableScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> teams = [];
  bool isLoading = true;
  String? errorMsg;

  // sort state
  int sortIndex = 6; // default: Points column
  bool sortAsc = false;

  // animated bg
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
    fetchPointsTable();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchPointsTable() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final response =
          await http.get(Uri.parse('${Constants.baseUrl}points_table/'));
      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body) as List)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
        setState(() {
          teams = data;
          isLoading = false;
        });
        _applySort(sortIndex, sortAsc);
        print('Response body: ${response.body}');
        print('Decoded data: $data');
        print('Team count: ${data.length}');
      } else {
        setState(() {
          errorMsg = "Failed to load (${response.statusCode}).";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = "Network error. Please try again.";
        isLoading = false;
      });
    }
  }

  // animated gradient bg with blobs
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

  // sort helper
  void _applySort(int columnIndex, bool ascending) {
    setState(() {
      sortIndex = columnIndex;
      sortAsc = ascending;
      teams.sort((a, b) {
        num av, bv;
        switch (columnIndex) {
          case 1: // P (matches_played)
            av = (a['matches_played'] ?? 0) as num;
            bv = (b['matches_played'] ?? 0) as num;
            break;
          case 2: // W
            av = (a['wins'] ?? 0) as num;
            bv = (b['wins'] ?? 0) as num;
            break;
          case 3: // L
            av = (a['losses'] ?? 0) as num;
            bv = (b['losses'] ?? 0) as num;
            break;
          case 4: // T
            av = (a['ties'] ?? 0) as num;
            bv = (b['ties'] ?? 0) as num;
            break;
          case 5: // NRR
            av = (a['net_run_rate'] ?? 0.0) as num;
            bv = (b['net_run_rate'] ?? 0.0) as num;
            break;
          case 6: // Pts
          default:
            av = (a['points'] ?? 0) as num;
            bv = (b['points'] ?? 0) as num;
        }
        return ascending ? av.compareTo(bv) : bv.compareTo(av);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _animatedBackground(),
          SafeArea(
            child: Column(
              children: [
                // Frosted AppBar
                _FrostedAppBar(
                  title: "Points Table",
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: _Brand.accent,
                    onRefresh: fetchPointsTable,
                    child: errorMsg != null
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
                                      Text(
                                        errorMsg!,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: fetchPointsTable,
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
                        : (isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 80),
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                              )
                            : ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 24),
                                children: [
                                  GlassSection(
                                    padding: const EdgeInsets.all(16),
                                    child: isWide
                                        ? _buildWideTable()
                                        : _buildCompactList(),
                                  ),
                                ],
                              )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Wide screens: DataTable-like header + rows
  Widget _buildWideTable() {
    return Column(
      children: [
        // header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: Row(
            children: [
              const _HdrCell("Team", flex: 3),
              _SortableHdr(
                label: "P",
                onTap: () => _applySort(1, sortIndex == 1 ? !sortAsc : false),
                active: sortIndex == 1,
                asc: sortAsc,
              ),
              _SortableHdr(
                label: "W",
                onTap: () => _applySort(2, sortIndex == 2 ? !sortAsc : false),
                active: sortIndex == 2,
                asc: sortAsc,
              ),
              _SortableHdr(
                label: "L",
                onTap: () => _applySort(3, sortIndex == 3 ? !sortAsc : true),
                active: sortIndex == 3,
                asc: sortAsc,
              ),
              _SortableHdr(
                label: "T",
                onTap: () => _applySort(4, sortIndex == 4 ? !sortAsc : true),
                active: sortIndex == 4,
                asc: sortAsc,
              ),
              _SortableHdr(
                label: "NRR",
                onTap: () => _applySort(5, sortIndex == 5 ? !sortAsc : false),
                active: sortIndex == 5,
                asc: sortAsc,
                flex: 2,
              ),
              _SortableHdr(
                label: "Pts",
                onTap: () => _applySort(6, sortIndex == 6 ? !sortAsc : false),
                active: sortIndex == 6,
                asc: sortAsc,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.white24, height: 1),

        // rows
        ...List.generate(teams.length, (i) {
          final t = teams[i];
          final fullName = (t['name'] ?? '') as String;
          final short = teamNameMapping[fullName] ?? fullName;
          final nrr = ((t['net_run_rate'] ?? 0.0) as num).toDouble();

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                child: Row(
                  children: [
                    // team cell
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(t['logo'] ?? ''),
                            backgroundColor: Colors.white10,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              short,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatCell(t['matches_played']),
                    _StatCell(t['wins']),
                    _StatCell(t['losses']),
                    _StatCell(t['ties']),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 82,
                            height: 8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: _nrrToProgress(nrr),
                                backgroundColor: Colors.white12,
                                color:
                                    nrr >= 0 ? _Brand.accent : Colors.redAccent,
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            nrr.toStringAsFixed(2),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    _StatCell(t['points']),
                  ],
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.08), height: 1),
            ],
          );
        }),
      ],
    );
  }

  // Compact: list tiles
  Widget _buildCompactList() {
    return Column(
      children: List.generate(teams.length, (i) {
        final t = teams[i];
        final fullName = (t['name'] ?? '') as String;
        final short = teamNameMapping[fullName] ?? fullName;
        final nrr = ((t['net_run_rate'] ?? 0.0) as num).toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(t['logo'] ?? ''),
                backgroundColor: Colors.white10,
              ),
              title: Text(
                short,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Row(
                children: [
                  _pill("P ${t['matches_played'] ?? 0}"),
                  _pill("W ${t['wins'] ?? 0}"),
                  _pill("L ${t['losses'] ?? 0}"),
                  _pill("T ${t['ties'] ?? 0}"),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Pts ${t['points'] ?? 0}",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 120,
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _nrrToProgress(nrr),
                        backgroundColor: Colors.white12,
                        color: nrr >= 0 ? _Brand.accent : Colors.redAccent,
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  double _nrrToProgress(double nrr) {
    // map [-2.5, +2.5] => [0, 1]
    const min = -2.5, max = 2.5;
    final v = ((nrr - min) / (max - min)).clamp(0.0, 1.0);
    return v;
  }

  Widget _pill(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 6),
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

// ====== Frosted AppBar ======
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

// ====== UI helpers ======
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

class _StatCell extends StatelessWidget {
  const _StatCell(this.value, {this.flex = 1});
  final dynamic value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          '${value ?? 0}',
          style: const TextStyle(color: Colors.white),
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

class _SortableHdr extends StatelessWidget {
  const _SortableHdr({
    required this.label,
    required this.onTap,
    required this.active,
    required this.asc,
    this.flex = 1,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool asc;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                fontSize: 12,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 4),
              Icon(
                asc ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 18,
                color: Colors.white,
              ),
            ],
          ],
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
