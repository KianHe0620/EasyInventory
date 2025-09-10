import 'package:easyinventory/views/utils/global.colors.dart';
import 'package:flutter/material.dart';

class BtmNavigationBar extends StatelessWidget {
  const BtmNavigationBar({super.key, required this.selectedIndex, required this.onDestinationSelected});

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: GlobalColors.textFieldColor,
      indicatorColor: const Color(0xFFE0E0E0),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined), 
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard'
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined), 
          selectedIcon: Icon(Icons.inventory_2),
          label: 'Items'
        ),
        NavigationDestination(
          icon: Icon(Icons.sell_outlined), 
          selectedIcon: Icon(Icons.sell),
          label: 'Sell'
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined), 
          selectedIcon: Icon(Icons.settings),
          label: 'Settings'
        ),
      ],
    );
  }
}