import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'm3uparser.dart';
import 'video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String?, List<Channel>>? _channelsByGroup;

  bool _isLoading = false;
  String? _errorMessage;

  void _submit() async {
    String url = _controller.text;

    if (url.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a URL.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final parser = M3UParser();
      final channels = await parser.parseM3U(url);
      setState(() {
        _channelsByGroup = channels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load channels. Please check the URL.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IPTV Test"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'M3U Url',
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _channelsByGroup == null
                    ? const Text("No channels available.")
                    : Expanded(
                        child: ListView(
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
                                        const Icon(Icons
                                            .image_not_supported),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit
                                        .cover,
                                  ),
                                  title: Text(channel.name),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoPlayerScreen(
                                          channelName: channel.name,
                                          channelUrl: channel.url,
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
