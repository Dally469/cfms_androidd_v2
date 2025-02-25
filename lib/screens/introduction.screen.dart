// ignore_for_file: use_build_context_synchronously

import 'package:cfms/widgets/cards/intro_item_card.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'login.screen.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController controller = PageController();
  bool isLastPage = false;
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 3;
              });
            },
            children: [
              IntroPage(
                  image: Image.asset(
                    "assets/images/logo/logo.png",
                    scale: 3,
                  ),
                  backgroundColor: transparentColor,
                  title: translate('app_txt_title'),
                  desc: translate('app_txt_subtitle')),
              IntroPage(
                  image: Image.asset(
                    "assets/images/logo/members.png",
                    scale: 3,
                  ),
                  backgroundColor: transparentColor,
                  title: translate('app_txt_title1'),
                  desc: translate('app_txt_subtitle1')),
              IntroPage(
                  image: Image.asset(
                    "assets/images/logo/offering.png",
                    scale: 3,
                  ),
                  backgroundColor: transparentColor,
                  title: translate('app_txt_title2'),
                  desc: translate('app_txt_subtitle2')),
              IntroPage(
                  image: Image.asset(
                    "assets/images/logo/history.png",
                    scale: 3,
                  ),
                  backgroundColor: transparentColor,
                  title: translate('app_txt_title3'),
                  desc: translate('app_txt_subtitle3')),
            ],
          ),
          Container(
            alignment: Alignment(0, isLastPage ? 0.9 : 1),
            child: isLastPage
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: transparentColor,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: TextButton(
                            onPressed: () async {
                                final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('showHome', true);
                              Navigator.push(
                                  context, MyPageRoute(widget: const Login()));
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: primaryColor,
                              minimumSize: const Size(170, 40),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              child: Text(translate('app_txt_get_started'),
                                  style: GoogleFonts.poppins(
                                      color: whiteColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 19)),
                            )),
                      ),
                    ],
                  )
                : Container(
                    color: transparentColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () async {
                                final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('showHome', true);
                              Navigator.push(
                                  context, MyPageRoute(widget: const Login()));
                            },
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.resolveWith(
                                        (state) => Colors.orange)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              child: Text(translate('app_txt_skip'),
                                  style: GoogleFonts.poppins(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15)),
                            )),
                        Center(
                          child: SmoothPageIndicator(
                            controller: controller,
                            count: 4,
                            effect: const WormEffect(
                                spacing: 10,
                                dotColor: primaryOverlayColor,
                                activeDotColor: primaryColor,
                                dotHeight: 10,
                                dotWidth: 10),
                            onDotClicked: (index) => controller.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut),
                          ),
                        ),
                        TextButton(
                            onPressed: () => controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              child: Row(
                                children: [
                                  Text(translate('app_txt_next'),
                                      style: GoogleFonts.poppins(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15)),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: primaryColor,
                                    size: 20,
                                  )
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
