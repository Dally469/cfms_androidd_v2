import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChurchItem extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double height;
  final String title;
  final String code;
  final Function()? onTap;

  const ChurchItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.code,
    this.iconColor = primaryOverlayColor,
    this.backgroundColor = whiteColor,
    this.height = 70, this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0.0, 5.0),
              color: Color(0xffEDEDED),
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            color: blackColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 185,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 1.0, vertical: 5),
                          child: Text(
                            code,
                            style: GoogleFonts.poppins(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontSize: 10),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
