// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cfms/models/cache_model.dart';
import 'package:cfms/models/donations/donation.dart';
import 'package:cfms/models/entity_model.dart';
import 'package:cfms/models/group_model.dart';

import 'package:cfms/models/members/member.dart';
import 'package:cfms/models/offering_model.dart';
import 'package:cfms/models/payment_history_model.dart';
import 'package:cfms/models/summary_offering_model.dart';
import 'package:cfms/services/db/db_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/country_model.dart';
import '../../models/pending_model.dart';
import '../../models/quick_history_model.dart';
import '../../models/summary_offerings_model.dart';

class HttpService {
  final String _landingUrl = "https://sdacfms.com/get_countries";

  // final String _fullUrl = "https://rw.sdacfms.com/api/api/";
  final String _urlTEST = 'http://192.168.10.104/cfms-api/public/api/';
  final String _http = 'https://';
  final String _url = '.sdacfms.com/api/api/';
  final String _urlNew = '.sdacfms.com/api/';
  String? query;

  final String _getEntity = "v2/getEntity";
  final String _cashReceiptInvoice = "v2/invoice/cash-receipt";
  final String _offeringReceiptInvoice = "v2/invoice/offering-receipt";
  final String _getCurrency = "v2/get-currency";
  final String _getOfferings = "v2/offerings";
  final String _getGroups = "v2/getGroups/3";

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };


  Future<List<EntityModel>> getEntitySuggestions(String query) async {
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';
    if (countryCode == "") {
      throw Exception("Unable to fetch country");
    }
    // var fullUrl = _http + countryCode + _url + _getEntity;
    var fullUrl =
        "$_http$countryCode$_url$_getEntity?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}";
    if (kDebugMode) {
      print(fullUrl);
    }

    DbHelper dbHelper = DbHelper();
    List<CacheModel>? cached = await dbHelper.getCachedData(fullUrl);
    String body = "";
    if (cached != null) {
      CacheModel cache = cached[0];
      if (kDebugMode) {
        print("Cached version found,${cache.data}");
      }
      body = cache.data ?? "";
    } else {
      final res = await http.get(Uri.parse(fullUrl));
      if (res.statusCode == 200) {
        CacheModel cacheData = CacheModel(
            data: res.body,
            url: fullUrl,
            cachedAt: DateTime.now().microsecondsSinceEpoch);
        dbHelper.saveCache(cacheData);
        body = res.body;
        if (kDebugMode) {
          print("Cache saved,$body");
        }
      } else {
        throw Exception();
      }
    }
    final List offerings = json.decode(body);
    return offerings
        .map((model) => EntityModel.fromJson(model))
        .where((offering) {
      final lowerName = offering.name?.toLowerCase();
      final queryLower = query.toLowerCase();
      return lowerName!.contains(queryLower);
    }).toList();
  }

  Future<List> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';
    if (countryCode == "") {
      throw Exception("Unable to fetch country");
    }
    // var fullUrl = _http + countryCode + _url + _getEntity;
    var fullUrl =
        "$_http$countryCode$_url$_getCurrency?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}";
    if (kDebugMode) {
      print(fullUrl);
    }

    DbHelper dbHelper = DbHelper();
    List<CacheModel>? cached = await dbHelper.getCachedData(fullUrl);
    String body = "";
    if (cached != null) {
      CacheModel cache = cached[0];
      if (kDebugMode) {
        print("Cached version found,${cache.data}");
      }
      body = cache.data ?? "";
    } else {
      final res = await http.get(Uri.parse(fullUrl));
      if (res.statusCode == 200) {
        CacheModel cacheData = CacheModel(
            data: res.body,
            url: fullUrl,
            cachedAt: DateTime.now().microsecondsSinceEpoch);
        dbHelper.saveCache(cacheData);
        body = res.body;
        if (kDebugMode) {
          print("Cache saved,$body");
        }
      } else {
        throw Exception();
      }
    }
    final List currencies = json.decode(body);
    if (kDebugMode) {
      print(currencies);
    }
    return currencies;
  }

  Future<List<OfferingModel>> getOfferingSuggestions(String query) async {
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';
    if (countryCode == "") {
      throw Exception("Unable to fetch country");
    }
    var fullUrl =
        "$_http$countryCode$_url$_getOfferings?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}";
    if (kDebugMode) {
      print(fullUrl);
    }
    DbHelper dbHelper = DbHelper();
    List<CacheModel>? cached = await dbHelper.getCachedData(fullUrl);
    String body = "";
    if (cached != null) {
      CacheModel cache = cached[0];
      if (kDebugMode) {
        print("Cached version found,${cache.data}");
      }
      body = cache.data ?? "";
    } else {
      final res = await http.get(Uri.parse(fullUrl));
      if (res.statusCode == 200) {
        CacheModel cacheData = CacheModel(
            data: res.body,
            url: fullUrl,
            cachedAt: DateTime.now().microsecondsSinceEpoch);
        dbHelper.saveCache(cacheData);
        body = res.body;
        if (kDebugMode) {
          print("Cache saved,$body");
        }
      } else {
        throw Exception();
      }
    }
    final List offerings = json.decode(body);
    return offerings
        .map((model) => OfferingModel.fromJson(model))
        .where((offering) {
      final lowerName = offering.name?.toLowerCase();
      final queryLower = query.toLowerCase();
      return lowerName!.contains(queryLower);
    }).toList();
  }

  Future<List<GroupModel>> getGroupSuggestions(String query) async {
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';

    var fullUrl = _http + countryCode + _url + _getGroups;
    final res = await http.get(Uri.parse(fullUrl));
    if (res.statusCode == 200) {
      final List groups = json.decode(res.body);
      return groups.map((model) => GroupModel.fromJson(model)).where((group) {
        final lowerName = group.groupName?.toLowerCase();
        final queryLower = query.toLowerCase();
        return lowerName!.contains(queryLower);
      }).toList();
    } else {
      throw Exception();
    }
  }

  Future<List<PaymentHistoryModel>> getPaymentHistory(String apiRoute) async {
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';
    var fullUrl =
        "$_http$countryCode$_url$apiRoute?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}";
    // var fullUrlTEST = _urlTEST + apiRoute;

    final res = await http.get(Uri.parse(fullUrl));

    if (kDebugMode) {
      print("ENDPOINT $fullUrl");
    }
    if (res.statusCode == 200) {
      final List offerings = json.decode(res.body);
      // print("RESULT ${offerings}");
      return offerings
          .map((model) => PaymentHistoryModel.fromJson(model))
          .toList();
    } else {
      var data = jsonDecode(res.body);
      throw Exception(data["message"]);
    }
  }

  Future<List<QuickHistoryModel>> getQuickPaymentHistory(
      String apiRoute) async {
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';
    var fullUrl =
        "$_http$countryCode$_url$apiRoute?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}";
    // var fullUrl = _url + apiRoute;
    if (kDebugMode) {
      print(fullUrl);
    }
    final res = await http.get(Uri.parse(fullUrl));
    if (res.statusCode == 200) {
      if (kDebugMode) {
        print(res.body);
      }
      final List offerings = json.decode(res.body);
      return offerings
          .map((model) => QuickHistoryModel.fromJson(model))
          .toList();
    } else {
      throw Exception();
    }
  }

   Future<List<PendingOfferingsModel>> getPendingPaymentHistory(
     String apiRoute, Object data) async {
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';
    var fullUrl =
        "$_http$countryCode$_url$apiRoute?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}";
    // var fullUrl = _url + apiRoute;
    if (kDebugMode) {
      print(data);
    }
    final res = await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
    if (res.statusCode == 200) {
      if (kDebugMode) {
        print("MYDATA ${res.body}");
      }
      final List offerings = json.decode(res.body);
      return offerings
          .map((model) => PendingOfferingsModel.fromJson(model))
          .toList();
    } else {
      throw Exception();
    }
  }


  Future<List<SummaryOfferingsModel>> getSummaryPaymentHistory(
      String apiRoute, Object data) async {
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';
    var fullUrl =
        "$_http$countryCode$_url$apiRoute?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}";
    // var fullUrl = _url + apiRoute;
    if (kDebugMode) {
      print(data);
    }
    final res = await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
    if (res.statusCode == 200) {
      if (kDebugMode) {
        print(res.body);
      }
      final List offerings = json.decode(res.body);
      return offerings
          .map((model) => SummaryOfferingsModel.fromJson(model))
          .toList();
    } else {
      throw Exception();
    }
  }

  Future<String?> downloadReceipt(String refNo, int type) async {
    // final prefs = await SharedPreferences.getInstance();
    // String countryCode = prefs.getString('countryCode') ?? '';
    // String receiptUrl =
    //     type == 1 ? _cashReceiptInvoice : _offeringReceiptInvoice;
    // var fullUrl =
    //     "$_http$countryCode$_url$receiptUrl/$refNo?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}";
    // if (kDebugMode) {
    //   print(fullUrl);
    // }
    // var status = await Permission.storage.status;
    // if (status.isDenied) {
    //   //request permission
    //   status = await Permission.storage.request();
    //   if (!status.isGranted) {
    //     return "app_txt_storage_permission_issue".tr();
    //   }
    // }
    // String? localPath = await getDownloadPath();
    // final savedDir = Directory(localPath!);
    // bool hasExisted = await savedDir.exists();
    // if (!hasExisted) {
    //   savedDir.create();
    // }
    // String filename =
    //     "cfms_invoice_${DateTime.now().millisecondsSinceEpoch}.pdf";
    // final taskId = await FlutterDownloader.enqueue(
    //   url: fullUrl,
    //   headers: {}, // optional: header send with url (auth token etc)
    //   savedDir: localPath,
    //   saveInPublicStorage: true,
    //   fileName: filename,
    //   showNotification:
    //       true, // show download progress in status bar (for Android)
    //   openFileFromNotification:
    //       true, // click on notification to open downloaded file (for Android)
    // );
    // // prefs.setString("download$taskId", "$localPath/$filename");
    return null;
  }

  Future<List<SummaryModel>> getSummaryHistory(String apiRoute) async {
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';
    var fullUrl =
        "$_http$countryCode$_url$apiRoute?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}";
    if (kDebugMode) {
      print(fullUrl);
    }
    final res = await http.get(Uri.parse(fullUrl));
    if (res.statusCode == 200) {
      final List offerings = json.decode(res.body);

      if (kDebugMode) {
        print(offerings);
      }
      return offerings.map((model) => SummaryModel.fromJson(model)).toList();
    } else {
      throw Exception();
    }
  }

  Future<List<DonationModel>> getPaymentOfferingHistory(String apiRoute) async {
    final prefs = await SharedPreferences.getInstance();
    String countryCode = prefs.getString('countryCode') ?? '';

    if (kDebugMode) {
      print(countryCode);
    }
    var fullUrl =
        "$_http$countryCode$_url$apiRoute?lang=${prefs.getString("currentLang")!}&v=${prefs.getString("version")!}";
    final res = await http.get(Uri.parse(fullUrl));

    if (res.statusCode == 200) {
      final List paymentOffering = json.decode(res.body);
      if (kDebugMode) {
        print('PRINTED $paymentOffering');
      }
      return paymentOffering
          .map((model) => DonationModel.fromJson(model))
          .toList();
    } else {
      throw Exception();
    }
  }

  postAppData(data, countryCode, apiUrl) async {
    var fullUrl = _http + countryCode + _url + apiUrl + await _getToken();
    // var fullUrl = _urlTEST + apiUrl + await _getToken() ;
    if (kDebugMode) {
      print(fullUrl);
    }
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  postAppDataNew(data, countryCode, apiUrl) async {
    var fullUrl = _http + countryCode + _urlNew + apiUrl + await _getToken();
    // var fullUrl = _urlTEST + apiUrl + await _getToken() ;
    if (kDebugMode) {
      print(fullUrl);
    }
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  postAppDataLocal(data, countryCode, apiUrl, params) async {
    var fullUrl =
        _http + countryCode + _url + apiUrl + await _getToken() + params;
    // var fullUrl = _urlTEST + apiUrl + await _getToken() + params;
    if (kDebugMode) {
      print(fullUrl);
      print(data);
    }
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  Future<Data> createMember(data, apiUrl) async {
    final response = await http.post(
      Uri.parse(_url + apiUrl + await _getToken()),
      headers: _setHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return Data.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get member.');
    }
  }

  getPublicData(countryCode, apiUrl) async {
    var fullUrl = _http + countryCode + _url + apiUrl;
    // var fullUrl = _url + apiUrl;
    http.Response response = await http.get(Uri.parse(fullUrl));
    if (kDebugMode) {
      print(fullUrl);
    }
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return 'failed';
    }
  }

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return '?token=$token';
  }
}
