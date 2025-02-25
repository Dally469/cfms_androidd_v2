// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/widgets/lists/country_item.dart';
import 'package:cfms/utils/colors.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/country_model.dart';
import '../../../services/api/http_services.dart';
import '../../../utils/routes.dart';
import '../../widgets/buttons/loading_button.dart';
import '../../widgets/texts/heading.dart';
import 'package:flutter/foundation.dart';

import 'admin/admin.dashboard.screen.dart';

class Login extends StatefulWidget {
  // final String churchId;
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RegExp digitValidator = RegExp(r'(^(?:[+0]9)?[0-9]{10}$)');
  bool isEmail = true;
  bool isANumber = true;
  bool _isLoading = false;
  bool _isSettingDashboard = false;
  bool _isApiLoading = false;
  bool _passwordVisible = false;
  CountryModel? _selectedCountry;
  String? _selectedCodeUrl;
  final formGlobalKey = GlobalKey<FormState>();
  HttpService httpService = HttpService();
  bool _showWebReceipt = false;
  String _userToken = "";
  String? token;

  @override
  void initState() {
    super.initState();
    // _gettingPreferences();
    getUniqueDeviceId();
    getCountries();
    getLang();
  }

  _gettingPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('countryCode') ?? '';
    if (url == '') {
      showError(translate('app_txt_system_error'));
    }
    setState(() {
      _selectedCodeUrl = url;
    });
  }

  _login() async {
    print(_selectedCodeUrl);
    try {
      final prefs = await SharedPreferences.getInstance();
      var data = {
        'email': emailController.text,
        'password': passwordController.text,
      };
      //switch to live request or local
      // var response = await httpService.postAppData(data, _selectedCodeUrl, 'v3/login');
      var response = await httpService.postAppDataLocal(
          data,
          _selectedCodeUrl,
          'v3/login',
          '&lang=${prefs.getString("lang")}&device_model=$deviceModel');
      // if (kDebugMode) {
      //   print("RESULT ${response.body}");
      // }
      var body = json.decode(response.body);
      if (kDebugMode) {
        print("RESULT $response");
      }

      if (response.statusCode == 200) {
        setState(() {
          _isSettingDashboard = true;
        });
        // Member isRegister
        prefs.setString('currentUser', response.body);
        prefs.setString('current_member', response.body);
        prefs.setString('currency', jsonEncode(body['currency']));
        // prefs.setString('adminChurchId', jsonEncode(widget.churchId));
        prefs.setBool('showHome', true);
        prefs.setBool('isLoggedIn', true);
        setState(() {
          _isSettingDashboard = false;
          _isLoading = false;
        });
        Navigator.push(context, MyPageRoute(widget: const AdminDashboard()));
      } else if (response.statusCode == 401) {
        //device is not allowed, show option for web cash receipt
        _userToken = body['accessToken'];
        setState(() {
          _isLoading = false;
          _showWebReceipt = true;
          _isApiLoading = false;
          _isSettingDashboard = false;
        });
      } else {
        showError(body['message']);
        setState(() {
          _isLoading = false;

          _isApiLoading = false;
          _isSettingDashboard = false;
        });
      }
    } catch (e) {
      if (e is SocketException) {
        showError("Socket exception: ${e.toString()}");
        setState(() {
          _isLoading = false;

          _isApiLoading = false;
          _isSettingDashboard = false;
        });
      } else if (e is TimeoutException) {
        showError("Timeout exception: ${e.toString()}");
        setState(() {
          _isLoading = false;

          _isApiLoading = false;
          _isSettingDashboard = false;
        });
      } else {
        showError("Unhandled exception: ${e.toString()}");
        setState(() {
          _isLoading = false;

          _isApiLoading = false;
          _isSettingDashboard = false;
        });
      }
    }
  }

  void getCountries() async {
    setState(() {
      _isSettingDashboard = true;
    });
    countries = await HttpService().getCountrySuggestions("");
    setState(() {
      _isSettingDashboard = false;
    });
  }

  List<CountryModel> countries = [];
  Future<String> getUniqueDeviceId() async {
    String uniqueDeviceId = '';
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      uniqueDeviceId =
          '${iosDeviceInfo.name}:${iosDeviceInfo.identifierForVendor}'; // unique ID on iOS
      deviceId = '${iosDeviceInfo.identifierForVendor}';
      deviceModel = '${iosDeviceInfo.model}';
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      uniqueDeviceId =
          '${androidDeviceInfo.model}:${androidDeviceInfo.id}'; // unique ID on Android
      deviceId = '${androidDeviceInfo.id}';
      deviceModel = '${androidDeviceInfo.model}';
      if (kDebugMode) {
        print(deviceId);
        print(deviceModel);
      }
    }

    return uniqueDeviceId;
  }

  String? lang;
  bool isLoggedIn = false;
  int id = 1;
  getLang() async {
    final prefs = await SharedPreferences.getInstance();
    lang = prefs.getString('currentLang');
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return lang;
  }

  void setCountryCode(String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('countryCode', countryCode);
    });

    print(countryCode);
  }

  int selectedTab = 1;
  bool selectCountry = false;
  bool isAdmin = false;
  String deviceId = '';
  String deviceModel = '';
  bool _isRegistered = false;

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
                              style: GoogleFonts.poppins(
                                  fontSize: 17, color: primaryColor),
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
                                      setState(() async {
                                        id = 1;
                                        changeLocale(context, "en");

                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
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
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15),
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
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
                                                    setState(() async {
                                                      id = 1;
                                                      changeLocale(
                                                          context, "en");

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
                                      setState(() async {
                                        id = 4;
                                        changeLocale(context, "fr");

                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
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
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15),
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
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
                                                    setState(() async {
                                                      id = 4;
                                                      changeLocale(
                                                          context, "fr");

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
                                      setState(() async {
                                        id = 2;
                                        changeLocale(context, "sw");

                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
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
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15),
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
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
                                                    setState(() async {
                                                      id = 2;
                                                      changeLocale(
                                                          context, "sw");

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
                                      setState(() async {
                                        id = 3;
                                        changeLocale(context, "rw");

                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
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
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15),
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
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
                                                    setState(() async {
                                                      id = 3;
                                                      changeLocale(
                                                          context, "rw");

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
                                    style: GoogleFonts.poppins(
                                        fontSize: 17, color: redColor)),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: Stack(
          children: [
            Scaffold(
              key: scaffoldKey,
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
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () {
                       showCustomDialog(context);
                      },
                      child: Row(
                        children: [
                          Text(
                            translate('app_txt_app_change'),
                            style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: primaryOverlayColor, width: 2),
                                image: const DecorationImage(
                                    // image: ExactAssetImage(context
                                    //             .locale.languageCode
                                    //             .toString() ==
                                    //         "rw"
                                    //     ? "assets/images/icons/rw_flag.png"
                                    //     : context.locale.languageCode
                                    //                 .toString() ==
                                    //             "sw"
                                    //         ? "assets/images/icons/swa.png"
                                    //         : context.locale.languageCode
                                    //                     .toString() ==
                                    //                 "fr"
                                    //             ? "assets/images/icons/fr.png"
                                    //             : "assets/images/icons/eng.png"),
                                    image: ExactAssetImage(
                                        "assets/images/icons/eng.png"),
                                    fit: BoxFit.cover)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: Center(
                  child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Heading(
                        title: _showWebReceipt
                            ? translate('app_txt_secureDeviceIssue')
                            : translate("app_txt_connect_account"),
                        subtitle: _showWebReceipt
                            ? translate('app_txt_you_have_permission')
                            : translate('app_txt_choose_region')),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                          color: greyColor1,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedTab = 1;
                                  isAdmin = false;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                decoration: BoxDecoration(
                                    color: selectedTab == 1
                                        ? primaryColor
                                        : greyColor1,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: selectedTab == 1
                                            ? greyColor1
                                            : primaryColor,
                                        size: 18,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 10),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              320,
                                          child: Text(
                                            translate("app_txt_member"),
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                                color: selectedTab == 1
                                                    ? whiteColor
                                                    : primaryColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedTab = 2;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                decoration: BoxDecoration(
                                    color: selectedTab == 2
                                        ? primaryColor
                                        : greyColor1,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: selectedTab == 2
                                            ? whiteColor
                                            : primaryColor,
                                        size: 18,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 10),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              320,
                                          child: Text(
                                            translate("app_txt_login_admin"),
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                                color: selectedTab == 2
                                                    ? whiteColor
                                                    : primaryColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                        visible: !isAdmin,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.only(top: 10),
                          height: 300,
                          child: ListView(
                            children: List.generate(countries.length, (index) {
                              CountryModel country = countries[index];
                              return CountryItem(
                                selectedId: _selectedCountry != null
                                    ? _selectedCountry!.countryCode!
                                    : "",
                                id: country.countryCode!,
                                image: Image.network(
                                  "https://sdacfms.com/assets/flags/${country.countryFlag}",
                                  scale: 2,
                                  height: 30,
                                  width: 35,
                                ),
                                title: country.countryName!,
                                code: country.countryCode ?? "",
                                onTap: () => {
                                  setState(() {
                                    if (selectedTab == 1) {
                                      _selectedCountry = country;
                                      _selectedCodeUrl = country.countryShort;
                                      _isRegistered = false;
                                      _isApiLoading = false;
                                    } else {
                                      isAdmin = true;
                                      _selectedCountry = null;
                                      _selectedCodeUrl = country.countryShort;
                                    }
                                  }),
                                  setCountryCode(_selectedCodeUrl ?? "")
                                },
                              );
                            }),
                          ),
                        )),
                    Visibility(
                      visible: !_showWebReceipt && isAdmin,
                      child: Form(
                        key: formGlobalKey,
                        child: Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 30),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: TextField(
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller: emailController,
                                          style: GoogleFonts.poppins(
                                              fontSize: 13.0),
                                          decoration: InputDecoration(
                                            errorText: isEmail
                                                ? null
                                                : translate(
                                                    'app_txt_please_enter_phone_number'),
                                            hintText:
                                                translate('app_txt_username'),
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 10),
                                            suffixIcon: isEmail ||
                                                    emailController.text.isEmpty
                                                ? !emailController.text.isEmpty
                                                    ? const Icon(
                                                        Icons.check_circle,
                                                        color: greenColor,
                                                      )
                                                    : const Text(" ")
                                                : const Icon(
                                                    Icons.error,
                                                    color: redColor,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: TextField(
                                          keyboardType: TextInputType.text,
                                          controller: passwordController,
                                          obscureText: !_passwordVisible,
                                          style: GoogleFonts.poppins(
                                              fontSize: 13.0),
                                          decoration: InputDecoration(
                                            errorText: isANumber
                                                ? null
                                                : translate(
                                                    'app_txt_please_enter_phone_number'),
                                            hintText:
                                                translate('app_txt_password'),
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 10),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                // Based on passwordVisible state choose the icon
                                                _passwordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: primaryOverlayColor,
                                                size: 23,
                                              ),
                                              onPressed: () {
                                                // Update the state i.e. toogle the state of passwordVisible variable
                                                setState(() {
                                                  _passwordVisible =
                                                      !_passwordVisible;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  )
                                ],
                              ),
                            ),
                            _isApiLoading
                                ? const SpinKitCircle(
                                    color: primaryColor,
                                    size: 44,
                                  )
                                : LoadingButton(
                                    icon: Icons.arrow_forward,
                                    backgroundColor: primaryColor,
                                    width: 220,
                                    title: translate('app_txt_login'),
                                    isLoading: _isLoading,
                                    onTap: () {
                                      if (formGlobalKey.currentState!
                                          .validate()) {
                                        if (!isANumber ||
                                            passwordController.text.isEmpty) {
                                          showError(translate(
                                              "app_txt_please_enter_valid_phone_number"));
                                        } else {
                                          setState(() {
                                            _isApiLoading = true;
                                            _isLoading = true;
                                          });
                                          _login();
                                        }
                                      }
                                    },
                                  ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                        visible: _showWebReceipt,
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/images/logo/no_data_found.png",
                              scale: 1.5,
                            ),
                            LoadingButton(
                              icon: Icons.arrow_forward,
                              backgroundColor: primaryColor,
                              width: 200,
                              title: translate('app_txt_openSecuredVersion'),
                              isLoading: _isLoading,
                              onTap: () async {
                                String url =
                                    "https://$_selectedCodeUrl.sdacfms.com/cash-receipt?token=$_userToken";
                                if (kDebugMode) {
                                  print(url);
                                }
                                Uri uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                  Navigator.of(context).pop(true);
                                } else {
                                  showError(
                                      'Could not launch online secure version, please check if your browser is up to date and try again');
                                }
                              },
                            ),
                            TextButton(
                                onPressed: () => setState(() {
                                      _showWebReceipt = false;
                                    }),
                                child: Text(translate("app_txt_dismiss")))
                          ],
                        )),
                  ],
                ),
              )),
              bottomSheet: _selectedCountry != null
                  ? _isRegistered
                      ? personalFound()
                      : countrySelected()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logo/logo.png",
                          scale: 2,
                          height: 50,
                          color: primaryOverlayColor,
                          width: 50,
                        )
                      ],
                    ),
            ),
            Visibility(
              visible: _isSettingDashboard && isAdmin,
              child: Positioned(
                  child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: transparentColor2,
                    child: const Center(
                      child: SpinKitFadingCube(
                        color: whiteColor,
                        size: 50,
                      ),
                    ),
                  )
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  void showError(String message) {
    Flushbar(
      message: message,
      icon: const Icon(
        Icons.info_outline,
        size: 28.0,
        color: redColor,
      ),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      messageColor: redColor,
      borderRadius: BorderRadius.circular(30),
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: redColorOverlay,
    ).show(context);
  }

  void setValidator(valid) {
    setState(() {
      isANumber = valid;
    });
  }

  Widget personalFound() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            )
          ],
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    height: 75,
                    width: 75,
                    decoration: const BoxDecoration(
                        color: primaryOverlayColor, shape: BoxShape.circle),
                    child: Center(
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage("assets/images/icons/user.png")),
                            shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                            color: greenColor, shape: BoxShape.circle),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            size: 17,
                            color: whiteColor,
                          ),
                        ),
                      ))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    mNameFound.replaceAll('"', ''),
                    style: GoogleFonts.poppins(
                        color: blackColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 17),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        mPhoneFound.replaceAll('"', ''),
                        style: GoogleFonts.poppins(
                            color: blackColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          InkWell(
            onTap: () {
              _sendOtpSMS();
            },
            child: LoadingButton(
              icon: Icons.arrow_forward,
              backgroundColor: primaryColor,
              width: 200,
              title: translate('app_txt_verify'),
              isLoading: _isLoading,
            ),
          )
        ],
      ),
    );
  }

  String sysMember = '', sysChurch = '', sysGroup = '';
  String mNameFound = '';
  String mPhoneFound = '';
  String memberId = '';
  TextEditingController phoneController = TextEditingController();

  _createMember() async {
    try {
      var data = {
        'code': phoneController.text,
      };
      //countryCode required here in  ????
      var response =
          await httpService.postAppData(data, _selectedCodeUrl, 'v3/member');
      var body = json.decode(response.body);

      if (kDebugMode) {
        print(body);
      }
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('countryCode', _selectedCountry!.countryShort ?? "");
      if (response.statusCode == 200) {
        sysMember = jsonEncode(body['data'][0]);
        sysChurch = jsonEncode(body['church_details'][0]);
        sysGroup = jsonEncode(body['group_details']);
        setState(() {
          _isSettingDashboard = true;
          _isLoading = false;
          _isRegistered = true;
          mNameFound = jsonEncode(body['data'][0]['names']);
          mPhoneFound =
              jsonEncode(body['data'][0]['phone']).replaceAll('"', '');
          memberId = jsonEncode(body['data'][0]['id']);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _isLoading = false;
          _isApiLoading = false;
          // _isRegistered = false;
        });
        // Navigator.push(
        //     context,
        //     MyPageRoute(
        //         widget: CreateAccount(
        //             phoneNumber: phoneController.text,
        //             country: _selectedCountry!,
        //             suggestedName: body['suggested_name'])));
        return;
      } else {
        // Member Not Registered
        setState(() {
          _isLoading = false;
          _isApiLoading = false;
          // _isRegistered = false;
        });
        showErrorAlert(body.message);
      }
    } catch (e) {
      var message = "";
      if (e is SocketException) {
        message = "Socket exception: ${e.toString()}";
      } else if (e is TimeoutException) {
        message = "Timeout exception: ${e.toString()}";
      } else {
        message = "Unhandled exception: ${e.toString()}";
        // Member Not Registered
        // Navigator.push(context, MyPageRoute(widget: const CreateAccount()));
      }
      if (kDebugMode) {
        print(message);
      }
      showErrorAlert(message);
    }
  }

  String sentOtp = "";
  String getOtp() {
    Random random = Random();
    String number = '';
    for (int i = 0; i < 4; i++) {
      number = number + random.nextInt(9).toString();
    }
    if (kDebugMode) {
      print('OTP: $number');
    }
    return number;
  }

  _sendOtpSMS() async {
    setState(() {
      _isLoading = true;
    });
    sentOtp = getOtp();
    var data = {
      'phone': mPhoneFound,
      'memberId': memberId,
      'message': sentOtp,
    };

    var response =
        await httpService.postAppData(data, _selectedCodeUrl, 'v3/sendOtp');
    var body = json.decode(response.body);
    if (kDebugMode) {
      print(body);
    }
    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(body);
      }
      // Navigator.push(
      //     context,
      //     MyPageRoute(
      //         widget: Verification(
      //       memberId: memberId,
      //       sysMember: sysMember,
      //       sysChurch: sysChurch,
      //       sysGroup: sysGroup,
      //       otp: body['otp'],
      //       phone: mPhoneFound,
      //       memberName: mNameFound,
      //     )));
    } else {
      if (kDebugMode) {
        print("sms not sent");
      }
      showErrorAlert(translate("app_txt_otp_not_sent"));
    }
  }

  void showErrorAlert(String message) {
    Flushbar(
      title: "Error",
      message: message,
      icon: const Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(30),
      borderRadius: BorderRadius.circular(10),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.elasticInOut,
      forwardAnimationCurve: Curves.elasticInOut,
      backgroundColor: redColor,
    ).show(context);
  }

  Widget countrySelected() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            )
          ],
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                "https://sdacfms.com/assets/flags/${_selectedCountry!.countryFlag}",
                scale: 2,
                height: 30,
                width: 35,
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 170,
                child: Text(
                  _selectedCountry != null
                      ? _selectedCountry!.countryName!
                      : "",
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 20),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                _selectedCountry != null
                    ? "+${_selectedCountry!.countryCode}"
                    : "",
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    fontSize: 20),
              )
            ],
          ),
          Form(
              key: formGlobalKey,
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    onChanged: (inputValue) {
                      if (inputValue.isEmpty ||
                          digitValidator.hasMatch(inputValue)) {
                        setValidator(true);
                      } else {
                        setValidator(false);
                      }
                    },
                    decoration: InputDecoration(
                      errorText: isANumber
                          ? null
                          : translate('app_txt_please_enter_phone_number'),
                      hintText: translate('app_txt_phone_number'),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      suffixIcon: isANumber || phoneController.text.isEmpty
                          ? phoneController.text.isNotEmpty
                              ? const Icon(
                                  Icons.check_circle,
                                  color: greenColor,
                                )
                              : const Text(" ")
                          : const Icon(
                              Icons.error,
                              color: redColor,
                            ),
                    ),
                  ),
                ),
              ])),
          GestureDetector(
            onTap: () {
              if (formGlobalKey.currentState!.validate()) {
                if (!isANumber || phoneController.text.isEmpty) {
                  showErrorAlert(
                      translate("app_txt_please_enter_valid_phone_number"));
                } else {
                  setState(() {
                    _isApiLoading = true;
                    _isLoading = true;
                  });
                  _createMember();
                }
              }
            },
            child: _isApiLoading
                ? const SpinKitCircle(
                    color: primaryColor,
                    size: 44,
                  )
                : LoadingButton(
                    icon: Icons.arrow_forward,
                    backgroundColor: primaryColor,
                    width: 200,
                    title: translate('app_txt_continue'),
                    isLoading: _isLoading,
                  ),
          ),
          TextButton(
              onPressed: () => setState(() {
                    _selectedCountry = null;
                  }),
              child: Text(translate("app_txt_dismiss")))
        ],
      ),
    );
  }
}
