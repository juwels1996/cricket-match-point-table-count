import 'dart:convert';
import 'package:flutter/material.dart';
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
      Uri.parse("http://192.168.0.107:8000/api/teams/${widget.teamId}/"),
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
  }

  @override
  Widget build(BuildContext context) {
    if (teamData == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(teamData!['name'])),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Logo
            if (teamData!['logo'] != null && teamData!['logo'].isNotEmpty)
              Center(
                child: Image.network(
                  teamData!['logo'],
                  height: 100,
                ),
              ),
            SizedBox(height: 20),

            // Players Grid
            Text("Players",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildGrid(teamData!['players'], "No players available"),

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

  /// ✅ **Build Responsive Grid for Players, Coaches & Owners**
  Widget _buildGrid(List<dynamic>? list, String emptyMessage) {
    if (list == null || list.isEmpty) {
      return Center(
          child: Text(emptyMessage, style: TextStyle(color: Colors.grey)));
    }

    int crossAxisCount = Responsive.isLargeScreen(context) ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 2 on small, 4 on large screens
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 4, // Adjust for better layout
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildCard(list[index]);
      },
    );
  }

  /// ✅ **Build Individual Cards**
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
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            )
          else
            Icon(Icons.person, size: 60, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            item['name'],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          if (item.containsKey('role'))
            Text(
              item['role'],
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
