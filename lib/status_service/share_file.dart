import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareFile {
  Future<void> share(String filePath) async {
    final File originalFile = File(filePath);

    if (!await originalFile.exists()) {
      print("File does not exist: $filePath");
      return;
    }

    // Step 1: Get temporary directory
    final tempDir = await getTemporaryDirectory();

    // Step 2: Create a new temporary file
    final tempFile = File("${tempDir.path}/${originalFile.uri.pathSegments.last}");

    // Step 3: Copy the file to temp (required by share_plus)
    await tempFile.writeAsBytes(await originalFile.readAsBytes());

    // Step 4: Share the local file
    await Share.shareXFiles([XFile(tempFile.path)], text: "Shared from Status Saver app");
  }
}
