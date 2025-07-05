import 'package:cricket_scorecard/src/ui/homescreen/componenets/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:convert';
import '../../widgets/highlight_card.dart';

class VideoListScreen extends StatefulWidget {
  VideoListScreen({Key? key}) : super(key: key);

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List videos = [];

  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    fetchVideos();
    MediaKit.ensureInitialized();
  }

// Fetch YouTube video data from the backend
  Future<void> fetchVideos() async {
    final response = await http
        .get(Uri.parse("https://backend.dplt10.org/api/youtube_videos/"));
    if (response.statusCode == 200) {
      setState(() {
        videos = jsonDecode(response.body);
        print("video list check $videos");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Magic Moments - All Videos")),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                          videoLink: videos[index]['video_link']),
                    ),
                  ),
              child: Column(
                children: [
                  HighlightCard1(
                    title: videos[index]['title'],
                    imageUrl: videos[index]['thumbnail_url'],
                    date: videos[index]['created_at'],
                    views: "",
                    duration: "",
                  ),
                  Divider(),
                ],
              ));
        },
      ),
    );
  }
}
