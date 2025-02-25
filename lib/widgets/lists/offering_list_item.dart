import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ItemRecordList extends StatefulWidget {
  final String letter;
  final Color backgroundColor;
  final Color iconColor;
  final String title;
  final String amount;
  final int status;
  final String churchCode;
  final DateTime date;
  const ItemRecordList({
    Key? key,
    required this.letter,
    required this.title,
    required this.amount,
    required this.status,
    required this.churchCode,
    required this.date,
    this.iconColor = primaryColor,
    this.backgroundColor = whiteColor,
  }) : super(key: key);
  @override
  State<ItemRecordList> createState() => _ItemRecordListState();
}

class _ItemRecordListState extends State<ItemRecordList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Expanded(
                flex: 1,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryOverlayColor
                  ),
                  child: const Center(
                    child: Icon(Icons.church_rounded, color: primaryColor,),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          child: Text(
                            widget.title,
                            style: GoogleFonts.lato(
                                color: blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Text(
                              translate('app_txt_code')+widget.churchCode,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13),
                            ),
                          ),
                        )
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      child: Text(
                        widget.amount,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),

            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 7, bottom: 3),
                child: Text(
                  translate('app_txt_date') + DateFormat.yMMMEd().format(widget.date) ,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 7, bottom: 3),
                child: Text(
                  widget.status == 1 ? translate('app_txt_completed') : widget.status == 2 ? translate('app_txt_cancelled') : translate('app_txt_pending'),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      color: widget.status == 1 ? greenColor : widget.status == 2 ? redColor : orangeColor,
                      fontSize: 12),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }



}

