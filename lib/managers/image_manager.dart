import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageManager {
  static Future<String> saveImage(String imagePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.png';
    final savedImage = await File(imagePath).copy('${appDir.path}/$fileName');
    return savedImage.path;
  }

  static Future<void> deleteImage(String imgPath) async {
    final file = File(imgPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Widget getImage(String? imagePath, {double size = 72.0}) {
    if (imagePath == null || imagePath.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        child: Icon(Icons.person, size: size / 2),
      );
    }
    final file = File(imagePath);
    if (file.existsSync()) {
      return ClipOval(
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return CircleAvatar(
        radius: size / 2,
        child: Icon(Icons.person, size: size / 2),
      );
    }
  }
}
