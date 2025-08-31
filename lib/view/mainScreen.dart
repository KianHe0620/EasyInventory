import 'package:easyinventory/view/dashboard.dart';
import 'package:easyinventory/view/items/items.dart';
import 'package:easyinventory/view/sell/sell.dart';
import 'package:easyinventory/view/settings/settings.dart';
import 'package:easyinventory/view/widgets/bottomNavigationBar.global.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ItemsPage(),
    SellPage(),
    SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BtmNavigationBar(
        selectedIndex: _currentIndex, 
        onDestinationSelected: (index){
          setState(() {
            _currentIndex = index;
          });
        }
      ),
    );
  }
}