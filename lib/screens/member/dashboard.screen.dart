import 'dart:convert';

import 'package:cfms/models/summary_offering_model.dart';
import 'package:cfms/screens/member/donation_history.dart';
import 'package:cfms/screens/member/select_church.dart';
import 'package:cfms/screens/member/settings.dart';
import 'package:cfms/services/api/http_services.dart';

import 'package:cfms/widgets/cards/dashboard_card.dart';
import 'package:cfms/widgets/cards/member_card.dart';
import 'package:cfms/widgets/cards/member_card_loading.dart';
import 'package:cfms/widgets/cards/payment_card_loading.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/members/member.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Data user;
  bool _isClicked = false;
  bool isLoading = true;
  bool _isLoadingData = true;

  HttpService httpService = HttpService();
  late String countryCodeUrl;
  String countryCurrency = '';
  bool isBackButtonActivated = false;
  String? currentName, currentPhone, currentCode, currentChurch, currentId;
 
  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'current_member';
    String json = prefs.getString(key) ?? '';
    String url = prefs.getString('countryCode') ?? '';
    String currency = prefs.getString('countryCurrency') ?? '';

    if (kDebugMode) {
      print(json);
    }
    // String newJson = json.replaceAll('[', '');
    // String newJson1 = newJson.replaceAll(']', '');
    Map<String, dynamic> map = jsonDecode(json);
    user = Data.fromJson(map);
    setState(() {
      currentName = user.names;
      currentPhone = user.phone;
      currentCode = user.code;
      currentChurch = user.cHURCH;
      currentId = user.id;
      countryCodeUrl = url;
      countryCurrency = currency;
      isLoading = false;
    });
  }

  var listSummary = <SummaryModel>[];

  @override
  void initState() {
    super.initState();
    _loadData();
    user = Data();
  }

  didPopRoute() {
    bool override;
    if (isBackButtonActivated) {
      override = true;
    } else {
      override = true;
    }
    return Future<bool>.value(override);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: whiteColor,
            elevation: 0,
            title: Text(translate('app_txt_dashboard'),
                style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            actions: [
              InkWell(
                  onTap: () {
                    Navigator.push(
                        context, MyPageRoute(widget: const Settings()));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(
                      Icons.settings,
                      color: primaryColor,
                    ),
                  ))
            ],
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                isLoading
                    ? const MemberCardLoading()
                    : MemberCard(
                        name: currentName.toString(),
                        phone: currentPhone.toString(),
                        church: currentChurch.toString(),
                        photo: "assets/images/logo/hhh.png"),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context, MyPageRoute(widget: const SelectChurch()));
                      },
                      child: DashboardCard(
                        icon: "assets/images/logo/offering.png",
                        backgroundColor: whiteColor,
                        title: translate('app_txt_new_donation'),
                        btnTitle: translate('app_txt_add_new'),
                        desc: translate('app_txt_church_donation'),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: whiteColor,
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Text(
                                    translate('app_txt_history'),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17),
                                  )),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MyPageRoute(
                                          widget: HistoryDonation(
                                        memberCode: currentId.toString(),
                                        countryCode: countryCodeUrl,
                                        countryCurrency: countryCurrency,
                                      )));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: whiteColor,
                                      border: Border.all(
                                          width: 2, color: primaryOverlayColor),
                                      borderRadius: BorderRadius.circular(18)),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      child: Text(translate('app_txt_view_all'),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  decoration: const BoxDecoration(
                                    color: transparentColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                      child: Image.asset(
                                    "assets/images/logo/history.png",
                                    height: 50,
                                    width: 50,
                                  ))),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 210,
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 1),
                                        child: Text(
                                          translate('app_txt_view_summary'),
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.poppins(
                                              color: blackColor,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 11),
                                        )),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                     final prefs = await SharedPreferences.getInstance();
                                      _isClicked
                                          ? setState(() {
                                              _isClicked = false;
                                            })
                                          : setState(() {
                                              _isClicked = true;

                                              httpService
                                                  .getPublicData(countryCodeUrl,
                                                      'v3/getTotalByOfferingId/$currentId?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}')
                                                  .then((response) {
                                                setState(() {
                                                  Iterable list = json
                                                      .decode(response.body);
                                                  listSummary = list
                                                      .map((model) =>
                                                          SummaryModel.fromJson(
                                                              model))
                                                      .toList();

                                                  setState(() {
                                                    _isLoadingData = false;
                                                  });

                                                  // print(list);
                                                });
                                              });
                                            });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(
                                        _isClicked
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        size: 30,
                                        color: blackColor,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Visibility(
                            visible: _isClicked,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Text(
                                      translate('app_txt_list_summary'),
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.poppins(
                                          color: blackColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12),
                                    )),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  height: 100,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: transparentColor,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: _isLoadingData
                                      ? ListView.builder(
                                          itemCount: 4,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, pos) {
                                            return const PaymentCardLoading();
                                          })
                                      : listSummary.isEmpty
                                          ? Center(
                                              child: Column(
                                                children: [
                                                  Image.asset(
                                                    "assets/images/logo/no_result.png",
                                                    height: 60,
                                                    width: 60,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      translate(
                                                          "app_txt_no_data_found"),
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: redColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: listSummary.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  width: 110,
                                                  height: 90,
                                                  margin:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: whiteColor1,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 11.0,
                                                                      right: 2,
                                                                      bottom:
                                                                          3),
                                                              child: Text(
                                                                countryCurrency,
                                                                style: GoogleFonts.poppins(
                                                                    color:
                                                                        primaryColor,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 7.0,
                                                                      bottom:
                                                                          3),
                                                              child: Text(
                                                                listSummary[
                                                                        index]
                                                                    .total
                                                                    .toString(),
                                                                style: GoogleFonts.poppins(
                                                                    color:
                                                                        primaryColor,
                                                                    fontSize:
                                                                        19,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          listSummary[index]
                                                              .offering
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color:
                                                                      blackColor,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
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
      ),
    );
  }
}
