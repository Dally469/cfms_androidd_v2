import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/nb55_printer/nb55_printer.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

import '../../../../models/item_history_model.dart';
import '../../../../models/member_history_model.dart';
import '../../../../models/members/member.dart';
import '../../../../models/user_model.dart';
import '../../../../services/api/http_services.dart';
import '../../../../utils/colors.dart';
import '../../../widgets/buttons/loading_button.dart';
import '../../../widgets/callbacks/message_response.dart';
import '../../../widgets/item_history_row.dart';
import '../../../widgets/texts/heading.dart';

class ReprintReceipt extends StatefulWidget {
  final String churchName;
  final String churchCode;
  final String countryCode;
  const ReprintReceipt(
      {Key? key, required this.churchName, required this.churchCode, required this.countryCode})
      : super(key: key);

  @override
  State<ReprintReceipt> createState() => _ReprintReceiptState();
}

class _ReprintReceiptState extends State<ReprintReceipt> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController churchController = TextEditingController();
  TextEditingController churchCodeController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  RegExp digitValidator = RegExp(r'(^(?:[+0]9)?[0-9]{10}$)');
  bool isANumber = true;
  bool isName = true;
  bool _isLoading = false;
  bool _isDownloading = false;
  bool _isRegistered = true;
  bool _isApiLoading = false;
  bool _isSelected = false;
  String donationList = '';
  bool isCode = true;
  double totalAmount = 0.00;
  String currencyPrint = "CDF";
  late UserModel member;
  bool viewAll = false;
  String countryCurrency = "";
  String selectedId = "";
  HttpService httpService = HttpService();
  String? memberId, memberName, memberCode, memberChurch, currentChurchCode;
  List<PaymentInfo> histories = [];
  List<ItemHistory> _selectedOffering = [];

  final formGlobalKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _isLoading = false;
    member = UserModel();
    getUniqueDeviceId();
    _gettingPreferences();
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

  _gettingPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('countryCode') ?? '';
    String json = prefs.getString('current_member') ?? '';

    Map<String, dynamic> map = jsonDecode(json);
    member = UserModel.fromJson(map);
    setState(() {
      currentChurchCode = member.churchCode;
    });
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

  Future<Uint8List> readFileBytes(String path) async {
    ByteData fileData = await rootBundle.load(path);
    Uint8List fileUnit8List = fileData.buffer
        .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
    return fileUnit8List;
  }

  checkingMember() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String countryCode = prefs.getString('countryCode') ?? '';

      var data = {
        'code': phoneController.text,
      };
      //countryCode required here in  ????
      var response =
          await httpService.postAppData(data, countryCode, 'v3/member');
      var body = json.decode(response.body);
      if (kDebugMode) {
        print(body);
      }
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _isSelected = true;
          memberName = jsonEncode(body['data'][0]['names']).replaceAll('"', '');
          memberCode = jsonEncode(body['data'][0]['phone']).replaceAll('"', '');
          memberId = jsonEncode(body['data'][0]['id']).replaceAll('"', '');

          gettingMemberHistory(body['data'][0]['id']);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _isLoading = false;
          _isApiLoading = false;
          // _isRegistered = false;
        });

        return;
      } else {
        // Member Not Registered
        setState(() {
          _isLoading = false;
          _isApiLoading = false;
          // _isRegistered = false;
        });
        showError(body.message);
      }
    } catch (e) {
      var message = "";
      if (e is SocketException) {
        message = "Socket exception: ${e.toString()}";
      } else if (e is TimeoutException) {
        message = "Timeout exception: ${e.toString()}";
      } else {
        message = "Unhandled exception: ${e.toString()}";
      }
      if (kDebugMode) {
        print(message);
      }
      showError(message);
    }
  }

  gettingMemberHistory(memberId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String countryCode = prefs.getString('countryCode') ?? '';

      var data = {
        'memberId': memberId,
      };
      //countryCode required here in  ????
      var response = await httpService.postAppData(
          data, countryCode, 'v2/get-member-report');
      var body = json.decode(response.body)["paymentInfo"];
      if (kDebugMode) {
        print(body);
      }
      if (response.statusCode == 200) {
        setState(() {
          Iterable list = body;
          histories = list.map((model) => PaymentInfo.fromJson(model)).toList();

          // print(body["details"]);
        });
      } else {
        // Member Not Registered
        setState(() {
          _isLoading = false;
          _isApiLoading = false;
          // _isRegistered = false;
        });
        showError(body.message);
      }
    } catch (e) {
      var message = "";
      if (e is SocketException) {
        message = "Socket exception: ${e.toString()}";
      } else if (e is TimeoutException) {
        message = "Timeout exception: ${e.toString()}";
      } else {
        message = "Unhandled exception: ${e.toString()}";
      }
      if (kDebugMode) {
        print(message);
      }
      showError(message);
    }
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
                  backgroundColor: primaryColor,
                  elevation: 0,
                  toolbarHeight: _isSelected ? 70 : 50,
                  leading: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: whiteColor,
                      )),
                  title: _isSelected
                      ? Column(
                          children: [
                            userProfile(),
                          ],
                        )
                      : Text(""),
                ),
                body: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: _isSelected
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            histories.isEmpty
                                ? Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                        SizedBox(
                                          height: 100,
                                        ),
                                        Image.asset(
                                            "assets/images/logo/no_data_found.png"),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3, horizontal: 8),
                                          child: Text(
                                              translate('app_txt_no_offering_available'),
                                              style: GoogleFonts.poppins(
                                                  fontSize: 19,
                                                  color: transparentColor2)),
                                        )
                                      ]))
                                : Column(
                                    children: List.generate(histories.length,
                                        (index) {
                                      PaymentInfo record = histories[index];
                                      return SingleHistoryRow(
                                        count: record.count.toString(),
                                        amount: record.amount.toString(),
                                        currency: record.currency.toString(),
                                        newTrxId: record.trxId.toString(),
                                        church: widget.churchName,
                                        date: DateTime.parse(
                                            record.updatedAt.toString()),
                                        status:
                                            int.parse(record.status.toString()),
                                        onTap: () {
                                          setState(() {
                                            selectedId =
                                                record.trxId.toString();
                                          });
                                        },

                                        onPrintTap: () {
                                          setState(() {
                                            currencyPrint = record.currency.toString();
                                            totalAmount = double.parse(
                                                record.amount.toString());
                                            var tagObjJson = jsonDecode(
                                                    record.details.toString())
                                                as List;
                                            _selectedOffering = tagObjJson
                                                .map((tagJson) =>
                                                    ItemHistory.fromJson(
                                                        tagJson))
                                                .toList();
                                            if (kDebugMode) {
                                              print(
                                                  "ONE TAP $_selectedOffering");
                                            }
                                          });

                                          printCashReceipt();
                                        },
                                        id: record.trxId.toString(),
                                        selectedId: selectedId,
                                        details: record.details.toString(),
                                      );
                                    }),
                                  ),
                            SizedBox(
                              height: (_isSelected != null ? 280 : 140) + 20,
                            ),
                          ],
                        ))
                      : searchMember(),
                ),
                bottomSheet: Row(
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
                )),
          ],
        ),
      ),
    );
  }

  cancelReceipt(String selectedCodeUrl, String id, String phone) async {
    var data = {
      'id': id.toString(),
      'userId': memberId.toString(),
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
      }
      setState(() {
        reasonController.text = "";
      });
      Navigator.pop(context);
    } else {
      if (kDebugMode) {
        print("sms not sent");
      }
      // showErrorAlert("app_txt_otp_not_sent".tr());
    }
  }

  Widget singleItem(String count, String amount, String currency,
      String newTrxId, String church, DateTime date, int status) {
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
                          width: 100,
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
                    TextButton(
                        onPressed: () {
                          printCashReceipt();
                        },
                        child: Text(
                          translate("app_txt_print"),
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: greenColor,
                              fontSize: 15),
                        ))
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

  Widget userProfile() {
    return Row(
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
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberName.toString(),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                          color: whiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                    Text(
                      "+$memberCode",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400, fontSize: 12),
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
    );
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
    await SunmiPrinter.printText('${translate('app_txt_member')}: $memberName',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.printText('${translate('app_txt_phone')}: $memberCode',
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

    _selectedOffering.map((item) {
      return SunmiPrinter.printRow(cols: [
        ColumnMaker(
            text: '${item.title}', width: 18, align: SunmiPrintAlign.LEFT),
        ColumnMaker(
            text: '${item.amount}', width: 12, align: SunmiPrintAlign.RIGHT),
      ]);
    }).toList();

    await SunmiPrinter.line();
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
          text: translate('app_txt_total'), width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: "${totalAmount.toStringAsFixed(1)} $currencyPrint",
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

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
        '${translate('app_txt_member')}: $memberName');
    await Nb55Printer.printText(
        '${translate('app_txt_phone')}: $memberCode');
    await Nb55Printer.printText('${translate('app_txt_church')}: ${member.church}');
    await Nb55Printer.printText('${translate('app_txt_code')}${member.churchCode}');
    await Nb55Printer.printText(translate('app_txt_donation'));

   _selectedOffering.map((item) {
      return Nb55Printer.printText('${item.title}: ${item.amount}');
    }).toList();

    await Nb55Printer.printText(
        "${translate('app_txt_total')}: ${totalAmount.toStringAsFixed(1)}  $currencyPrint ");
    await Nb55Printer.printText('${translate('app_txt_printed_by')}: ${member.name}');
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

  void showSuccess(String message) {
    Flushbar(
      message: message,
      icon: const Icon(
        Icons.check_circle_outline,
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

  Widget searchMember() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
              visible: !_isRegistered,
              child: MessageResponse(
                icon: Icons.info_outline,
                msgTitle: translate("app_txt_member_not_found"),
                msgDesc: translate("app_txt_member_not_found_desc"),
                refNo: '',
                color: redColor,
                backgroundColor: redColorOverlay,
              )),
          const SizedBox(height: 20),
          Heading(
              title: translate("app_txt_cash_reprint_receipt"),
              subtitle: translate('app_txt_search_member')),
          Form(
            key: formGlobalKey,
            child: Column(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
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
                _isApiLoading
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
                        onTap: () {
                          if (formGlobalKey.currentState!.validate()) {
                            if (!isANumber || phoneController.text.isEmpty) {
                              showError(
                                  translate(
                                  "app_txt_please_enter_valid_phone_number"
                                    ));
                            } else {
                              setState(() {
                                _isApiLoading = true;
                                _isLoading = true;
                              });
                              checkingMember();
                            }
                          }
                        },
                      ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void setValidator(valid) {
    setState(() {
      isANumber = valid;
    });
  }
}
