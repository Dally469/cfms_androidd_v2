import 'dart:async';

import 'package:cfms/screens/select.language.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MyPageRoute(widget: const SelectLanguage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/icons/logo.png",
                width: 180,
                height: 180,
                color: whiteColor,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 90),
                child: Text(
                  "Church Financial Management System",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w500,
                      color: whiteColor,
                      fontSize: 25),
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          bottom: 60,
          left: 80,
          right: 80,
          child: Center(
            child: SpinKitDoubleBounce(
              color: orangeColor,
            ),
          ),
        ),
      ]),
    );
  }
}
