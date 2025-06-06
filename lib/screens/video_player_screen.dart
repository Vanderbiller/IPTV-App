import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avtv/managers/video_manager.dart';

class VideoPlayerPage extends StatefulWidget {
  final String channelUrl;
  final String title;
  final String? thumbnailUrl;
  final String? description;
  final String? category;
  final String? duration;

  const VideoPlayerPage({
    super.key, 
    required this.channelUrl, 
    required this.title,
    this.thumbnailUrl,
    this.description,
    this.category,
    this.duration,
  });

  @override
  VideoPlayerPageState createState() => VideoPlayerPageState();
}

class VideoPlayerPageState extends State<VideoPlayerPage> {
  bool _isLoading = false;
  String? _errorMessage;
  double _lastPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLastPosition();
    VideoManager.registerPositionUpdateHandler((url, newPos) {
      if (mounted && url == widget.channelUrl) {
        setState(() {
          _lastPosition = newPos;
        });
      }
    });
  }

  Future<void> _loadLastPosition() async {
    final position = await VideoManager.loadLastPosition(widget.channelUrl);
    if (mounted) {
      setState(() {
        _lastPosition = position;
      });
    }
  }

  Future<void> _playVideo(String videoUrl, String title, {double startPoint = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await VideoManager.playVideo(videoUrl, title, startPoint: startPoint);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to play video: '${e.message}'.");
      }
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail/Preview Area
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: widget.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded, color: Colors.white30, size: 40),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.play_circle_outline_rounded, color: Colors.white30, size: 60),
                      ),
                    ),
                  // Play Button Overlay
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _playVideo(widget.channelUrl, widget.title),
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_lastPosition > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _playVideo(widget.channelUrl, widget.title, startPoint: _lastPosition),
                      child: const Text('Resume'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _playVideo(widget.channelUrl, widget.title),
                      child: const Text('Start Over'),
                    ),
                  ],
                ),
              ),
            // Video Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.category != null || widget.duration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          if (widget.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.category!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (widget.duration != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              widget.duration!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  if (widget.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        widget.description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}