import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';

class BoldAppIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  const BoldAppIcon({
    Key? key,
    required this.icon,
    this.backgroundColor = whiteColor1,
    this.iconColor = primaryColor,
    this.size = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.all(size / 3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size),
          color: backgroundColor),
      child: Icon(
        icon,
        color: iconColor,

      ),
    );
  }
}