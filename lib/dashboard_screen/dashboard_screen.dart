import 'package:flutter/material.dart';
import 'package:whatsapp_status_saver_app/constants/constants.dart';

import '../navigation_screens/saved_screen.dart';
import '../navigation_screens/status_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    StatusScreen(),
    SavedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: Text("Status App", style: TextStyle(color: kWhite)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.call_outlined),
            color: kWhite,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.send_sharp),
            color: kWhite,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings),
            color: kWhite,
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.call_outlined),
            label: "Status",
            //title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_outlined),
            label: "Saved",
            //title: Text('Download'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimary,
        unselectedItemColor: kGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}
