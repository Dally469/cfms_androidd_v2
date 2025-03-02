// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cfms/models/members/member.dart';
import 'package:cfms/services/db/db_helper.dart';

import 'package:cfms/widgets/cards/item_setting_row.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/admin.dashboard.screen.dart';
import '../login.screen.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String date = "";
  final format = NumberFormat("#,##0.00", "en_US");
  String? lang;
  int id = 1;
  bool isSelected = false;
  bool _isClicked = false;
  bool isLang = false;
  bool isLoggedIn = false;
  String? logger, loggerPhone;
  late Data user;
  bool showProduct = false;
  bool showCashInOut = false;
  final DbHelper _dbHelper = DbHelper();
  String? currentName, currentPhone, currentCode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting();
    date = DateFormat("EEEE dd-mm-yyyy", "en").format(DateTime.now());
    getLang();
    user = Data();
    _loadMemberData();
  }

  _loadMemberData() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'current_member';
    String json = prefs.getString(key) ?? '';

    String newJson = json.replaceAll('[', '');
    String newJson1 = newJson.replaceAll(']', '');
    if (newJson1 == null) {
      print('No dATA');
    } else {
      Map<String, dynamic> map = jsonDecode(newJson1);
      user = Data.fromJson(map);
      setState(() {
        currentName = user.names;
        currentPhone = user.phone;
        currentCode = user.code;
      });
    }
  }

  getLang() async {
    final prefs = await SharedPreferences.getInstance();
    lang = prefs.getString('currentLang');
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return lang;
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              translate("app_txt_app_change"),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 17, color: primaryColor),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              height: 240,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        id = 1;
                        changeLocale(context, "en");

                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0.0, 2.0),
                            color: Color(0xffEDEDED),
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/icons/eng.png",
                                height: 25,
                                width: 25,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                translate('app_txt_english'),
                                style: GoogleFonts.poppins(
                                    color: blackColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 15),
                              )
                            ],
                          ),
                          id == 1
                              ? Container(
                                  height: 30,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: whiteColor,
                                    ),
                                  ),
                                )
                              : Radio(
                                  value: 1,
                                  groupValue: id,
                                  activeColor: primaryColor,
                                  onChanged: (val) {
                                    setState(() {
                                      id = 1;
                                      changeLocale(context, "en");

                                      Navigator.pop(context);
                                    });
                                  },
                                )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        id = 4;
                        changeLocale(context, "fr");

                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0.0, 2.0),
                            color: Color(0xffEDEDED),
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/icons/fr.png",
                                height: 25,
                                width: 25,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                translate('app_txt_french'),
                                style: GoogleFonts.poppins(
                                    color: blackColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 15),
                              )
                            ],
                          ),
                          id == 4
                              ? Container(
                                  height: 30,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: whiteColor,
                                    ),
                                  ),
                                )
                              : Radio(
                                  value: 4,
                                  groupValue: id,
                                  activeColor: primaryColor,
                                  onChanged: (val) {
                                    setState(() {
                                      id = 4;
                                      changeLocale(context, "fr");

                                      Navigator.pop(context);
                                    });
                                  },
                                )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        id = 2;
                        changeLocale(context, "sw");

                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0.0, 2.0),
                            color: Color(0xffEDEDED),
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/icons/swa.png",
                                height: 25,
                                width: 25,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                translate("app_txt_swahili"),
                                style: GoogleFonts.poppins(
                                    color: blackColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 15),
                              )
                            ],
                          ),
                          id == 2
                              ? Container(
                                  height: 30,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: whiteColor,
                                    ),
                                  ),
                                )
                              : Radio(
                                  value: 2,
                                  groupValue: id,
                                  activeColor: primaryColor,
                                  onChanged: (val) {
                                    setState(() {
                                      id = 2;
                                      changeLocale(context, "sw");

                                      Navigator.pop(context);
                                    });
                                  },
                                )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        id = 3;
                        changeLocale(context, "rw");

                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0.0, 2.0),
                            color: Color(0xffEDEDED),
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/icons/rw_flag.png",
                                height: 25,
                                width: 25,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                translate("app_txt_rwanda"),
                                style: GoogleFonts.poppins(
                                    color: blackColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 15),
                              )
                            ],
                          ),
                          id == 3
                              ? Container(
                                  height: 30,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: whiteColor,
                                    ),
                                  ),
                                )
                              : Radio(
                                  value: 3,
                                  groupValue: id,
                                  activeColor: primaryColor,
                                  onChanged: (val) {
                                    setState(() {
                                      id = 3;
                                      changeLocale(context, "rw");

                                      Navigator.pop(context);
                                    });
                                  },
                                )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(translate("app_txt_cancel"),
                    style: GoogleFonts.poppins(fontSize: 17, color: redColor)),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
        var localizationDelegate = LocalizedApp.of(context).delegate;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: Scaffold(
          key: scaffoldKey,
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
            title: Center(
              child: Text("",
                  style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 20)),
            ),
            actions: const [],
          ),
          backgroundColor: whiteColor,
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              margin:
                  const EdgeInsets.only(bottom: 5, left: 15, right: 15, top: 5),
              decoration: BoxDecoration(
                  color: whiteColor, borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    child: Text(
                      translate('app_txt_setting'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: primaryColor,
                          fontSize: 36,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 17, horizontal: 30),
                    child: Text(
                      translate('app_txt_account'),
                      style: GoogleFonts.poppins(
                          color: blackColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        top: 5, left: 8, right: 8, bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                    height: 60,
                                    width: 60,
                                    margin: EdgeInsets.only(
                                        bottom: 2, top: 2, right: 10),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: whiteColor1, width: 3),
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "assets/images/logo/hhh.png")))),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        currentName.toString(),
                                        style: GoogleFonts.poppins(
                                            color: primaryColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        translate(
                                            'app_txt_all_profile_changes'),
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                _isClicked
                                    ? setState(() {
                                        _isClicked = false;
                                      })
                                    : setState(() {
                                        _isClicked = true;
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
                        Visibility(
                          visible: _isClicked,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: transparentColor1,
                                borderRadius: BorderRadius.circular(6)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              translate("app_txt_member_phone"),
                                              style: GoogleFonts.poppins(
                                                  color: blackColor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                            Text(
                                              currentPhone.toString(),
                                              style: GoogleFonts.poppins(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              translate("app_txt_member_code"),
                                              style: GoogleFonts.poppins(
                                                  color: blackColor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                            Text(
                                              currentCode.toString(),
                                              style: GoogleFonts.poppins(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 17, horizontal: 30),
                    child: Text(
                      translate('app_txt_setting'),
                      style: GoogleFonts.poppins(
                          color: blackColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () {
                      isLoggedIn
                          ? Navigator.push(
                              context, MyPageRoute(widget: AdminDashboard()))
                          : Navigator.push(
                              context, MyPageRoute(widget: Login()));
                    },
                    child: ItemSetting(
                        title: translate("app_txt_login"),
                        subtitle: translate('app_txt_login_as_church_admin'),
                        icon: Icons.login,
                        iconColor: primaryColor,
                        isLang: isLoggedIn,
                        image: 'assets/images/logo/users.png'),
                  ),
                  ItemSetting(
                      title: translate("app_txt_notification"),
                      subtitle: translate('app_txt_get_app_notification_changes'),
                      icon: Icons.notifications_active,
                      iconColor: primaryColor,
                      isLang: false,
                      image: ''),
                  InkWell(
                    onTap: () {
                     showCustomDialog(context);
                    },
                    child: ItemSetting(
                        title: translate("app_txt_app_change"),
                        subtitle: translate('app_txt_change_lang_setting'),
                        icon: Icons.language,
                        iconColor: primaryColor,
                        isLang: true,
                         image: localizationDelegate.currentLocale.languageCode ==
                              "rw"
                          ? "assets/images/icons/rw_flag.png"
                          : localizationDelegate.currentLocale.languageCode ==
                                  "sw"
                              ? "assets/images/icons/swa.png"
                              : localizationDelegate
                                          .currentLocale.languageCode ==
                                      "fr"
                                  ? "assets/images/icons/fr.png"
                                  : "assets/images/icons/eng.png",
                        ),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.of(context)
                      //     .push(MyPageRoute(widget: const Church()));
                    },
                    child: ItemSetting(
                        title: translate("app_txt_church"),
                        subtitle: translate('app_txt_default_pref_information'),
                        icon: Icons.church_rounded,
                        iconColor: primaryColor,
                        isLang: false,
                        image: ''),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.of(context)
                      //     .push(MyPageRoute(widget: const Groups()));
                    },
                    child: ItemSetting(
                        title: translate("app_txt_group"),
                        subtitle: translate('app_txt_get_help'),
                        icon: Icons.people,
                        iconColor: primaryColor,
                        isLang: false,
                        image: ''),
                  ),
                  InkWell(
                    onTap: () async {
                      final pref = await SharedPreferences.getInstance();
                      await pref.remove("current_member");
                      await pref.remove("current_church");
                      await pref.remove("current_group");
                      _dbHelper.clearCache();
                      // Phoenix.rebirth(context);
                    },
                    child: ItemSetting(
                        title: translate("app_txt_logout"),
                        subtitle: translate('app_txt_get_help'),
                        icon: Icons.logout,
                        iconColor: primaryColor,
                        isLang: false,
                        image: ''),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
