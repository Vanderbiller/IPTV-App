import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoPlayerPage extends StatefulWidget {
  final String channelUrl;
  const VideoPlayerPage({super.key, required this.channelUrl});

  @override
VideoPlayerPageState createState() => VideoPlayerPageState();
}

class VideoPlayerPageState extends State<VideoPlayerPage> {
  static const platform = MethodChannel('video_player_channel');

  Future<void> _playVideo(String videoUrl) async {
    try {
      await platform.invokeMethod('playVideo', {
        'url': videoUrl,
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
            _playVideo(widget.channelUrl);
          },
          child: const Text('Play Video'),
        ),
      ),
    );
  }
}