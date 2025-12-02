import 'package:flutter/material.dart';

class FloatingAddBtn extends StatelessWidget {
  const FloatingAddBtn({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF0A84D0),
      child: Icon(
        Icons.add,
        size: 28,
        color: Colors.white,
        ),
    );
  }
}