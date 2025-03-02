import 'package:cfms/models/language_model.dart';
import 'package:cfms/widgets/buttons/state_button.dart';
import 'package:cfms/widgets/texts/heading.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/constants.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/lists/lang_item.dart';
import 'introduction.screen.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({Key? key}) : super(key: key);

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  int id = 1;
  bool isSelected = false;
  bool isLang = false;
  String selectedLang = "";
  late SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPrefs();
  }

  void getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Heading(
                  title: translate("app_txt_language"),
                  subtitle: translate("app_txt_choose_language")),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                child: Column(
                  children: List.generate(getLocales().length, (index) {
                    LanguageModel lang = getLocales()[index];
                    return LangItem(
                        selectedId: id,
                        id: lang.getId(),
                        icon: lang.icon,
                        title: lang.getTitle(),
                        onTap: () async {
                          prefs = await SharedPreferences.getInstance();
                          setState(() {
                            id = lang.id;
                            prefs.setString("currentLang", lang.getCode());
                            changeLocale(
                                context, lang.getCode()); // Change to French
                          });
                        });
                  }),
                ),
              ),
              GestureDetector(
                onTap: () {
                  prefs.setString("currentLang", selectedLang);
                  Navigator.push(
                      context, MyPageRoute(widget: const IntroductionScreen()));
                },
                child: StateButton(
                    icon: Icons.arrow_forward,
                    backgroundColor: primaryColor,
                    width: 200,
                    title: translate('app_txt_continue')),
              )
            ],
          )
        ],
      )),
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
  }
}
