import 'package:flutter/material.dart';
import 'package:whatsapp_status_saver_app/tab_screens/image_screen.dart';
import 'package:whatsapp_status_saver_app/tab_screens/video_screen.dart';

import '../constants/constants.dart';
import '../model_classes/status_model.dart';

class TabBarScreen extends StatelessWidget {

  final List<StatusModel>? savedStatuses;

  const TabBarScreen({this.savedStatuses, super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: kPrimary,
            unselectedLabelColor: kBlack,
            indicatorColor: kPrimary,
            tabs: [
              Tab(text: "Images"),
              Tab(text: "Videos"),
            ],
          ),
          Expanded(child: TabBarView(children: [ImageScreen(savedStatuses: savedStatuses), VideoScreen(savedStatuses: savedStatuses)])),
        ],
      ),
    );
  }
}
