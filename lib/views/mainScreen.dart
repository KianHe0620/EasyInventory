import 'package:flutter/material.dart';
import 'package:easyinventory/controllers/item.controller.dart';
import 'package:easyinventory/controllers/sell.controller.dart';
import 'package:easyinventory/controllers/settings.controller.dart';
import 'package:easyinventory/controllers/authentication.controller.dart';
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

  late final AuthController authController;
  late final ItemController itemController;
  late final SellController sellController;
  late final SettingsController settingsController;

  // Make pages lazy (build after controllers are ready)
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // init controllers in the correct order
    authController = AuthController();
    itemController = ItemController();
    sellController = SellController(itemController: itemController);
    settingsController = SettingsController(authController: authController);

    // now that controllers exist, create pages
    _pages = [
      DashboardPage(itemController: itemController, sellController: sellController),
      ItemsPage(itemController: itemController, sellController: sellController),
      SellPage(itemController: itemController, sellController: sellController),
      SettingsPage(settingsController: settingsController),
    ];
  }

  @override
  void dispose() {
    // dispose controllers that are ChangeNotifiers if they need disposing
    itemController.dispose();
    sellController.dispose();
    settingsController.dispose();
    // authController does not hold streams by default; dispose if you added listeners
    super.dispose();
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
