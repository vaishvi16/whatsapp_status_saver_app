import 'package:flutter/material.dart';
import 'package:whatsapp_status_saver_app/tab_screens/tab_bar.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    return TabBarScreen();
  }
}
