// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/models/user_model.dart';
import 'package:cfms/screens/admin/admin.dashboard.screen.dart';
import 'package:cfms/screens/admin/select_quick_payment.dart';
import 'package:flutter_translate/flutter_translate.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cfms/models/donations/donation.dart';
import 'package:cfms/models/members/member.dart';
import 'package:cfms/models/payment_history_model.dart';
import 'package:cfms/services/api/http_services.dart';
import 'package:cfms/widgets/buttons/loading_button.dart';
import 'package:cfms/widgets/cards/history_card_loading.dart';
import 'package:cfms/widgets/lists/offering_list_item.dart';
import 'package:cfms/widgets/lists/offering_payment_item.dart';
import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/pending_model.dart';
import '../../models/quick_history_model.dart';
import '../../services/provider/donation_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';

import '../../utils/routes.dart';

class QuickPaymentHistory extends StatefulWidget {
  final String userId;
  final String countryCode;
  final String churchName;

  const QuickPaymentHistory(
      {Key? key,
      required this.userId,
      required this.countryCode,
      required this.churchName})
      : super(key: key);

  @override
  State<QuickPaymentHistory> createState() => _QuickPaymentHistoryState();
}

class _QuickPaymentHistoryState extends State<QuickPaymentHistory> {
  HttpService httpService = HttpService();
  TextEditingController reasonController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  final formGlobalKeyCancel = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();

  bool _isFilter = false;
  bool _isSwitch = false;
  final bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isDownloading = false;
  late Data user;
  var offeringPayments = <DonationModel>[];
  var listFiltered = <PaymentHistoryModel>[];
  // String _startDate = '2022-01-01';
  String _startDate =  DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 30)));
  String _endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  // String _endDate = '2024-07-01';
  late UserModel currentUser;
  String countryCurrency = "";
  String? userId, userPhone;
  late final Future<List<QuickHistoryModel>> fetchHistory;
  late Future<List<PendingOfferingsModel>> fetchPendingHistory;
  final ReceivePort _port = ReceivePort();


  _loadingUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('currentUser') ?? '';
    String currency = prefs.getString('countryCurrency') ?? '';
    Map<String, dynamic> map = jsonDecode(json);
    currentUser = UserModel.fromJson(map);
    setState(() {
      userId = currentUser.id;
      userPhone = currentUser.phone;
      countryCurrency = currency;
    });
  }

  //test
  List<DateTime>? rangeSelect;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting();
    _loadingUserData();
    print("${_endDate} ${_startDate}");
    fetchHistory = httpService
        .getQuickPaymentHistory('v3/quick-payment/report/${widget.userId}');
    fetchPendingHistory = httpService.getPendingPaymentHistory(
        'v3/getPendingCashReceipts', {
      "user_id": widget.userId,
      "startDate": _startDate,
      "endDate": _endDate
    });
    // monitorDownloadProgress();
  }
  int hasDataFetch = 0;
  // void monitorDownloadProgress() async {
  //   IsolateNameServer.registerPortWithName(
  //       _port.sendPort, "invoice_downloader_port");
  //   _port.listen((dynamic data) {
  //     String id = data[0];
  //     DownloadTaskStatus status = data[1];
  //     int progress = data[2];
  //     if (kDebugMode) {
  //       print("invoice_downloader_port $progress");
  //     }
  //     if (status.index == 3) {
  //       //downloaded, open
  //       Future.delayed(const Duration(seconds: 2))
  //           .then((value) => FlutterDownloader.open(taskId: id));
  //       showSuccess("download completed");
  //     }
  //   });
  // }

  quickPaymentPay(String amount, DateTime date) async {}

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('invoice_downloader_port');
    super.dispose();
  }

  cancelReceipt(String selectedCodeUrl, String id, String phone) async {
    var data = {
      'id': id.toString(),
      'userId': widget.userId,
      'reason': reasonController.text,
      'phone': phone
    };

    if (kDebugMode) {
      print(data);
    }
    var response = await httpService.postAppData(
        data, selectedCodeUrl, 'v2/cancelQuickPaymentMobile');
    var body = json.decode(response.body);
    if (kDebugMode) {
      print(response);
    }
    setState(() {});
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(body);
        print("offerings cancelled sent");
        getFilterPendingRecords();
      }
      setState(() {
        reasonController.text = "";
      });
      Navigator.pop(context);
    } else {
      if (kDebugMode) {
        print("sms not sent");
      }
      showErrorAlert(translate("app_txt_otp_not_sent"));
    }
  }
  bool isANumber = true;
  bool _isApiLoading = false;
  RegExp digitValidator = RegExp(r'(^(?:[+0]9)?[0-9]{5,10}$)');
  void setValidator(valid) {
    setState(() {
      isANumber = valid;
    });
  }
    DateTime? _rangeStart;
  DateTime? _rangeEnd;
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

  int selectedTab = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (_) => DonationProvider(),
        child: Builder(
          builder: (context) {
            final records = Provider.of<DonationProvider>(context);
            return Scaffold(
              backgroundColor: whiteColor,
              appBar: AppBar(
                backgroundColor: primaryColor,
                elevation: 0,
                leading: InkWell(
                    onTap: () {
                      Navigator.push(
                          context, MyPageRoute(widget: AdminDashboard()));
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
                physics: const NeverScrollableScrollPhysics(),
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
                                        _isSwitch = false;
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
                              visible: !_isSwitch,
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
                            InkWell(
                              onTap: () => {},
                              child: _isSwitch
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: transparentColor1,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      margin: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        translate(
                                                            'app_txt_from'),
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300)),
                                                  ),
                                                  Text(_startDate,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                  const SizedBox(
                                                    height: 5,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        translate('app_txt_to'),
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300)),
                                                  ),
                                                  Text(_endDate,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                  const SizedBox(
                                                    height: 5,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : LoadingButton(
                                      icon: Icons.calendar_today_outlined,
                                      backgroundColor: primaryColor,
                                      width: 200,
                                      title: translate('app_txt_pick_date'),
                                      isLoading: _isLoading,
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                          color: greyColor1,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedTab = 1;
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
                                                translate(
                                                    "app_txt_offering_by_total"),
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
                                                translate(
                                                    "app_txt_list_donation"),
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
                          Visibility(
                            visible: selectedTab == 2,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: whiteColor,

                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Form(
                                key: formGlobalKey,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 11, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3, horizontal: 8),
                                            child: Text(
                                                "${translate('app_txt_phone_number')} / ${translate('app_txt_member_code')} ",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 12, color: transparentColor2)),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(vertical: 5),
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
                                              style: GoogleFonts.poppins(fontSize: 12.0),
                                              decoration: InputDecoration(
                                                errorText: isANumber
                                                    ? null
                                                    : translate('app_txt_please_enter_phone_number'),
                                                hintText: translate(
                                                    'app_txt_phone_number'),
                                                border: const OutlineInputBorder(),
                                                contentPadding: const EdgeInsets.symmetric(
                                                    vertical: 15, horizontal: 10),
                                                suffixIcon:
                                                isANumber || phoneController.text.isEmpty
                                                    ? !phoneController.text.isEmpty
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

                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: true,
                                      child: _isApiLoading
                                          ? const SpinKitCircle(
                                        color: primaryColor,
                                        size: 44,
                                      )
                                          : LoadingButton(
                                        icon: Icons.search_rounded,
                                        backgroundColor: primaryColor,
                                        width: 200,
                                        title: translate('app_txt_search'),
                                        isLoading: _isLoading,
                                        onTap: () {
                                          if (formGlobalKey.currentState!.validate()) {
                                            if (!isANumber ||
                                                phoneController.text.isEmpty) {
                                              showError(translate(
                                                        "app_txt_you_must_enter_all_field"));
                                            } else {
                                              setState(() {
                                                _isApiLoading = true;
                                              });
                                              searchMember();
                                            }
                                          }
                                        },
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Visibility(
                      visible: selectedTab == 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 10),
                            child: Text(
                              translate("app_txt_offering_by_total"),
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                  fontSize: 17, fontWeight: FontWeight.w400),
                            ),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: _isSwitch
                                ? !_isLoadingData
                                    ? ListView.builder(
                                        itemCount: 4,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, pos) {
                                          return const HistoryCardLoading();
                                        })
                                    : listFiltered.isEmpty
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                   translate( "app_txt_no_data_found"),
                                                    style: GoogleFonts.poppins(
                                                        color: redColor,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount: listFiltered.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () async {
                                                  await httpService
                                                      .getPublicData(
                                                          widget.countryCode,
                                                          'v2/paymentOfferingHistory/${listFiltered[index].id}')
                                                      .then((response) {
                                                    setState(() {
                                                      Iterable list =
                                                          json.decode(
                                                              response.body);
                                                      offeringPayments = list
                                                          .map((model) =>
                                                              DonationModel
                                                                  .fromJson(
                                                                      model))
                                                          .toList();
                                                      // print(list);
                                                    });
                                                  });
                                                   AlertDialog(
                                                    title: Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .church_rounded,
                                                            size: 35,
                                                            color: primaryColor,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    listFiltered[
                                                                            index]
                                                                        .church
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color:
                                                                            primaryColor,
                                                                        fontSize:
                                                                            13)),
                                                                Text(
                                                                    translate('app_txt_code') +
                                                                        listFiltered[index]
                                                                            .churchCode
                                                                            .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w300,
                                                                        color:
                                                                            primaryColor,
                                                                        fontSize:
                                                                            13)),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    content: SizedBox(
                                                      height: 270,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    transparentColor1,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7)),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8.0,
                                                                  vertical: 5),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      translate(
                                                                          "app_txt_tot_amount"),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: GoogleFonts.poppins(
                                                                          fontWeight: FontWeight
                                                                              .w300,
                                                                          color:
                                                                              primaryColor,
                                                                          fontSize:
                                                                              12)),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                          countryCurrency,
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style: GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w300,
                                                                              color: primaryColor,
                                                                              fontSize: 20)),
                                                                      Text(
                                                                          listFiltered[index]
                                                                              .amount
                                                                              .toString(),
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style: GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w500,
                                                                              color: primaryColor,
                                                                              fontSize: 20)),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 210,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: ListView
                                                                .builder(
                                                                    itemCount:
                                                                        offeringPayments
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return OfferingPaymentItem(
                                                                        title:
                                                                            '${offeringPayments[index].donationName}',
                                                                        amount:
                                                                            '${offeringPayments[index].amount}',
                                                                        icon: Icons
                                                                            .church_rounded,
                                                                        currency:
                                                                            countryCurrency,
                                                                      );
                                                                    }),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                          child: Text(
                                                              translate(
                                                                  "app_txt_close"),
                                                              style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color:
                                                                      redColor,
                                                                  fontSize:
                                                                      14)),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          }),
                                                    ],
                                                  );
                                                },
                                                child: ItemRecordList(
                                                  letter: listFiltered[index]
                                                      .church
                                                      .toString()[0]
                                                      .toUpperCase(),
                                                  title: listFiltered[index]
                                                      .church
                                                      .toString(),
                                                  amount: listFiltered[index]
                                                      .amount
                                                      .toString(),
                                                  status: int.parse(
                                                      listFiltered[index]
                                                          .status
                                                          .toString()),
                                                  churchCode:
                                                      listFiltered[index]
                                                          .churchCode
                                                          .toString(),
                                                  date: DateTime.parse(
                                                      listFiltered[index]
                                                          .date
                                                          .toString()),
                                                ),
                                              );
                                            })
                                : FutureBuilder(
                                    future: fetchHistory,
                                    builder: (BuildContext ctx,
                                        AsyncSnapshot<List<QuickHistoryModel>>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        return ListView.builder(
                                            itemCount: snapshot.data?.length,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              var item = snapshot.data!;
                                              return singleGroupItem(
                                                item[index].id.toString(),
                                                item[index].count.toString(),
                                                item[index].amount.toString(),
                                                item[index].currency.toString(),
                                                item[index].newTrxId.toString(),
                                                widget.churchName,
                                                DateTime.parse(item[index]
                                                    .date
                                                    .toString()),
                                                int.parse(item[index]
                                                    .status
                                                    .toString()),
                                              );
                                            });
                                      } else {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: const [
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
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: selectedTab == 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 10),
                            child: Text(
                              translate("app_txt_list_donation"),
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                  fontSize: 17, fontWeight: FontWeight.w400),
                            ),
                          ),
                          const SizedBox(
                            height: 1,
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: FutureBuilder(
                              future: fetchPendingHistory,
                              builder: (BuildContext ctx,
                                  AsyncSnapshot<List<PendingOfferingsModel>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  hasDataFetch = snapshot.data!.length;
                                  return ListView.builder(
                                      itemCount: snapshot.data?.length,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        var item = snapshot.data!;
                                        return singleItem(
                                            item[index].id.toString(),
                                            item[index].phone.toString(),
                                            item[index].totalAmount.toString(),
                                            DateTime.parse(item[index]
                                                .createdAt
                                                .toString()),
                                            item[index].currency.toString());
                                      });
                                } else {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: const [
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
                            ),
                          )  ,
                        ],
                      ),
                    ),
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
            );
          },
        ),
      ),
    );
  }

  getFilterPendingRecords() async {
    fetchPendingHistory = httpService.getPendingPaymentHistory(
        'v3/getPendingCashReceipts', {
      "user_id": widget.userId,
      "startDate": _startDate,
      "endDate": _endDate
    });
  }

  getFilterRecords() async {
    await httpService
        .getPublicData(widget.countryCode,
            'v3/paymentHistory/${widget.userId}/$_startDate/$_endDate')
        .then((response) {
      setState(() {
        print("RESULT NEW ${response.body}");
        Iterable list = json.decode(response.body);
        listFiltered =
            list.map((model) => PaymentHistoryModel.fromJson(model)).toList();
        setState(() {
          _isLoadingData = false;
        });
        print("RESULT NEW ${list}");
      });
    });
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

      _isSwitch = true;

      if (kDebugMode) {
        print('START : $_startDate - LAST $_endDate');
      }
    });

    getFilterPendingRecords();
  }
  Widget singleItem(
      String id, String phone, String amount, DateTime date, String currency) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: primaryOverlayColor),
                  child: Center(
                    child: Text(
                      "1",
                      style: GoogleFonts.poppins(
                          color: blackColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 19),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phone,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400, fontSize: 13),
                        ),
                        SizedBox(
                          width: 170,
                          child: Row(
                            children: [
                              Text(
                                amount,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: blackColor,
                                    fontSize: 18),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  currency,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      color: blackColor,
                                      fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        TextButton(
                            onPressed: () async {
                              await AlertDialog(
                                title: Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            color: redColorOverlay,
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  translate(
                                                      "app_txt_cancel_cash_receipt"),
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: redColor,
                                                      fontSize: 20)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                        "${translate("app_txt_phone")}: ",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    primaryColor,
                                                                fontSize: 14)),
                                                    Text(phone,
                                                        textAlign:
                                                            TextAlign.left,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    primaryColor,
                                                                fontSize: 18)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                        "${translate("app_txt_amount")}: ",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    primaryColor,
                                                                fontSize: 14)),
                                                    Text(amount,
                                                        textAlign:
                                                            TextAlign.left,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    primaryColor,
                                                                fontSize: 18)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                content: Container(
                                  height: 190,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                                translate(
                                                    "app_txt_are_you_sure"),
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w300,
                                                    color: redColor,
                                                    fontSize: 15)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 145,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Form(
                                          key: formGlobalKeyCancel,
                                          child: Column(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            vertical: 5),
                                                        child: TextField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          controller:
                                                              reasonController,
                                                          maxLines: 4,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize:
                                                                      13.0),
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                translate(
                                                                'app_txt_reason'),
                                                            border:
                                                                const OutlineInputBorder(),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        10),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: LoadingButton(
                                      icon: Icons.arrow_forward,
                                      backgroundColor: primaryColor,
                                      width: 180,
                                      title: translate(
                                          'app_txt_cancel_cash_receipt'),
                                      isLoading: _isLoading,
                                      onTap: () {
                                        if (reasonController.text.length > 0) {
                                          cancelReceipt(
                                            widget.countryCode,
                                            id,
                                            phone,
                                          );
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                translate(
                                                    "app_txt_reason_required"),
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w300,
                                                    color: redColor,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  )
                                ],
                              );
                            },
                            child: Text(
                              translate("app_txt_cancel"),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: redColor,
                                  fontSize: 15),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 7, bottom: 3),
                child: Text(
                  translate('app_txt_date') + DateFormat.yMMMEd().format(date),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget singleGroupItem(
      String id,
      String count,
      String amount,
      String currency,
      String newTrxId,
      String church,
      DateTime date,
      int status) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: primaryOverlayColor),
                  child: Center(
                    child: Text(
                      count,
                      style: GoogleFonts.poppins(
                          color: blackColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 19),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          church,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400, fontSize: 13),
                        ),
                        SizedBox(
                          width: 170,
                          child: Row(
                            children: [
                              Text(
                                amount,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: blackColor,
                                    fontSize: 18),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  currency,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      color: blackColor,
                                      fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        status != 1
                            ? TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MyPageRoute(
                                          widget: QuickPaymentMethod(
                                        totalAmount: amount,
                                        date: DateFormat('yyyy-MM-dd')
                                            .format(date),
                                        userId: '$userId',
                                        userPhone: '$userPhone',
                                        countryCurrency: currency,
                                      )));
                                },
                                child: Text(
                                  translate("app_txt_tap_pay"),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: greenColor,
                                      fontSize: 15),
                                ))
                            : Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, top: 7, bottom: 3),
                                child: Column(
                                  children: [
                                    Text(
                                      status == 1
                                          ? translate('app_txt_approved')
                                          : status == 2
                                              ? translate('app_txt_cancelled')
                                              : translate('app_txt_pending'),
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: status == 1
                                              ? greenColor
                                              : status == 2
                                                  ? redColor
                                                  : orangeColor,
                                          fontSize: 14),
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          child: _isDownloading
                                              ? const SizedBox(
                                                  height: 30,
                                                  width: 30,
                                                  child:
                                                      CircularProgressIndicator())
                                              : const Icon(
                                                  Icons.cloud_download_rounded,
                                                  size: 30,
                                                ),
                                          onTap: () async {
                                            // var storageStatus = await Permission
                                            //     .storage
                                            //     .request();
                                            // if (!storageStatus.isGranted) {
                                            //   showError(
                                            //       "app_txt_storage_permission_issue"
                                            //           .tr());
                                            //   return;
                                            // }

                                            // var result = await HttpService()
                                            //     .downloadReceipt(newTrxId, 1);
                                            // if (result != null) {
                                            //   showError(result);
                                            //   setState(() {
                                            //     _isDownloading = false;
                                            //   });
                                            // } else {
                                            //   showSuccess("Download started");
                                            // }
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 7, bottom: 3),
                child: Text(
                  translate('app_txt_date') + DateFormat.yMMMEd().format(date),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300, fontSize: 12),
                ),
              ),
            ],
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

  void searchMember() {
    fetchPendingHistory = httpService.getPendingPaymentHistory(
        'v3/getPendingCashReceipts', {
      "user_id": widget.userId,
      "startDate": _startDate,
      "endDate": _endDate,
      'searchQuery': phoneController.text
    });

    setState(() {
      _isApiLoading = false;
    });
  }
}
