import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../../../utils/responsives_classes.dart';
import '../owner_details_Screen.dart';

class TeamDetailScreen extends StatefulWidget {
  final int teamId;

  TeamDetailScreen({required this.teamId});

  @override
  _TeamDetailScreenState createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? teamData;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  Future<void> fetchTeamDetails() async {
    final response = await http.get(
      Uri.parse("https://backend.dplt10.org/api/teams/${widget.teamId}/"),
    );

    if (response.statusCode == 200) {
      setState(() {
        teamData = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeamDetails();

    // Set up the animation controller for slide-in animation
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.0), // Start position (below the screen)
      end: Offset(0.0, 0.0), // End position (center of the screen)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (teamData == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Separate players by category
    var localPlayers = teamData!['players']
        .where((player) => player['category'] == 'Local')
        .toList();
    var semiLocalPlayers = teamData!['players']
        .where((player) => player['category'] == 'Semi-Local')
        .toList();
    var overseasPlayers = teamData!['players']
        .where((player) => player['category'] == 'Overseas')
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(teamData!['name'])),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (teamData!['logo'] != null && teamData!['logo'].isNotEmpty)
              Center(
                child: Image.network(
                  teamData!['logo'],
                  height: 85.h,
                ),
              ),
            SizedBox(height: 20.h),

            _buildCategorySection("Local Players", localPlayers),
            _buildCategorySection("Semi-Local Players", semiLocalPlayers),
            _buildCategorySection("Overseas Players", overseasPlayers),

            SizedBox(height: 20),

            // Coaches Grid
            Text("Coaches",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildGrid(teamData!['coaches'], "No coaches available"),

            SizedBox(height: 20),

            // Owners Grid with animation
            Text("Owners",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SlideTransition(
              position: _slideAnimation,
              child: _buildGrid(teamData!['owners'], "No owners available"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String categoryName, List<dynamic> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(categoryName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        if (players.isEmpty)
          Center(
              child: Text("No $categoryName available",
                  style: TextStyle(color: Colors.grey))),
        _buildGrid(players, "No $categoryName available"),
      ],
    );
  }

  /// Build responsive grid for players, coaches, and owners
  Widget _buildGrid(List<dynamic>? list, String emptyMessage) {
    if (list == null || list.isEmpty) {
      return Center(
          child: Text(emptyMessage, style: TextStyle(color: Colors.grey)));
    }

    int crossAxisCount = Responsive.isLargeScreen(context) ? 5 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 2 on small, 4 on large screens
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Navigate to OwnerDetailsScreen and pass the selected owner data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OwnerDetailsScreen(
                  owner: list[index], // Pass the owner data
                ),
              ),
            );
          },
          child: _buildCard(list[index]),
        );
      },
    );
  }

  /// Build individual cards
  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      width: 120, // Fixed width to maintain consistent card size
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: Responsive.isLargeScreen(context)
                    ? 1.4
                    : 1.4, // Taller image ratio
                child: item['image_url'] != null && item['image_url'].isNotEmpty
                    ? Image.network(
                        item['image_url'],
                        fit: BoxFit.fill,
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/images/default_avatar.png'),
                      )
                    : Image.asset('assets/images/default_avatar.png'),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
              child: Column(
                children: [
                  Text(
                    item['name'] ?? 'No Name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    item['role'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
