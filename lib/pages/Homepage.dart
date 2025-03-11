import 'package:flutter/material.dart';
import 'package:medicinedocter/pages/Med.dart';
import 'package:medicinedocter/pages/notiPage.dart';
import 'package:medicinedocter/pages/timeForm.dart';
import 'alarm.dart';
import 'camera.dart';
import 'search.dart';
import 'setting.dart';
import 'listMed.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

int _selectedIndex = 0;

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget> _pageWidget = <Widget>[
     Meds(),
     CameraScreen(),
     
     notiPage(),
     settingPage()
     
  ];

  final List<BottomNavigationBarItem> _menuBar = <BottomNavigationBarItem>[
    
    BottomNavigationBarItem(
      
      icon: Icon(Icons.add),
      label: 'Add',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.camera_alt_outlined),
      label: 'Camera',
    ),
   
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications),
      label: 'Notification',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Setting',
    ),
    
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageWidget.elementAt(_selectedIndex),
      
      bottomNavigationBar: BottomNavigationBar(
        items: _menuBar,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
