// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/models/members/member.dart';
import 'package:cfms/models/offering_model.dart';
import 'package:cfms/nb55_printer/nb55_printer.dart';
import 'package:cfms/screens/admin/quick_payment_view.dart';
import 'package:cfms/services/api/http_services.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ndialog/ndialog.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

import '../../../../models/donation_record_model.dart';
import '../../../../models/donations/donation.dart';
import '../../../../models/local_member_model.dart';
import '../../../../services/db/db_helper.dart';
import '../../../widgets/buttons/button.dart';
import '../../../widgets/buttons/loading_button.dart';
import '../../../widgets/cards/currency_card_widget.dart';
import '../../../widgets/lists/donation_item.dart';
import '../../../widgets/texts/heading.dart';
import 'package:flutter/services.dart';


class SearchMember extends StatefulWidget {
  final String churchId;
  const SearchMember({Key? key, required this.churchId}) : super(key: key);

  @override
  State<SearchMember> createState() => _SearchMemberState();
}

class _SearchMemberState extends State<SearchMember> {
   TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController narrationController = TextEditingController();
  RegExp digitValidator = RegExp(r'(^(?:[+0]9)?[0-9]{5,10}$)');
  RegExp amountValidator = RegExp(r'^[0-9]*\.?[0-9]+$');
  bool isANumber = true;
  bool isName = true;
  bool _isLoading = false;
  bool selectedBefore = false;
  bool _isCreating = false;
  int _isRegistered = 0;
  bool _isApiLoading = false;
  bool _isSelected = false;
  String donationList = '';
  late Data member;
  bool viewAll = false;
  String countryCurrency = "";
  String selectedId = "";
  String? memberName, memberCode, memberChurch, currentChurchCode;
  TextEditingController amountController = TextEditingController();
  TextEditingController donationNameController = TextEditingController();
  TextEditingController donationIdController = TextEditingController();
  final List<DonationModel> _selectedOffering = [];
  final DbHelper _dbHelper = DbHelper();
  double totalAmount = 0.00;
  String? _selectedCodeUrl;
  final formGlobalKey = GlobalKey<FormState>();
  HttpService httpService = HttpService();
  String? memberId;
  DonationRecordModel? _selectedSingleOffering;
  List<DonationRecordModel> offerings = [];
  late List currencyLIst;
  int selectedIndex = -1;
  late SharedPreferences prefs;

  void getOfferings() async {
    prefs = await SharedPreferences.getInstance();
    List<OfferingModel> data = await HttpService().getOfferingSuggestions("");
    for (OfferingModel a in data) {
      final names = jsonDecode(a.translation!);
      String name = names[prefs.getString("currentLang")!.toLowerCase()] ?? "";
      offerings.add(DonationRecordModel(
          donationName: (name == "" ? a.name : name),
          donationId: a.id,
          requireNarration: a.requireNarration));
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _selectedCodeUrl = '';
    _isLoading = false;
    member = Data();
    _gettingPreferences();
    getOfferings();
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
    getCurrencies();
    _dbHelper.getMemberList();
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
  void getCurrencies() async {
    setState(() {});
    currencyLIst = await HttpService().getCurrency();
    setState(() {});
  }

  _gettingPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('countryCode') ?? '';
    String json = prefs.getString('current_member') ?? '';

    Map<String, dynamic> map = jsonDecode(json);
    member = Data.fromJson(map);
    setState(() {
      currentChurchCode = member.cHURCHCode;
      _selectedCodeUrl = url;
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
          _isRegistered = 1;
          _isApiLoading = false;
          _isSelected = true;
          selectedBefore = true;
          memberName = body['data'][0]['names'];
          memberCode = body['data'][0]['phone'];
          memberCode = memberCode!.length<5?body['data'][0]['code']:memberCode;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _isLoading = false;
          _isApiLoading = false;
          _isRegistered = 2;
        });

        return;
      } else {
        // Member Not Registered
        setState(() {
          _isLoading = false;
          _isApiLoading = false;
          _isRegistered = 2;
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
                    : const Text(""),
              ),
              body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _isSelected
                    ? Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Visibility(
                              visible: selectedBefore,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: redColor, width: 1.5)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        translate("app_txt_select_currency"),
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: GoogleFonts.poppins(
                                            color: redColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20),
                                      ),
                                    ),
                                    FutureBuilder<List>(
                                        future: HttpService().getCurrency(),
                                        builder: ((context, snapshot) {
                                          if (snapshot.hasData) {
                                            var items = snapshot.data;
                                            countryCurrency = items![0]['code'];
                                            return SizedBox(
                                              height: 110,
                                              child: ListView.builder(
                                                  itemCount: items.length,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    final currency =
                                                        items[index];
                                                    return CurrencyCard(
                                                      title: currency['title'],
                                                      id: currency['code'],
                                                      selectedId: selectedId,
                                                      onTap: () {
                                                        setState(() {
                                                          countryCurrency =
                                                              currency['code'];
                                                          selectedId =
                                                              currency['code'];
                                                          selectedBefore =
                                                              false;
                                                        });
                                                      },
                                                    );
                                                  }),
                                            );
                                          }
                                          return const Text("Loading...");
                                        })),
                                  ],
                                ),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: List.generate(offerings.length, (index) {
                              DonationRecordModel offering = offerings[index];
                              return DonationItem(
                                icon: Icons.church_rounded,
                                currency: selectedId,
                                title: offering.donationName!,
                                amount: "${offering.amount ?? ""}",
                                narration: offering.narration ?? "",
                                onTap: () => setState(() {
                                  if (selectedId != "") {
                                    _selectedSingleOffering = offering;
                                    selectedIndex = index;
                                    if (offering.amount != null) {
                                      amountController.value = TextEditingValue(
                                          text: "${offering.amount ?? ""}");
                                      _selectedSingleOffering!.isEditable =
                                          false;
                                    } else {
                                      _selectedSingleOffering!.isEditable =
                                          true;
                                      amountController.value =
                                          TextEditingValue.empty;
                                    }
                                  } else {
                                    showError(
                                        "Please currency can not be null");
                                  }
                                }),
                              );
                            }),
                          ),
                          SizedBox(
                            height:
                                (_selectedSingleOffering != null ? 280 : 140) +
                                    20,
                          ),
                        ],
                      ))
                    : searchMember(),
              ),
              bottomSheet: _selectedSingleOffering != null
                  ? (_selectedSingleOffering!.isEditable!
                      ? getAmountSelector()
                      : showRemoveAmount())
                  : (totalAmount != 0
                      ? showTotalAmount()
                      : Row(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget getAmountSelector() {
    return Container(
      height: _selectedSingleOffering!.requireNarration! == 1 ? 380 : 280,
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
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: MediaQuery.of(context).size.width - 170,
                child: Text(
                  _selectedSingleOffering != null
                      ? _selectedSingleOffering!.donationName!
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
            ],
          ),
          Form(
              key: formGlobalKey,
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: amountController,
                    onChanged: (inputValue) {
                      if (inputValue.isEmpty ||
                          amountValidator.hasMatch(inputValue)) {
                        setAmountValidator(true);
                      } else {
                        setAmountValidator(false);
                      }
                    },
                    decoration: InputDecoration(
                      errorText: isANumber
                          ? null
                          : translate('app_txt_plz_enter_valid_amount'),
                      hintText: translate('app_txt_enter_amount'),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      suffix: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(selectedId,
                            style: const TextStyle(
                              fontSize: 20,
                            )),
                      ),
                      suffixIcon: isANumber || amountController.text.isEmpty
                          ? amountController.text.isNotEmpty
                              ? const Icon(
                                  Icons.check_circle,
                                  color: greenColor,
                                )
                              : const Icon(
                                  Icons.error,
                                  color: Colors.grey,
                                )
                          : const Icon(
                              Icons.error,
                              color: redColor,
                            ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _selectedSingleOffering!.requireNarration! == 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: TextField(
                      maxLines: 2,
                      keyboardType: TextInputType.text,
                      controller: narrationController,
                      onChanged: (inputValue) {
                        if (inputValue.length > 3) {
                          setValidator(true);
                        } else {
                          setValidator(false);
                        }
                      },
                      decoration: InputDecoration(
                        errorText: narrationController.value.text.length > 3 &&
                                _selectedSingleOffering!.requireNarration! == 1
                            ? null
                            : translate('app_txt_narration_required'),
                        hintText: translate('app_txt_enter_narration'),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                      ),
                    ),
                  ),
                ),
              ])),
          GestureDetector(
            onTap: () {
              if (formGlobalKey.currentState!.validate()) {
                if (!isANumber || amountController.text.isEmpty) {
                  showError(translate("app_txt_plz_enter_valid_amount"));
                } else if (narrationController.text.length < 3 &&
                    _selectedSingleOffering!.requireNarration! == 1) {
                  showError(translate("app_txt_narration_required"));
                } else {
                  setState(() {
                    if (selectedIndex == -1) {
                      return;
                    }
                    DonationRecordModel record = offerings[selectedIndex];
                    record.amount = double.parse(amountController.value.text);
                    record.narration = narrationController.value.text;
                    totalAmount += record.amount!;
                    offerings[selectedIndex] = record;
                    _selectedSingleOffering = null;
                    selectedIndex = -1;
                    amountController.value = TextEditingValue.empty;

                    _selectedOffering.add(DonationModel(
                        donationId: donationIdController.value.text,
                        donationName: _selectedSingleOffering?.churchName,
                        amount: amountController.value.text,
                        narration:
                         ''));

                    if (kDebugMode) {
                      print("LIST ${narrationController.text}");
                    }
                  });
                }
              }
            },
            child: LoadingButton(
              icon: Icons.arrow_forward,
              backgroundColor: primaryColor,
              width: 200,
              title: translate('app_txt_add'),
              isLoading: _isLoading,
            ),
          ),
          TextButton(
              onPressed: () => setState(() {
                    _selectedSingleOffering = null;
                    selectedIndex = -1;
                  }),
              child: Text(translate("app_txt_dismiss")))
        ],
      ),
    );
  }

  Widget showTotalAmount() {
    return Container(
      height: 140,
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
              const Icon(
                Icons.church_rounded,
                size: 30,
                color: Colors.black45,
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: MediaQuery.of(context).size.width - 170,
                child: Text(
                  translate("app_txt_tot_amount"),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 20),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                totalAmount.toStringAsFixed(1),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    fontSize: 20),
              ),
              const Expanded(child: SizedBox()),
              LoadingButton(
                icon: Icons.arrow_forward,
                backgroundColor: primaryColor,
                width: 170,
                title: translate('app_txt_continue'),
                isLoading: _isLoading,
                onTap: () => setState(() {
                  var donationMap = [];
                  for (DonationRecordModel item in offerings) {
                    if (item.amount != null) {
                      donationMap.add({
                        "amount": item.amount.toString(),
                        "id": item.donationId,
                        "title": item.donationName,
                      });
                    }
                  }
                  donationList = json.encode(donationMap);
                  if (kDebugMode) {
                    print(donationList);
                  }

                  Navigator.pushReplacement(
                      context,
                      MyPageRoute(
                          widget: QuickViewPayment(
                        totalAmount: totalAmount,
                        donationList: donationList,
                        churchCode: member.cHURCHCode.toString(),
                        churchName: member.cHURCH.toString(),
                        memberId: '$memberId',
                        memberName: memberName.toString(),
                        memberPhone: memberCode.toString(),
                        currency: selectedId,
                      )));
                }),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget showRemoveAmount() {
    return Container(
      height: 140,
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
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: MediaQuery.of(context).size.width - 170,
                child: Text(
                  _selectedSingleOffering!.donationName!,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 20),
                ),
              ),
            ],
          ),
          Row(
            children: [
              LoadingButton(
                icon: Icons.delete,
                backgroundColor: Colors.orangeAccent,
                width: 150,
                title: translate('app_txt_remove'),
                isLoading: _isLoading,
                onTap: () => setState(() {
                  final String name =
                      _selectedSingleOffering!.donationName ?? "";
                  totalAmount -= _selectedSingleOffering!.amount!;
                  _selectedSingleOffering = null;
                  offerings[selectedIndex].amount = null;
                  selectedIndex = -1;
                  showSuccess(translate("app_txt_removed")+ name);
                }),
              ),
              const Expanded(child: SizedBox()),
              LoadingButton(
                icon: Icons.edit,
                backgroundColor: Colors.green,
                width: 150,
                title: translate('app_txt_edit'),
                isLoading: _isLoading,
                onTap: () => setState(() {
                  _selectedSingleOffering!.isEditable = true;
                }),
              ),
            ],
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

  void setAmountValidator(valid) {
    setState(() {
      isANumber = valid;
    });
  }

  void setNameValidator(valid) {
    setState(() {
      isName = valid;
    });
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
    await SunmiPrinter.printText('${translate('app_txt_church')}: ${member.cHURCH}',
        style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: false));
    await SunmiPrinter.printText('${translate('app_txt_code')}${member.code}',
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
            text: '${item.donationName}',
            width: 14,
            align: SunmiPrintAlign.LEFT),


        ColumnMaker(
            text: '${item.amount}', width: 12, align: SunmiPrintAlign.RIGHT),
      ]);
    }).toList();

    await SunmiPrinter.line();
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
          text: translate('app_txt_total'), width: 18, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: "${totalAmount.toStringAsFixed(2)} $selectedId",
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);

    await SunmiPrinter.line();
    await SunmiPrinter.printText(
        '${translate('app_txt_printed_by')}: ${member.names}',
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
    if (!printerInitiated!){
      showError("Unable to print receipt, no supported printer found. Contact BESOFT Team");
      return;
    }
    await Nb55Printer.printText(translate('app_txt_cash_receipt'));
    await Nb55Printer.line();
    await Nb55Printer.printText('${translate('app_txt_member')}: $memberName');
    await Nb55Printer.printText('${translate('app_txt_phone')}: $memberCode');
    await Nb55Printer.printText('${translate('app_txt_church')}: ${member.cHURCH}');
    await Nb55Printer.printText('${translate('app_txt_code')}${member.code}');

    await Nb55Printer.printText(translate('app_txt_donation'));

    _selectedOffering.map((item) {
      return SunmiPrinter.printText('${item.donationName}: ${item.amount}');
    }).toList();

    await Nb55Printer.printText("${translate('app_txt_total')}: ${totalAmount.toStringAsFixed(2)} $selectedId");

    await Nb55Printer.printText(
        '${translate('app_txt_printed_by')}: ${member.names}');
    await Nb55Printer.printText(
        '${translate('app_txt_printed_at')}: ${DateFormat("yyyy-MM-dd h:m:s").format(DateTime.now())}');
    await Nb55Printer.printText(".\n\n");
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
    return Column(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Heading(
                  title: translate("app_txt_cash_receipt"),
                  subtitle: translate('app_txt_search_member')),
              Form(
                key: formGlobalKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 30),
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
                                    : translate(
                                        'app_txt_please_enter_phone_number'),
                                hintText: translate('app_txt_phone_number'),
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
                          Visibility(
                            visible: _isRegistered == 2,
                            child: Column(
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3, horizontal: 8),
                                        child: Text(
                                            translate('app_txt_member_names'),
                                            textAlign: TextAlign.start,
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: transparentColor2)),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: TextField(
                                          keyboardType: TextInputType.text,
                                          controller: nameController,
                                          onChanged: (inputValue) {
                                            if (inputValue.isEmpty ||
                                                inputValue.length > 5) {
                                              setNameValidator(true);
                                            } else {
                                              setNameValidator(false);
                                            }
                                          },
                                          style: GoogleFonts.poppins(
                                              fontSize: 12.0),
                                          decoration: InputDecoration(
                                            errorText: isName
                                                ? null
                                                : translate(
                                                    'app_txt_member_valid_names'),
                                            hintText: translate('app_txt_enter_name'),
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 10),
                                            suffixIcon: isName ||
                                                    nameController.text.isEmpty
                                                ? !nameController.text.isEmpty
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
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 8),
                                        child: Text(
                                            translate('app_txt_currency'),
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: transparentColor2)),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 0),
                                        child: FutureBuilder<List>(
                                            future: HttpService().getCurrency(),
                                            builder: ((context, snapshot) {
                                              if (snapshot.hasData) {
                                                var items = snapshot.data;
                                                countryCurrency =
                                                    items![0]['code'];
                                                return SizedBox(
                                                  height: 120,
                                                  child: ListView.builder(
                                                      itemCount: items.length,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        final currency =
                                                            items[index];
                                                        return CurrencyCard(
                                                          title:
                                                              currency['title'],
                                                          id: currency['code'],
                                                          selectedId:
                                                              selectedId,
                                                          onTap: () {
                                                            setState(() {
                                                              countryCurrency =
                                                                  currency[
                                                                      'code'];
                                                              selectedId =
                                                                  currency[
                                                                      'code'];
                                                            });
                                                          },
                                                        );
                                                      }),
                                                );
                                              }
                                              return const Text("Loading...");
                                            })),
                                      ),
                                    ]),
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
                                          if (formGlobalKey.currentState!
                                              .validate()) {
                                            if (!isANumber ||
                                                phoneController.text.isEmpty ||
                                                !isName ||
                                                nameController.text.isEmpty) {
                                              showError(
                                                  translate("app_txt_you_must_enter_all_field"));
                                            } else if (countryCurrency == '') {
                                              showError(
                                                  translate(
                                                  "app_txt_currency_is_required"));
                                            } else {
                                              setState(() {
                                                _isApiLoading = false;
                                                _isSelected = true;
                                                memberName =
                                                    nameController.text;
                                                memberCode =
                                                    phoneController.text;
                                              });
                                              _dbHelper
                                                  .insertMember(
                                                      MemberLocalModel(
                                                          name: nameController
                                                              .text,
                                                          phone: phoneController
                                                              .text,
                                                          churchCode:
                                                              widget.churchId))
                                                  .then((value) {
                                                setState(() {
                                                  memberId = value.toString();
                                                });
                                                if (kDebugMode) {
                                                  print(
                                                      'MEMBER ID :  $memberId');
                                                }
                                              }).onError((error, stackTrace) {
                                                if (kDebugMode) {
                                                  print(error.toString());
                                                }
                                              });
                                            }
                                          }
                                        },
                                      ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _isRegistered == 0,
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
                                    checkingMember();
                                  }
                                }
                              },
                            ),
                    ),
                    const SizedBox(
                      height: 150,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget addOffering() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
        key: formGlobalKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          translate("app_txt_select_donation_name"),
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(top: 1, bottom: 1, right: 5),
                        child: TypeAheadField<OfferingModel?>(
                          suggestionsCallback:
                              HttpService().getOfferingSuggestions,
                          itemBuilder: (context, OfferingModel? suggestion) {
                            final entity = suggestion;
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(5)),
                              child: ListTile(
                                title: Text(entity!.name.toString(),
                                    style: GoogleFonts.poppins(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13)),
                                subtitle: Text(
                                    "${translate('app_txt_code')}${entity.id}",
                                    style: GoogleFonts.poppins(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13)),
                              ),
                            );
                          },
                          onSuggestionSelected: (OfferingModel? suggestion) {
                            final donation = suggestion;
                            setState(() {
                              donationNameController.text =
                                  donation!.name.toString();
                              donationIdController.text =
                                  donation.id.toString();
                            });
                          },
                          noItemsFoundBuilder: (context) => SizedBox(
                            height: 95,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.info,
                                      size: 24,
                                      color: redColor,
                                    ),
                                    Text(translate('app_txt_no_church_found'),
                                        style: GoogleFonts.poppins(
                                            color: redColor,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: donationNameController,
                            style: GoogleFonts.poppins(fontSize: 12.0),
                            decoration: InputDecoration(
                              hintText: translate('app_txt_offering_name'),
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          translate("app_txt_amount"),
                          style: GoogleFonts.poppins(
                              fontSize: 11, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: amountController,
                          style: GoogleFonts.poppins(fontSize: 12.0),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 8),
                            hintText: translate('app_txt_enter_amount'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                if (amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                      content: Text('Try again, Church code not found'),
                    ));
                } else {
                  if (amountController.text.isEmpty ||
                      donationIdController.text.isEmpty) {
                    showError(translate("app_txt_plz_enter_amount"));
                  } else {
                    var contain = _selectedOffering.where((element) =>
                        element.donationId == donationIdController.text);
                    if (contain.isEmpty) {
                      _selectedOffering.add(DonationModel(
                          donationId: donationIdController.text,
                          donationName: donationNameController.text,
                          amount: amountController.text,
                          narration: narrationController.text
                          ));

                      setState(() {
                        totalAmount += double.parse(amountController.text);
                      });

                      // donation.addTotalAmount(double.parse(amountController.text));
                      // donation.addCounter();
                      showSuccess(translate("app_txt_add_donation"));
                      amountController.text = '';
                      donationNameController.text = '';
                    } else {
                      showError(translate("app_txt_is_exist"));
                    }
                  }
                }
              },
              child: ActiveButton(
                  icon: Icons.add,
                  backgroundColor: greenColor,
                  width: MediaQuery.of(context).size.width,
                  title: translate("app_txt_save_donation")),
            )
          ],
        ),
      ),
    );
  }

  Widget viewAllOfferings() {
    return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: _selectedOffering.isNotEmpty
            ? ListView.builder(
                itemCount: _selectedOffering.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(6),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0.0, 2.0),
                          color: Color(0xffEDEDED),
                          blurRadius: 3.0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.church_rounded,
                              size: 24,
                              color: primaryOverlayColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedOffering[index]
                                          .donationName
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 1.0, vertical: 5),
                                      child: Row(
                                        children: [
                                          Text(
                                            " ",
                                            style: GoogleFonts.poppins(
                                                color: blackColor,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            _selectedOffering[index]
                                                .amount
                                                .toString(),
                                            style: GoogleFonts.poppins(
                                                color: blackColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              totalAmount -= double.parse(
                                  _selectedOffering[index].amount.toString());
                              _selectedOffering.removeWhere((offering) =>
                                  offering.donationId ==
                                  _selectedOffering[index].donationId);
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.delete_forever_rounded,
                              color: redColor,
                              size: 25,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                })
            : const Column(
                children: [
                  Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 88.0),
                    child: SpinKitDoubleBounce(
                      color: orangeColor,
                    ),
                  )),
                ],
              ));
  }

  Widget offeringsActionButton() {
    //add new offering button and view history
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      decoration: BoxDecoration(
          color: whiteColor, borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isCreating = false;
                });
              },
              child: Text(
                translate('app_txt_view_history'),
                style: GoogleFonts.poppins(
                    fontSize: 12.0,
                    color: primaryColor,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isCreating = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: _isCreating ? greenColor : whiteColor, width: 1),
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  translate('app_txt_new_donation'),
                  style: GoogleFonts.poppins(
                      fontSize: 12.0,
                      color: greenColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget recentHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                color: whiteColor1, borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Text(
                    translate("app_text_recently_history"),
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                        color: primaryColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          _selectedOffering.isEmpty
              ? const Column(
                  children: [
                    Center(child: Text("No data")),
                  ],
                )
              : ListView.builder(
                  itemCount: _selectedOffering.length,
                  itemBuilder: (context, pos) {
                    return Text('$pos');
                  })
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
                      memberCode.toString(),
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
}
