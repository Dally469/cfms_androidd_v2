import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

///*SunmiPrinter*
///
///This class is a core of our printer system.
///With this class you can print everything you like. If you want to print a text, qrcode, barcode, bold text, bigger text or the smallest text possible.
///Your imagination is the limit!
class Nb55Printer {
  ///*sunmi_printer_plus
  ///
  //A callable method to start the comunitation with the native code!
  static const MethodChannel _channel = MethodChannel('com.example.cfms/nb55_printer');

  ///*bindingPrinter*
  ///
  ///This method will intializate the printer to start the whole print.
  ///This method *Must* be executed before any other print and LCD command.
  static Future<bool?> bindingPrinter() async {
    final bool? status = await _channel.invokeMethod('BIND_PRINTER_SERVICE');
    return status;
  }

  ///*unbindingPrinter*
  ///
  ///This method is the opposite of [bindingPrinter].
  ///This will unbind or 'close' the connection with the printer, and must be the last execution.

  static Future<bool?> unbindingPrinter() async {
    final bool? status = await _channel.invokeMethod('UNBIND_PRINTER_SERVICE');
    return status;
  }

  ///*printText*
  ///
  ///This method will print a simple text in your printer
  /// With the [SunmiStyle] you can put in one line, the size, alignment and bold
  static Future<void> printText(String text) async {
    // if (style != null) {
    //   if (style.align != null) {
    //     await setAlignment(style.align!);
    //   }
    //
    //   if (style.fontSize != null) {
    //     await setFontSize(style.fontSize!);
    //   }
    //
    //   if (style.bold != null) {
    //     if (style.bold == true) {
    //       await bold();
    //     }
    //   }
    // }
    Map<String, dynamic> arguments = <String, dynamic>{"text": '$text\n'};
    await _channel.invokeMethod("PRINT_TEXT", arguments);
    // await initPrinter();
  }

  ///*cut*
  ///
  ///This method will  cut the paper
  static Future<void> cut() async {
    await _channel.invokeMethod("CUT_PAPER");
  }
  ///*line*
  ///
  ///With this method you can draw a line to divide sections.
  static Future<void> line() async {
    await _channel.invokeMethod("PAPER_OUT");
  }
}
