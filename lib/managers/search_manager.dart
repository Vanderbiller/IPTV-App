import '../models/movie.dart';
import '../models/channel.dart';
import '../models/show.dart';

class SearchManager {
  final Map<String?, List<Movie>>? movies;
  final Map<String?, List<Channel>>? channels;
  final Map<String, Show>? shows;

  SearchManager({
    required this.movies,
    required this.channels,
    required this.shows,
  });

  Map<String, List<dynamic>> search(String query) {
    if (query.isEmpty) return {};

    final results = <String, List<dynamic>>{};
    
    // Search movies
    if (movies != null) {
      for (final category in movies!.entries) {
        final categoryName = category.key ?? 'Uncategorized';
        final movies = category.value.where((movie) =>
            movie.title.toLowerCase().contains(query) ||
            movie.category.toLowerCase().contains(query)).toList();
        
        if (movies.isNotEmpty) {
          results[categoryName] = movies;
        }
      }
    }

    // Search channels
    if (channels != null) {
      for (final group in channels!.entries) {
        final groupName = group.key ?? 'Uncategorized';
        final channels = group.value.where((channel) =>
            channel.name.toLowerCase().contains(query) ||
            channel.grouping.toLowerCase().contains(query)).toList();
        
        if (channels.isNotEmpty) {
          results['LIVE TV | $groupName'] = channels;
        }
      }
    }

    // Search shows
    if (shows != null) {
      final shows = this.shows!.entries.where((entry) =>
          entry.key.toLowerCase().contains(query)).toList();
      
      if (shows.isNotEmpty) {
        results['TV SHOWS'] = shows.map((e) => e.value).toList();
      }
    }

    return results;
  }
} 