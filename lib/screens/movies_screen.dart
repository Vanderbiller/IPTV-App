import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import 'video_player_screen.dart';

class MoviesScreen extends StatelessWidget {
  final Map<String?, List<Movie>>? movies;
  const MoviesScreen({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies == null || movies!.isEmpty) {
      return const Center(
        child: Text(
          'No movies available.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    String? latestMoviesCategory;
    for (final key in movies!.keys) {
      if (key?.toUpperCase() == 'VOD | EN LATEST MOVIES') {
        latestMoviesCategory = key;
        break;
      }
    }
    latestMoviesCategory ??= movies!.keys.first;
    final carouselMovies = movies![latestMoviesCategory]!;

    return _AutoSwipingCarousel(
      carouselMovies: carouselMovies,
      allMovies: movies!,
    );
  }
}

class _AutoSwipingCarousel extends StatefulWidget {
  final List<Movie> carouselMovies;
  final Map<String?, List<Movie>> allMovies;
  const _AutoSwipingCarousel({required this.carouselMovies, required this.allMovies});

  @override
  State<_AutoSwipingCarousel> createState() => _AutoSwipingCarouselState();
}

class _AutoSwipingCarouselState extends State<_AutoSwipingCarousel> {
  late final PageController _pageController;
  int _currentPage = 1;
  late final List<Movie> _carouselMovies;
  late final Map<String?, List<Movie>> _allMovies;
  @override
  void initState() {
    super.initState();
    _carouselMovies = widget.carouselMovies;
    _allMovies = widget.allMovies;
    int initial = (_carouselMovies.length > 1) ? 1 : 0;
    _currentPage = initial;
    _pageController = PageController(viewportFraction: 0.65, initialPage: initial);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _carouselMovies.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final movie = _carouselMovies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerPage(
                        channelUrl: movie.url,
                        title: movie.title,
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
        ..._allMovies.entries.map((entry) {
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
        }).toList(),
      ],
    );
  }
}
