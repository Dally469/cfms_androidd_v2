import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberCard extends StatelessWidget {
  final String name;
  final String phone;
  final String church;
  final Color backgroundColor;
  final String photo;
  const MemberCard({
    Key? key,
    required this.name,
    required this.phone,
    required this.church,
    this.backgroundColor = whiteColor,
    required this.photo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: transparentColor, width: 3),
                  image: DecorationImage(image: AssetImage(photo)))),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translate('app_txt_phone'),
                        style: GoogleFonts.poppins(
                            color: blackColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 12),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 0),
                        child: Text(
                          phone,
                          style: GoogleFonts.poppins(
                              color: blackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translate('app_txt_church'),
                        style: GoogleFonts.poppins(
                            color: blackColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 12),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 0),
                        child: Text(
                          church,
                          style: GoogleFonts.poppins(
                              color: blackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 2,
          )
        ],
      ),
    );
  }
}
