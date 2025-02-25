import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickPayItem extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double height;
  final String title;
  final String narration;
  final String amount;
  final String currency;
  final Function()? onTap;

  const QuickPayItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.currency,
    this.iconColor = primaryOverlayColor,
    this.backgroundColor = whiteColor,
    this.height = 70,
    this.onTap,
    required this.narration,
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
                  width: 2,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: blackColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 13),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 150,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 1.0, vertical: 5),
                      child: Text(
                        narration,
                        style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontSize: 10),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 100,
                  padding: const EdgeInsets.all(8.0),
                  child: amount != ""
                      ? Text(
                          "$currency $amount",
                          textAlign: TextAlign.end,
                          style: GoogleFonts.poppins(
                              color: blackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 15),
                        )
                      : const Text(""),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
