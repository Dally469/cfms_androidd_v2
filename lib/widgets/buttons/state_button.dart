import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StateButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double height;
  final double width;
  final String title;
   StateButton({
    Key? key,
    required this.icon,
    required this.backgroundColor,
    required this.width,
    required this.title,
    this.iconColor = whiteColor,
    this.height = 45,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 5),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), color: backgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
                color: whiteColor, fontWeight: FontWeight.w400, fontSize: 12),
          ),
          SizedBox(
            width: 5,
          ),
          Icon(
            icon,
            color: iconColor,
            size: height / 2,
          ),
        ],
      ),
    );
  }
}
