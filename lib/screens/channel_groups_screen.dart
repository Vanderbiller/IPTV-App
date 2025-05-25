import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../managers/m3u_manager.dart';
import 'video_player_screen.dart';

class ChannelGroupsScreen extends StatefulWidget {
  /// The M3U playlist URL to load and parse
  final String m3uUrl;

  const ChannelGroupsScreen({
    Key? key,
    required this.m3uUrl,
  }) : super(key: key);

  @override
  _ChannelGroupsScreenState createState() => _ChannelGroupsScreenState();
}

class _ChannelGroupsScreenState extends State<ChannelGroupsScreen> {
  Map<String?, List<Channel>>? _channelsByGroup;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final parser = M3UParser();
      final channels = await parser.parseM3U(widget.m3uUrl);
      if (!mounted) return;
      setState(() {
        _channelsByGroup = channels;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load channels. Please check the URL.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : (_channelsByGroup == null || _channelsByGroup!.isEmpty)
                    ? const Center(child: Text('No channels available.'))
                    : ListView(
                        children: _channelsByGroup!.entries.map((entry) {
                          return ExpansionTile(
                            title: Text(
                              entry.key ?? 'Other',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: entry.value.map((channel) {
                              return ListTile(
                                leading: CachedNetworkImage(
                                  imageUrl: channel.logo,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.image_not_supported),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(channel.name),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerPage(
                                        channelUrl: channel.url,
                                        title: channel.name,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}