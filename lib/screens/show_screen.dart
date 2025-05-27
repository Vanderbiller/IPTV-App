import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/show.dart';
import 'video_player_screen.dart';

class ShowScreen extends StatelessWidget {
  final Map<String, Show>? shows;

  const ShowScreen({super.key, required this.shows});

  @override
  Widget build(BuildContext context) {
    if (shows == null || shows!.isEmpty) {
      return const Center(
        child: Text(
          'No shows available.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Group shows by category
    final showsByCategory = <String, List<Show>>{};
    for (final show in shows!.values) {
      showsByCategory.putIfAbsent(show.category, () => []);
      showsByCategory[show.category]!.add(show);
    }

    // Get latest shows for carousel
    String? latestShowsCategory;
    for (final key in showsByCategory.keys) {
      if (key.toUpperCase().contains('LATEST')) {
        latestShowsCategory = key;
        break;
      }
    }
    latestShowsCategory ??= showsByCategory.keys.first;
    final carouselShows = showsByCategory[latestShowsCategory]!;

    return _AutoSwipingCarousel(
      carouselShows: carouselShows,
      allShows: showsByCategory,
    );
  }
}

class _AutoSwipingCarousel extends StatefulWidget {
  final List<Show> carouselShows;
  final Map<String, List<Show>> allShows;
  const _AutoSwipingCarousel({required this.carouselShows, required this.allShows});

  @override
  State<_AutoSwipingCarousel> createState() => _AutoSwipingCarouselState();
}

class _AutoSwipingCarouselState extends State<_AutoSwipingCarousel> {
  late final PageController _pageController;
  late final List<Show> _carouselShows;
  late final Map<String, List<Show>> _allShows;

  @override
  void initState() {
    super.initState();
    _carouselShows = widget.carouselShows;
    _allShows = widget.allShows;
    int initial = (_carouselShows.length > 1) ? 1 : 0;
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
            itemCount: _carouselShows.length,
            onPageChanged: (i) {},
            itemBuilder: (context, index) {
              final show = _carouselShows[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShowDetailScreen(show: show),
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
                            imageUrl: show.logo,
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
                                show.title,
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
                          if (show.category.isNotEmpty)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 14,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  show.category,
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
        ..._allShows.entries.map((entry) {
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
                    category.toUpperCase(),
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
                      final show = list[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShowDetailScreen(show: show),
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
                                  imageUrl: show.logo,
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
                                    show.title,
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
      ],
    );
  }
}

class ShowDetailScreen extends StatefulWidget {
  final Show show;

  const ShowDetailScreen({super.key, required this.show});

  @override
  State<ShowDetailScreen> createState() => _ShowDetailScreenState();
}

class _ShowDetailScreenState extends State<ShowDetailScreen> {
  String? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _selectedSeason = widget.show.seasons.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.show.title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.show.logo),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.show.category,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: widget.show.seasons.length > 1 
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSeason,
                    isExpanded: true,
                    dropdownColor: Colors.black,
                    style: TextStyle(
                      color: widget.show.seasons.length > 1 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    icon: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: widget.show.seasons.length > 1 ? 1.0 : 0.3,
                      child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ),
                    items: widget.show.seasons.keys.map((String season) {
                      return DropdownMenuItem<String>(
                        value: season,
                        child: Text(season),
                      );
                    }).toList(),
                    onChanged: widget.show.seasons.length > 1
                        ? (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedSeason = newValue;
                              });
                            }
                          }
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedSeason != null)
              ...widget.show.seasons[_selectedSeason]!.asMap().entries.map((entry) {
                final episode = entry.value;

                return ListTile(
                  leading: Container(
                    width: 80,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: episode.logo,
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
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    episode.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerPage(
                          channelUrl: episode.url,
                          title: episode.title,
                          thumbnailUrl: episode.logo,
                          category: widget.show.category,
                        ),
                      ),
                    );
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
} 