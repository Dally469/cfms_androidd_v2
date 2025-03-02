import 'dart:convert';

import 'package:cfms/models/members/member.dart';
import 'package:cfms/screens/member/payments/quick_payment_confirm.dart';

import 'package:cfms/widgets/buttons/state_button.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../utils/colors.dart';
import '../../widgets/texts/heading.dart';

class QuickPaymentMethod extends StatefulWidget {
  final String totalAmount;
  final String date;
  final String userId;
  final String userPhone;
  final String countryCurrency;

  const QuickPaymentMethod(
      {Key? key,
        required this.totalAmount,
        required this.date,
        required this.userId,
        required this.userPhone,
        required this.countryCurrency,
        }) : super(key: key);

  @override
  State<QuickPaymentMethod> createState() => _QuickPaymentMethodState();
}

class _QuickPaymentMethodState extends State<QuickPaymentMethod> {
  int id = 1;
  String? currentMemberPhone;
  late Data member;

  _loadMemberData() async {
    final prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("current_member") ?? '';
    String newJson = json.replaceAll('[', '');
    String newJson1 = newJson.replaceAll(']', '');
    if (newJson1 == null) {
      if (kDebugMode) {
        print('No dATA');
      }
    } else {
      Map<String, dynamic> map = jsonDecode(newJson1);
      member = Data.fromJson(map);
      currentMemberPhone = member.phone;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          leading: InkWell(
              onTap: () {
                Navigator.of(context).pop(true);
              },
              child: const Icon(
                Icons.arrow_back,
                color: primaryColor,
              )),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Heading(
                    title: translate("app_txt_quick_payment"),
                    subtitle: translate("app_txt_choose_payment")),
                Column(
                  children: [
                    Text(
                      translate("app_txt_tot_amount"),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: primaryOverlayColor,
                          fontWeight: FontWeight.w300),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30),
                      child: Text(
                        "${widget.countryCurrency} ${widget.totalAmount}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: greenColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 35),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: greenOverlayColor,
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  id = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  border: Border.all(
                                      width: 1,
                                      color: id == 1 ? greenColor : whiteColor),
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
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Image.asset(
                                      "assets/images/logo/momo.png",
                                      height: 40,
                                      width: 40,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        id == 1
                                            ? Container(
                                          height: 20,
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: greenColor),
                                          child: const Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 60 / 4,
                                              color: whiteColor,
                                            ),
                                          ),
                                        )
                                            : Radio(
                                          value: 1,
                                          groupValue: id,
                                          activeColor: greenColor,
                                          onChanged: (val) {
                                            setState(() {
                                              id = 1;
                                              print("Momo selected");
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              translate("app_txt_momo_payment"),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                  color: blackColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  id = 3;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  border: Border.all(
                                      width: 1,
                                      color: id == 3 ? greenColor : whiteColor),
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
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Image.asset(
                                      "assets/images/logo/cheque.png",
                                      height: 40,
                                      width: 40,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        id == 3
                                            ? Container(
                                          height: 20,
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.all(1),
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: greenColor),
                                          child: const Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 60 / 4,
                                              color: whiteColor,
                                            ),
                                          ),
                                        )
                                            : Radio(
                                          value: 3,
                                          groupValue: id,
                                          activeColor: greenColor,
                                          onChanged: (val) {
                                            setState(() {
                                              id = 3;
                                              if (kDebugMode) {
                                                print("bANK selected");
                                              }
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              translate("app_txt_bank_payment"),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                  color: blackColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (kDebugMode) {
                      print("CLICKED");
                    }
                    Navigator.push(context, MyPageRoute(
                        widget: QuickConfirmPayment(
                          methodId: id,
                          totalAmount: widget.totalAmount,
                          countryCurrency: widget.countryCurrency,
                          date: widget.date,
                          userPhone: widget.userPhone,
                          userId: widget.userId,
                        )));
                  },
                  child: StateButton(
                      icon: Icons.arrow_forward,
                      backgroundColor: primaryColor,
                      width: 200,
                      title: translate("app_txt_continue")),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo/logo.png",
              scale: 2,
              height: 50,
              color: primaryOverlayColor,
              width: 50,
            ),
          ],
        ),
      ),
    );
  }
}