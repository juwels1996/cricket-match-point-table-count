import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../../../utils/responsives_classes.dart';

class TeamDetailScreen extends StatefulWidget {
  final int teamId;

  TeamDetailScreen({required this.teamId});

  @override
  _TeamDetailScreenState createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  Map<String, dynamic>? teamData;

  Future<void> fetchTeamDetails() async {
    final response = await http.get(
      Uri.parse("https://backend.dplt10.org/api/teams/${widget.teamId}/"),
    );

    if (response.statusCode == 200) {
      setState(() {
        teamData = jsonDecode(response.body);

        print("team details-----${response.body}");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeamDetails();
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
                  height: 100.h,
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

            // Owners Grid
            Text("Owners",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildGrid(teamData!['owners'], "No owners available"),
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
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: Responsive.isLargeScreen(context)
            ? 1.5
            : 1.1, // Adjust aspect ratio based on screen size
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildCard(list[index]);
      },
    );
  }

  /// Build individual cards
  Widget _buildCard(Map<String, dynamic> item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item['image_url'] != null && item['image_url'].isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image_url'],
                height: 90.h,
                width: 70,
                fit: BoxFit.cover,
              ),
            )
          else
            Icon(Icons.person, size: 60.sp, color: Colors.grey),
          SizedBox(height: 5),
          Text(
            item['name'],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          if (item.containsKey('role'))
            Text(
              item['role'],
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
        ],
      ),
    );
  }
}
