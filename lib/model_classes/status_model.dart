// lib/models/status_model.dart
class StatusModel {
  final String id;
  final String filePath;
  final String fileName;
  final bool isVideo;
  final DateTime dateCreated;

  StatusModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.isVideo,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'isVideo': isVideo,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      id: map['id'] ?? '',
      filePath: map['filePath'] ?? '',
      fileName: map['fileName'] ?? '',
      isVideo: map['isVideo'] ?? false,
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] ?? 0),
    );
  }
}
