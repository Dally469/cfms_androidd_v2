// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_translate/flutter_translate.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:cfms/models/donations/donation.dart';
import 'package:cfms/models/members/member.dart';
import 'package:cfms/models/payment_history_model.dart';
import 'package:cfms/services/api/http_services.dart';
import 'package:cfms/widgets/buttons/loading_button.dart';
import 'package:cfms/widgets/cards/history_card_loading.dart';
import 'package:cfms/widgets/lists/offering_list_item.dart';
import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/provider/donation_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../widgets/lists/offering_payment_item.dart';

class HistoryDonation extends StatefulWidget {
  final String memberCode;
  final String countryCode;
  final String countryCurrency;

  const HistoryDonation(
      {Key? key,
      required this.memberCode,
      required this.countryCode,
      required this.countryCurrency})
      : super(key: key);

  @override
  State<HistoryDonation> createState() => _HistoryDonationState();
}

class _HistoryDonationState extends State<HistoryDonation> {
  HttpService httpService = HttpService();
  bool _isFilter = false;
  bool _isSwitch = false;
  bool _isLoading = false;
  bool _isSwitchData = false;
  bool _isLoadingData = true;
  bool _isDataAvailable = false;
  bool _isDownloading = false;
  late Data user;
  var offeringPayments = <DonationModel>[];
  var listFiltered = <PaymentHistoryModel>[];
  var allListFiltered = <PaymentHistoryModel>[];
  String _startDate = '';
  String _endDate = '';

  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  //test
  List<DateTime>? rangeSelect;
  final ReceivePort _port = ReceivePort();
  late Future<List<PaymentHistoryModel>> fetchPaymentHistory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting();
    fetchPaymentHistory = httpService
        .getPaymentHistory('v2/paymentHistory/${widget.memberCode}')
        .catchError((e) {
      List<PaymentHistoryModel> data = [];
      return data;
    });
    updateUi();
    // monitorDownloadProgress();
  }

  // void monitorDownloadProgress()async{
  //   IsolateNameServer.registerPortWithName(_port.sendPort, "invoice_downloader_port");
  //   _port.listen((dynamic data) {
  //     String id = data[0];
  //     DownloadTaskStatus status = data[1];
  //     int progress = data[2];
  //     if (kDebugMode) {
  //       print("invoice_downloader_port $progress");
  //     }
  //     if (status.index ==3){
  //       //downloaded, open
  //       showSuccess("download completed");
  //       Future.delayed(const Duration(seconds: 2)).then((value) => FlutterDownloader.open(taskId: id));
  //     }
  //     setState((){
  //       _isDownloading = false;
  //     });
  //   });

  // }

  void updateUi() async {
    List list = await fetchPaymentHistory;
    setState(() {
      _isDataAvailable = list.isNotEmpty;
    });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('invoice_downloader_port');
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
            final records = Provider.of<DonationProvider>(context);
            return Scaffold(
              backgroundColor: whiteColor,
              appBar: AppBar(
                backgroundColor: primaryColor,
                elevation: 0,
                leading: InkWell(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop(context);
                      // Navigator.push(context, MyPageRoute(widget: Dashboard()));
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: whiteColor,
                    )),
                title: Text(translate("app_txt_history"),
                    style: GoogleFonts.poppins(
                        color: whiteColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 20)),
                actions: [
                  Visibility(
                    visible: _isDataAvailable,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            _isFilter = true;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextButton(
                            onPressed: () {},
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: whiteColor,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Text("Export",
                                      style: GoogleFonts.poppins(
                                        color: whiteColor,
                                        fontWeight: FontWeight.w400,
                                      )),
                                )
                              ],
                            ),
                          ),
                        )),
                  ),
                  Visibility(
                    visible: _isDataAvailable,
                    child: InkWell(
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
                  ),
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
                                        _isSwitch = false;
                                        _isFilter = false;
                                        _isLoadingData = false;
                                        _isSwitchData = false;
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
                    Column(
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
                          child: _isSwitch
                              ? _isLoadingData
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
                                                  translate(
                                                      "app_txt_no_data_found"),
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
                                                setState(() {
                                                  _isLoadingData = true;
                                                });
                                                await httpService
                                                    .getPublicData(
                                                        widget.countryCode,
                                                        'v2/paymentOfferingHistory/${listFiltered[index].id}')
                                                    .then((response) {
                                                  setState(() {
                                                    Iterable list = json
                                                        .decode(response.body);
                                                    offeringPayments = list
                                                        .map((model) =>
                                                            DonationModel
                                                                .fromJson(
                                                                    model))
                                                        .toList();
                                                    // print(list);
                                                  });
                                                });
                                                // await NDialog(
                                                //   dialogStyle: DialogStyle(
                                                //       titleDivider: false),
                                                //   title: Container(
                                                //     margin:
                                                //         EdgeInsets.symmetric(
                                                //             vertical: 10),
                                                //     child: Row(
                                                //       children: [
                                                //         Padding(
                                                //           padding:
                                                //               const EdgeInsets
                                                //                       .symmetric(
                                                //                   horizontal:
                                                //                       8.0),
                                                //           child: Column(
                                                //             mainAxisAlignment:
                                                //                 MainAxisAlignment
                                                //                     .start,
                                                //             crossAxisAlignment:
                                                //                 CrossAxisAlignment
                                                //                     .start,
                                                //             children: [
                                                //               Text(
                                                //                   listFiltered[
                                                //                           index]
                                                //                       .church
                                                //                       .toString(),
                                                //                   textAlign:
                                                //                       TextAlign
                                                //                           .left,
                                                //                   style: GoogleFonts.poppins(
                                                //                       fontWeight:
                                                //                           FontWeight
                                                //                               .w400,
                                                //                       color:
                                                //                           primaryColor,
                                                //                       fontSize:
                                                //                           13)),
                                                //               Text(
                                                //                   'app_txt_code'
                                                //                           .tr() +
                                                //                       listFiltered[
                                                //                               index]
                                                //                           .churchCode
                                                //                           .toString(),
                                                //                   textAlign:
                                                //                       TextAlign
                                                //                           .left,
                                                //                   style: GoogleFonts.poppins(
                                                //                       fontWeight:
                                                //                           FontWeight
                                                //                               .w300,
                                                //                       color:
                                                //                           primaryColor,
                                                //                       fontSize:
                                                //                           13)),
                                                //             ],
                                                //           ),
                                                //         ),
                                                //         Expanded(
                                                //             child: Center()),
                                                //         InkWell(
                                                //           child: _isDownloading
                                                //               ? const SizedBox(
                                                //                   height: 30,
                                                //                   width: 30,
                                                //                   child:
                                                //                       CircularProgressIndicator())
                                                //               : Row(
                                                //                 children: [
                                                //                   const Icon(
                                                //                       Icons
                                                //                           .cloud_download_rounded,
                                                //                       size: 30,
                                                //                     ),
                                                //                   Text("app_txt_download".tr(), style: TextStyle(fontSize: 15)),
                                                //                 ],
                                                //               ),
                                                //           onTap: () async {
                                                //             showSuccess("Download started");
                                                //             var storageStatus =
                                                //                 await Permission
                                                //                     .storage
                                                //                     .request();
                                                //             if (!storageStatus
                                                //                 .isGranted) {
                                                //               showError(
                                                //                   "app_txt_storage_permission_issue"
                                                //                       .tr());
                                                //               return;
                                                //             }
                                                //             setState(() {
                                                //               _isDownloading =
                                                //               true;
                                                //             });
                                                //             var result = await HttpService()
                                                //                 .downloadReceipt(
                                                //                     listFiltered[
                                                //                             index]
                                                //                         .trxId!,
                                                //                     0);
                                                //             if (result !=
                                                //                 null) {
                                                //               showError(result);
                                                //               setState(() {
                                                //                 _isDownloading =
                                                //                     false;
                                                //               });
                                                //             }
                                                //           },
                                                //         )
                                                //       ],
                                                //     ),
                                                //   ),
                                                //   content: SizedBox(
                                                //     height: 270,
                                                //     child: Column(
                                                //       mainAxisAlignment:
                                                //           MainAxisAlignment
                                                //               .start,
                                                //       crossAxisAlignment:
                                                //           CrossAxisAlignment
                                                //               .start,
                                                //       children: [
                                                //         Container(
                                                //           width: MediaQuery.of(
                                                //                   context)
                                                //               .size
                                                //               .width,
                                                //           decoration: BoxDecoration(
                                                //               color:
                                                //                   transparentColor1,
                                                //               borderRadius:
                                                //                   BorderRadius
                                                //                       .circular(
                                                //                           7)),
                                                //           child: Padding(
                                                //             padding:
                                                //                 const EdgeInsets
                                                //                         .symmetric(
                                                //                     horizontal:
                                                //                         8.0,
                                                //                     vertical:
                                                //                         5),
                                                //             child: Column(
                                                //               crossAxisAlignment:
                                                //                   CrossAxisAlignment
                                                //                       .start,
                                                //               mainAxisAlignment:
                                                //                   MainAxisAlignment
                                                //                       .start,
                                                //               children: [
                                                //                 Text("app_txt_tot_amount".tr(),
                                                //                     textAlign:
                                                //                         TextAlign
                                                //                             .center,
                                                //                     style: GoogleFonts.poppins(
                                                //                         fontWeight:
                                                //                             FontWeight
                                                //                                 .w300,
                                                //                         color:
                                                //                             primaryColor,
                                                //                         fontSize:
                                                //                             12)),
                                                //                 Row(
                                                //                   children: [
                                                //                     Text(
                                                //                         '${widget.countryCurrency} ' +
                                                //                             ' ',
                                                //                         textAlign:
                                                //                             TextAlign
                                                //                                 .center,
                                                //                         style: GoogleFonts.poppins(
                                                //                             fontWeight: FontWeight
                                                //                                 .w300,
                                                //                             color:
                                                //                                 primaryColor,
                                                //                             fontSize:
                                                //                                 20)),
                                                //                     Text(
                                                //                         listFiltered[index]
                                                //                             .amount
                                                //                             .toString(),
                                                //                         textAlign:
                                                //                             TextAlign
                                                //                                 .center,
                                                //                         style: GoogleFonts.poppins(
                                                //                             fontWeight: FontWeight
                                                //                                 .w500,
                                                //                             color:
                                                //                                 primaryColor,
                                                //                             fontSize:
                                                //                                 20)),
                                                //                   ],
                                                //                 ),
                                                //               ],
                                                //             ),
                                                //           ),
                                                //         ),
                                                //         Container(
                                                //           height: 210,
                                                //           width: MediaQuery.of(
                                                //                   context)
                                                //               .size
                                                //               .width,
                                                //           child:
                                                //               ListView.builder(
                                                //                   itemCount:
                                                //                       offeringPayments
                                                //                           .length,
                                                //                   itemBuilder:
                                                //                       (context,
                                                //                           index) {
                                                //                     return OfferingPaymentItem(
                                                //                       title:
                                                //                           '${offeringPayments[index].donationName}',
                                                //                       amount:
                                                //                           '${offeringPayments[index].amount}',
                                                //                       icon: Icons
                                                //                           .church_rounded,
                                                //                       currency:
                                                //                           '${widget.countryCurrency}',
                                                //                     );
                                                //                   }),
                                                //         )
                                                //       ],
                                                //     ),
                                                //   ),
                                                //   actions: <Widget>[
                                                //     TextButton(
                                                //         child: Text(
                                                //             "app_txt_close"
                                                //                 .tr(),
                                                //             style: GoogleFonts.poppins(
                                                //                 fontWeight:
                                                //                     FontWeight
                                                //                         .w300,
                                                //                 color: redColor,
                                                //                 fontSize: 14)),
                                                //         onPressed: () {
                                                //           Navigator.pop(
                                                //               context);
                                                //         }),
                                                //   ],
                                                // ).show(context);
                                                setState(() {
                                                  _isLoadingData = false;
                                                });
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
                                                churchCode: listFiltered[index]
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
                                  future: fetchPaymentHistory,
                                  builder: (BuildContext ctx,
                                      AsyncSnapshot<List<PaymentHistoryModel>>
                                          snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data?.length == 0) {
                                        return Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                "assets/images/logo/no_data_found.png",
                                                scale: 1.5,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    "${translate("app_txt_no_data_available")} ${_startDate} - ${_endDate}",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: blackColor)),
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                      return _isSwitchData
                                          ? Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 140,
                                                  ),
                                                  const SpinKitDoubleBounce(
                                                    size: 40,
                                                    color: primaryOverlayColor,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        "${translate("app_txt_loading_data_available")} ${_startDate} - ${_endDate}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    blackColor)),
                                                  )
                                                ],
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: snapshot.data?.length,
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return InkWell(
                                                  onTap: () async {
                                                    await httpService
                                                        .getPublicData(
                                                            widget.countryCode,
                                                            'v2/paymentOfferingHistory/${snapshot.data![index].id}')
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
                                                    showCustomDialog(context, snapshot, index);
                                                  },
                                                  child: ItemRecordList(
                                                    letter:
                                                        snapshot.data![index].church.toString()[0].toUpperCase(),
                                                    title: snapshot
                                                        .data![index].church
                                                        .toString(),
                                                    amount: snapshot
                                                        .data![index].amount
                                                        .toString(),
                                                    status: int.parse(snapshot
                                                        .data![index].status
                                                        .toString()),
                                                    churchCode: snapshot
                                                        .data![index].churchCode
                                                        .toString(),
                                                    date: DateTime.parse(
                                                        snapshot
                                                            .data![index].date
                                                            .toString()),
                                                  ),
                                                );
                                              });
                                    } else {
                                      return _isLoadingData
                                          ? const Center(
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
                                            )
                                          : Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    "assets/images/logo/no_data_found.png",
                                                    scale: 1.5,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        translate(
                                                            "app_txt_no_offering_available"),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    blackColor)),
                                                  )
                                                ],
                                              ),
                                            );
                                      ;
                                    }
                                  },
                                ),
                        ),
                      ],
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

  getFilterRecords() async {
    setState(() {
      listFiltered = <PaymentHistoryModel>[];
      _isLoadingData = true;
    });

    await httpService
        .getPublicData(widget.countryCode,
            'v3/paymentHistory/${widget.memberCode}/$_startDate/$_endDate')
        .then((response) {
      setState(() {
        _isLoadingData = false;
        _isLoading = false;
      });
      if (kDebugMode) {
        print("paymentHistory " + response.body);
      }
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        Iterable list = data;
        listFiltered =
            list.map((model) => PaymentHistoryModel.fromJson(model)).toList();
      } else {
        showError(data['message']);
      }
      setState(() {});
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
      _isSwitchData = true;

      if (kDebugMode) {
        print('START : $_startDate - LAST $_endDate');
      }
    });

    getFilterRecords();
  }

  void showCustomDialog(BuildContext context , AsyncSnapshot<List<PaymentHistoryModel>>  snapshot, index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(snapshot.data![index].church.toString(),
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: primaryColor,
                              fontSize: 13)),
                      Text(
                          translate('app_txt_code') +
                              snapshot.data![index].churchCode.toString(),
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w300,
                              color: primaryColor,
                              fontSize: 13)),
                    ],
                  ),
                ),
                const Expanded(child: Center()),
                InkWell(
                  child: _isDownloading
                      ? const SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator())
                      : Row(
                          children: [
                            const Icon(
                              Icons.cloud_download_rounded,
                              size: 30,
                            ),
                            Text(translate("app_txt_download"),
                                style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                  onTap: () async {
                    showSuccess("Download started");
                    // var storageStatus = await Permission.storage.request();
                    // if (!storageStatus.isGranted) {
                    //   showError("app_txt_storage_permission_issue".tr());
                    //   return;
                    // }
                    // setState(() {
                    //   _isDownloading = true;
                    // });
                    // var result = await HttpService()
                    //     .downloadReceipt(snapshot.data![index].trxId!, 0);
                    // if (result != null) {
                    //   showError(result);
                    //   setState(() {
                    //     _isDownloading = false;
                    //   });
                    // }
                  },
                )
              ],
            ),
          ),
          content: SizedBox(
            height: 270,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: transparentColor1,
                      borderRadius: BorderRadius.circular(7)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(translate('app_txt_tot_amount'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300,
                                color: primaryColor,
                                fontSize: 12)),
                        Row(
                          children: [
                            Text('${widget.countryCurrency} ' + ' ',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                    color: primaryColor,
                                    fontSize: 20)),
                            Text(snapshot.data![index].amount.toString(),
                                textAlign: TextAlign.center,
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
                SizedBox(
                  height: 210,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      itemCount: offeringPayments.length,
                      itemBuilder: (context, index) {
                        return OfferingPaymentItem(
                          title: '${offeringPayments[index].donationName}',
                          amount: '${offeringPayments[index].amount}',
                          icon: Icons.church_rounded,
                          currency: widget.countryCurrency,
                        );
                      }),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(translate("app_txt_close"),
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w300,
                        color: redColor,
                        fontSize: 14)),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        );
      },
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
}
