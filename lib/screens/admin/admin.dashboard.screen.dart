import 'dart:async';
import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/models/quick_payment_model.dart';
import 'package:cfms/models/user_model.dart';
import 'package:cfms/screens/admin/church_reprint_receipt.dart';
import 'package:cfms/screens/admin/quick_payment_history.dart';
import 'package:cfms/screens/admin/quick_view_summary.dart';
import 'package:cfms/screens/admin/search_member.dart';
import 'package:cfms/services/api/http_services.dart';
import 'package:cfms/services/db/db_helper.dart';
import 'package:cfms/services/synchrinize.dart';
// import 'package:cfms/screens/admin/admin_setting.dart';
// import 'package:cfms/screens/admin/dashboard/search_member.dart';
// import 'package:cfms/screens/quick_payment_history.dart';
// import 'package:cfms/screens/quick_view_summary.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
// import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/cards/admin_home_card_loading.dart';
// import 'church_reprint_receipt.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with WidgetsBindingObserver {
  bool isClicked = false;
  bool isClicked1 = false;
  bool isLoading = true;
  bool _isSync = false;
  bool _hasLocalData = false;
  HttpService httpService = HttpService();
  List<QuickPaymentModel> dataToSync = [];
  final DbHelper _dbHelper = DbHelper();
  late UserModel user;
  List currencies = [];
  String? currentName,
      currentPhone,
      currentCode,
      countryCodeUrl,
      countryCurrency,
      churchId,
      currentId;
  Timer? syncTimer;

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('current_member') ?? '';
    currencies = jsonDecode(prefs.getString('currency') ?? '');
    String url = prefs.getString('countryCode') ?? '';
    String currency = prefs.getString('countryCurrency') ?? '';
    String chrId = prefs.getString('adminChurchId') ?? '';

    if (json == null) {
      if (kDebugMode) {
        print('No dATA');
      }
    } else {
      print(json);
      Map<String, dynamic> map = jsonDecode(json);
      user = UserModel.fromJson(map);

      setState(() {
        currentName = user.name;
        currentPhone = user.church;
        currentCode = user.position;
        currentId = user.id;
        countryCodeUrl = url;
        countryCurrency = currency;
        churchId = user.churchId;
        isLoading = false;
      });
    }
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return translate('app_text_morning');
    } else if (hour < 17) {
      return translate('app_text_afternoon');
    } else {
      return translate('app_text_evening');
    }
  }

  Future isInternet() async {
    dataToSync = await _dbHelper.getLocalCashReceipt();

    if (dataToSync.isNotEmpty) {
      setState(() {
        _hasLocalData = true;
      });
    } else {
      setState(() {
        _hasLocalData = false;
        _isSync = false;
      });
      return;
    }
    await Synchronization.isNetworkAvailable().then((connection) {
      if (connection) {
        if (_isSync) {
          syncData();
        } else {
          if (kDebugMode) {
            print("there is an ongoing sync, waiting...");
          }
        }
      } else {
        showError("No internet connection");
      }
    });
  }

  void iniTimer() {
    syncTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_hasLocalData) {
        isInternet();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    user = UserModel();
    isInternet();
    iniTimer();
  }

  void stopTimer() {
    syncTimer!.cancel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    // TODO: implement dispose
    stopTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (kDebugMode) {
          print("State resumed");
        }
        iniTimer();
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        if (kDebugMode) {
          print("State inactive");
        }
        stopTimer();
        break;
      case AppLifecycleState.paused:
        // widget is paused
        if (kDebugMode) {
          print("State paused");
        }
        stopTimer();
        break;
      case AppLifecycleState.detached:
        // widget is detached
        if (kDebugMode) {
          print("State detached");
        }
        stopTimer();
        break;
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    stopTimer();
  }

  @override
  void activate() {
    super.activate();
    iniTimer();
  }

  Future syncData() async {
    print(dataToSync.length);
    setState(() {
      _isSync = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';
    //showing sync progress
    setState(() {
      _isSync = true;
      _hasLocalData = true;
    });
    int failed = 0;
    for (var i = 0; i < dataToSync.length; i++) {
      Map<String, dynamic> data = {
        "phone": dataToSync[i].phone.toString(),
        "names": dataToSync[i].name.toString(),
        "device_name": "sunmi v2",
        "offerings": dataToSync[i].offerings,
        "user_id": user.id.toString(),
        "currency": dataToSync[i].currency.toString(),
      };
      var response = await httpService.postAppDataLocal(
          data,
          countryCode,
          'v3/quick-payment/add',
          '&lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}');
      var body = json.decode(response.body);
      if (kDebugMode) {
        print("MYDATA");
        print(body);
      }
      if (response.statusCode == 200) {
        _dbHelper.deleteSyncedQuickPayment(dataToSync[i].id!);
      } else {
        failed++;
        if (kDebugMode) {
          print(response.statusCode);
        }
      }
    }
    if (failed == 0) {
      _hasLocalData = false;
      dataToSync = [];
      showSuccess("Sync completed!");
    } else {
      _hasLocalData = true;
    }
    _isSync = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {'/admin': (context) => const AdminDashboard()},
        home: Material(
            child: Scaffold(
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
            title: Text(translate('app_txt_dashboard'),
                style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            actions: [
              Visibility(
                visible: _hasLocalData,
                child: TextButton(
                    onPressed: () {
                      isInternet();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border.all(width: 1, color: redColor),
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          child: Row(
                            children: [
                              _isSync
                                  ? const SpinKitDualRing(
                                      color: redColor, size: 11)
                                  : const Icon(Icons.sync,
                                      color: redColor, size: 17),
                              const SizedBox(width: 10),
                              Text(_isSync ? "Syncing..." : "Sync",
                                  style: GoogleFonts.lato(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: redColor)),
                            ],
                          ),
                        ),
                      ),
                    )),
              ),
              InkWell(
                  onTap: () {
                    // Navigator.push(
                    //     context, MyPageRoute(widget: const AdminSetting()));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20, left: 7),
                    child: const Icon(
                      Icons.settings,
                      color: primaryColor,
                    ),
                  ))
            ],
          ),
          backgroundColor: whiteColor,
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                isLoading
                    ? const AdminHomeCardLoading()
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 10),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    height: 60,
                                    width: 60,
                                    margin: const EdgeInsets.only(
                                        bottom: 2, top: 2),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: whiteColor1, width: 3),
                                        image: const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/logo/hhh.png")))),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2, vertical: 4),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 10),
                                        child: Text(
                                          currentName.toString(),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Position: ",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: primaryColor,
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    "Admin",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Church: ",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: primaryColor,
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    currentPhone.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isClicked = true;
                                    setState(() {
                                      isClicked = false;
                                      //todo enable when is fixed error
                                      Navigator.push(
                                          context,
                                          MyPageRoute(
                                              widget: SearchMember(
                                            churchId: churchId!,
                                          )));
                                    });
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(5),
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
                                  child: Stack(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: transparentColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 120,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 3,
                                                                  horizontal:
                                                                      02),
                                                          child: Text(
                                                            translate(
                                                                "app_txt_cash_receipt"),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts.poppins(
                                                                color:
                                                                    primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 15),
                                                          )),
                                                    ),
                                                    Container(
                                                      width: 75,
                                                      height: 75,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10),
                                                      decoration:
                                                          const BoxDecoration(
                                                              color:
                                                                  transparentColor,
                                                              shape: BoxShape
                                                                  .circle),
                                                      child: Center(
                                                          child: Image.asset(
                                                        "assets/images/logo/offering.png",
                                                        scale: 2,
                                                      )),
                                                    ),
                                                    Container(
                                                      width: 120,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Text(
                                                          translate(
                                                              "app_txt_make_cash_receipt"),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.lato(
                                                                  color:
                                                                      blackColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 13,
                                                      vertical: 5),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: isClicked
                                                      ? primaryColor
                                                      : whiteColor,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: isClicked
                                                          ? primaryColor
                                                          : primaryOverlayColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: Text(
                                                      translate(
                                                          "app_txt_click_here"),
                                                      style: GoogleFonts.lato(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: isClicked
                                                              ? whiteColor
                                                              : primaryColor)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                    isClicked1 = true;
                                    dataToSync.isNotEmpty
                                        ? showError(
                                            "Please must sync application")
                                        : setState(() {
                                            isClicked1 = false;
                                            //TODO Enable  it when is fixed
                                            Navigator.push(
                                                context,
                                                MyPageRoute(
                                                    widget: QuickPaymentHistory(
                                                  countryCode:
                                                      countryCodeUrl.toString(),
                                                  userId: '${user.id}',
                                                  churchName:
                                                      user.church.toString(),
                                                )));
                                          });
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(5),
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
                                  child: Stack(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: transparentColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 120,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 3,
                                                                  horizontal:
                                                                      02),
                                                          child: Text(
                                                            translate(
                                                                "app_txt_history"),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts.poppins(
                                                                color:
                                                                    primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 15),
                                                          )),
                                                    ),
                                                    Container(
                                                      width: 75,
                                                      height: 75,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10),
                                                      decoration:
                                                          const BoxDecoration(
                                                              color:
                                                                  transparentColor,
                                                              shape: BoxShape
                                                                  .circle),
                                                      child: Center(
                                                          child: Image.asset(
                                                        "assets/images/logo/history.png",
                                                        scale: 2,
                                                      )),
                                                    ),
                                                    Container(
                                                      width: 120,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Text(
                                                          translate(
                                                              "app_txt_make_cash_history"),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.lato(
                                                                  color:
                                                                      blackColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 13,
                                                      vertical: 5),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: isClicked1
                                                      ? primaryColor
                                                      : whiteColor,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: isClicked1
                                                          ? primaryColor
                                                          : primaryOverlayColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: Text(
                                                      translate(
                                                          "app_txt_click_here"),
                                                      style: GoogleFonts.lato(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: isClicked1
                                                              ? whiteColor
                                                              : primaryColor)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isClicked = true;
                                    setState(() {
                                      isClicked = false;
                                      //TODO Enale whne error are fixed

                                      Navigator.push(
                                          context,
                                          MyPageRoute(
                                              widget: ReprintReceipt(
                                            churchName: currentPhone!,
                                            churchCode: currentCode!,
                                            countryCode:
                                                countryCodeUrl.toString(),
                                          )));
                                    });
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(5),
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
                                  child: Stack(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: transparentColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 120,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 3,
                                                                  horizontal:
                                                                      02),
                                                          child: Text(
                                                            translate(
                                                                "app_txt_cash_reprint_receipt"),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts.poppins(
                                                                color:
                                                                    primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 15),
                                                          )),
                                                    ),
                                                    Container(
                                                      width: 75,
                                                      height: 75,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10),
                                                      decoration:
                                                          const BoxDecoration(
                                                              color:
                                                                  transparentColor,
                                                              shape: BoxShape
                                                                  .circle),
                                                      child: Center(
                                                          child: Image.asset(
                                                        "assets/images/logo/reprint.png",
                                                        scale: 2,
                                                      )),
                                                    ),
                                                    Container(
                                                      width: 120,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Text(
                                                          translate(
                                                              "app_txt_make_cash_receipt"),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.lato(
                                                                  color:
                                                                      blackColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 13,
                                                      vertical: 5),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: isClicked
                                                      ? primaryColor
                                                      : whiteColor,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: isClicked
                                                          ? primaryColor
                                                          : primaryOverlayColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: Text(
                                                      translate(
                                                          "app_txt_click_here"),
                                                      style: GoogleFonts.lato(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: isClicked
                                                              ? whiteColor
                                                              : primaryColor)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Visibility(
                                visible: true,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      isClicked1 = false;
                                      //todo enable when error are fixed
                                      Navigator.push(
                                          context,
                                          MyPageRoute(
                                              widget: QuickViewSummary(
                                            countryCode:
                                                countryCodeUrl.toString(),
                                            churchId: '${user.churchId}',
                                            churchName: user.church.toString(),
                                          )));
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
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
                                    child: Stack(
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.all(6),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: transparentColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                                                              mainAxisAlignment:
                                                    MainAxisAlignment.center,

                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 120,
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 3,
                                                                    horizontal:
                                                                        02),
                                                            child: Text(
                                                              translate(
                                                                  "app_txt_history_summary"),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts.poppins(
                                                                  color:
                                                                      primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 15),
                                                            )),
                                                      ),
                                                      Container(
                                                        width: 75,
                                                        height: 75,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            vertical: 10),
                                                        decoration:
                                                            const BoxDecoration(
                                                                color:
                                                                    transparentColor,
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: Center(
                                                            child: Image.asset(
                                                          "assets/images/logo/calendar_s.png",
                                                          scale: 2,
                                                        )),
                                                      ),
                                                      Container(
                                                        width: 120,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 10),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Text(
                                                            translate(
                                                                "app_txt_make_cash_summary"),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts.lato(
                                                                color:
                                                                    blackColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 13,
                                                        vertical: 5),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                    color: isClicked1
                                                        ? primaryColor
                                                        : whiteColor,
                                                    border: Border.all(
                                                        width: 1,
                                                        color: isClicked1
                                                            ? primaryColor
                                                            : primaryOverlayColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25)),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: Text(
                                                        translate(
                                                            "app_txt_click_here"),
                                                        style: GoogleFonts.lato(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: isClicked1
                                                                ? whiteColor
                                                                : primaryColor)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )));
  }

  void showError(String message) {
    setState(() {
      isClicked1 = false;
    });
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

  void showSuccess(String message) {
    setState(() {
      isClicked1 = false;
    });
    Flushbar(
      message: message,
      icon: const Icon(
        Icons.check_circle,
        size: 28.0,
        color: greenColor,
      ),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      messageColor: greenColor,
      borderRadius: BorderRadius.circular(30),
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: greenOverlayColor,
    ).show(context);
  }
}
