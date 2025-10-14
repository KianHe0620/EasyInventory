import 'package:easyinventory/controllers/item.controller.dart';
import 'package:easyinventory/controllers/sell.controller.dart';
import 'package:easyinventory/views/dashboard.dart';
import 'package:easyinventory/views/items/items.dart';
import 'package:easyinventory/views/sell/sell.dart';
import 'package:easyinventory/views/settings/settings.dart';
import 'package:easyinventory/views/widgets/bottom_navigation_bar.global.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final ItemController itemController;
  late final SellController sellController;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    itemController = ItemController();
    sellController = SellController(itemController: itemController);

    _pages = [
      DashboardPage(itemController: itemController, sellController: sellController),
      ItemsPage(itemController: itemController, sellController: sellController),
      SellPage(itemController: itemController, sellController: sellController,),
      const SettingsPage(),
    ];
  }

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
