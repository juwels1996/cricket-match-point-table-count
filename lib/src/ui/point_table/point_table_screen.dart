import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PointsTableScreen extends StatefulWidget {
  @override
  _PointsTableScreenState createState() => _PointsTableScreenState();
}

class _PointsTableScreenState extends State<PointsTableScreen> {
  List teams = [];

  Future<void> fetchPointsTable() async {
    final response = await http
        .get(Uri.parse("http://192.168.0.111:8000/api/points_table/"));
    if (response.statusCode == 200) {
      setState(() {
        teams = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPointsTable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Points Table")),
      body: teams.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(teams[index]['name']),
                  subtitle: Text(
                      "Points: ${teams[index]['points']} | NRR: ${teams[index]['net_run_rate'].toStringAsFixed(3)}"),
                );
              },
            ),
    );
  }
}
