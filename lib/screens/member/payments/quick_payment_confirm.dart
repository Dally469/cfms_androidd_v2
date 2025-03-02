// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/models/donations/donation.dart';
import 'package:cfms/models/members/member.dart';
import 'package:cfms/screens/member/payments/approved_payment.dart';
import 'package:cfms/services/api/http_services.dart';
import 'package:cfms/services/db/db_helper.dart';
import 'package:cfms/widgets/callbacks/message_response.dart';
import 'package:cfms/widgets/texts/heading.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/buttons/loading_button.dart';

class QuickConfirmPayment extends StatefulWidget {
  final int methodId;
  final String totalAmount;
  final String date;
  final String userId;
  final String userPhone;
  final String countryCurrency;

  const QuickConfirmPayment(
      {Key? key,
        required this.methodId,
        required this.totalAmount,
        required this.date,
        required this.userId,
        required this.userPhone,
        required this.countryCurrency,
      }) : super(key: key);


  @override
  State<QuickConfirmPayment> createState() => _QuickConfirmPaymentState();
}

class _QuickConfirmPaymentState extends State<QuickConfirmPayment> {
  HttpService httpService = HttpService();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  DbHelper? _dbHelper = DbHelper();
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late List<DonationModel > _list;
  TextEditingController phoneController = TextEditingController();
  RegExp digitValidator = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
  bool isANumber = true;
  bool isClicked = false;
  bool _isLoading = false;
  bool _isApiLoading = false;
  bool _responseError = false;
  bool _responseStatusCode = false;

  int id = 0;
  int mId = 1;
  String title = '';
  String method = '';
  String phone = '';
  String responseMessage = '';
  String refNo = '';
  String countryCodeUrl = '';
  String countryCurrency = '';
  String? currentMemberPhone, memberCode;
  late Data member;

  _loadMemberData() async {
    final prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("current_member") ?? '';
    String url = prefs.getString("countryCode") ?? '';
    // String currency = prefs.getString('countryCurrency') ?? '';
    String newJson = json.replaceAll('[', '');
    String newJson1 = newJson.replaceAll(']', '');
    if (newJson1 == null) {
      if (kDebugMode) {
        print('No dATA');
      }
    } else {
      Map<String, dynamic> map = jsonDecode(newJson1);
      member = Data.fromJson(map);
      setState(() {
        currentMemberPhone = member.phone;
        memberCode = member.code;
        countryCodeUrl = url;
      });
    }
  }

  _createNewDonation() async {
    // showError("Error: ${widget.methodId}");
    // return;
    _responseError = false;
    responseMessage = "";
    if (widget.methodId == 1) {
      phone = widget.userPhone;
    } else if (widget.methodId == 4) {
      phone = phoneController.text;
    } else if (widget.methodId == 3) {
      phone = widget.userPhone;
    } else {
      showError("Payment failed, unhandled error occurred. try again later");
      return;
    }
    if(phone.length < 9){
      showError("Please enter a valid phone number ${widget.methodId} - $phone");
      return;
    }
    setState(() {
      _isLoading = true;
      _isApiLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';
    var data = {
      "userId" : widget.userId,
      "phone" : widget.userPhone,
      "date" : widget.date,
      "amount" : widget.totalAmount,
      "currency" : widget.countryCurrency,
      "method" : widget.methodId == 3 ? "teller" : "mobile",
    };

    var response = await httpService.postAppDataLocal(
        data,
        countryCode,
        'v3/quick-payment/pay',
        '&lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}'
    );
    var body = json.decode(response.body);
    if (kDebugMode) {
      print(body);
    }
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        _responseStatusCode = true;
        _isApiLoading = false;
        responseMessage = body['message'];
        refNo = body['reference_no'];
      });
      Navigator.pushAndRemoveUntil(
          context,
           MyPageRoute(
              widget:  ApprovalPayment(
                type: 1,
                method: widget.methodId,
                totalAmount: double.parse(widget.totalAmount),
                message: responseMessage,
                refNo:refNo,
                countryCurrency: widget.countryCurrency, memberName: widget.userPhone, memberPhone: widget.userPhone,
              )),
          (route)=>route.isFirst);
    } else {
      if (response.statusCode == 500) {
        setState(() {
          _responseError = true;
          responseMessage = body['message'];
          _isApiLoading = false;
        });
      }
      setState(() {
        _isLoading = false;
        _responseError = true;
        _isApiLoading = false;
      });
    }
  }

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
    _loadMemberData();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.methodId == 1) {
      title = translate("app_txt_momo_payment");
    } else if (widget.methodId == 2) {
      title = translate("app_txt_card_payment");
    } else if (widget.methodId == 3) {
      title = translate("app_txt_bank_payment");
    } else {
      title = translate("app_txt_other_payment");
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
            child: Text(" ",
                style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: primaryColor,
                  )),
            ),
          ],
        ),
        backgroundColor: whiteColor,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Heading(
                    title: title,
                    subtitle: translate("app_txt_thanks_payment") + title),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Text(
                      translate("app_txt_tot_amount"),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: primaryOverlayColor,
                          fontWeight: FontWeight.w300),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 30),
                      child: Text(
                        "${widget.countryCurrency} ${widget.totalAmount}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: greenColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 30),
                      ),
                    ),
                    Container(
                      width: 70,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: greenOverlayColor,
                      ),
                    )
                  ],
                ),
                Visibility(
                  visible: _responseError,
                  child: MessageResponse(
                    refNo: refNo,
                    icon: _responseStatusCode
                        ? Icons.check_circle_outlined
                        : Icons.info_outline,
                    msgTitle: _responseStatusCode
                        ? translate("app_txt_member_success")
                        : translate("app_txt_member_failed"),
                    msgDesc: responseMessage,
                    color: _responseStatusCode ? greenColor : redColor,
                    backgroundColor: _responseStatusCode
                        ? greenOverlayColor
                        : redColorOverlay,
                  ),
                ),
                Visibility(
                  visible: widget.methodId == 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              mId = 1;
                              _isApiLoading = false;
                              _responseError = false;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              border: Border.all(
                                  width: 1,
                                  color: mId == 1 ? greenColor : whiteColor),
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
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 170,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          translate(
                                              "app_txt_member_current_phone"),
                                          style: GoogleFonts.poppins(
                                              color: blackColor,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ),
                                    mId == 1
                                        ? Container(
                                            height: 30,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: greenColor),
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
                                            groupValue: mId,
                                            activeColor: greenColor,
                                            onChanged: (val) {
                                              setState(() {
                                                mId = 1;
                                                _responseError = false;
                                              });
                                            },
                                          )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 12),
                                  child: Text(
                                    widget.userPhone,
                                    style: GoogleFonts.poppins(
                                        color: blackColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              mId = 2;
                              _isApiLoading = false;
                              _responseError = false;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              border: Border.all(
                                  width: 1,
                                  color: mId == 2 ? greenColor : whiteColor),
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
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        translate("app_txt_other"),
                                        style: GoogleFonts.poppins(
                                            color: blackColor,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14),
                                      ),
                                    ),
                                    mId == 2
                                        ? Container(
                                            height: 30,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: greenColor),
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
                                            groupValue: mId,
                                            activeColor: greenColor,
                                            onChanged: (val) {
                                              setState(() {
                                                mId = 2;
                                                _responseError = false;
                                              });
                                            },
                                          )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 12),
                                  child: Text(
                                    translate("app_txt_other_numbers"),
                                    style: GoogleFonts.poppins(
                                        color: blackColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isLoading = true;
                              _isApiLoading = true;
                            });
                            if (mId == 1) {
                              widget.methodId == 1;
                              _createNewDonation();
                            } else {
                              Navigator.push(
                                  context,
                                  MyPageRoute(
                                      widget: QuickConfirmPayment(
                                          methodId: 4,
                                          totalAmount: widget.totalAmount, date: widget.date, countryCurrency: widget.countryCurrency, userPhone: widget.userPhone, userId: widget.userId,
                                      )));
                            }
                          },
                          child: _isApiLoading
                              ? const SpinKitCircle(
                                  color: primaryColor,
                                  size: 44,
                                )
                              : LoadingButton(
                                  icon: Icons.check,
                                  backgroundColor: primaryColor,
                                  width: 250,
                                  title: translate("app_txt_confirm"),
                                  isLoading: _isLoading,
                                ),
                        )
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.methodId == 3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    id = 1;
                                  });
                                },
                                child: Container(
                                  height: 60,
                                  width: MediaQuery.of(context).size.width,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    border: Border.all(
                                        width: 1,
                                        color:
                                            id == 1 ? greenColor : whiteColor),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        offset: Offset(0.0, 5.0),
                                        color: Color(0xffEDEDED),
                                        blurRadius: 5.0,
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isLoading = true;
                                        _isApiLoading = true;
                                      });
                                        _createNewDonation();
                                    },
                                    child: _isApiLoading
                                        ? const SpinKitCircle(
                                      color: primaryColor,
                                      size: 44,
                                    )
                                        : LoadingButton(
                                      icon: Icons.check,
                                      backgroundColor: primaryColor,
                                      width: 250,
                                      title: translate("app_txt_confirm"),
                                      isLoading: _isLoading,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.methodId == 4,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    id = 1;
                                  });
                                },
                                child: Container(
                                  height: 60,
                                  width: MediaQuery.of(context).size.width,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    border: Border.all(
                                        width: 1,
                                        color:
                                            id == 1 ? greenColor : whiteColor),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        offset: Offset(0.0, 5.0),
                                        color: Color(0xffEDEDED),
                                        blurRadius: 5.0,
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
                                            "assets/images/logo/momo.png",
                                            height: 25,
                                            width: 25,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            translate("app_txt_momo_payment"),
                                            style: GoogleFonts.poppins(
                                                color: blackColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 15),
                                          )
                                        ],
                                      ),
                                      id == 1
                                          ? Container(
                                              height: 30,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: greenColor),
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
                                              activeColor: greenColor,
                                              onChanged: (val) {
                                                setState(() {
                                                  id = 1;
                                                  _responseError = false;
                                                  print("English selected");
                                                });
                                              },
                                            )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: false,//currently hidden
                              child: Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      id = 2;
                                    });
                                  },
                                  child: Container(
                                    height: 60,
                                    width: MediaQuery.of(context).size.width,
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 5),
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      border: Border.all(
                                          width: 1,
                                          color:
                                              id == 2 ? greenColor : whiteColor),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          offset: Offset(0.0, 5.0),
                                          color: Color(0xffEDEDED),
                                          blurRadius: 5.0,
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
                                              "assets/images/logo/airtel.png",
                                              height: 25,
                                              width: 25,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Airtel",
                                              style: GoogleFonts.poppins(
                                                  color: blackColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 17),
                                            )
                                          ],
                                        ),
                                        id == 2
                                            ? Container(
                                                height: 30,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: greenColor),
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
                                                activeColor: greenColor,
                                                onChanged: (val) {
                                                  setState(() {
                                                    id = 2;
                                                    _responseError = false;
                                                    print("Aitel selected");
                                                  });
                                                },
                                              )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 9),
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
                              errorText:
                                  isANumber ? null : "Please enter a number",
                              hintText: 'Phone number',
                              border: const OutlineInputBorder(),
                              suffixIcon:
                                  isANumber || phoneController.text.isEmpty
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
                        const SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: () {
                            if (id == 1) {
                              if (isANumber) {
                                _createNewDonation();
                              } else {
                                print('mtn invalid!');
                              }
                            } else {
                              showError("Please select payment option");
                            }
                          },
                          child: _isApiLoading
                              ? const SpinKitCircle(
                                  color: primaryColor,
                                  size: 44,
                                )
                              : LoadingButton(
                                  icon: Icons.check,
                                  backgroundColor: primaryColor,
                                  width: 250,
                                  title: translate("app_txt_confirm"),
                                  isLoading: _isLoading,
                                ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  void setValidator(valid) {
    setState(() {
      isANumber = valid;
    });
  }


  void showError(String message) {
    setState(() {
      _isApiLoading = false;
      _isLoading = false;
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

}
