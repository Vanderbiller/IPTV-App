import 'package:flutter/material.dart';
import 'package:sample_app/models/channel.dart';
import 'package:sample_app/models/movie.dart';
import '../managers/m3u_manager.dart';
import 'channel_groups_screen.dart';
import 'movies_screen.dart';

class MainScreen extends StatefulWidget {
  final String m3uUrl;

  const MainScreen({
    super.key,
    required this.m3uUrl,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  Map<String?, List<Channel>>? _channelsByGroup;
  Map<String?, List<Movie>>? _moviesByCategory;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showBottomBar = true;
  double _lastScrollPosition = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        _isLoading = false;
      });
      // Show bottom bar if there are movies
      final hasMovies = result.moviesByCategory.isNotEmpty;
      if (hasMovies) {
        setState(() {
          _showBottomBar = true;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load content. Please check the URL.';
      });
    }
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final currentScroll = notification.metrics.pixels;
      
      // Show bottom bar if at the top of the page
      if (currentScroll <= 0) {
        if (!_showBottomBar) {
          setState(() {
            _showBottomBar = true;
          });
          _animationController.forward();
        }
      } else {
        // Handle scroll direction
        if (currentScroll > _lastScrollPosition && _showBottomBar) {
          // Scrolling down
          setState(() {
            _showBottomBar = false;
          });
          _animationController.reverse();
        } else if (currentScroll < _lastScrollPosition && !_showBottomBar) {
          // Scrolling up
          setState(() {
            _showBottomBar = true;
          });
          _animationController.forward();
        }
      }
      _lastScrollPosition = currentScroll;
    }
    return true;
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                ChannelGroupsScreen(
                  channels: _channelsByGroup,
                ),
                if (hasMovies) MoviesScreen(movies: _moviesByCategory),
              ],
            ),
          ),
          if (hasMovies)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 100 * (1 - _animation.value)),
                    child: Opacity(
                      opacity: _animation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: BottomNavigationBar(
                          currentIndex: _selectedIndex,
                          onTap: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          selectedItemColor: Colors.redAccent,
                          unselectedItemColor: Colors.white70,
                          items: const [
                            BottomNavigationBarItem(
                              icon: Icon(Icons.tv),
                              label: 'Channels',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.movie),
                              label: 'Movies',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
} 