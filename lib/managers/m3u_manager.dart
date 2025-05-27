import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/show.dart';

class M3UParser {
  Future<({
    Map<String?, List<Channel>> channelsByGroup,
    Map<String, List<Movie>> moviesByCategory,
    Map<String, Show> showsByTitle,
  })> parseM3U(String url) async {
    final client = http.Client();
        // Ensure URL uses type=m3u_plus and output=m3u8
    Uri uri = Uri.parse(url);
    final params = Map<String, String>.from(uri.queryParameters);
    if (params['type'] != 'm3u_plus' || params['output'] != 'm3u8') {
      params['type'] = 'm3u_plus';
      params['output'] = 'm3u8';
      uri = uri.replace(queryParameters: params);
    }
    final request = http.Request('GET', uri);
    final res = await client.send(request);

    if (res.statusCode == 200) {
      final channelsByGroup = <String?, List<Channel>>{};
      final moviesByCategory = <String, List<Movie>>{};
      final showsByTitle = <String, Show>{};

      final stream =
          res.stream.transform(utf8.decoder).transform(const LineSplitter());

      String? currentName;
      String? currentLogo;
      String? currentGrouping;

      await for (var line in stream) {
        if (line.startsWith('#EXTINF')) {
          currentName =
              RegExp(r'tvg-name="([^"]*)"').firstMatch(line)?.group(1);
          currentName ??= line.split(',').length > 1
              ? line.split(',')[1].trim()
              : ''; //Condition if tvg-name isnt present
          currentLogo =
              RegExp(r'tvg-logo="([^"]*)"').firstMatch(line)?.group(1);
          currentLogo ??= '';

          currentGrouping =
              RegExp(r'group-title="([^"]*)"').firstMatch(line)?.group(1);
          currentGrouping ??= 'Other';
        } else if (line.startsWith('http') && currentName != null) {
          final streamUrl = line.trim();
          final grouping = currentGrouping ?? 'Other';

          if (grouping.contains('VOD')) {
            final category = grouping.contains('VOD:')
                ? grouping.split('VOD:')[1].trim()
                : grouping;
            moviesByCategory.putIfAbsent(category, () => []);
            moviesByCategory[category]!.add(Movie(
              title: currentName,
              logo: currentLogo ?? '',
              url: streamUrl,
              category: category,
            ));
          } else if (grouping.contains('SRS')) {
            // Episode
            final rc = RegExp(r'(.+?)\s*[Ss](\d+)\s*[Ee](\d+)', caseSensitive: false);
            final match = rc.firstMatch(currentName);
            if (match != null) {
              final showTitle = match.group(1)!.trim();
              final seasonNum = match.group(2)!;
              final seasonKey = 'Season $seasonNum';

              final parts = grouping.split('|');
              final showCategory = parts.length > 1 ? parts[1].trim() : grouping;

              final episode = Episode(
                title: currentName,
                url: streamUrl,
                logo: currentLogo ?? '',
              );

              if (!showsByTitle.containsKey(showTitle)) {
                showsByTitle[showTitle] = Show(
                  title: showTitle,
                  logo: currentLogo ?? '',
                  category: showCategory,
                  seasons: {},
                );
              }
              final show = showsByTitle[showTitle]!;
              show.seasons.putIfAbsent(seasonKey, () => []);
              show.seasons[seasonKey]!.add(episode);
            }
          } else {
            // Live TV channel
            channelsByGroup.putIfAbsent(grouping, () => []);
            channelsByGroup[grouping]!.add(Channel(
              name: currentName,
              logo: currentLogo ?? '',
              url: streamUrl,
              grouping: grouping,
            ));
          }
        }
      }
      return (
        channelsByGroup: channelsByGroup,
        moviesByCategory: moviesByCategory,
        showsByTitle: showsByTitle,
      );
    } else {
      throw Exception("Failed to load M3U File");
    }
  }
}
