class SummaryOfferingsModel {
  String? title;
  String? translation;
  List<Currencies>? currencies;

  SummaryOfferingsModel({this.title, this.translation, this.currencies});

  SummaryOfferingsModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    translation = json['translation'];
    if (json['currencies'] != null) {
      currencies = <Currencies>[];
      json['currencies'].forEach((v) {
        currencies!.add(Currencies.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['translation'] = translation;
    if (currencies != null) {
      data['currencies'] = currencies!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Currencies {
  String? currency;
  String? amount;

  Currencies({this.currency, this.amount});

  Currencies.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currency'] = currency;
    data['amount'] = amount;
    return data;
  }
}

// import 'dart:convert';

// class SummaryOfferingsModel {
//   final String title;
//   final Map<String, String> translation;
//   final List<Currency> currencies;

//   SummaryOfferingsModel({
//     required this.title,
//     required this.translation,
//     required this.currencies,
//   });

//   factory SummaryOfferingsModel.fromJson(Map<String, dynamic> json) {
//     var currenciesList = json['currencies'] as List;
//     List<Currency> currencies =
//         currenciesList.map((i) => Currency.fromJson(i)).toList();

//     return SummaryOfferingsModel(
//       title: json['title'],
//       translation: Map<String, String>.from(jsonDecode(json['translation'])),
//       currencies: currencies,
//     );
//   }

  
// }

// class Currency {
//   final String currency;
//   final String amount;

//   Currency({required this.currency, required this.amount});

//   factory Currency.fromJson(Map<String, dynamic> json) {
//     return Currency(
//       currency: json['currency'],
//       amount: json['amount'],
//     );
//   }
// }
