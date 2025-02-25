import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OfferingPaymentItem extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double height;
  final String title;
  final String currency;
  final String amount;
  const OfferingPaymentItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.currency,
    this.iconColor = primaryOverlayColor,
    this.backgroundColor = whiteColor,
    this.height = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(6),
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          new BoxShadow(
            offset: Offset(0.0, 5.0),
            color: Color(0xffEDEDED),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: height / 2,
                ),
                SizedBox(
                  width: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                              color: blackColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 13),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 5),
                          child: Row(
                            children: [
                              Text(
                                currency,
                                style: GoogleFonts.poppins(
                                    color: blackColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12),
                              ),
                              SizedBox(width: 4,),
                              Text(
                                amount,
                                style: GoogleFonts.poppins(
                                    color: blackColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
