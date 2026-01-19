import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget{
  const GlobalAppBar({super.key, required this.title, this.rightIconBtn, this.onRightButtonPressed});

  final String title;
  final IconData? rightIconBtn;
  final VoidCallback? onRightButtonPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Get.back(), 
        icon: const Icon(Icons.arrow_back)
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25
        ),
      ),
      actions: [
        if (rightIconBtn != null)
        IconButton(
          onPressed: onRightButtonPressed, 
          icon: Icon(rightIconBtn))
      ],
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}