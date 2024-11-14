import 'dart:convert';

import 'package:http/http.dart' as http;

class Channel {
  final String name;
  final String logo;
  final String url;
  final String grouping;

  Channel({
    required this.name,
    required this.logo,
    required this.url,
    required this.grouping
  });
}

class M3UParser {
  Future<List<Channel>> parseM3U(String url) async {
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    final res = await client.send(request);

    if (res.statusCode == 200) {
      List<Channel> channels = [];

      final stream = res.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

      String? currentName;
      String? currentLogo;
      String? currentGrouping;

      print("Started");
      await for (var line in stream) {
        if (line.startsWith('#EXTINF')) {
          currentName = RegExp(r'tvg-name="([^"]*)"').firstMatch(line)?.group(1);
          currentLogo = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line)?.group(1);
          currentGrouping = RegExp(r'group-title="([^"]*)"').firstMatch(line)?.group(1);
        } else if (line.startsWith('http') && currentName != null) {
          channels.add(Channel(
            name: currentName,
            logo: currentLogo ?? '',
            url: line.trim(),
            grouping: currentGrouping ?? ''
          ));
        }
      }
      print("finished");
      channels;
    }
    
    else {
      throw Exception("Failed to load M3U File");
    }
    

    return List<Channel>.empty();
  }
}