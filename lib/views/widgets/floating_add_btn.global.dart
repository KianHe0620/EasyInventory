import 'package:easyinventory/views/utils/global.colors.dart';
import 'package:flutter/material.dart';

class FloatingAddBtn extends StatelessWidget {
  const FloatingAddBtn({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: GlobalColors.mainColor,
      child: Icon(
        Icons.add,
        size: 28,
        color: Colors.white,
        ),
    );
  }
}