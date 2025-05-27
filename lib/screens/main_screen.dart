import 'package:flutter/material.dart';
import 'package:sample_app/models/channel.dart';
import 'package:sample_app/models/movie.dart';
import 'package:sample_app/models/show.dart';
import '../managers/m3u_manager.dart';
import 'channel_groups_screen.dart';
import 'movies_screen.dart';
import 'show_screen.dart';

class MainScreen extends StatefulWidget {
  final String m3uUrl;

  const MainScreen({
    super.key,
    required this.m3uUrl,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Map<String?, List<Channel>>? _channelsByGroup;
  Map<String?, List<Movie>>? _moviesByCategory;
  Map<String, Show>? _showsByTitle;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final parser = M3UParser();
      final result = await parser.parseM3U(widget.m3uUrl);
      if (!mounted) return;
      setState(() {
        _channelsByGroup = result.channelsByGroup;
        _moviesByCategory = result.moviesByCategory;
        _showsByTitle = result.showsByTitle;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load content. Please check the URL.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    final hasMovies = _moviesByCategory != null && _moviesByCategory!.isNotEmpty;
    final hasShows = _showsByTitle != null && _showsByTitle!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: (hasMovies || hasShows)
          ? Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(
                    color: Colors.white10,
                    width: 0.5,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                backgroundColor: Colors.black,
                elevation: 0,
                selectedItemColor: Colors.redAccent,
                unselectedItemColor: Colors.white70,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.tv_rounded),
                    activeIcon: Icon(Icons.tv_rounded, color: Colors.redAccent),
                    label: 'Channels',
                  ),
                  if (hasMovies)
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.movie_creation_rounded),
                      activeIcon: Icon(Icons.movie_creation_rounded, color: Colors.redAccent),
                      label: 'Movies',
                    ),
                  if (hasShows)
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.play_circle_outline_rounded),
                      activeIcon: Icon(Icons.play_circle_outline_rounded, color: Colors.redAccent),
                      label: 'Shows',
                    ),
                ],
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            ChannelGroupsScreen(
              channels: _channelsByGroup,
            ),
            if (hasMovies) MoviesScreen(movies: _moviesByCategory),
            if (hasShows) ShowScreen(shows: _showsByTitle),
          ],
        ),
      ),
    );
  }
} 