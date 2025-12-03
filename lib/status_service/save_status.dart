import 'dart:io';
import 'package:path/path.dart';

import '../model_classes/status_model.dart';

class SaveStatus {
  // Base paths for saved media
  final String imagesPath = "/storage/emulated/0/Pictures/StatusSaver";
  final String videosPath = "/storage/emulated/0/Movies/StatusSaver";

  // Fetch both images & videos
  Future<List<StatusModel>> fetchSavedStatuses() async {
    List<StatusModel> saved = [];

    saved.addAll(await _fetchFromDirectory(imagesPath, false)); // images
    saved.addAll(await _fetchFromDirectory(videosPath, true));  // videos

    // Sort by latest first
    saved.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));

    return saved;
  }

  // Fetch media from one folder
  Future<List<StatusModel>> _fetchFromDirectory(
      String dirPath, bool isVideo) async {
    Directory directory = Directory(dirPath);
    List<StatusModel> list = [];

    if (await directory.exists()) {
      final files = directory.listSync();

      for (var file in files) {
        if (file is File) {
          String fileName = basename(file.path);

          // Validate extensions
          if (!isVideo &&
              !_isImage(fileName)) {
            continue;
          }

          if (isVideo &&
              !_isVideo(fileName)) {
            continue;
          }

          final stat = await file.stat();

          list.add(
            StatusModel(
              id: "${DateTime.now().millisecondsSinceEpoch}_$fileName",
              filePath: file.path,
              fileName: fileName,
              isVideo: isVideo,
              dateCreated: stat.modified,
            ),
          );
        }
      }
    }

    return list;
  }

  // Helper for image extensions
  bool _isImage(String name) {
    name = name.toLowerCase();
    return name.endsWith(".jpg") ||
        name.endsWith(".jpeg") ||
        name.endsWith(".png") ||
        name.endsWith(".gif") ||
        name.endsWith(".webp");
  }

  // Helper for video extensions
  bool _isVideo(String name) {
    name = name.toLowerCase();
    return name.endsWith(".mp4") ||
        name.endsWith(".mov") ||
        name.endsWith(".mkv") ||
        name.endsWith(".avi");
  }
}
