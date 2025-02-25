// ignore_for_file: non_constant_identifier_names

import 'package:cfms/utils/colors.dart';
 import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SummaryCardItem extends StatelessWidget {
  final String offerings;
  final String? tot_dollar;
  final String? tot_fc;
  const SummaryCardItem({
    Key? key,
    required this.offerings,
    this.tot_dollar,
    this.tot_fc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: whiteColor1,
        border: Border.all(width: 1, color: greyColor1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Text(
                  offerings.toString(),
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              )),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total en dollars",
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          tot_dollar.toString(),
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total en Fc",
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          tot_fc.toString(),
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
        ],
      ),
    );
  }
}
