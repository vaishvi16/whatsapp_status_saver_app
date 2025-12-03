import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_status_saver_app/model_classes/status_model.dart';
import 'package:whatsapp_status_saver_app/status_service/status.dart';
import 'package:whatsapp_status_saver_app/tab_screens/video_player_screen.dart';

import '../constants/constants.dart';
import '../status_service/delete_saved_status.dart';
import '../status_service/download_file.dart';
import '../status_service/share_file.dart';

class VideoScreen extends StatefulWidget {
  final List<StatusModel>? savedStatuses;

  const VideoScreen({this.savedStatuses, super.key});


  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  List<StatusModel> videos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    await requestPermissions();

    if (widget.savedStatuses != null) {
      videos = widget.savedStatuses!.where((s) => s.isVideo).toList();
      loading = false;
      setState(() {});
      return;
    }

    final statuses = await Status().fetchStatuses();
    videos = statuses.where((s) => s.isVideo).toList();
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
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    if (loading) {
      return const Center(child: CircularProgressIndicator(color: kPrimary));
    }

    if (videos.isEmpty) {
      return Center(child: Text("No video statuses found"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.6,
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final item = videos[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(status: item, savedStatus: widget.savedStatuses,),
              ),
            );
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
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.black,
                            child: Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  (widget.savedStatuses != null && widget.savedStatuses!.isNotEmpty) ?                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: kPaddingS),
                        child: IconButton(
                          onPressed: () {
                            ShareFile().share(item.filePath);
                          },
                          icon: Icon(Icons.share, size: 20),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: kPaddingS),
                        child: IconButton(
                          onPressed: () async {
                            print("Saved btn clicked");
                            bool isSaved = await DownloadFile()
                                .saveFilesToGallery(item);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isSaved
                                      ? "Video Saved!"
                                      : "Failed to Save Video",
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.save_alt_outlined, size: 20),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: kPaddingS),
                        child: IconButton(
                          onPressed: () async {
                           await _showDeleteConfirmation(item, index);
                          },
                          icon: Icon(Icons.delete, size: 20),
                        ),
                      ),
                    ],
                  ) : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: kPaddingS),
                        child: IconButton(
                          onPressed: () {
                            ShareFile().share(item.filePath);
                          },
                          icon: Icon(Icons.share, size: 20),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: kPaddingS),
                        child: IconButton(
                          onPressed: () async {
                            print("Saved btn clicked");
                            bool isSaved = await DownloadFile()
                                .saveFilesToGallery(item);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isSaved
                                      ? "Video Saved!"
                                      : "Failed to Save Video",
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.save_alt_outlined, size: 20),
                        ),
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
            child: const Text('Cancel', style: TextStyle(color: kPrimary),),
          ),
          TextButton(
            onPressed: () async {
              bool deleted = await DeleteSavedStatus().deleteStatus(item);

              if (deleted) {
                setState(() {
                  videos.removeAt(index);
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
