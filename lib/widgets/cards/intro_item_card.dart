import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPage extends StatefulWidget {
  final Image image;
  final Color backgroundColor;
  final String title;
  final String desc;
  const IntroPage({
    Key? key,
    required this.image,
    required this.backgroundColor,
    required this.title,
    required this.desc,
  }) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            height: 250,
            child: widget.image,
          ),
          Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 3, horizontal: 02),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 30),
              )),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                widget.desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: blackColor,
                    fontWeight: FontWeight.w300,
                    fontSize: 14),
              ),
            ),
          ),
          //
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 85, vertical: 10),
          //   padding: EdgeInsets.symmetric(vertical: 7),
          //   decoration: BoxDecoration(
          //       color:  appColor7,
          //       border: Border.all(width: 1, color:  appColor7),
          //       borderRadius: BorderRadius.circular(25)),
          //   child: Center(
          //     child: Padding(
          //       padding:
          //       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //       child: Text(widget.btnTitle,
          //           style: GoogleFonts.poppins(
          //               fontSize: 12,
          //               fontWeight: FontWeight.w400,
          //               color: appColor0)),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
