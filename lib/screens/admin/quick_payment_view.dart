// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/models/quick_payment_model.dart';
import 'package:cfms/models/quick_view.dart';
import 'package:cfms/models/user_model.dart';
import 'package:cfms/screens/admin/admin.dashboard.screen.dart';
import 'package:cfms/screens/admin/confirm_quick_payment.dart';
import 'package:cfms/services/db/db_helper.dart';
 import 'package:cfms/widgets/buttons/state_button.dart';
import 'package:cfms/widgets/lists/view_quick_item.dart';
import 'package:cfms/utils/routes.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
 import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
 import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import '../../nb55_printer/nb55_printer.dart';
import '../../utils/colors.dart';

class QuickViewPayment extends StatefulWidget {
  final double totalAmount;
  final String donationList;
  final String churchCode;
  final String churchName;
  final String memberId;
  final String memberName;
  final String memberPhone;
  final String currency;

  const QuickViewPayment(
      {Key? key,
      required this.totalAmount,
      required this.donationList,
      required this.churchCode,
      required this.churchName,
      required this.memberId,
      required this.memberName,
      required this.memberPhone,
      required this.currency})
      : super(key: key);

  @override
  State<QuickViewPayment> createState() => _QuickViewPaymentState();
}

class _QuickViewPaymentState extends State<QuickViewPayment> {
  int id = 1;
  List<QuickView> quickList = [];
  bool checkBoxValue = false;

  _loadMemberData() async {
    final prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("current_member") ?? '';
    // String newJson = json.replaceAll('[', '');
    // String newJson1 = newJson.replaceAll(']', '');
    Map<String, dynamic> map = jsonDecode(json);
    member = UserModel.fromJson(map);

    print(widget.donationList);
    setState(() {
      Iterable list = jsonDecode(widget.donationList);
      quickList = list.map((model) => QuickView.fromJson(model)).toList();
    });
  }

  late UserModel member;

  final DbHelper _dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    _loadMemberData();
    _dbHelper.getLocalCashReceipt();
    _bindingPOSPrinter();
    member = UserModel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          toolbarHeight: 70,
          leading: InkWell(
              onTap: () {
                Navigator.push(context, MyPageRoute(widget: AdminDashboard()));
              },
              child: const Icon(
                Icons.arrow_back,
                color: whiteColor,
              )),
          title: memberProfile(),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: whiteColor1),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        translate("app_txt_tot_amount"),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 10),
                      child: Text(
                        widget.totalAmount.toStringAsFixed(1),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: greenColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 31),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                    itemCount: quickList.length,
                    itemBuilder: (context, index) {
                      return QuickPayItem(
                        icon: Icons.church_rounded,
                        title: quickList[index].feeName.toString(),
                        amount: quickList[index].amount.toString(),
                        // narration: quickList[index].feeDescription ?? "",
                        narration: "",
                        onTap: () => setState(() {}),
                        currency: widget.currency,
                      );
                    }),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                        value: checkBoxValue,
                        activeColor: Colors.green,
                        onChanged: (newValue) {
                          setState(() {
                            checkBoxValue = newValue!;
                            if (kDebugMode) {
                              print(checkBoxValue);
                            }
                          });
                        }),
                    Text(translate('app_txt_check_here_to_print'),
                        style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 13))
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (isRedundentClick(DateTime.now())) {
                    print('hold on, processing');
                    return;
                  }
                  print('run process');

                  int result = await _dbHelper.quickPaymentAdd(
                      QuickPaymentModel(
                          name: widget.memberName,
                          phone: widget.memberPhone,
                          currency: widget.currency,
                          offerings: widget.donationList,
                          churchId: member.churchId,
                          totalAmount: widget.totalAmount.toString(),
                          createdAt: DateTime.now()));
                  if (result == 0) {
                    showError(translate("app_txt_cash_receipt_not_saved"));
                    return;
                  }
                  // printCashReceipt();
                  setState(() {});
                  if (checkBoxValue) {
                    printCashReceipt();
                  }

                  Navigator.pushReplacement(
                      context,
                      MyPageRoute(
                          widget: ConfirmQuickPayment(
                        memberPhone: widget.memberPhone,
                        memberName: widget.memberName,
                        countryCurrency: widget.currency,
                        totalAmount: widget.totalAmount,
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

  DateTime? loginClickTime;

  bool isRedundentClick(DateTime currentTime) {
    if (loginClickTime == null) {
      loginClickTime = currentTime;
      print("first click");
      return false;
    }
    print('diff is ${currentTime.difference(loginClickTime!).inSeconds}');
    if (currentTime.difference(loginClickTime!).inSeconds < 10) {
      // set this difference time in seconds

      return true;
    }

    loginClickTime = currentTime;
    return false;
  }

  _bindingPOSPrinter() {
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

  Widget memberProfile() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(bottom: 2, top: 2),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: whiteColor1, width: 3),
                    image: const DecorationImage(
                        image: AssetImage("assets/images/logo/hhh.png")))),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.memberName,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                              color: whiteColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                        Text(
                          widget.memberPhone,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: whiteColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 2,
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  printCashReceipt() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      var deviceModel = androidDeviceInfo.model;
      // showError("Device model: $deviceModel");
      if (deviceModel == 'NB55'){
        await printCashReceiptWithNB55();
        return;
      }
    } else {
      showError("Print is not available for IOS");
      return;
    }
    await SunmiPrinter.initPrinter()??false;
    await SunmiPrinter.startTransactionPrint(true);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText(translate('app_txt_cash_receipt'),
        style: SunmiStyle(fontSize: SunmiFontSize.XL, bold: true));
    await SunmiPrinter.line();
    await SunmiPrinter.printText(
        '${translate('app_txt_member')}: ${widget.memberName}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.printText(
        '${translate('app_txt_phone')}: ${widget.memberPhone}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.printText('${translate('app_txt_church')}: ${member.church}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.printText('${translate('app_txt_code')}${member.churchCode}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));

    await SunmiPrinter.line();

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
          text: translate('app_txt_donation'),
          width: 18,
          align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: translate('app_txt_amount'), width: 12, align: SunmiPrintAlign.RIGHT),
    ]);

    json.decode(widget.donationList).map((item) {
      return SunmiPrinter.printRow(cols: [
        ColumnMaker(
            text: '${item['title']}', width: 18, align: SunmiPrintAlign.LEFT),
        ColumnMaker(
            text: '${item['amount']}', width: 12, align: SunmiPrintAlign.RIGHT),
      ]);
    }).toList();

    await SunmiPrinter.line();
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
          text: translate('app_txt_total'), width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: "${widget.totalAmount.toStringAsFixed(1)} ${widget.currency}",
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.line();
    await SunmiPrinter.printText('${translate('app_txt_printed_by')}: ${member.name}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
                await initializeDateFormatting('en', null);

    await SunmiPrinter.printText(
        '${translate('app_txt_printed_at')}: ${DateFormat("yyyy-MM-dd h:m:s").format(DateTime.now())}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.line();
    await SunmiPrinter.printText("\n\n");
    await SunmiPrinter.line();
    await SunmiPrinter.exitTransactionPrint(true);
  }
  printCashReceiptWithNB55() async {
    bool? printerInitiated = await Nb55Printer.bindingPrinter();
    if (!printerInitiated!){
      showError("Unable to print receipt, no supported printer found. Contact BESOFT Team");
      return;
    }
    await Nb55Printer.printText(translate('app_txt_cash_receipt'));
    await Nb55Printer.line();
    await Nb55Printer.printText(
        '${translate('app_txt_member')}: ${widget.memberName}');
    await Nb55Printer.printText(
        '${translate('app_txt_phone')}: ${widget.memberPhone}');
    await Nb55Printer.printText('${translate('app_txt_church')}: ${member.church}');
    await Nb55Printer.printText('${translate('app_txt_code')}${member.churchCode}');
    await Nb55Printer.printText(translate('app_txt_donation'));

    json.decode(widget.donationList).map((item) {
      return Nb55Printer.printText('${item['title']}: ${item['amount']}');
    }).toList();

    await Nb55Printer.printText("${translate('app_txt_total')}: ${widget.totalAmount.toStringAsFixed(1)} ${widget.currency}");
    await Nb55Printer.printText(
        '${translate('app_txt_printed_by')}: ${member.name}');
        await initializeDateFormatting('en', null);
    await Nb55Printer.printText(
        '${translate('app_txt_printed_at')}: ${DateFormat("yyyy-MM-dd h:m:s").format(DateTime.now())}');
    await Nb55Printer.printText("\n\n");
    await Nb55Printer.line();
    await Nb55Printer.line();

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
}
