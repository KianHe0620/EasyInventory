import 'package:flutter/material.dart';
import '../../controllers/item.controller.dart';

class BtmNavigationBar extends StatelessWidget {
  const BtmNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.itemController, // pass controller from parent
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final ItemController itemController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: itemController,
      builder: (context, _) {
        final hasLowStock = itemController.items.any(
          (item) => item.quantity <= item.minQuantity,
        );

        return NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: const Color(0xFFF2F2F2),
          indicatorColor: const Color(0xFFE0E0E0),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Stack(
                children: [
                  const Icon(Icons.inventory_2_outlined),
                  if (hasLowStock)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              selectedIcon: Stack(
                children: [
                  const Icon(Icons.inventory_2),
                  if (hasLowStock)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Items',
            ),
            const NavigationDestination(
              icon: Icon(Icons.sell_outlined),
              selectedIcon: Icon(Icons.sell),
              label: 'Sell',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      },
    );
  }
}

