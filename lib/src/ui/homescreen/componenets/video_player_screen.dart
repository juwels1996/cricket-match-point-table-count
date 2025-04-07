import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoLink;
  VideoPlayerScreen({required this.videoLink});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final player = Player();
  late final controller = VideoController(player);

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer(widget.videoLink);
  }

  // Initialize the player with the video URL
  void _initializePlayer(String videoUrl) {
    player.open(Media(videoUrl));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Playing Video")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                child: Video(controller: controller), // Display the video
              ),
            ),
    );
  }
}
