import 'dart:convert';

import 'package:http/http.dart' as http;

class Channel {
  final String name;
  final String logo;
  final String url;
  final String grouping;

  Channel(
      {required this.name,
      required this.logo,
      required this.url,
      required this.grouping});
}

class M3UParser {
  Future<Map<String?, List<Channel>>> parseM3U(String url) async {
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
      Map<String?, List<Channel>> channels = {};

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
          if (!channels.containsKey(currentGrouping)) {
            channels[currentGrouping] = [];
          }
          channels[currentGrouping]!.add(Channel(
              name: currentName,
              logo: currentLogo ?? '',
              url: line.trim(),
              grouping: currentGrouping ?? ''));
        }
      }
      return channels;
    } else {
      throw Exception("Failed to load M3U File");
    }
  }
}
