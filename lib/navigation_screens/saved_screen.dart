import 'package:flutter/material.dart';
import 'package:whatsapp_status_saver_app/status_service/save_status.dart';

import '../model_classes/status_model.dart';
import '../tab_screens/tab_bar.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<StatusModel> savedStatuses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSaved();
  }

  Future<void> loadSaved() async {
    savedStatuses = await SaveStatus().fetchSavedStatuses();
    print("Fetched saved statuses: ${savedStatuses.length}");
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());

    return TabBarScreen(savedStatuses: savedStatuses);
  }
}

