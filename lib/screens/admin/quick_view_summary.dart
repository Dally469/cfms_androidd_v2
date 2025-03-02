// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/models/user_model.dart';
import 'package:cfms/screens/admin/admin.dashboard.screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_translate/flutter_translate.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:cfms/models/donations/donation.dart';
import 'package:cfms/models/members/member.dart';
import 'package:cfms/models/payment_history_model.dart';
import 'package:cfms/services/api/http_services.dart';
import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/summary_offerings_model.dart';
import '../../nb55_printer/nb55_printer.dart';
import '../../services/provider/donation_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';

import '../../utils/routes.dart';

class QuickViewSummary extends StatefulWidget {
  final String churchId;
  final String countryCode;
  final String churchName;

  const QuickViewSummary(
      {Key? key,
      required this.churchId,
      required this.countryCode,
      required this.churchName})
      : super(key: key);

  @override
  State<QuickViewSummary> createState() => _QuickViewSummaryState();
}

class _QuickViewSummaryState extends State<QuickViewSummary> {
  HttpService httpService = HttpService();

  bool _isFilter = false;
  late Data user;
  var offeringPayments = <DonationModel>[];
  var listFiltered = <PaymentHistoryModel>[];

  final List<Map<String, dynamic>> jsonData = [
    {
      "title": "Autre paur Eglise",
      "translation":
          "{\"en\":\"Autre paur Eglise\",\"sw\":\"Autre paur Eglise\",\"fr\":\"Autre paur Eglise\",\"rw\":\"Autre paur Eglise\"}",
      "currencies": [
        {"currency": "CDF", "amount": "4256760"},
        {"currency": "USD", "amount": "7897"}
      ]
    },
    {
      "title": "Camp Meeting",
      "translation":
          "{\"en\":\"Camp Meeting\",\"sw\":\"Camp Meeting\",\"fr\":\"Camp Meeting\",\"rw\":\"Camp Meeting\"}",
      "currencies": [
        {"currency": "CDF", "amount": "1617000"},
        {"currency": "USD", "amount": "2714"}
      ]
    },
    {
      "title": "CHUNGUCHUNGU",
      "translation":
          "{\"en\":\"CHUNGUCHUNGU\",\"sw\":\"CHUNGUCHUNGU\",\"fr\":\"Dimes de tas\",\"rw\":\"Ibirundo\"}",
      "currencies": [
        {"currency": "CDF", "amount": "2810300"},
        {"currency": "USD", "amount": "9044"}
      ]
    },
    {
      "title": "CONSTRUCTION",
      "translation":
          "{\"en\":\"Construction\",\"sw\":\"Construction\",\"fr\":\"Construction\",\"rw\":\"Construction\"}",
      "currencies": [
        {"currency": "CDF", "amount": "1226800"},
        {"currency": "USD", "amount": "4837"}
      ]
    },
    {
      "title": "Dime",
      "translation":
          "{\"en\":\"Tith\",\"sw\":\"Zaka\",\"fr\":\"Dime\",\"rw\":\"Icyacumi\"}",
      "currencies": [
        {"currency": "CDF", "amount": "35050010"},
        {"currency": "USD", "amount": "49293"}
      ]
    },
    {
      "title": "Offrandes combines",
      "translation":
          "{\"en\":\"Combine offering\",\"sw\":\"Sadaka\",\"fr\":\"Offrandes combines\",\"rw\":\"Amaturo\"}",
      "currencies": [
        {"currency": "CDF", "amount": "29818460"},
        {"currency": "USD", "amount": "20132"}
      ]
    },
    {
      "title": "RADIO MONDIALE",
      "translation":
          "{\"en\":\"RADIO MONDIALE\",\"sw\":\"RADIO MONDIALE\",\"fr\":\"RADIO MONDIALE\",\"rw\":\"RADIO MONDIALE\"}",
      "currencies": [
        {"currency": "CDF", "amount": "246500"},
        {"currency": "USD", "amount": "120"}
      ]
    }
  ];
  List<SummaryOfferingsModel> _selectedOffering = [];
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  String _startDate =  DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 30)));
  String _endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late UserModel member;
  String countryCurrency = "";
  String? userId, userPhone;
  late  Future<List<SummaryOfferingsModel>> fetchHistory;
  final ReceivePort _port = ReceivePort();
  late SharedPreferences prefs;
  _loadingUserData() async {
    prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('currentUser') ?? '';
    String currency = prefs.getString('countryCurrency') ?? '';
    Map<String, dynamic> map = jsonDecode(json);
    member = UserModel.fromJson(map);
    setState(() {
      userId = member.id;
      userPhone = member.phone;
      countryCurrency = currency;
    });
    // lang = prefs.getString("currentLang")!.toLowerCase();

    // print(lang);
  }

  String lang = "fr";
  //test
  List<DateTime>? rangeSelect;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting();
    _loadingUserData();
    member = UserModel();
    fetchHistory =
        httpService.getSummaryPaymentHistory('v2/paymentOfferingSummary', {
      "churchId": widget.churchId,
      "startDate": _startDate,
      "endDate": _endDate,
    });

    totalsFuture = calculateTotals(fetchHistory);
    monitorDownloadProgress();

    getUniqueDeviceId();

    //POS TEST
    _bindingPrinter().then((bool? isBind) async {
      SunmiPrinter.paperSize().then((int size) {
        setState(() {
          paperSize = size;
        });
      });

      SunmiPrinter.printerVersion().then((String version) {
        setState(() {
          printerVersion = version;
        });
      });

      SunmiPrinter.serialNumber().then((String serial) {
        setState(() {
          serialNumber = serial;
        });
      });

      setState(() {
        printBinded = isBind!;
      });
    });
  }

  void monitorDownloadProgress() async {
    // IsolateNameServer.registerPortWithName(
    //     _port.sendPort, "invoice_downloader_port");
    // _port.listen((dynamic data) {
    //   String id = data[0];
    //   DownloadTaskStatus status = data[1];
    //   int progress = data[2];
    //   if (kDebugMode) {
    //     print("invoice_downloader_port $progress");
    //   }
    //   if (status.index == 3) {
    //     //downloaded, open
    //     Future.delayed(const Duration(seconds: 2))
    //         .then((value) => FlutterDownloader.open(taskId: id));
    //     showSuccess("download completed");
    //   }
    // });
  }

  quickPaymentPay(String amount, DateTime date) async {}
  @override
  void dispose() {
    // IsolateNameServer.removePortNameMapping('invoice_downloader_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (_) => DonationProvider(),
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: whiteColor,
              appBar: AppBar(
                backgroundColor: primaryColor,
                elevation: 0,
                leading: InkWell(
                    onTap: () {
                      // Navigator.pop(context);

                      Navigator.push(
                          context, MyPageRoute(widget: const AdminDashboard()));
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: whiteColor,
                    )),
                title: Center(
                  child: Text(translate("app_txt_quick_payment_history"),
                      style: GoogleFonts.poppins(
                          color: whiteColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 17)),
                ),
                actions: [
                  InkWell(
                      onTap: () {
                        setState(() {
                          _isFilter = true;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: whiteColor,
                        ),
                      )),
                ],
              ),
              body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: _isFilter,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 9),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0.0, 5.0),
                                color: Color(0xffEDEDED),
                                blurRadius: 5.0,
                              )
                            ]),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      translate(
                                          "app_txt_view_offering_by_date"),
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: blackColor),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isFilter = false;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            translate("app_txt_close"),
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: blackColor),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.close,
                                          color: redColor,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                              visible: true,
                              child: TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: DateTime.now(),
                                rangeStartDay: _rangeStart,
                                rangeEndDay: _rangeEnd,
                                rangeSelectionMode: RangeSelectionMode.enforced,
                                onRangeSelected: (start, end, focusedDay) {
                                  if (start != null && end != null) {
                                    // Only process complete selections
                                    _onSelectionChanged(start, end);
                                  }
                                },
                                calendarFormat: CalendarFormat.month,
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 10),
                          child: Text(
                            translate("app_txt_history_summary"),
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                                fontSize: 17, fontWeight: FontWeight.w400),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: grayColor, width: 1)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Started Date"),
                                  Text("$_startDate", style: GoogleFonts.poppins(color: primaryColor, fontSize: 17),),

                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("End Date"),
                                  Text("$_endDate", style: GoogleFonts.poppins(color: primaryColor, fontSize: 17),),

                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: listFiltered.isNotEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/images/logo/no_result.png",
                                          height: 60,
                                          width: 60,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            translate("app_txt_no_data_found"),
                                            style: GoogleFonts.poppins(
                                                color: redColor,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : FutureBuilder(
                                    future: fetchHistory,
                                    builder: (BuildContext ctx,
                                        AsyncSnapshot<
                                                List<SummaryOfferingsModel>>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        _selectedOffering = snapshot.data!;
                                        return ListView.builder(
                                            itemCount: snapshot.data?.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              var item = snapshot.data!;
                                              return singleItem(
                                                item[index].title.toString(),
                                                [
                                                  ...item[index]
                                                      .currencies!
                                                      .map((currency) =>
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              margin: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    currency
                                                                        .currency
                                                                        .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  Text(
                                                                    currency
                                                                        .amount
                                                                        .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            17,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ))
                                                      .toList(),
                                                ],
                                              );
                                            });
                                      } else {
                                        return const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 140,
                                              ),
                                              SpinKitDoubleBounce(
                                                size: 40,
                                                color: primaryOverlayColor,
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  ))
                      ],
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                margin: const EdgeInsets.only(top: 15),
                decoration: const BoxDecoration(
                    border:
                        Border(top: BorderSide(color: primaryColor, width: 2))),
                height: listFiltered.isNotEmpty ? 60 : 200,
                child: Column(
                  children: [
                    Visibility(
                      visible: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 10),
                            child: Text(
                              "Grand Total  ",
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          FutureBuilder<Map<String, double>>(
                            future: totalsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text('No data available'));
                              } else {
                                Map<String, double> totals = snapshot.data!;
                                totalReview = snapshot.data!;
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: totals.entries
                                        .map((entry) => Expanded(
                                              flex: 1,
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 0.0),
                                                      child: Text(
                                                        "Total ${entry.key}",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    ),
                                                    Text(
                                                      entry.value
                                                          .toStringAsFixed(2),
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ))
                                        .toList());
                              }
                            },
                          ),

                          InkWell(
                            onTap: () => printCashReceipt(),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              decoration: BoxDecoration( borderRadius: BorderRadius.circular(10), color: primaryColor),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Print Report", style: GoogleFonts.poppins(color: whiteColor, fontWeight: FontWeight.w600),),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
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
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  getFilterRecords() {
    fetchHistory = httpService.getSummaryPaymentHistory(
        'v2/paymentOfferingSummary', {
      "churchId": widget.churchId,
      "startDate": _startDate,
      "endDate": _endDate
    });

    totalsFuture = calculateTotals(fetchHistory);
  }



   void _onSelectionChanged(DateTime startDate, DateTime endDate) {
    // Equivalent to your SfDateRangePicker selection handler
    if (startDate == null || endDate == null) {
      return;
    }

    setState(() {
      _rangeStart = startDate;
      _rangeEnd = endDate;

      _startDate = DateFormat('yyyy-MM-dd').format(startDate);
      _endDate = DateFormat('yyyy-MM-dd').format(endDate);


      if (kDebugMode) {
        print('START : $_startDate - LAST $_endDate');
      }
    });

    getFilterRecords();
  }

  Future<Map<String, double>>? totalsFuture;
  Map<String, double> ?    totalReview ;
  Future<Map<String, double>> calculateTotals(
      Future<List<SummaryOfferingsModel>> futureRecords) async {
    Map<String, double> totals = {};

    List<SummaryOfferingsModel> records = await futureRecords;

    for (var record in records) {
      for (var currency in record.currencies!) {
        if (totals.containsKey(currency.currency)) {
          totals[currency.currency!] =
              totals[currency.currency!]! + double.parse(currency.amount!);
        } else {
          totals[currency.currency!] = double.parse(currency.amount!);
        }
      }
    }

    return totals;
  }

  Future<String> getUniqueDeviceId() async {
    String uniqueDeviceId = '';

    var deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      uniqueDeviceId =
      '${iosDeviceInfo.name}:${iosDeviceInfo.identifierForVendor}'; // unique ID on iOS
      deviceId = '${iosDeviceInfo.identifierForVendor}';
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      uniqueDeviceId =
      '${androidDeviceInfo.model}:${androidDeviceInfo.id}'; // unique ID on Android
      deviceId = '${androidDeviceInfo.id}';
    }

    return uniqueDeviceId;
  }

  String deviceId = '';

  //POS SUN MI PRINTER
  bool printBinded = false;
  int paperSize = 0;
  String serialNumber = "";
  String printerVersion = "";

  /// must binding ur printer at first init in app
  Future<bool?> _bindingPrinter() async {
    final bool? result = await SunmiPrinter.bindingPrinter();
    return result;
  }

  Widget singleItem(String title, List<Widget> curreny) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: grayColor),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0.0, 2.0),
            color: Color(0xffEDEDED),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: curreny,
          ),
        ],
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

  void showSuccess(String message) {
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

  printCashReceipt() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      var deviceModel = androidDeviceInfo.model;
      // showError("Device model: $deviceModel");
      if (deviceModel == 'NB55') {
        await printCashReceiptWithNB55();
        return;
      }
    } else {
      showError("Print is not available for IOS");
      return;
    }
    await SunmiPrinter.initPrinter();
    await SunmiPrinter.startTransactionPrint(true);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText(translate('app_txt_cash_receipt'),
        style: SunmiStyle(fontSize: SunmiFontSize.XL, bold: true));
    await SunmiPrinter.line();
    await SunmiPrinter.printText('${translate('app_txt_member')}: ${member.name}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.printText('${translate('app_txt_phone')}: ${member.phone}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.printText('${translate('app_txt_church')}: ${member.church}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.printText('${translate('app_txt_code')}${member.churchCode}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));

    await SunmiPrinter.line();


    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
          text: translate('app_txt_donation'),
          width: 16,
          align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: translate('app_txt_amount'), width: 12, align: SunmiPrintAlign.RIGHT),

    ]);


    _selectedOffering.map((item) {
      SunmiPrinter.printRow(cols: [
        ColumnMaker(
            text: '${item.title}', width: 30, align: SunmiPrintAlign.LEFT),
      ]);
      item.currencies!.forEach((element) {
        SunmiPrinter.printRow(cols: [
          ColumnMaker( text: '${element.currency}', width: 15, align: SunmiPrintAlign.RIGHT),
          ColumnMaker( text: '${element.amount}', width: 15, align: SunmiPrintAlign.RIGHT),
        ]);
      });

    }).toList();

    await SunmiPrinter.line();
    await SunmiPrinter.printText(
        '${translate('app_txt_total')}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    totalReview!.entries.map((item) {
      SunmiPrinter.printRow(cols: [
        ColumnMaker(
            text: '${item.key}', width: 30, align: SunmiPrintAlign.LEFT),
        ColumnMaker(
            text: '${item.value}', width: 30, align: SunmiPrintAlign.LEFT),
      ]);
    }).toList();

    await SunmiPrinter.line();
    await SunmiPrinter.printText(
        '${translate('app_txt_printed_by')}: ${member.name}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.printText(
        '${translate('app_txt_printed_at')}: ${DateFormat("yyyy-MM-dd h:m:s").format(DateTime.now())}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.line();
    await SunmiPrinter.printText(".\n\n");
    await SunmiPrinter.line();
    await SunmiPrinter.exitTransactionPrint(true);
  }

  printCashReceiptWithNB55() async {
    bool? printerInitiated = await Nb55Printer.bindingPrinter();
    if (!printerInitiated!) {
      showError(
          "Unable to print receipt, no supported printer found. Contact BESOFT Team");
      return;
    }
    await Nb55Printer.printText(translate('app_txt_cash_receipt'));
    await Nb55Printer.line();
    await Nb55Printer.printText(
        '${translate('app_txt_member')}: ${member.name}');
    await Nb55Printer.printText(
        '${translate('app_txt_phone')}: ${member.phone}');
    await Nb55Printer.printText('${translate('app_txt_church')}: ${member.church}');
    await Nb55Printer.printText('${translate('app_txt_code')}${member.churchCode}');
    await Nb55Printer.printText(translate('app_txt_donation'));

    _selectedOffering.map((item) {
       Nb55Printer.printText('${item.title}');
      item.currencies!.forEach((element) {
        Nb55Printer.printText('${element.currency}: ${element.amount}');});
    }).toList();

    await Nb55Printer.printText(
        "${translate('app_txt_total')} ");

    totalReview!.entries.map((item) {
      Nb55Printer.printText(
          "${item.key}: ${item.value.toStringAsFixed(2)} ");
    }).toList();
    await Nb55Printer.printText('${translate('app_txt_printed_by')}: ${member.name}');
    await Nb55Printer.printText(
        '${translate('app_txt_printed_at')}: ${DateFormat("yyyy-MM-dd h:m:s").format(DateTime.now())}');
    await Nb55Printer.printText("\n\n");
    await Nb55Printer.line();
    await Nb55Printer.line();
  }

}
