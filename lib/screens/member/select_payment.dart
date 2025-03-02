// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:cfms/models/members/member.dart';
import 'package:cfms/screens/member/payments/confirmation.dart';
import 'package:cfms/widgets/buttons/state_button.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';
import '../../widgets/texts/heading.dart';

class Payment extends StatefulWidget {
  final double totalAmount;
  final String donationList;
  final String churchCode;
  final String churchName;
  final String countryCurrency;
  final String countryCode;
  final String memberName;
  final String memberPhone;

  const Payment(
      {Key? key,
        required this.totalAmount,
        required this.donationList,
        required this.churchCode,
        required this.churchName,
        required this.countryCurrency, required this.memberName, required this.memberPhone, required this.countryCode})
      : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
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
    if (kDebugMode) {
      print('Country code: ${widget.countryCode}');
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
                    title: translate("app_txt_payment"),
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
                        "${widget.countryCurrency} ${widget.totalAmount.toStringAsFixed(0)}",
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
                          paymentWidget(1, translate("app_txt_momo_payment"), "assets/images/logo/momo.png"),
                          paymentWidget(2, translate("app_txt_card_payment"), "assets/images/logo/card.png"),
                        ],
                      ),
                      Row(
                        children: [
                          paymentWidget(3, translate("app_txt_bank_payment"), "assets/images/logo/cheque.png"),
                          paymentWidget(4, widget.countryCode=="ug"?"FlexiPay": translate("app_txt_other_payment"), widget.countryCode=="ug"?"assets/images/logo/flexipay.png":"assets/images/logo/other.png"),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MyPageRoute(
                            widget: ConfirmPayment(
                              methodId: id,
                              currency: widget.countryCurrency,
                              totalAmount: widget.totalAmount,
                              donationList: widget.donationList,
                              churchCode: widget.churchCode,
                              churchName: widget.churchName, memberName: widget.memberName, memberPhone: widget.memberPhone, countryCode: widget.countryCode,
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

  Widget paymentWidget(int widgetId, String title, String icon){
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          setState(() {
            id = widgetId;
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
                color: id == widgetId ? greenColor : whiteColor),
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
                icon,
                height: 40,
                width: 40,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  id == widgetId
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
                    value: widgetId,
                    groupValue: id,
                    activeColor: greenColor,
                    onChanged: (val) {
                      setState(() {
                        id = widgetId;
                        if (kDebugMode) {
                          print("Momo selected");
                        }
                      });
                    },
                  ),
                  SizedBox(
                    width: 120,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        title,
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
    );
  }
}