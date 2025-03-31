import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String videoLink;
  VideoPlayerScreen({required this.videoLink});

  @override
  Widget build(BuildContext context) {
    final videoId = Uri.parse(videoLink)
        .queryParameters['v']; // Extract video ID from YouTube URL
    // final YoutubePlayerController _controller = YoutubePlayerController(
    //   initialVideoId: videoId!,
    //   flags: YoutubePlayerFlags(
    //     autoPlay: true,
    //     mute: false,
    //   ),
    // );

    return Scaffold(
        appBar: AppBar(title: Text("Playing Video")), body: Container());
  }
}
