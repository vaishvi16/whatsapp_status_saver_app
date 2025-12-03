import 'dart:io';

import '../model_classes/status_model.dart';

class DeleteSavedStatus {

  Future<bool> deleteStatus(StatusModel status) async {
    try {
      final file = File(status.filePath);

      if (await file.exists()) {
        await file.delete();
        return true;
      } else {
        print("File not found: ${status.filePath}");
        return false;
      }
    } catch (e) {
      print("Error deleting file: $e");
      return false;
    }
  }


}