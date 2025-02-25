import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StateOutlinedButton extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final bool clicked;
  StateOutlinedButton({
    Key? key,
    required this.backgroundColor,
    required this.title,
    required this.clicked
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: clicked ? primaryOverlayColor : backgroundColor),
          color:  clicked ? primaryColor : whiteColor,
          borderRadius: BorderRadius.circular(30),),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
                color:  clicked ? whiteColor : backgroundColor, fontWeight: FontWeight.w400, fontSize: 13),
          ),

        ],
      ),
    );
  }
}
