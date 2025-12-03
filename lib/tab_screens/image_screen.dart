import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_status_saver_app/constants/constants.dart';
import 'package:whatsapp_status_saver_app/model_classes/status_model.dart';
import 'package:whatsapp_status_saver_app/status_service/share_file.dart';
import 'package:whatsapp_status_saver_app/status_service/status.dart';

import '../status_service/delete_saved_status.dart';
import '../status_service/download_file.dart';
import 'image_full_screen.dart';

class ImageScreen extends StatefulWidget {
  final List<StatusModel>? savedStatuses;

  const ImageScreen({this.savedStatuses, super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final Status _status = Status();
  List<StatusModel> images = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    await requestPermissions();

    if (widget.savedStatuses != null) {
      // SHOW SAVED IMAGES
      images = widget.savedStatuses!.where((s) => !s.isVideo).toList();
      loading = false;
      setState(() {});
      return;
    }

    // ELSE LOAD LIVE STATUS IMAGES
    final statuses = await _status.fetchStatuses();
    images = statuses.where((s) => !s.isVideo).toList();
    loading = false;
    setState(() {});
  }

  Future<void> requestPermissions() async {
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

    if (sdk >= 30) {
      await Permission.manageExternalStorage.request();
    } else {
      await Permission.storage.request();
    }

    if (Platform.isAndroid) {
      if (await Permission.photos.request().isDenied ||
          await Permission.videos.request().isDenied) {
        await Permission.photos.request();
        await Permission.videos.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    if (loading) {
      return Center(child: CircularProgressIndicator(color: kPrimary));
    }

    if (images.isEmpty) {
      return Center(child: Text("No image statuses found"));
    }

    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.6,
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final item = images[index];
        return GestureDetector(
          onTap: () async{
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImageFullScreen(
                  status: item,
                  savedStatus: widget.savedStatuses,
                ),
              ),
            );

            if (result == true) {
              setState(() {
                images.removeAt(index); // Refresh UI
              });
            }

          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Card(
              elevation: 3,
              shadowColor: kLightGrey,
              color: kGrey,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Image.file(
                        File(item.filePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),

                  (widget.savedStatuses != null && widget.savedStatuses!.isNotEmpty) ?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          ShareFile().share(item.filePath);
                        },
                        icon: Icon(Icons.share, size: 20),
                      ),
                      IconButton(
                        onPressed: () async {
                          print("Saved btn clicked");
                          bool isSaved = await DownloadFile()
                              .saveFilesToGallery(item);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isSaved ? "Image Saved!" : "Failed to Save",
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.save_alt_outlined, size: 20),
                      ),
                      IconButton
                        (
                        onPressed: () async {
                          print("Delete clicked");

                          _showDeleteConfirmation(item, index);

                        },
                        icon: Icon(Icons.delete, size: 20),
                      ),

                    ],
                  ) : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          ShareFile().share(item.filePath);
                        },
                        icon: Icon(Icons.share, size: 20),
                      ),
                      IconButton(
                        onPressed: () async {
                          print("Saved btn clicked");
                          bool isSaved = await DownloadFile()
                              .saveFilesToGallery(item);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isSaved ? "Image Saved!" : "Failed to Save",
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.save_alt_outlined, size: 20),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(var item, int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Status'),
        content: Text('Are you sure you want to delete ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel',style: TextStyle(color: kPrimary),),
          ),
          TextButton(
            onPressed: () async {
              bool deleted = await DeleteSavedStatus().deleteStatus(item);

              if (deleted) {
                setState(() {
                  images.removeAt(index);
                  Navigator.of(context).pop(true);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Deleted Successfully !")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete")),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
