// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:ui';

import 'package:cfms/models/language_model.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

const String ENGLISH = 'en';
const String KINYARWANDA = 'rw';
const String SWAHILI = 'sw';
const String LANGUAGE_CODE = 'languageCode';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LANGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

List<LanguageModel> getLocales() {
  List<LanguageModel> languages = [];
  languages.add(LanguageModel(
      locale: const Locale("en", "US"),
      id: 1,
      title: translate("app_txt_english"),
      icon: "eng.png", code: 'en'));
  languages.add(LanguageModel(
      locale: const Locale("fr", "FR"),
      id: 2,
      title: translate("app_txt_french"),
      icon: "fr.png", code: 'fr'));
  languages.add(LanguageModel(
      locale: const Locale("sw", "KE"),
      id: 3,
      title: translate("app_txt_swahili"),
      icon: "swa.png", code: 'sw'));
  languages.add(LanguageModel(
      locale: const Locale("rw", "RW"),
      id: 4,
      title: translate("app_txt_rwanda"),
      icon: "rw_flag.png", code: 'rw'));
  return languages;
}

Locale _locale(String languageCode) {
  Locale _temp;
  switch (languageCode) {
    case ENGLISH:
      _temp = Locale(languageCode, 'US');
      break;
    case KINYARWANDA:
      _temp = Locale(languageCode, 'RW');
      break;
    default:
      _temp = Locale(languageCode, 'US');
  }
  return _temp;
}

Future<Locale> getLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString(LANGUAGE_CODE) ?? ENGLISH;
  return _locale(languageCode);
}

Future<String?> getDownloadPath() async {
  Directory? directory;
  try {
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = Directory('/storage/emulated/0/Download');
      // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
      // ignore: avoid_slow_async_io
      if (!await directory.exists())
        directory = await getExternalStorageDirectory();
    }
  } catch (err, stack) {
    if (kDebugMode) {
      print("Cannot get download folder path");
    }
  }
  return directory?.path;
}
