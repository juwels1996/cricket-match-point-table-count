import 'package:cricket_scorecard/src/ui/homescreen/componenets/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/highlight_card.dart';

class VideoListScreen extends StatefulWidget {
  VideoListScreen({Key? key}) : super(key: key);

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List videos = [];

  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    fetchVideos(); // Fetch the YouTube videos when the page loads
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
      // Initialize the YouTube player with the first video
      if (videos.isNotEmpty) {
        _initializePlayer(videos[0]['video_link']);
      }
    }
  }

// Initialize the YouTube Player with the first video URL
  void _initializePlayer(String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Magic Moments - All Videos")),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VideoPlayerScreen(videoLink: videos[index]['video_link']),
              ),
            ),
            child: HighlightCard(
              title: videos[index]['title'],
              imageUrl: videos[index]['thumbnail_url'],
              date: videos[index]['created_at'],
              views: "",
              duration: "05:14 mins",
            ),
          );
        },
      ),
    );
  }
}
