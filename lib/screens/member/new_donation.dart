import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/models/donation_record_model.dart';
import 'package:cfms/models/donations/donation.dart';
import 'package:cfms/models/offering_model.dart';
import 'package:cfms/screens/member/select_payment.dart';
import 'package:cfms/services/api/http_services.dart';
import 'package:cfms/services/provider/donation_provider.dart';
import 'package:cfms/widgets/lists/donation_item.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/colors.dart';
import '../../widgets/buttons/loading_button.dart';
import 'dashboard.screen.dart';

class NewDonation extends StatefulWidget {
  final String churchId;
  final String churchCode;
  final String churchName;
  final String countryCurrency;
  final String countryCode;
  final String mName;
  final String mPhone;

  const NewDonation({
    Key? key,
    required this.churchId,
    required this.churchCode,
    required this.churchName,
    required this.countryCode,
    required this.countryCurrency, required this.mName, required this.mPhone,
  }) : super(key: key);

  @override
  State<NewDonation> createState() => _NewDonationState();
}

class _NewDonationState extends State<NewDonation> {
  final formGlobalKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController narrationController = TextEditingController();
  TextEditingController donationNameController = TextEditingController();
  TextEditingController donationIdController = TextEditingController();
  List<DonationRecordModel> offerings = [];
  int bottomSheetHeight = 0;

  RegExp digitValidator = RegExp(r'^[0-9]*\.?[0-9]+$');
  bool isANumber = true;
  bool isClicked = false;
  final bool _isLoading = false;
  bool viewAll = true;
  String donationList = '';
  HttpService httpService = HttpService();

  List<DonationModel> _selectedOffering = [];
  DonationRecordModel? _selectedSingleOffering;
  int selectedIndex = -1;

  double totalAmount = 0.00;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getOfferings();
  }

  void getOfferings() async {
    prefs = await SharedPreferences.getInstance();
    List<OfferingModel> data = await HttpService().getOfferingSuggestions("");
    String lang = prefs.getString("currentLang")!.toLowerCase();
    for (OfferingModel a in data) {
      final names = jsonDecode(a.translation!);
      String name = names[lang]??a.name;
      offerings
          .add(DonationRecordModel(donationName: (name == ""?a.name: name), donationId: a.id, requireNarration: a.requireNarration));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: ChangeNotifierProvider(
            create: (_) => DonationProvider(),
            child: Builder(builder: (BuildContext context) {
              final donation = Provider.of<DonationProvider>(context);
              return Scaffold(
                key: scaffoldKey,
                backgroundColor: whiteColor,
                appBar: AppBar(
                  backgroundColor: primaryColor,
                  elevation: 0,
                  toolbarHeight: 80,
                  leading: InkWell(
                      onTap: () {
                        Navigator.push(
                            context, MyPageRoute(widget: const Dashboard()));
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: whiteColor,
                      )),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(translate("app_txt_new_donation"),
                          style: GoogleFonts.poppins(
                              color: whiteColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 17)),
                      Container(
                        decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius:
                            BorderRadius.circular(5)),
                        padding: EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.church_rounded,
                              size: 20,
                              color: primaryColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text("${widget.churchName} (${widget.churchCode})",
                                style: GoogleFonts.poppins(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text("")),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: List.generate(offerings.length, (index) {
                          DonationRecordModel offering = offerings[index];
                          return DonationItem(
                            icon: Icons.church_rounded,
                            currency: widget.countryCurrency,
                            title: offering.donationName!,
                            amount: "${offering.amount ?? ""}",
                            narration: offering.narration??"",
                            onTap: () => setState(() {
                              _selectedSingleOffering = offering;
                              selectedIndex = index;
                              if (offering.amount != null) {
                                amountController.value = TextEditingValue(
                                    text: "${offering.amount ?? ""}");
                                _selectedSingleOffering!.isEditable = false;
                              } else {
                                _selectedSingleOffering!.isEditable = true;
                                amountController.value = TextEditingValue.empty;
                              }
                            }),
                          );
                        }),
                      ),
                      SizedBox(
                        height:
                            (_selectedSingleOffering != null ? 280 : 140) + 20,
                      ),
                    ],
                  )),
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
              );
            })),
      ),
    );
  }

  Widget getAmountSelector() {
    return Container(
      height: _selectedSingleOffering!.requireNarration! == 1? 350: 280,
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
                          digitValidator.hasMatch(inputValue)) {
                        setValidator(true);
                      } else {
                        setValidator(false);
                      }
                    },
                    decoration: InputDecoration(
                      errorText: isANumber
                          ? null
                          : translate('app_txt_plz_enter_valid_amount'),
                      hintText: translate('app_txt_enter_amount'),
                      suffix: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(widget.countryCurrency, style: const TextStyle(fontSize: 20, )),
                      ),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
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
                } else if (narrationController.text.length < 3 && _selectedSingleOffering!.requireNarration! == 1) {
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
                size: 40,
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
                "$totalAmount",
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
                width: 200,
                title: translate('app_txt_continue'),
                isLoading: _isLoading,
                onTap: () => setState(() {
                  var donationMap = [];
                 for(DonationRecordModel item in offerings){
                   if (item.amount != null) {
                     donationMap.add({
                       "offering": item.donationId,
                       "fee_description": item.narration,
                       "fee_name": item.donationName,
                       "amount": item.amount,
                     });
                   }
                 }
                  donationList = json.encode(donationMap);
                  print(donationList);

                  Navigator.push(
                      context,
                      MyPageRoute(
                          widget: Payment(
                        totalAmount: totalAmount,
                        donationList: donationList,
                        churchCode: widget.churchCode,
                        churchName: widget.churchName,
                        countryCurrency: widget.countryCurrency, memberName: widget.mName, memberPhone: widget.mPhone, countryCode: widget.countryCode,
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
                  showSuccess(translate("app_txt_removed") +  name);
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

  String removeJsonAndArray(String text) {
    if (text.startsWith('[') || text.startsWith('{')) {
      text = text.substring(1, text.length - 1);
      if (text.startsWith('[') || text.startsWith('{')) {
        text = removeJsonAndArray(text);
      }
    }
    return text;
  }

  void showSuccess(String message) {
    Flushbar(
      title: donationNameController.text,
      message: message,
      icon: const Icon(
        Icons.check_circle_outline,
        size: 28.0,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(30),
      borderRadius: BorderRadius.circular(10),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: Colors.green,
    ).show(context);
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

  DropdownMenuItem<Object> buildMenuItem(Object item) => DropdownMenuItem(
      value: item,
      child: Text(
        item.toString(),
        style: GoogleFonts.poppins(fontSize: 17),
      ));
}
