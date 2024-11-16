# IPTV Player

An IPTV player app built with Flutter and Dart. This app allows users to load M3U playlists, parse channels, and stream live TV, movies, and shows.

## Features

- **M3U Parsing**: Extract channel information (name, logo, group, and URL) from M3U files.
- **User Input**: Enter an M3U playlist URL directly from the app's home screen.
- **Dynamic Channel List**: Display channels parsed from the M3U file in a clean, user-friendly interface.
- **Video Streaming**: Supports playing content directly from the parsed channel URLs.
- **Modular Design**: Clean code structure with a focus on reusability and scalability.

## Screenshots

*Include screenshots of the app here, if available.*

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. Launch the app.
2. Enter the URL of an M3U playlist in the provided input field.
3. Click the "Submit" button to load and parse the channels.
4. Select a channel from the list to start streaming.

## Code Highlights

- **Channel Model**:
  Encapsulates details about each channel.
  ```dart
  class Channel {
    final String name;
    final String logo;
    final String url;
    final String grouping;

    Channel({
      required this.name,
      required this.logo,
      required this.url,
      required this.grouping,
    });
  }
  ```

- **M3U Parser**:
  Handles fetching and parsing M3U playlists.
  ```dart
  class M3UParser {
    Future<List<Channel>> parseM3U(String url) async {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final lines = res.body.split('\n');
        List<Channel> channels = [];
        String? currentName;
        String? currentLogo;
        String? currentGrouping;

        for (String line in lines) {
          if (line.startsWith('#EXTINF')) {
            currentName = RegExp(r'tvg-name="([^"]*)"').firstMatch(line)?.group(1);
            currentLogo = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line)?.group(1);
            currentGrouping = RegExp(r'group-title="([^"]*)"').firstMatch(line)?.group(1);
          } else if (line.startsWith('http') && currentName != null) {
            channels.add(Channel(
              name: currentName,
              logo: currentLogo ?? '',
              url: line.trim(),
              grouping: currentGrouping ?? '',
            ));
          }
        }
        return channels;
      } else {
        throw Exception("Failed to load M3U file");
      }
    }
  }
  ```

## Contributions

Contributions are welcome! Feel free to submit a pull request or open an issue for bug reports or feature requests.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Disclaimer

This app is a tool for loading and parsing M3U playlists. The app does not host, distribute, or provide any content. Users are responsible for ensuring they use the app in compliance with local laws and regulations.
