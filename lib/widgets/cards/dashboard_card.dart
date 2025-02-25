// ignore_for_file: sized_box_for_whitespace

import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardCard extends StatelessWidget {
  final String icon;
  final Color backgroundColor;
  final Color iconColor;
  final String title;
  final String btnTitle;
  final String desc;
  const DashboardCard({
    Key? key,
    required this.icon,
    required this.backgroundColor,
    required this.title,
    required this.btnTitle,
    required this.desc,
    this.iconColor = whiteColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0.0, 5.0),
            color: Color(0xffEDEDED),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 17),
                  )),
              InkWell(
                splashFactory: NoSplash.splashFactory,
                child: Container(
                  decoration: BoxDecoration(
                      color: whiteColor,
                      border: Border.all(width: 2, color: primaryOverlayColor),
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Text(btnTitle,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: blackColor)),
                    ),
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: const BoxDecoration(
                  color: transparentColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(icon, height: 50, width: 50,),
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            desc,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 13),
                          )),
                          Container(
                            width: 240,
                            child: Padding(
                            padding:
                                const EdgeInsets.symmetric( horizontal: 10, vertical: 1),
                            child: Text(
                              translate('app_txt_help_desc'),
                              textAlign: TextAlign.left,

                              style: GoogleFonts.poppins(
                                  color: blackColor,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 11),
                            )),
                          ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
