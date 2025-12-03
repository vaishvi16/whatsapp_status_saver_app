// lib/services/status.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../model_classes/status_model.dart';

class Status {

  Future<List<StatusModel>> fetchStatuses() async {
    List<StatusModel> statuses = [];

    try {
      // First, ensure we have permission
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

      PermissionStatus permissionStatus;

      if (sdk >= 30) {
        permissionStatus = await Permission.manageExternalStorage.status;
        if (!permissionStatus.isGranted) {
          permissionStatus = await Permission.manageExternalStorage.request();
        }
      } else {
        permissionStatus = await Permission.storage.status;
        if (!permissionStatus.isGranted) {
          permissionStatus = await Permission.storage.request();
        }
      }


      String? statusPath = await getWhatsAppStatusPath();
      if (statusPath == null) {
        print('WhatsApp status path not found');
        return statuses;
      }

      print('Accessing directory: $statusPath');
      Directory statusDir = Directory(statusPath);

      if (await statusDir.exists()) {
        // Use list() instead of listSync() for better async handling
        List<FileSystemEntity> files = await statusDir.list().toList();
        print('Raw file count: ${files.length}');

        int validStatusCount = 0;

        for (FileSystemEntity file in files) {
          try {
            if (file is File) {
              String fileName = file.path.split('/').last;
              String fileExtension = fileName.toLowerCase();

              print('Checking file: $fileName');

              // Skip hidden files and check valid extensions
              if (!fileName.startsWith('.') &&
                  (fileExtension.endsWith('.jpg') ||
                      fileExtension.endsWith('.jpeg') ||
                      fileExtension.endsWith('.png') ||
                      fileExtension.endsWith('.mp4') ||
                      fileExtension.endsWith('.gif'))) {

                bool isVideo = fileExtension.endsWith('.mp4');

                // Get file stats
                File statFile = File(file.path);
                FileStat fileStat = await statFile.stat();
                int fileSize = await statFile.length();

                print('   File: $fileName');
                print('   Type: ${isVideo ? 'Video' : 'Image'}');
                print('   Size: $fileSize bytes');
                print('   Modified: ${fileStat.modified}');

                // Check if file has reasonable size (not empty or corrupted)
                if (fileSize > 1024) { // At least 1KB
                  statuses.add(StatusModel(
                    id: '${DateTime.now().millisecondsSinceEpoch}_$fileName',
                    filePath: file.path,
                    fileName: fileName,
                    isVideo: isVideo,
                    dateCreated: fileStat.modified,
                  ));
                  validStatusCount++;
                  print(' ADDED: $fileName');
                } else {
                  print(' Skipping - File too small: $fileName ($fileSize bytes)');
                }
              } else {
                if (!fileName.startsWith('.')) {
                  print('Skipping - Not a status file: $fileName');
                } else {
                  print(' Skipping - Hidden file: $fileName');
                }
              }
            }
          } catch (e) {
            print(' Error processing file: $e');
          }
        }

        // Sort by date created (newest first)
        statuses.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        print(' FINAL RESULT: $validStatusCount valid statuses loaded');

      } else {
        print('Status directory does not exist: $statusPath');

        // Let's try to create a test file to verify access
        try {
          File testFile = File('$statusPath/test_access.txt');
          await testFile.writeAsString('Test access');
          await testFile.delete();
          print(' Can write to directory');
        } catch (e) {
          print(' Cannot write to directory: $e');
        }
      }
    } catch (e) {
      print(' Error fetching statuses: $e');
    }

    return statuses;
  }

  Future<String?> getWhatsAppStatusPath() async {
    try {
      final Directory? externalDir = await getExternalStorageDirectory();
      print('External directory: ${externalDir?.path}');

      if (externalDir == null) {
        print('Cannot access external storage directory');
        return null;
      }

      // Test multiple possible WhatsApp paths
      List<String> possiblePaths = [
        '${externalDir.path}/WhatsApp/Media/.Statuses',
        '${externalDir.path}/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
        '/storage/emulated/0/WhatsApp/Media/.Statuses',
        '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
        '/sdcard/WhatsApp/Media/.Statuses',
        '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
      ];

      print(' Searching for WhatsApp status directory...');

      for (String path in possiblePaths) {
        Directory statusDir = Directory(path);
        bool exists = await statusDir.exists();
        print('Checking: $path → ${exists ? "EXISTS" : "NOT FOUND"}');

        if (exists) {
          // List files in the directory to verify content
          try {
            List<FileSystemEntity> files = statusDir.listSync();
            print('Directory "$path" contains ${files.length} items');

            // Print first few files to see what's there
            for (int i = 0; i < files.length && i < 5; i++) {
              String fileName = files[i].path.split('/').last;
              print('   $fileName');
            }

            return path;
          } catch (e) {
            print('Error reading directory $path: $e');
          }
        }
      }

      print('No WhatsApp status directory found in any known location');
      return null;
    } catch (e) {
      print('Error getting WhatsApp path: $e');
      return null;
    }
  }

}