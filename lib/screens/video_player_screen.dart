import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoPlayerPage extends StatefulWidget {
  final String channelUrl;
  final String title;
  const VideoPlayerPage({super.key, required this.channelUrl, required this.title});

  @override
VideoPlayerPageState createState() => VideoPlayerPageState();
}

class VideoPlayerPageState extends State<VideoPlayerPage> {
  static const platform = MethodChannel('video_player_channel');

  Future<void> _playVideo(String videoUrl, String title) async {
    try {
      await platform.invokeMethod('playVideo', {
        'url': videoUrl,
        'title': title
      });
    } on PlatformException catch (e) {
      print("Failed to play video: '${e.message}'.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play video: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _playVideo(widget.channelUrl, widget.title);
          },
          child: const Text('Play Video'),
        ),
      ),
    );
  }
}