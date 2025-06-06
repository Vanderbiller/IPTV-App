import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoManager {
  static const MethodChannel _channel = MethodChannel('video_player_channel');
  static Future<void> playVideo(String url, String title, {double startPoint = 0.0}) async {
    try {
      await _channel.invokeMethod('playVideo', {
        'url': url,
        'title': title,
        'startPoint': startPoint
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("VideoService.playVideo failed: ${e.message}");
      }
      rethrow;
    }
  }

  static void registerPositionUpdateHandler(void Function(String, double) onUpdate) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'positionUpdated') {
        final args = call.arguments as Map<dynamic, dynamic>;
        final url = args['url'] as String;
        final pos = (args['position'] as num).toDouble();
        if (kDebugMode) {
          print('Dart received positionUpdated for $url: $pos');
        }
        onUpdate(url, pos);
      }
      return null;
    });
  }

  static Future<void> saveLastPosition(String url, double position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lastPos__$url', position);
  }

  static Future<double> loadLastPosition(String url) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('lastPos__$url') ?? 0.0;
  }
}