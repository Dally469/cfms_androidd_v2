import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:cfms/models/entity_model.dart';
import 'package:cfms/models/members/member.dart';
import 'package:cfms/screens/member/new_donation.dart';
import 'package:cfms/services/api/http_services.dart';
import 'package:cfms/widgets/lists/church_item.dart';
import 'package:cfms/widgets/texts/heading.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/buttons/state_button.dart';

class SelectChurch extends StatefulWidget {
  const SelectChurch({Key? key}) : super(key: key);

  @override
  State<SelectChurch> createState() => _SelectChurchState();
}

class _SelectChurchState extends State<SelectChurch> {
  int id = 1;
  String? currentChurch;
  String? currentChurchCode, mNames, mPhone;
  late String countryCode;
  var countryCurrency = '';
  var lowerName;
  late ChurchDetails church;
  late Data member;
  TextEditingController churchController = TextEditingController();
  TextEditingController churchIdController = TextEditingController();
  TextEditingController churchCodeController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  bool _isLanding = false;
  bool _isOtherSelected = false;
  EntityModel? _selectedSingleEntity;
  int selectedIndex = -1;

  List<EntityModel> searchedEntity = [];
  List<DropdownMenuItem<String>> currencies = [];

  late Future<List> fetchCurrency;

  _loadChurchData() async {
    final prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('current_church') ?? '';
    String json1 = prefs.getString('current_member') ?? '';
    String currency = prefs.getString('countryCurrency') ?? '';
    String code = prefs.getString('countryCode') ?? '';
    if (kDebugMode) {
      print(json);
    }
    Map<String, dynamic> map = jsonDecode(json);
    church = ChurchDetails.fromJson(map);
    setState(() {
      currentChurch = church.church;
      currentChurchCode = church.churchCode;
      // countryCurrency = currency;
      countryCode = code;
    });
    Map<String, dynamic> map1 = jsonDecode(json1);
    member = Data.fromJson(map1);
    setState(() {
      mNames = member.names;
      mPhone = member.phone;
    });

    if (kDebugMode) {
      print(
          'load church data: ${church.church} and code: ${church.churchCode}');
    }
  }

  List<EntityModel> entities = [];
  List<EntityModel> allEntities = [];

  @override
  void initState() {
    super.initState();
    _loadChurchData();
    fetchCurrency = HttpService().getCurrency();
    getChurch();
  }

  void getChurch() async {
    final prefs =  await SharedPreferences.getInstance();
    List<EntityModel> data = await HttpService().getEntitySuggestions("");
    int count = 0;
    for (EntityModel a in data) {
      if (count < 15){
        entities.add(EntityModel(
            id: a.id,
            name: a.name,
            code: a.code,
            parentId: a.parentId,
            entityType: a.entityType));
      }
      allEntities.add(EntityModel(
          id: a.id,
          name: a.name,
          code: a.code,
          parentId: a.parentId,
          entityType: a.entityType));
      count++;
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: Scaffold(
          backgroundColor: whiteColor,
          appBar: AppBar(
            backgroundColor: whiteColor,
            elevation: 0,
            toolbarHeight: 80,
            leading: InkWell(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: primaryColor,
                )),
            title: _isLanding
                ? Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.text,
                        controller: searchController,
                        onChanged: (inputValue) {
                          if (inputValue.length >= 4) {
                            setState(() {
                              searchedEntity = allEntities.where((offering) {
                                if (double.tryParse(inputValue) != null) {
                                  lowerName = offering.code?.toLowerCase();
                                  if (kDebugMode) {
                                    print("NUMBER $inputValue");
                                  }
                                } else {
                                  lowerName = offering.name?.toLowerCase();
                                  if (kDebugMode) {
                                    print("WORD $inputValue");
                                  }
                                }
                                final queryLower = inputValue.toLowerCase();
                                return lowerName!.contains(queryLower);
                              }).toList();
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: translate('app_txt_search'),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: greenColor,
                          ),
                        ),
                      )
                    ],
                  )
                : const Text(""),
          ),
          body: Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _isLanding
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                          searchController.value.text.isNotEmpty &&
                                  searchController.value.text.length >= 4
                              ? searchedEntity.length
                              : entities.length, (index) {
                        EntityModel offering =
                            searchController.value.text.isNotEmpty &&
                                    searchController.value.text.length >= 4
                                ? searchedEntity[index]
                                : entities[index];
                        return ChurchItem(
                          icon: Icons.church_rounded,
                          title: offering.name!,
                          code: offering.code ?? "",
                          onTap: () => setState(() {
                            _selectedSingleEntity = offering;
                            selectedIndex = index;
                            _isLanding = false;
                            _isOtherSelected = true;
                          }),
                        );
                      }),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Heading(
                            title: translate('app_txt_select_church'),
                            subtitle: translate('app_txt_choose_church_for_donate')),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 30),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  FutureBuilder<List>(
                                      future: fetchCurrency,
                                      builder: ((context, snapshot) {
                                    if (snapshot.hasData){
                                      var items = snapshot.data;
                                      countryCurrency = items![0]['code'];
                                      return DropdownButton(
                                        items: items?.map((item){
                                          return DropdownMenuItem<String>(
                                              value: item['code'],
                                              child: Text(
                                                  "${item['title']} #${item['code']}"));
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          countryCurrency = newValue!;
                                          if (kDebugMode) {
                                            print("selected currency${newValue!}");
                                          }
                                        },
                                        value: countryCurrency,
                                      );
                                    }
                                    return const Text("Loading...");
                                  })),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          id = 1;
                                          _isLanding = false;
                                        });
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 2, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: whiteColor,
                                          border: Border.all(
                                              width: 1,
                                              color: id == 1
                                                  ? greenColor
                                                  : whiteColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                id == 1
                                                    ? Container(
                                                        height: 18,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 15,
                                                            vertical: 15),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    greenColor),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.check,
                                                            size: 15,
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
                                                          });
                                                        },
                                                      ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.church_rounded,
                                                      color: primaryColor,
                                                      size: 25,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                      width: 90,
                                                      child: Text(
                                                        "${translate('app_txt_home')} ($currentChurch)",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color:
                                                                    blackColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 10),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                )
                                              ],
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
                                          id = 2;
                                          _isLanding = true;
                                        });
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: whiteColor,
                                          border: Border.all(
                                              width: 1,
                                              color: id == 2
                                                  ? greenColor
                                                  : whiteColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                id == 2
                                                    ? Container(
                                                        height: 18,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 15,
                                                            vertical: 15),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    greenColor),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.check,
                                                            size: 15,
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
                                                            _isLanding = true;
                                                          });
                                                        },
                                                      ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.church_rounded,
                                                      color: primaryColor,
                                                      size: 25,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                      width: 90,
                                                      child: Text(
                                                        id == 2
                                                            ? _isOtherSelected
                                                                ? "${translate('app_txt_visit_church')} (${_selectedSingleEntity!.name})"
                                                                : translate(
                                                                    'app_txt_visit_church'
                                                                  )
                                                            : translate(
                                                                'app_txt_visit_church'
                                                                ),
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color:
                                                                    blackColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 10),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          id = 3;
                                          _isLanding = true;
                                        });
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: whiteColor,
                                          border: Border.all(
                                              width: 1,
                                              color: id == 3
                                                  ? greenColor
                                                  : whiteColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                id == 3
                                                    ? Container(
                                                        height: 18,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 15,
                                                            vertical: 15),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    greenColor),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.check,
                                                            size: 15,
                                                            color: whiteColor,
                                                          ),
                                                        ),
                                                      )
                                                    : Radio(
                                                        value: 3,
                                                        groupValue: id,
                                                        activeColor: greenColor,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            id = 3;
                                                            _isLanding = true;
                                                          });
                                                        },
                                                      ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.church_rounded,
                                                      color: primaryColor,
                                                      size: 25,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                      width: 90,
                                                      child: Text(
                                                        id == 3
                                                            ? _isOtherSelected
                                                                ? "${translate('app_txt_anonymous')} (${_selectedSingleEntity!.name})"
                                                                : translate(
                                                                    'app_txt_anonymous')
                                                            : translate(
                                                                'app_txt_anonymous'),
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color:
                                                                    blackColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 10),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                )
                                              ],
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
                                          id = 4;
                                          _isLanding = true;
                                        });
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: whiteColor,
                                          border: Border.all(
                                              width: 1,
                                              color: id == 4
                                                  ? greenColor
                                                  : whiteColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                id == 4
                                                    ? Container(
                                                        height: 18,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 15,
                                                            vertical: 15),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    greenColor),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.check,
                                                            size: 15,
                                                            color: whiteColor,
                                                          ),
                                                        ),
                                                      )
                                                    : Radio(
                                                        value: 4,
                                                        groupValue: id,
                                                        activeColor: greenColor,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            id = 4;
                                                            _isLanding = true;
                                                            print(
                                                                "Other selected");
                                                          });
                                                        },
                                                      ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.church_rounded,
                                                      color: primaryColor,
                                                      size: 25,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                        width: 90,
                                                        child: Text(
                                                          id == 4
                                                              ? _isOtherSelected
                                                                  ? "${translate('app_txt_other')} (${_selectedSingleEntity!.name})"
                                                                  : translate(
                                                                      'app_txt_other')
                                                              : translate(
                                                                  'app_txt_other'),
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color:
                                                                      blackColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 10),
                                                        ))
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if(countryCurrency == ""){
                              showError(
                                  translate("app_txt_currency_is_required"));
                              return;
                            }
                            if (id == 1) {
                              Navigator.push(
                                  context,
                                  MyPageRoute(
                                      widget: NewDonation(
                                    churchId: currentChurchCode.toString(),
                                    churchCode: currentChurchCode.toString(),
                                    churchName: currentChurch.toString(),
                                    countryCurrency: countryCurrency,
                                    countryCode: countryCode,
                                    mName: mNames.toString(),
                                    mPhone: mPhone.toString(),
                                  )));
                            } else {
                              if (_selectedSingleEntity!.code == '' ||
                                  _selectedSingleEntity!.name == '') {
                                if (kDebugMode) {
                                  print(translate("app_txt_plz_select_church"));
                                }
                                showError(translate("app_txt_plz_select_church"));
                              } else {
                                Navigator.push(
                                    context,
                                    MyPageRoute(
                                        widget: NewDonation(
                                            churchId: _selectedSingleEntity!.id
                                                .toString(),
                                            churchCode: _selectedSingleEntity!
                                                .code
                                                .toString(),
                                            churchName: _selectedSingleEntity!
                                                .name
                                                .toString(),
                                            countryCurrency: countryCurrency,
                                            countryCode: countryCode,
                                            mName: mNames.toString(),
                                            mPhone: mPhone.toString())));
                              }
                            }
                          },
                          child: StateButton(
                              icon: Icons.arrow_forward,
                              backgroundColor: primaryColor,
                              width: 200,
                              title: translate('app_txt_continue')),
                        ),
                        const SizedBox(
                          height: 20,
                        )
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
      ),
    );
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
  void showError(String message){
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
