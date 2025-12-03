import 'dart:io';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model_classes/status_model.dart';

class DownloadFile {

  // Save based on status.isVideo : image or video
  Future<bool> saveFilesToGallery(StatusModel status) async {
    await requestPermissions();

    try {
      bool? saved;

      if (status.isVideo) {
        saved = await GallerySaver.saveVideo(
          status.filePath,
          albumName: "StatusSaver",
        );
      } else {
        saved = await GallerySaver.saveImage(
          status.filePath,
          albumName: "StatusSaver",
        );
      }

      return saved ?? false;

    } catch (e) {
      print("Error saving file: $e");
      return false;
    }
  }

  /// Permissions for Android 13+
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.photos.request();
      await Permission.videos.request();
    }
  }
}
