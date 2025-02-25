import 'package:cfms/utils/colors.dart';
 import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class QuickHistoryItem extends StatefulWidget {
  final String count;
  final Color backgroundColor;
  final String amount;
  final int status;
  final String church;
  final DateTime date;
  final Function()? onTap;
  const QuickHistoryItem({
    Key? key,
    required this.count,
    required this.amount,
    required this.status,
    required this.church,
    required this.date,
    this.backgroundColor = whiteColor, this.onTap,
  }) : super(key: key);
  @override
  State<QuickHistoryItem> createState() => _QuickHistoryItemState();
}

class _QuickHistoryItemState extends State<QuickHistoryItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          new BoxShadow(
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
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryOverlayColor
                  ),
                  child: Center(
                    child: Text(
                      widget.count,
                      style: GoogleFonts.lato(
                          color: blackColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 17),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          child: Text(
                            widget.church,
                            style: GoogleFonts.lato(
                                color: blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                                child: Text(
                                  'RF',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      color: blackColor,
                                      fontSize: 13),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                child: Text(
                                  widget.amount,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: blackColor,
                                      fontSize: 20),
                                ),
                              ),
                            ],
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
                  widget.status == 1 ? translate('app_txt_approved') : widget.status == 2 ? translate('app_txt_cancelled') : translate('app_txt_pending'),
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

