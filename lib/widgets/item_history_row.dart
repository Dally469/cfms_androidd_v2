import 'dart:convert';

import 'package:cfms/models/item_history_model.dart';
import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SingleHistoryRow extends StatefulWidget {
  final String id, selectedId;
  final String details;
  final String count;
  final String amount;
  final String currency;
  final String newTrxId;
  final String church;
  final DateTime date;
  final int status;
  final Function() onTap;
  final Function() onPrintTap;

  const SingleHistoryRow(
      {Key? key,
      required this.count,
      required this.amount,
      required this.currency,
      required this.newTrxId,
      required this.church,
      required this.date,
      required this.status,
      required this.onTap,
      required this.id,
      required this.selectedId,
      required this.details,
      required this.onPrintTap,  })
      : super(key: key);

  @override
  State<SingleHistoryRow> createState() => _SingleHistoryRowState();
}

class _SingleHistoryRowState extends State<SingleHistoryRow> {
  List<ItemHistory> tagObjs = [];
  var list;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    try {
      var tagObjsJson = jsonDecode(widget.details) as List;
      tagObjs =
          tagObjsJson.map((tagJson) => ItemHistory.fromJson(tagJson)).toList();
      print("HHH $tagObjs");
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0.0, 2.0),
              color: Color(0xffEDEDED),
              blurRadius: 3.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: primaryOverlayColor),
                        child: Center(
                          child: Text(
                            widget.count,
                            style: GoogleFonts.poppins(
                                color: blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 19),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.church,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400, fontSize: 13),
                              ),
                              SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    Text(
                                      widget.amount,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: blackColor,
                                          fontSize: 16),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        widget.currency,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                            color: blackColor,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Column(children: [
                            TextButton(
                                onPressed: widget.onPrintTap,
                                child: Text(
                                  translate("app_txt_print"),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: greenColor,
                                      fontSize: 13),
                                )),
                          ])
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 5, top: 7, bottom: 3),
                      child: Text(
                        translate('app_txt_date') +
                            DateFormat.yMMMEd().format(widget.date),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300, fontSize: 12),
                      ),
                    ),

                  ],
                ),
              ],
            ),
            Visibility(
                visible: widget.id == widget.selectedId,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              translate("app_txt_offerings"),
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(
                            width: 100,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              translate("app_txt_amount"),
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                        child: Column(
                            children: List.generate(tagObjs.length, (index) {
                          ItemHistory item = tagObjs[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${item.title}"),
                              const SizedBox(
                                width: 100,
                              ),
                              Text("${item.amount}"),
                            ],
                          );
                        })),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
