import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlayersScreen extends StatefulWidget {
  @override
  _PlayersScreenState createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  List players = [];

  Future<void> fetchPlayers() async {
    final response =
        await http.get(Uri.parse("http://64.227.150.216:8454/api/players/"));
    if (response.statusCode == 200) {
      setState(() {
        players = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Players")),
      body: players.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(players[index]['name']),
                  subtitle: Text("Team: ${players[index]['team']}"),
                );
              },
            ),
    );
  }
}
