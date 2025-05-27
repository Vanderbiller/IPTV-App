import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import 'video_player_screen.dart';

class MoviesScreen extends StatefulWidget {
  final Map<String?, List<Movie>>? movies;

  const MoviesScreen({super.key, required this.movies});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final currentPosition = _scrollController.position.pixels;
    final isScrollingDown = currentPosition > _lastScrollPosition;
    final isAtTop = currentPosition <= 0;

    setState(() {
      if (isAtTop || _searchQuery.isNotEmpty) {
        _showSearch = true;
      } else if (isScrollingDown) {
        _showSearch = false;
      } else {
        _showSearch = true;
      }
    });

    _lastScrollPosition = currentPosition;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showSearch ? 44 : 0,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search Movies',
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      isDense: true,
                      constraints: const BoxConstraints(maxHeight: 36),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: _AutoSwipingCarousel(
                carouselMovies: widget.movies?.values.expand((movies) => movies).toList() ?? [],
                allMovies: widget.movies ?? {},
                searchQuery: _searchQuery,
                scrollController: _scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoSwipingCarousel extends StatefulWidget {
  final List<Movie> carouselMovies;
  final Map<String?, List<Movie>> allMovies;
  final String searchQuery;
  final ScrollController scrollController;

  const _AutoSwipingCarousel({
    required this.carouselMovies, 
    required this.allMovies,
    required this.searchQuery,
    required this.scrollController,
  });

  @override
  State<_AutoSwipingCarousel> createState() => _AutoSwipingCarouselState();
}

class _AutoSwipingCarouselState extends State<_AutoSwipingCarousel> {
  late final PageController _pageController;
  late final List<Movie> _carouselMovies;
  late final Map<String?, List<Movie>> _allMovies;

  @override
  void initState() {
    super.initState();
    _carouselMovies = widget.carouselMovies;
    _allMovies = widget.allMovies;
    int initial = (_carouselMovies.length > 1) ? 1 : 0;
    _pageController = PageController(viewportFraction: 0.65, initialPage: initial);
  }

  // Add this method to filter movies
  Map<String?, List<Movie>> _getFilteredMovies() {
    if (widget.searchQuery.isEmpty) {
      return _allMovies;
    }

    final query = widget.searchQuery.toLowerCase();
    final filtered = <String?, List<Movie>>{};

    _allMovies.forEach((category, movies) {
      final filteredMovies = movies.where((movie) {
        return movie.title.toLowerCase().contains(query) ||
               movie.category.toLowerCase().contains(query);
      }).toList();

      if (filteredMovies.isNotEmpty) {
        filtered[category] = filteredMovies;
      }
    });

    return filtered;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = _getFilteredMovies();
    
    return ListView(
      controller: widget.scrollController,
      children: [
        if (filteredMovies.isNotEmpty) ...[
          // Only show carousel when not searching
          if (widget.searchQuery.isEmpty) ...[
            SizedBox(
              height: 360,
              child: PageView.builder(
                controller: _pageController,
                itemCount: filteredMovies.values.expand((movies) => movies).toList().length,
                onPageChanged: (i) {},
                itemBuilder: (context, index) {
                  final movie = filteredMovies.values.expand((movies) => movies).toList()[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerPage(
                            channelUrl: movie.url,
                            title: movie.title,
                            thumbnailUrl: movie.logo,
                            category: movie.category,
                          ),
                        ),
                      );
                    },
                    child: Center(
                      child: Container(
                        width: 230,
                        height: 360,
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: movie.logo,
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
                                    child: Icon(Icons.broken_image, color: Colors.white30, size: 40),
                                  ),
                                ),
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black87,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 32,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    movie.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (movie.category.isNotEmpty)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 14,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      movie.category,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Rest of your category lists
          ...filteredMovies.entries.map((entry) {
            final category = entry.key;
            final list = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      category!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final movie = list[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerPage(
                                  channelUrl: movie.url,
                                  title: movie.title,
                                  thumbnailUrl: movie.logo,
                                  category: movie.category,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 110,
                            margin: EdgeInsets.only(
                              left: i == 0 ? 16 : 8,
                              right: i == list.length - 1 ? 16 : 0,
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: CachedNetworkImage(
                                    imageUrl: movie.logo,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: Icon(Icons.broken_image, color: Colors.white30),
                                      ),
                                    ),
                                    height: 160,
                                    width: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      movie.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ] else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No movies found',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
