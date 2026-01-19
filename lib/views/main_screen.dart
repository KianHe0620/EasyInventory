import 'package:flutter/material.dart';
import 'package:easyinventory/views/dashboard.dart';
import 'package:easyinventory/views/items/items.dart';
import 'package:easyinventory/views/sell/sell.dart';
import 'package:easyinventory/views/settings/settings.view.dart';
import 'package:easyinventory/views/widgets/bottom_navigation_bar.global.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    ItemsPage(),
    SellPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BtmNavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
