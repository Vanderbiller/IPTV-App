import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String channelName;

  const VideoPlayerScreen({super.key, required this.channelName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(channelName),
      ),
      body: Center(
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: 300,
          child: Center(
            child: Text(
              'Playing $channelName',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}