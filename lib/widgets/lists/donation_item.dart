import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';

class DonationItem extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double height;
  final String title;
  final String narration;
  final String amount;
  final String currency;
  final Function()? onTap;

  const DonationItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.amount,
    this.iconColor = primaryOverlayColor,
    this.backgroundColor = whiteColor,
    this.height = 90,
    this.onTap,
    required this.narration,
    required this.currency,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: narration != "",
                                child: Text(
                                  narration,
                                  style: GoogleFonts.poppins(
                                      color: Colors.lightGreen,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10),
                                ),
                              ),
                              Visibility(
                                visible: amount == "",
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width - 185,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                      "+ ${translate("app_txt_click_to_add_amount")}",
                                      style: GoogleFonts.poppins(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                            width: 140,
                            padding: const EdgeInsets.all(8.0),
                            child: Visibility(
                              visible: amount != "",
                              child: Text(
                                "$currency $amount",
                                textAlign: TextAlign.end,
                                style: GoogleFonts.poppins(
                                    color: blackColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15),
                              ),
                            ))
                      ],
                    )
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
