// ignore_for_file: depend_on_referenced_packages

import 'dart:isolate';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/services/db/db_helper.dart';
import 'package:cfms/services/provider/donation_provider.dart';
import 'package:cfms/widgets/buttons/button.dart';
import 'package:cfms/widgets/callbacks/message_response.dart';
import 'package:cfms/widgets/texts/heading.dart';
import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class ApprovalPayment extends StatefulWidget {
  final int method;
  final int type;
  final double totalAmount;
  final String message;
  final String countryCurrency;
  final String memberName;
  final String memberPhone;
  final String refNo;

  const ApprovalPayment(
      {Key? key,
      required this.method,
      required this.totalAmount,
      required this.message,
      required this.countryCurrency,
      required this.memberName,
      required this.memberPhone,
      required this.refNo, required this.type})
      : super(key: key);

  @override
  State<ApprovalPayment> createState() => _ApprovalPaymentState();
}

class _ApprovalPaymentState extends State<ApprovalPayment> {
  String title = '';
  final ReceivePort _port = ReceivePort();
  final DbHelper? _dbHelper = DbHelper();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // monitorDownloadProgress();
  }
  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('invoice_downloader_port');
    super.dispose();
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
  //       // _isDownloading = false;
  //     });
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    if (widget.method == 1) {
      title = translate("app_txt_momo_payment");
    } else if (widget.method == 2) {
      title = translate("app_txt_card_payment");
    } else if (widget.method == 3) {
      title = translate("app_txt_bank_payment");
    } else {
      title = translate("app_txt_other_payment");
    }
    return ChangeNotifierProvider(
        create: (_) => DonationProvider(),
        child: Builder(builder: (BuildContext context) {
          final donation = Provider.of<DonationProvider>(context);
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
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logo/success_two.gif",
                          scale: 2,
                        ),
                        Heading(title: translate("app_txt_thanks"), subtitle: " "),
                        Visibility(
                          child: MessageResponse(
                            icon: Icons.check_circle_outlined,
                            msgTitle: translate("app_txt_member_success"),
                            refNo: widget.refNo,
                            msgDesc: widget.message,
                            color: greenColor,
                            backgroundColor: greenOverlayColor,
                          ),
                        ),
                        Visibility(
                          visible: widget.refNo.length > 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            child: Text(
                              "Ref No: ${widget.refNo}",
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                  color: primaryColor),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          child: Text(
                            "${widget.countryCurrency} ${widget.totalAmount.toStringAsFixed(0)}",
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.w600,
                                fontSize: 45,
                                color: primaryColor),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: ActiveButton(
                                    icon: Icons.arrow_back,
                                    backgroundColor: orangeColor,
                                    width: 130,
                                    title: translate("app_txt_back"))),
                            InkWell(
                                onTap: () {
                                //  HttpService().downloadReceipt(widget.refNo, widget.type);
                                },
                                child: ActiveButton(
                                    icon: Icons.cloud_download_rounded,
                                    backgroundColor: greenColor,
                                    width: 170,
                                    title: translate("app_txt_download_receipt"))),
                          ],
                        )
                      ]),
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
        }));
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
