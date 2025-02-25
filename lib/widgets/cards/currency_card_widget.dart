import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrencyCard extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String id;
  final String selectedId;
  final Function() onTap;
  const CurrencyCard({
    Key? key,
    required this.title,
    required this.id,
    required this.selectedId,
    this.backgroundColor = whiteColor, required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:  onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: id == selectedId ? Border.all(width: 2, color: primaryColor) : Border.all(width: 0, color: whiteColor1),
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0.0, 5.0),
              color: Color(0xffEDEDED),
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                    color: blackColor, fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
