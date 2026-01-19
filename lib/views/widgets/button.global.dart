import 'package:flutter/material.dart';

class ButtonGlobal extends StatelessWidget {
  const ButtonGlobal({super.key, required this.boxColor, required this.text, required this.textColor, required this.width, required this.onTap});
  final Color boxColor;
  final String text;
  final Color textColor;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 30,
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(12),
          border: width > 0 //Set the border of button
          ?Border.all(color: const Color(0xFFF2F2F2), width: width)
          : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
    );
  }
}