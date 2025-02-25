import 'dart:ui';

class LanguageModel{
  final int id;
  final String title,icon,code;
  final Locale? locale;
  LanguageModel({required this.id,required this.title,required this.icon, required this.code, this.locale});
  String getTitle(){
    return title;
  }
  int getId(){
    return id;
  }
  String getCode(){
    return code;
  }
}