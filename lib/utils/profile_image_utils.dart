import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ProfileImageUtils {
  static bool isNetworkUrl(String url) =>
      url.startsWith('http://') || url.startsWith('https://');

  static bool isAssetPath(String url) => url.startsWith('assets/');

  static bool isLocalFile(String url) {
    if (url.isEmpty || isNetworkUrl(url) || isAssetPath(url)) {
      return false;
    }
    return File(url).existsSync();
  }

  static Future<String> persistLocalImage(String sourcePath, String uid) async {
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) return sourcePath;

    final directory = await getApplicationDocumentsDirectory();
    final extension = sourcePath.contains('.')
        ? sourcePath.substring(sourcePath.lastIndexOf('.'))
        : '.jpg';
    final destinationPath =
        '${directory.path}/profile_${uid}_${DateTime.now().millisecondsSinceEpoch}$extension';

    await sourceFile.copy(destinationPath);
    return destinationPath;
  }
}
