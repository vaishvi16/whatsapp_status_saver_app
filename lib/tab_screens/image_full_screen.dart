import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp_status_saver_app/model_classes/status_model.dart';

import '../constants/constants.dart';
import '../status_service/delete_saved_status.dart';
import '../status_service/download_file.dart';
import '../status_service/share_file.dart';

class ImageFullScreen extends StatefulWidget {
  final StatusModel status;
  final List<StatusModel>? savedStatus;

  const ImageFullScreen({required this.status, this.savedStatus, super.key});

  @override
  State<ImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<ImageFullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: kPrimary,
        title: Text("Image Status", style: TextStyle(color: kWhite)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(File(widget.status.filePath))
            ),
          ),
          (widget.savedStatus != null && widget.savedStatus!.isNotEmpty) ?
          Container(
            color: kGrey,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: EdgeInsets.all(kPaddingS),
                    child: IconButton(onPressed: () {
                      ShareFile().share(widget.status.filePath);
                    }, icon: Icon(Icons.share, size: 25),)
                  ),
                  Padding(
                    padding: EdgeInsets.all(kPaddingS),
                    child:  IconButton(
                      onPressed: () async{
                        print("Saved btn clicked");
                        bool isSaved = await DownloadFile().saveFilesToGallery(widget.status);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isSaved ? "Image Saved!" : "Failed to Save"),
                          ),
                        );
                      },
                      icon: Icon(Icons.save_alt_outlined, size: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(kPaddingS),
                    child:  IconButton(
                      onPressed: () async{
                       await _showDeleteConfirmation();
                      },
                      icon: Icon(Icons.delete, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ) : Container(
            color: kGrey,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                      padding: EdgeInsets.all(kPaddingS),
                      child: IconButton(onPressed: () {
                        ShareFile().share(widget.status.filePath);
                      }, icon: Icon(Icons.share, size: 25),)
                  ),
                  Padding(
                    padding: EdgeInsets.all(kPaddingS),
                    child:  IconButton(
                      onPressed: () async{
                        print("Saved btn clicked");
                        bool isSaved = await DownloadFile().saveFilesToGallery(widget.status);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isSaved ? "Image Saved!" : "Failed to Save"),
                          ),
                        );
                      },
                      icon: Icon(Icons.save_alt_outlined, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
     await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Status'),
        content: const Text('Are you sure you want to delete this?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: kPrimary)),
          ),
          TextButton(
            onPressed: () async {
              bool deleted = await DeleteSavedStatus().deleteStatus(widget.status);

              if (deleted) {
                Navigator.pop(context, true); // Close dialog
                Navigator.pop(context, true); // Close fullscreen screen

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Deleted Successfully!")),
                );
              } else {
                Navigator.pop(context, false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete")),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

}
